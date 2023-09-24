//
//  VisitDetailViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import UIKit

final class VisitDetailViewController: UIViewController {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var saleLabel: UILabel!
    @IBOutlet var finalCostLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    private var singleVisit: SingleVisit?
    var id: Int?
    private var oldCount: Int = 0
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = id else { return }
        UIBlockingProgressHUD.show()
        VisitDetailService().fetchVisitById(id: id, completion: completion)
    }
    
    private func completion(res: Result<SingleVisit, Error>) {
        UIBlockingProgressHUD.dismiss()
        switch res {
        case .success(let response):
            singleVisit = response
            updateData()
            updateTableViewAnimated()
        case.failure(let error):
            print(error)
        }
    }
    
    private func updateData() {
        guard let singleVisit = singleVisit else { return }
        dateLabel.text = singleVisit.date
        saleLabel.text = "\(singleVisit.saleSize) ₽"
        finalCostLabel.text = "\(singleVisit.cost) ₽"
    }
    
    private func updateTableViewAnimated() {
        guard let singleVisit = singleVisit else { return }
        let newCount = singleVisit.responsePriceInVisits.count
        if oldCount != newCount{
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
        oldCount = newCount
    }

    private func calculateTextViewHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let textView = UITextView()
        textView.text = text
        textView.font = font
        textView.frame.size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }
}

extension VisitDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        singleVisit?.responsePriceInVisits.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VisitDetailViewCell.reuseIdentifier, for: indexPath)
        
        guard let visitDetailCell = cell as? VisitDetailViewCell else { return UITableViewCell() }
        guard let singleVisit = singleVisit else { return UITableViewCell() }
        visitDetailCell.nameLabel.text = singleVisit.responsePriceInVisits[indexPath.row].procedureName
        visitDetailCell.costLabel.text = "\(singleVisit.responsePriceInVisits[indexPath.row].cost) ₽"
        visitDetailCell.costLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return visitDetailCell
    }
}

extension VisitDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let singleVisit = singleVisit else { return 0 }
        return calculateTextViewHeight(text: singleVisit.responsePriceInVisits[indexPath.row].procedureName, width: view.frame.width - 32, font: UIFont.systemFont(ofSize: 22)) + 30
    }
}
