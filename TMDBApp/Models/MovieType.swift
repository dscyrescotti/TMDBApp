//
//  MovieType.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation
import RealmSwift

enum MovieType: String, PersistableEnum {
    case popular, upcoming
}
