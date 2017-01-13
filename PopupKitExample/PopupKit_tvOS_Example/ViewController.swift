//
//  ViewController.swift
//  PopupKit_tvOS_Example
//
//  Created by Ryne Cheow on 6/1/17.
//  Copyright © 2017 Kullect. All rights reserved.
//

import UIKit
import PopupKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        view.backgroundColor = .red
        let popupView = PopupView(contentView: view)
        // Do any additional setup after loading the view, typically from a nib.
        popupView.show(duration: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

