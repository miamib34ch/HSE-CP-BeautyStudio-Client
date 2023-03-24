//
//  AuthViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 19.03.2023.
//

import UIKit

final class DataInputViewController: UIViewController {
    
    @IBOutlet private var loginTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var continueButton: UIButton!
    
    var delegate: AuthViewControllerProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if delegate?.isItLogin == false {
            alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Пароль должен включать",
                                                               message: "1. Большие и мальнькие буквы\n2. Цифры\n3. Специальные символы\n4. Минимум 8 символов\n5. Быть на английском языке!",
                                                               firstButtonText: "Ок",
                                                               firstButtonCompletion: nil,
                                                               secondButtonText: nil,
                                                               secondButtonCompletion: nil))
        }
    }
    
    @IBAction func continueTouchUp(_ sender: Any) {
        guard let login = loginTextField.text?.description else { return }
        guard let password = passwordTextField.text?.description else { return }
        UIBlockingProgressHUD.show()
        guard let res = delegate?.isItLogin else { return }
        switch res {
        case true:
            AuthService.fetchOAuthToken(login: login, password: password, isItLogin: res ,completion: completionLogin)
        case false:
            AuthService.fetchOAuthToken(login: login, password: password, isItLogin: res ,completion: completionRegistration)
        }
    }
    
    private func switchToClientTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "ClientTabBarController")
        window.rootViewController = tabBarController
    }
    
    private func completionLogin(_ result: Result<AuthResponseBody, Error>) {
        UIBlockingProgressHUD.dismiss()
        
        switch result {
        case .success(let response):
            succes(token: response.token, role: response.role)
            
        case .failure(let error):
            switch error {
            case URLSession.NetworkError.errorStatusCode(400):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                   message: "Неверный пароль!",
                                                                   firstButtonText: "Ок",
                                                                   firstButtonCompletion: nil,
                                                                   secondButtonText: nil,
                                                                   secondButtonCompletion: nil))
            case URLSession.NetworkError.errorStatusCode(404):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                   message: "Такой пользователь не существует!",
                                                                   firstButtonText: "Ок",
                                                                   firstButtonCompletion: nil,
                                                                   secondButtonText: nil,
                                                                   secondButtonCompletion: nil))
            default:
                print(error)
                
            }
        }
    }
    
    private func completionRegistration(_ result: Result<AuthResponseBody, Error>) {
        UIBlockingProgressHUD.dismiss()
        
        switch result {
        case .success(let response):
            succes(token: response.token, role: response.role)
            
        case .failure(let error):
            switch error {
            case URLSession.NetworkError.errorStatusCode(400):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                   message: "Пользователь уже существует!",
                                                                   firstButtonText: "Ок",
                                                                   firstButtonCompletion: nil,
                                                                   secondButtonText: nil,
                                                                   secondButtonCompletion: nil))
            case URLSession.NetworkError.errorStatusCode(406):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                   message: "Логин не может быть пустым!",
                                                                   firstButtonText: "Ок",
                                                                   firstButtonCompletion: nil,
                                                                   secondButtonText: nil,
                                                                   secondButtonCompletion: nil))
            case URLSession.NetworkError.errorStatusCode(409):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                   message: "Неподходящий пароль!",
                                                                   firstButtonText: "Ок",
                                                                   firstButtonCompletion: nil,
                                                                   secondButtonText: nil,
                                                                   secondButtonCompletion: nil))
            default:
                print(error)
                
            }
        }
    }
    
    private func succes(token: String, role: String) {
        guard let login = loginTextField.text?.description else { return }
        let authStorage = AuthStorage()
        authStorage.token = token
        authStorage.role = role
        authStorage.login = login
        switch role {
        case "client":
            switchToClientTabBarController()
        case "admin":
            break
        default:
            break
        }
    }
}
