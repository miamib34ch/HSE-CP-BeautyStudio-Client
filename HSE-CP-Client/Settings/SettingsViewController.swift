//
//  ettingsScreen.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var phoneTextField: UITextField!
    
    private var alertPresenter: AlertPresenterProtocol?
    var delegate: ProfileViewControllerProtocol?
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.profileTakePhone()
    }
    
    @IBAction private func saveButton(_ sender: Any) {
        UIBlockingProgressHUD.show()
        var phone: String?
        var pass: String?
        
        if !(passwordTextField.text == "" || passwordTextField.text == nil) {
            pass = passwordTextField.text
        }
        
        if !(phoneTextField.text == "" || phoneTextField.text == nil) {
            phone = phoneTextField.text
        }
        
        SettingsService().sendUpdateRequest(phone: phone, pass: pass, completion: completionUpdate)
    }
    
    @IBAction private func deleteButton(_ sender: Any) {
        let model = AlertModel(title: "Пока, пока!",
                               message: "Уверены, что хотите удалить аккаунт?",
                               firstButtonText: "Да",
                               firstButtonCompletion: { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            SettingsService().sendDeleteRequest(completion: self.completionDelete)
        },
                               secondButtonText: "Нет",
                               secondButtonCompletion: nil)
        alertPresenter?.showAlertWithTwoButton(model: model)
    }
    
    private func completionDelete(res: Result<String,Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success:
            ProfileViewController.exit()
        case .failure(let error):
            print(error)
        }
    }
    
    private func completionUpdate(res: Result<String,Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success:
            if (passwordTextField.text == "" || passwordTextField.text == nil) && (phoneTextField.text == "" || phoneTextField.text == nil) {
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы обновлять нечем!",
                                                                         message: "Введите новые данные!",
                                                                         firstButtonText: "Ок",
                                                                         firstButtonCompletion: nil,
                                                                         secondButtonText: nil,
                                                                         secondButtonCompletion: nil))
            }
            
            alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Ура",
                                                                     message: "Данные обновлены!",
                                                                     firstButtonText: "Ок",
                                                                     firstButtonCompletion: nil,
                                                                     secondButtonText: nil,
                                                                     secondButtonCompletion: nil))
        case .failure(let error):
            switch error {
            case URLSession.NetworkError.errorStatusCode(400):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                         message: "Телефон не подходит!",
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
            case URLSession.NetworkError.errorStatusCode(423):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                         message: "Обновить телефон могут только клиенты!",
                                                                         firstButtonText: "Ок",
                                                                         firstButtonCompletion: nil,
                                                                         secondButtonText: nil,
                                                                         secondButtonCompletion: nil))
            default:
                print(error)
                
            }
        }
    }
}
