//
//  InfoCell.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit

class InfoCell: UITableViewCell {
    static let identifier: String = "InfoCell"
    var posterImageView: UIImageView = UIImageView().then { imageView in
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
    }
    
    var titleLabel: UILabel = UILabel().then { label in
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 2
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(posterImageView)
        addSubview(titleLabel)
        posterImageView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(70)
            make.leading.bottom.top.equalToSuperview().inset(10)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
        }
    }
    
    func setupCell(title: String, url: URL?) {
        titleLabel.text = title
        posterImageView.kf.setImage(with: url)
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        posterImageView.kf.cancelDownloadTask()
        super.prepareForReuse()
    }
}
