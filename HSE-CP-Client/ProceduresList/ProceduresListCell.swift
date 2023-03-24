//
//  ProceduresListCell.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import UIKit
import Kingfisher

final class ProceduresListCell: UITableViewCell {
    static let reuseIdentifier = "ProcedureCell"
    var gradientSublayer: CALayer?
    
    @IBOutlet weak var imageInCell: UIImageView!
    @IBOutlet weak var nameProcedureLabel: UILabel!
    @IBOutlet weak var gradientNameView: UIView!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var gradientCostView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageInCell.kf.cancelDownloadTask()
    }

}
