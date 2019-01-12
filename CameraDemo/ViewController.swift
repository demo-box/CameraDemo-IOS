//
//  ViewController.swift
//  CameraDemo
//
//  Created by 悖论 on 2019/1/12.
//  Copyright © 2019 悖论. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var qrcodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ScanViewController
        dest.delegate = self
    }
}

