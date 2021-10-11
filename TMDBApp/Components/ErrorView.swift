//
//  ErrorView.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit

class ErrorView: UIView {
    var titleLabel: UILabel = UILabel().then { label in
        label.text = "Oops! Something went wrong."
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
    }
    var retryButton: UIButton = UIButton(type: .system).then { button in
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.setTitle("Retry", for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(retryButton)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
        }
        retryButton.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel.snp.bottom).inset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
