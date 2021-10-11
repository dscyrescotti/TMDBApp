//
//  MovieDetailWorker.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift

class MovieDetailWorker {
    var apiService: MovieDetailAPIService
    var dbService: MovieDetailDBService
    
    init(apiService: MovieDetailAPIService, dbService: MovieDetailDBService) {
        self.apiService = apiService
        self.dbService = dbService
    }
    
    func fetchMovieDetail(id: Int) -> Observable<MovieDetailModel.APIResponse> {
        apiService.fetchMovieDetail(id: id)
    }
    
    func fetchCachedMovie(id: Int) -> Observable<Movie?> {
        Single<Movie?>.create { [unowned self] observer in
            observer(.success(dbService.fetchMovie(id: id)))
            return Disposables.create()
        }.asObservable()
    }
    
    func toggleFavorite(id: Int, isFavorite: Bool) {
        dbService.toggleFavorite(id: id, isFavorite: isFavorite)
    }
}

protocol MovieDetailAPIService {
    func fetchMovieDetail(id: Int) -> Observable<MovieDetailModel.APIResponse>
}

protocol MovieDetailDBService: FavoriteMovieDBService { }
