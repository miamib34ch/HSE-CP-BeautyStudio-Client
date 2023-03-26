//
//  ProfileViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import UIKit

protocol ProfileViewControllerProtocol {
    func profileTakePhone() -> Void
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private var alertPresenter: AlertPresenterProtocol?
    private var visits: [Visit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let username = AuthStorage().login else { return }
        usernameLabel.text = "@" + username
        profileTakePhone()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    func profileTakePhone() {
        UIBlockingProgressHUD.show()
        TakeCallService().fetchPhone(completion: updatePhoneLabel)
    }
    
    private func updatePhoneLabel(res: Result<PhoneResult, Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success(let phone):
            phoneNumberLabel.text = phone.phone
        case .failure:
            phoneNumberLabel.text = "Телефон не указан"
        }
        UIBlockingProgressHUD.show()
        ProfileVisitsService.shared.fetchVisits(completion: completion)
    }
    
    private func completion(res: Result<[Visit],Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success:
            updateTableViewAnimated()
        case .failure:
            alertPresenter?.showAlertWithOneButton(model: AlertModel(title: "Увы",
                                                                     message: "У Вас нет посещений!",
                                                                     firstButtonText: "Ок",
                                                                     firstButtonCompletion: nil,
                                                                     secondButtonText: nil,
                                                                     secondButtonCompletion: nil))
        }
    }
    
    private func updateTableViewAnimated() {
        let profileVisitsServiceVisits = ProfileVisitsService.shared.visits
        let oldCount = visits.count
        let newCount = profileVisitsServiceVisits.count
        visits = profileVisitsServiceVisits
        if oldCount != newCount{
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    @IBAction func leave(_ sender: Any) {
        let model = AlertModel(title: "Пока, пока!",
                   message: "Уверены, что хотите выйти из аккаунта?",
                   firstButtonText: "Да",
                   firstButtonCompletion: { ProfileViewController.exit() },
                   secondButtonText: "Нет",
                   secondButtonCompletion: nil)
        alertPresenter?.showAlertWithTwoButton(model: model)
    }
    
    static func exit() {
        AuthStorage().delete()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SplashScreenViewController")
        window.rootViewController = tabBarController
    }
    
}


extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitCell", for: indexPath)
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        }
        if indexPath.row == visits.count-1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        }
        cell.textLabel?.text = visits[indexPath.row].date
        
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowVisit", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVisit" {
            guard let indexPath = sender as? IndexPath else { return }
            guard let singleVisitView = segue.destination as? VisitDetailViewController else { return }
            singleVisitView.id = visits[indexPath.row].idVisit
        } else if segue.identifier == "ShowSettings" {
            guard let settingsView = segue.destination as? SettingsViewController else { return }
            settingsView.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}
