//
//  MoviesRouter.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit

protocol MoviesRoutingLogic: AnyObject {
    func routeToMovie(index: Int)
}
protocol MoviesDataPassing {
    var dataSource: MoviesDataSource? { get }
}

class MoviesRouter: MoviesRoutingLogic, MoviesDataPassing {
    weak var viewController: MoviesViewController?
    var dataSource: MoviesDataSource?
    
    func routeToMovie(index: Int) {
        guard let movie = dataSource?.movies[index] else { return }
        let vc = MovieDetailViewController()
        vc.setup(with: movie.id)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
