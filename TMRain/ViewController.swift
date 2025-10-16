//
//  ViewController.swift
//  TMRain
//
//  Created by linghugoogle on 2025/10/16.
//

import UIKit

class ViewController: UIViewController {
    
    private var matrixView: MatrixRainView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMatrixRain()
    }
    
    private func setupMatrixRain() {
        matrixView = MatrixRainView(frame: view.bounds)
        matrixView.backgroundColor = UIColor.black
        view.addSubview(matrixView)
        
        matrixView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
