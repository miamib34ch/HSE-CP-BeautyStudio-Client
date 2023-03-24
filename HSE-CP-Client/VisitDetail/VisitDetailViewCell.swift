//
//  VisitDetailViewCell.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import UIKit

final class VisitDetailViewCell: UITableViewCell {
    static let reuseIdentifier = "VisitDetailViewCell"
    
    @IBOutlet var nameLabel: UITextView!
    @IBOutlet var costLabel: UILabel!
    
}
