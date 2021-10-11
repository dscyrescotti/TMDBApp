//
//  BackdropCell.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit

class BackdropCell: UITableViewCell {
    static let identifier = "BackdropCell"
    
    var backdropImageView: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupUI() {
        addSubview(backdropImageView)
        backdropImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    func setupCell(url: URL?) {
        backdropImageView.kf.setImage(with: url)
    }
    
    override func prepareForReuse() {
        backdropImageView.kf.cancelDownloadTask()
        super.prepareForReuse()
    }
}
