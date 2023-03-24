//
//  ProcedureViewController.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import UIKit
import Kingfisher

final class SingleProcedureViewController: UIViewController {
    
    @IBOutlet private var procedureTitle: UITextView!
    @IBOutlet private var cost: UILabel!
    @IBOutlet private var desription: UITextView!
    @IBOutlet private var image: UIImageView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    private var procedure: SingleProcedure?
    var idProcedure: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = idProcedure else { return }
        UIBlockingProgressHUD.show()
        SingleProcedureService().fetchProcedure(id: id, completion: completion)
    }
    
    private func update() {
        UIBlockingProgressHUD.dismiss()
        procedureTitle.text = procedure?.procedureName
        desription.text = procedure?.procedureInfo ?? "Отсуствует!"
        guard let cost = procedure?.cost else { return }
        self.cost.text = "\(cost) ₽"
        guard let photoName = procedure?.photoName else { return }
        image.kf.setImage(with: URL(string: serverURL + "/photo?photoName=" + photoName), placeholder: UIImage(named: "placeholder"))
        
    }
    
    private func completion(res: Result<SingleProcedure, Error>) {
        switch res {
        case .success(let procedure):
            self.procedure = procedure
            update()
        case.failure(let error):
            print(error)
        }
    }
}
