//
//  ViewController.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let apiService = APIService()
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
    }


}

