//
//  MovieDetailModel.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation

enum MovieDetailModel {
    struct APIResponse: Codable {
        let id: Int
        let title: String
        let poster: String?
        let backdrop: String?
        
        enum CodingKeys: String, CodingKey {
            case id, title
            case poster = "poster_path"
            case backdrop = "backdrop_path"
        }
    }
    
    struct DBResponse {
        var movie: Movie?
    }
    
    struct ViewModel {
        enum CellType {
            case backdropCell(URL?)
            case infoCell(String, URL?)
        }
        var cellTypes: [CellType]
    }
}
