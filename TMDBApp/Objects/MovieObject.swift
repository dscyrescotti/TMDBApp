//
//  MovieObject.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import RealmSwift

class MovieObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var poster: String?
    @Persisted var isFavorite: Bool = false
    @Persisted var isPopular: Bool = false
    @Persisted var isUpcoming: Bool = false
}

extension MovieObject {
    var movie: Movie {
        Movie(id: id, title: title, poster: poster, isFavorite: isFavorite, isPopular: isPopular, isUpcoming: isUpcoming)
    }
}
