//
//  MoviesWorker.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift

class MoviesWorker {    
    var movieType: MovieType
    var apiService: MoviesAPIService
    var dbService: MoviesDBService
    
    init(movieType: MovieType, apiService: MoviesAPIService, dbService: MoviesDBService) {
        self.movieType = movieType
        self.apiService = apiService
        self.dbService = dbService
    }
    
    func fetchMovies() -> Observable<MoviesModel.APIResponse> {
        apiService.fetchMovies(movieType: movieType)
    }
    
    func fetchCachedMovies() -> Observable<MoviesModel.DBResponse> {
        dbService.fetchMovies(movieType: movieType)
    }
    
    func fetchMovie(id: Int) -> Movie? {
        dbService.fetchMovie(id: id)
    }
    
    func saveMovies(movies: [Movie]) {
        dbService.saveMovies(movies: movies)
    }
    
    func toggleFavorite(id: Int, isFavorite: Bool) {
        dbService.toggleFavorite(id: id, isFavorite: isFavorite)
    }
}

protocol MoviesAPIService {
    func fetchMovies(movieType: MovieType) -> Observable<MoviesModel.APIResponse>
}

protocol MoviesDBService: FavoriteMovieDBService {
    func fetchMovies(movieType: MovieType) -> Observable<MoviesModel.DBResponse>
    func saveMovies(movies: [Movie])
}

protocol FavoriteMovieDBService {
    func toggleFavorite(id: Int, isFavorite: Bool)
    func fetchMovie(id: Int) -> Movie?
}
