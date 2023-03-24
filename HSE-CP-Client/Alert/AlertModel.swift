//
//  AlertModel.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let firstButtonText: String
    let firstButtonCompletion: (() -> Void)?
    let secondButtonText: String?
    let secondButtonCompletion: (() -> Void)?
}
