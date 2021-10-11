//
//  DBService.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class DBService {
    var realm: Realm
    init() {
        self.realm = try! Realm()
    }
}

extension DBService: MoviesDBService {
    func fetchMovies(movieType: MovieType) -> Observable<MoviesModel.DBResponse> {
        let format = movieType == .popular ? "isPopular == true" : "isUpcoming == true"
        return Single<[Movie]>.create { [unowned self] observer in
            let movies = self.realm.objects(MovieObject.self).filter(NSPredicate(format: format))
            observer(.success(movies.map { $0.movie }))
            return Disposables.create()
        }
        .map { movies in
            MoviesModel.DBResponse(movies: movies)
        }
        .asObservable()
    }
    
    func saveMovies(movies: [Movie]) {
        let objects = movies.map { $0.object }
        try! realm.write {
            realm.add(objects, update: .modified)
        }
    }
    
    func fetchMovie(id: Int) -> Movie? {
        realm.object(ofType: MovieObject.self, forPrimaryKey: id)?.movie
    }
    
    func toggleFavorite(id: Int, isFavorite: Bool) {
        guard let object = realm.object(ofType: MovieObject.self, forPrimaryKey: id) else { return }
        try! realm.write({
            object.isFavorite = isFavorite
            realm.add(object, update: .modified)
        })
    }
}

extension DBService: MovieDetailDBService { }
