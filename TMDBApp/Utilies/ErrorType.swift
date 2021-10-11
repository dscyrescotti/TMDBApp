//
//  ErrorType.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation
import Alamofire

enum ErrorType: Error {
    case urlInvalid
    case networkFailed
    case decodingFailed
    case unknown
}
