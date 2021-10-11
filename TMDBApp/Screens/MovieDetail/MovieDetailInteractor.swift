//
//  MovieDetailInteractor.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift
import RxRelay
import Alamofire
import RxCocoa
import SwiftUI

protocol MovieDetailBusinessLogic: AnyObject {
    var dbResponseRelay: PublishRelay<MovieDetailModel.DBResponse> { get }
    var apiResponseRelay: PublishRelay<MovieDetailModel.APIResponse> { get }
    var loadingRelay: PublishRelay<Bool> { get }
    var toggleFavoriteRelay: PublishRelay<Void> { get }
    
    func fetchMovieDetail()
    func fetchCachedMovie()
}
protocol MovieDetailDataSource: AnyObject {
    var movieDetail: MovieDetail? { get set }
    var isFavorite: Bool { get set }
}

class MovieDetailInteractor: MovieDetailBusinessLogic, MovieDetailDataSource {
    private let bag = DisposeBag()
    var presenter: MovieDetailPresentationLogic?
    var worker: MovieDetailWorker
    var movieDetail: MovieDetail?
    var isFavorite: Bool = false
    
    lazy var apiResponseRelay: PublishRelay<MovieDetailModel.APIResponse> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
    lazy var toggleFavoriteRelay: PublishRelay<Void> = .init()
    lazy var dbResponseRelay: PublishRelay<MovieDetailModel.DBResponse> = .init()
    
    var id: Int
    
    init(id: Int) {
        self.id = id
        self.worker = MovieDetailWorker(apiService: APIService(), dbService: DBService())
    }
    
    func fetchMovieDetail() {
        loadingRelay.accept(true)
        worker.fetchMovieDetail(id: id)
            .subscribe(onNext: { [weak self] response in
                self?.movieDetail = MovieDetail(id: response.id, title: response.title, poster: response.poster, backdrop: response.backdrop)
                self?.apiResponseRelay.accept(response)
            }, onError: { [weak self] error in
                if self?.movieDetail == nil {
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
    
    func fetchCachedMovie() {
        worker.fetchCachedMovie(id: id)
            .map { movie -> MovieDetailModel.DBResponse in MovieDetailModel.DBResponse(movie: movie) }
            .bind(to: dbResponseRelay)
            .disposed(by: bag)
    }
}

extension MovieDetailInteractor {
    func bind() {
        apiResponseRelay
            .bind(to: presenter?.movieDetialResponseRelay ?? .init())
            .disposed(by: bag)
        loadingRelay
            .bind(to: presenter?.loadingRelay ?? .init())
            .disposed(by: bag)
        dbResponseRelay
            .map {
                $0.movie?.isFavorite ?? false
            }
            .subscribe(onNext: { [weak self] in
                self?.isFavorite = $0
                self?.presenter?.isFavoriteRelay.accept($0)
            })
            .disposed(by: bag)
        toggleFavoriteRelay
            .map { [unowned self] in
                !isFavorite
            }
            .subscribe(onNext: { [unowned self] in
                worker.toggleFavorite(id: id, isFavorite: $0)
                isFavorite = $0
                fetchCachedMovie()
            })
            .disposed(by: bag)
        
    }
}
