//
//  takeCallViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import UIKit

final class TakeCallViewController: UIViewController {
    
    @IBOutlet private var phone: UITextField!
    @IBOutlet private var massage: UITextField!
    
    private var names: [String] = []
    private var selectedProcedure: String?
    private var alertPresenter: AlertPresenterProtocol?
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        selectedProcedure = ProceduresListService.shared.procedures[0].procedureName
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIBlockingProgressHUD.show()
        TakeCallService().fetchPhone(completion: updatePhoneLabel)
    }
    
    @IBAction private func makeCall(_ sender: Any) {
        guard let selectedProcedure = selectedProcedure else { return }
        guard let phone = phone.text else { return }
        TakeCallService().sendNote(procedureName: selectedProcedure, massage: massage.text, phone: phone, completion: completion)
    }
    
    private func completion(res: Result<MsgResult,Error>) {
        switch res {
        case .success:
            alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Ваш запрос отправлен",
                                                                     message: "Вам перезвонят",
                                                                     firstButtonText: "Ок",
                                                                     firstButtonCompletion: nil,
                                                                     secondButtonText: nil,
                                                                     secondButtonCompletion: nil))
        case .failure(let error):
            switch error{
            case URLSession.NetworkError.errorStatusCode(400):
                alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                         message: "Указаный номер не подходит!",
                                                                         firstButtonText: "Ок",
                                                                         firstButtonCompletion: nil,
                                                                         secondButtonText: nil,
                                                                         secondButtonCompletion: nil))
            default:
                print(error)
            }
        }
    }
    
    private func updatePhoneLabel(res: Result<PhoneResult, Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success(let phone):
            self.phone.text = phone.phone
        case .failure(let error):
            print(error)
        }
    }
    
}

extension TakeCallViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           selectedProcedure = names[row]
        }
}

extension TakeCallViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ProceduresListService.shared.procedures.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        ProceduresListService.shared.procedures.forEach{ p in
            names.append(p.procedureName)
        }
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 17)
            pickerLabel?.textAlignment = .left
        }
        pickerLabel?.text = names[row]
        pickerLabel?.textColor = UIColor.black

        return pickerLabel!
    }

}


