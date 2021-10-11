//
//  MovieCell.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import Then
import Kingfisher
import RxSwift

class MovieCell: UICollectionViewCell {
    static let identifier: String = "MovieCell"
    
    private let bag = DisposeBag()
    
    var titleLabel: UILabel = UILabel().then { label in
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
    }
    
    var posterImageView: UIImageView = UIImageView().then { image in
        image.layer.cornerRadius = 5
        image.layer.masksToBounds = true
        image.contentMode = .scaleToFill
    }
    
    var likeButton: UIButton = UIButton(type: .system).then { button in
        button.tintColor = .systemRed
    }
    var tapAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupUI() {
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(likeButton)
        
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(5)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalToSuperview().inset(5)
            make.height.equalTo(20)
        }
        likeButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(posterImageView).inset(10)
        }
    }
    
    func bind() {
        likeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                tapAction?()
            })
            .disposed(by: bag)
    }
    
    func setupCell(movie: MoviesModel.ViewModel.DisplayedMovie) {
        titleLabel.text = movie.title
        posterImageView.kf.setImage(with: movie.poster, placeholder: UIImage(named: "placeholder-poster"))
        likeButton.setImage(UIImage(systemName: movie.isFavorite ? "heart.fill" : "heart"), for: .normal)
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        posterImageView.kf.cancelDownloadTask()
        likeButton.setImage(nil, for: .normal)
        tapAction = nil
        super.prepareForReuse()
    }
}
