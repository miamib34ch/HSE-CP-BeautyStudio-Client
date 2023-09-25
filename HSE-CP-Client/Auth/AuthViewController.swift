//
//  AuthViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import UIKit

protocol AuthViewControllerProtocol {
    var isItLogin: Bool? { get set }
}

final class AuthViewController: UIViewController, AuthViewControllerProtocol {
    var isItLogin: Bool?
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    @IBAction func registrationTouch(_ sender: Any) {
        isItLogin = false
    }

    @IBAction func loginTouch(_ sender: Any) {
        isItLogin = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRegistration" || segue.identifier == "ShowLogin" {
            guard let dataInputViewViewController = segue.destination as? DataInputViewController
            else { fatalError("Failed to prepare for ShowRegistration") }
            dataInputViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
