//
//  SceneDelegate.swift
//  TMDBApp
//
//  Created by Dscyre Scotti on 10/10/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let tabBarVC = UITabBarController()
        tabBarVC.title = "TMDB"
        let popularMoviesVC = MoviesViewController()
        popularMoviesVC.setup(for: .popular)
        popularMoviesVC.tabBarItem = .init(title: "Popular", image: UIImage(systemName: "film.fill"), tag: 0)
        let upcomingMoviesVC = MoviesViewController()
        upcomingMoviesVC.setup(for: .upcoming)
        upcomingMoviesVC.tabBarItem = .init(title: "Upcoming", image: UIImage(systemName: "bookmark.fill"), tag: 1)
        tabBarVC.setViewControllers([popularMoviesVC, upcomingMoviesVC], animated: true)
        window.rootViewController = UINavigationController(rootViewController: tabBarVC)
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }


}

