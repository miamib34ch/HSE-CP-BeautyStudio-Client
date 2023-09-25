//
//  ProceduresViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import UIKit

final class ProceduresListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private var procedures: [Procedures] = []
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIBlockingProgressHUD.show()
        ProceduresListService.shared.fetchProcedures(completion: completion)
    }

    private func completion(res: Result<[Procedures], Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success:
            updateTableViewAnimated()
        case.failure(let error):
            print(error)
        }
    }

    private func updateTableViewAnimated() {
        let proceduresListServiceProcedures = ProceduresListService.shared.procedures
        let oldCount = procedures.count
        let newCount = proceduresListServiceProcedures.count
        procedures = proceduresListServiceProcedures
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in
            }
        }
    }
}

extension ProceduresListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        procedures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProceduresListCell.reuseIdentifier, for: indexPath)
        guard let procedureListCell = cell as? ProceduresListCell else { return UITableViewCell() }
        configCell(for: procedureListCell, with: indexPath)
        return procedureListCell
    }

    private func configCell(for cell: ProceduresListCell, with indexPath: IndexPath) {
        cell.nameProcedureLabel.text = procedures[indexPath.row].procedureName
        cell.costLabel.text = "\(procedures[indexPath.row].cost) ₽"
        if cell.gradientSublayer == nil {
            let gradientNameLayer = CAGradientLayer()
            gradientNameLayer.frame = cell.gradientNameView.bounds
            gradientNameLayer.colors = [
                UIColor.black.withAlphaComponent(0.4).cgColor as Any,
                UIColor.black.withAlphaComponent(0).cgColor as Any
            ]
            cell.gradientNameView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.gradientNameView.layer.addSublayer(gradientNameLayer)
            let gradientCostLayer = CAGradientLayer()
            gradientCostLayer.frame = cell.gradientCostView.bounds
            gradientCostLayer.colors = [
                UIColor.black.withAlphaComponent(0).cgColor as Any,
                UIColor.black.withAlphaComponent(0.4).cgColor as Any
            ]
            cell.gradientCostView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.gradientCostView.layer.addSublayer(gradientCostLayer)
            cell.gradientSublayer = gradientCostLayer
        }

        guard let photoName = procedures[indexPath.row].photoName else { return }
        cell.imageInCell.kf.indicatorType = .activity
        cell.imageInCell.kf.setImage(with: URL(string: serverURL + "/photo?photoName=" + photoName), placeholder: UIImage(named: "placeholder"))
    }
}

extension ProceduresListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowProcedure", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProcedure" {
            guard let indexPath = sender as? IndexPath else { return }
            guard let singleProcedureView = segue.destination as? SingleProcedureViewController else { return }
            singleProcedureView.idProcedure = procedures[indexPath.row].idProcedure
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
}
