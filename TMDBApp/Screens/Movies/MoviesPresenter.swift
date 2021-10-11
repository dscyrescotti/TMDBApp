//
//  MoviesPresenter.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol MoviesPresentationLogic: AnyObject {
    var movieResponseRelay: PublishRelay<MoviesModel.DBResponse> { get }
    var errorRelay: PublishRelay<ErrorType> { get }
    var loadingRelay: PublishRelay<Bool> { get }
}

class MoviesPresenter: MoviesPresentationLogic {
    private let bag = DisposeBag()
    
    weak var viewController: MoviesDisplayLogic?
    
    lazy var movieResponseRelay: PublishRelay<MoviesModel.DBResponse> = .init()
    lazy var errorRelay: PublishRelay<ErrorType> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
}

extension MoviesPresenter {
    func bind() {
        movieResponseRelay
            .map { response -> MoviesModel.ViewModel in
                let displayedMovies = response.movies.map {
                    MoviesModel.ViewModel.DisplayedMovie.init(id: $0.id, title: $0.title, poster: URL(string: "https://image.tmdb.org/t/p/w300" + ($0.poster ?? "")), isFavorite: $0.isFavorite)
                }
                return MoviesModel.ViewModel(displayedMovies: displayedMovies)
            }
            .bind(to: viewController?.moviesViewModelRelay ?? .init())
            .disposed(by: bag)
        
        movieResponseRelay
            .map { $0.movies.isEmpty }
            .bind(to: loadingRelay)
            .disposed(by: bag)
        
        loadingRelay
            .bind(to: viewController?.loadingRelay ?? .init())
            .disposed(by: bag)
        
        errorRelay
            .bind(to: viewController?.errorRelay ?? .init())
            .disposed(by: bag)
    }
}
