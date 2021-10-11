//
//  MovieDetailPresenter.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

protocol MovieDetailPresentationLogic: AnyObject {
    var movieDetialResponseRelay: PublishRelay<MovieDetailModel.APIResponse> { get }
    var isFavoriteRelay: PublishRelay<Bool> { get }
    var errorRelay: PublishRelay<ErrorType> { get }
    var loadingRelay: PublishRelay<Bool> { get }
}

class MovieDetailPresenter: MovieDetailPresentationLogic {
    private let bag = DisposeBag()
    
    weak var viewController: MovieDetailDisplayLogic?
    
    lazy var movieDetialResponseRelay: PublishRelay<MovieDetailModel.APIResponse> = .init()
    lazy var errorRelay: PublishRelay<ErrorType> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
    lazy var isFavoriteRelay: PublishRelay<Bool> = .init()
}

extension MovieDetailPresenter {
    func bind() {
        movieDetialResponseRelay
            .map { response -> MovieDetailModel.ViewModel in
                let backdropURL = URL(string: "https://image.tmdb.org/t/p/w300" + (response.backdrop ?? ""))
                let posterURL = URL(string: "https://image.tmdb.org/t/p/w300" + (response.poster ?? ""))
                let cellTypes: [MovieDetailModel.ViewModel.CellType] = [.backdropCell(backdropURL), .infoCell(response.title, posterURL)]
                return .init(cellTypes: cellTypes)
            }
            .bind(to: viewController?.movieDetailViewModelRelay ?? .init())
            .disposed(by: bag)
        
        movieDetialResponseRelay
            .map { _ in false }
            .bind(to: loadingRelay)
            .disposed(by: bag)
        
        loadingRelay
            .bind(to: viewController?.loadingRelay ?? .init())
            .disposed(by: bag)
        
        errorRelay
            .bind(to: viewController?.errorRelay ?? .init())
            .disposed(by: bag)
        
        isFavoriteRelay
            .bind(to: viewController?.isFavoriteRelay ?? .init())
            .disposed(by: bag)
    }
}
