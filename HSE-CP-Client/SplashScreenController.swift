//
//  SplashScreenController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import UIKit

final class SplashScreenController: UIViewController {
    
    private let authStorage = AuthStorage()
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let role = authStorage.role {
            switch role {
            case "client":
                switchToClientTabBarController()
            case "admin":
                break
            default:
                break
            }
        } else {
            let auth = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController")
            auth.modalPresentationStyle = .fullScreen
            present(auth, animated: true)
        }
    }
    
    private func switchToClientTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ClientTabBarController")
        window.rootViewController = tabBarController
    }
}
