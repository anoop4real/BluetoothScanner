//
//  ViewController.swift
//  BlueToothScanner
//
//  Created by anoop mohanan on 10/01/18.
//  Copyright © 2018 anoop. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var textValue:UITextView!
    let bleManager = BluetoothManager.sharedManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleManager.message.bind {[unowned self] in
            self.textValue.text = $0
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startScanning(){
        
        bleManager.startScanning()

    }



}


