//
//  MoviesModel.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation

enum MoviesModel {
    struct APIResponse: Codable {
        let page: Int
        let results: [Movie]
        let totalPages: Int
        let totalResults: Int
        
        enum CodingKeys: String, CodingKey {
            case page, results
            case totalPages = "total_pages"
            case totalResults = "total_results"
        }
        struct Movie: Codable {
            let id: Int
            let title: String
            let poster: String?
            
            enum CodingKeys: String, CodingKey {
                case id, title
                case poster = "poster_path"
            }
        }
    }
    struct DBResponse {
        let movies: [Movie]
    }
    struct ViewModel {
        struct DisplayedMovie {
            let id: Int
            let title: String
            let poster: URL?
            let isFavorite: Bool
        }
        
        let displayedMovies: [DisplayedMovie]
    }
}
