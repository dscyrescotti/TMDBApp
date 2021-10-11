//
//  Movie.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation

struct Movie {
    let id: Int
    let title: String
    let poster: String?
    var isFavorite: Bool
    var isPopular: Bool
    var isUpcoming: Bool
}

extension Movie {
    var object: MovieObject {
        let movie = MovieObject()
        movie.id = id
        movie.title = title
        movie.poster = poster
        movie.isFavorite = isFavorite
        movie.isPopular = isPopular
        movie.isUpcoming = isUpcoming
        return movie
    }
}
