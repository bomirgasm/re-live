//
//  MainTabBarController.swift
//  re-live
//
//  Created by Suzie Kim on 6/18/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
    }
    
    private func setupTabBar() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let recordsVC = UINavigationController(rootViewController: RecordsViewController())
        recordsVC.tabBarItem = UITabBarItem(title: "Records", image: UIImage(systemName: "list.bullet.rectangle"), tag: 1)
        
        let trendsVC = UINavigationController(rootViewController: GraphViewController())
        trendsVC.tabBarItem = UITabBarItem(title: "Trends", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 2)
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeVC, recordsVC, trendsVC, profileVC]
    }
}
