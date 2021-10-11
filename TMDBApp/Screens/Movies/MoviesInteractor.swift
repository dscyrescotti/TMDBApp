//
//  MoviesInteractor.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

protocol MoviesBusinessLogic: AnyObject {
    var dbResponseRelay: PublishRelay<MoviesModel.DBResponse> { get }
    var loadingRelay: PublishRelay<Bool> { get }
    var apiResponseRelay: PublishRelay<MoviesModel.APIResponse> { get }
    var toggleFavoriteRelay: PublishRelay<Int> { get }
    
    func fetchMovies()
    func fetchCachedMovies()
}
protocol MoviesDataSource: AnyObject {
    var movies: [Movie] { get set }
}

class MoviesInteractor: MoviesBusinessLogic, MoviesDataSource {
    private let bag = DisposeBag()
    
    var presenter: MoviesPresentationLogic?
    var worker: MoviesWorker
    
    lazy var dbResponseRelay: PublishRelay<MoviesModel.DBResponse> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
    lazy var apiResponseRelay: PublishRelay<MoviesModel.APIResponse> = .init()
    lazy var toggleFavoriteRelay: PublishRelay<Int> = .init()
    var movies: [Movie] = .init()
    
    var movieType: MovieType
    
    init(movieType: MovieType) {
        self.movieType = movieType
        self.worker = MoviesWorker(movieType: movieType, apiService: APIService(), dbService: DBService())
    }
    
    func fetchMovies() {
        loadingRelay.accept(true)
        worker.fetchMovies()
            .subscribe(onNext: { [weak self] response in
                self?.apiResponseRelay.accept(response)
            }, onError: { [weak self] error in
                if self?.movies.isEmpty ?? true {
                    switch error {
                    case let errorType as ErrorType:
                        self?.presenter?.errorRelay.accept(errorType)
                    case is AFError:
                        self?.presenter?.errorRelay.accept(.networkFailed)
                    case is DecodingError:
                        self?.presenter?.errorRelay.accept(.decodingFailed)
                    default:
                        self?.presenter?.errorRelay.accept(.unknown)
                    }
                }
            })
            .disposed(by: bag)
    }
    
    func fetchCachedMovies() {
        worker.fetchCachedMovies()
            .bind(to: dbResponseRelay)
            .disposed(by: bag)
    }
}

extension MoviesInteractor {
    func bind() {
        apiResponseRelay
            .subscribe(onNext: { [weak self] response in
                let movies: [Movie] = response.results.map { result in
                    if var movie = self?.worker.fetchMovie(id: result.id) {
                        movie.isPopular = !movie.isPopular ? self?.movieType == .popular : movie.isPopular
                        movie.isUpcoming = !movie.isUpcoming ? self?.movieType == .upcoming : movie.isUpcoming
                        return movie
                    }
                    return Movie(id: result.id, title: result.title, poster: result.poster, isFavorite: false, isPopular: self?.movieType == .popular, isUpcoming: self?.movieType == .upcoming)
                }
                self?.worker.saveMovies(movies: movies)
                self?.dbResponseRelay.accept(MoviesModel.DBResponse(movies: movies))
            })
            .disposed(by: bag)
        dbResponseRelay
            .subscribe(onNext: { [weak self] response in
                self?.movies = response.movies
                self?.presenter?.movieResponseRelay.accept(response)
            })
            .disposed(by: bag)
        loadingRelay
            .bind(to: presenter?.loadingRelay ?? .init())
            .disposed(by: bag)
        toggleFavoriteRelay
            .subscribe(onNext: { [unowned self] index in
                movies[index].isFavorite.toggle()
                let movie = movies[index]
                worker.toggleFavorite(id: movie.id, isFavorite: movie.isFavorite)
                dbResponseRelay.accept(MoviesModel.DBResponse(movies: movies))
            })
            .disposed(by: bag)
    }
}
