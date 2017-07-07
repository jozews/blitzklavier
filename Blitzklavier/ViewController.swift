//
//  ViewController.swift
//  Blitzklavier
//
//  Created by Jože Ws on 8/29/16.
//  Copyright © 2016 JožeWs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view = PianoView.init(frame: view.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

