//
//  MoviesViewController.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol MoviesDisplayLogic: AnyObject {
    var moviesViewModelRelay: PublishRelay<MoviesModel.ViewModel> { get }
    var loadingRelay: PublishRelay<Bool> { get }
    var errorRelay: PublishRelay<ErrorType> { get }
}

class MoviesViewController: UIViewController, MoviesDisplayLogic {
    private let bag = DisposeBag()
    var collectionView: UICollectionView!
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView().then { indicator in
        indicator.isHidden = true
    }
    var errorView: ErrorView = ErrorView().then { view in
        view.isHidden = true
    }
    
    var interactor: MoviesBusinessLogic?
    var router: (MoviesRoutingLogic & MoviesDataPassing)?
    lazy var moviesViewModelRelay: PublishRelay<MoviesModel.ViewModel> = .init()
    lazy var loadingRelay: PublishRelay<Bool> = .init()
    lazy var errorRelay: PublishRelay<ErrorType> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        interactor?.fetchMovies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchCachedMovies()
    }
    
    func setup(for movieType: MovieType) {
        let interactor = MoviesInteractor(movieType: movieType)
        let presenter = MoviesPresenter()
        let router = MoviesRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataSource = interactor
        interactor.bind()
        presenter.bind()
    }
    
    private func bind() {
        moviesViewModelRelay
            .map { $0.displayedMovies }
            .bind(to: collectionView.rx.items(cellIdentifier: MovieCell.identifier, cellType: MovieCell.self)) { [unowned self] index, movie, cell in
                cell.setupCell(movie: movie)
                cell.tapAction = { [unowned self] in
                    interactor?.toggleFavoriteRelay.accept(index)
                }
            }
            .disposed(by: bag)
        
        loadingRelay
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.indicatorView.isHidden = false
                    self?.indicatorView.startAnimating()
                    self?.collectionView.isHidden = true
                    self?.errorView.isHidden = true
                } else {
                    self?.indicatorView.isHidden = true
                    self?.indicatorView.stopAnimating()
                    self?.collectionView.isHidden = false
                }
            })
            .disposed(by: bag)
        
        errorRelay
            .subscribe(onNext: { [weak self] _ in
                self?.errorView.isHidden = false
                self?.indicatorView.isHidden = true
                self?.indicatorView.stopAnimating()
                self?.collectionView.isHidden = false
            })
            .disposed(by: bag)
        
        errorView.retryButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                interactor?.fetchMovies()
            })
            .disposed(by: bag)
        
        collectionView.rx.itemSelected
            .map { $0.item }
            .subscribe(onNext: { [unowned self] in
                router?.routeToMovie(index: $0)
            })
            .disposed(by: bag)
    }
}

extension MoviesViewController {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupIndicatorView()
        setupErrorView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            self?.gridLayout()
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
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
    
    private func gridLayout() -> NSCollectionLayoutSection {
        let isLandscape = view.bounds.width > view.bounds.height
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: isLandscape ? .fractionalWidth(1/3) : .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: isLandscape ? .fractionalWidth(0.4) : .fractionalWidth(0.7)), subitem: item, count: isLandscape ? 3 : 2)
        group.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
