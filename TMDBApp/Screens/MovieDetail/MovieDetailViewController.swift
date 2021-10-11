//
//  MovieDetailViewController.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift
import RxRelay

protocol MovieDetailDisplayLogic: AnyObject {
    var movieDetailViewModelRelay: PublishRelay<MovieDetailModel.ViewModel> { get }
    var loadingRelay: PublishRelay<Bool> { get }
    var errorRelay: PublishRelay<ErrorType> { get }
    var isFavoriteRelay: PublishRelay<Bool> { get }
}

class MovieDetailViewController: UIViewController, MovieDetailDisplayLogic {
    private let bag = DisposeBag()
    var tableView: UITableView!
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView().then { indicator in
        indicator.isHidden = true
    }
    var errorView: ErrorView = ErrorView().then { view in
        view.isHidden = true
    }
    var likeButton: UIButton = UIButton(type: .system).then { button in
        button.tintColor = .systemRed
    }
    
    var interactor: MovieDetailBusinessLogic?
    lazy var movieDetailViewModelRelay: PublishRelay<MovieDetailModel.ViewModel> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
    lazy var errorRelay: PublishRelay<ErrorType> = .init()
    lazy var isFavoriteRelay: PublishRelay<Bool> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        interactor?.fetchMovieDetail()
        interactor?.fetchCachedMovie()
    }
    
    func setup(with id: Int) {
        let interactor = MovieDetailInteractor(id: id)
        let presenter = MovieDetailPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
        interactor.bind()
        presenter.bind()
    }
    
    func bind() {
        movieDetailViewModelRelay
            .map { $0.cellTypes }
            .bind(to: tableView.rx.items) { tableView, index, cellType in
                switch cellType {
                case .backdropCell(let url):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: BackdropCell.identifier) as? BackdropCell else { return UITableViewCell() }
                    cell.setupCell(url: url)
                    return cell
                case .infoCell(let title, let url):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier) as? InfoCell else { return UITableViewCell() }
                    cell.setupCell(title: title, url: url)
                    return cell
                }
            }
            .disposed(by: bag)
        
        loadingRelay
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.indicatorView.isHidden = false
                    self?.indicatorView.startAnimating()
                    self?.tableView.isHidden = true
                    self?.errorView.isHidden = true
                } else {
                    self?.indicatorView.isHidden = true
                    self?.indicatorView.stopAnimating()
                    self?.tableView.isHidden = false
                }
            })
            .disposed(by: bag)
        
        errorRelay
            .subscribe(onNext: { [weak self] _ in
                self?.errorView.isHidden = false
                self?.indicatorView.isHidden = true
                self?.indicatorView.stopAnimating()
                self?.tableView.isHidden = false
            })
            .disposed(by: bag)
        
        errorView.retryButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                interactor?.fetchMovieDetail()
            })
            .disposed(by: bag)
        
        isFavoriteRelay
            .subscribe(onNext: { [weak self] isFavorite in
                self?.likeButton.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
            })
            .disposed(by: bag)
        
        likeButton.rx.tap
            .bind(to: interactor?.toggleFavoriteRelay ?? .init())
            .disposed(by: bag)
    }
}

extension MovieDetailViewController {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTableView()
        setupIndicatorView()
        setupErrorView()
        setupLikeButton()
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(BackdropCell.self, forCellReuseIdentifier: BackdropCell.identifier)
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.identifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupIndicatorView() {
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupErrorView() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupLikeButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
    }
}
