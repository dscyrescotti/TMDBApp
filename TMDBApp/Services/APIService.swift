//
//  APIService.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import Foundation
import RxSwift
import RxAlamofire

final class APIService {
    private let BASE_URL = "https://api.themoviedb.org/3/"
    private let API_KEY = "2bd3ef300e0f952b182ebf1955bba316"
    private let API_SCHEDULER = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    private let JSON_DECODER = JSONDecoder()
    
    private func urlRequest(endpoint: String, query: [String: Any], header: [String: String] = [:]) -> URLRequest? {
        guard var components = URLComponents(string: "\(BASE_URL)\(endpoint)") else { return nil }
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") } + [URLQueryItem(name: "api_key", value: API_KEY)]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        for dict in header {
            request.setValue(dict.value, forHTTPHeaderField: dict.key)
        }
        return request
    }
    
    private func alamofireRequest<T: Codable>(_ type: T.Type, request: URLRequest) -> Observable<T> {
        return RxAlamofire.request(request)
            .subscribe(on: API_SCHEDULER)
            .validate(statusCode: 200..<300)
            .data()
            .decode(type: type, decoder: JSON_DECODER)
            .asObservable()
    }
}

extension APIService: MoviesAPIService {
    func fetchMovies(movieType: MovieType) -> Observable<MoviesModel.APIResponse> {
        guard let request = urlRequest(endpoint: "movie/\(movieType.rawValue)", query: ["page": 1]) else {
            return Observable.error(ErrorType.urlInvalid)
        }
        return alamofireRequest(MoviesModel.APIResponse.self, request: request)
    }
}

extension APIService: MovieDetailAPIService {
    func fetchMovieDetail(id: Int) -> Observable<MovieDetailModel.APIResponse> {
        guard let request = urlRequest(endpoint: "movie/\(id)", query: [:]) else {
            return Observable.error(ErrorType.urlInvalid)
        }
        return alamofireRequest(MovieDetailModel.APIResponse.self, request: request)
    }
}
