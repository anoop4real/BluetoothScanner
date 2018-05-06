//
//  ViewController.swift
//  BlueToothScanner
//
//  Created by anoop mohanan on 10/01/18.
//  Copyright © 2018 anoop. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol UIPresenterProtocol: class {
    
    func updateUI()
}

class ViewController: UIViewController, UIPresenterProtocol {

    


    let bleManager = BluetoothManager.sharedManager()
    @IBOutlet weak var deviceTable:UITableView!
    @IBOutlet weak var scanButton:UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        bleManager.message.bind {[unowned self] in
//            //self.textValue.text = $0
//        }
        bleManager.presenter = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startScanning(){
        
        switch bleManager.scanState {
        case .stopped:
            bleManager.startScanning()
            scanButton.setTitle("STOP SCANNING", for: .normal)
        case .inprogress:
            bleManager.stopScanning()
            scanButton.setTitle("START SCANNING", for: .normal)
        }
        

    }
    
    func updateUI() {
        
        deviceTable.beginUpdates()
        deviceTable.insertRows(at: [IndexPath(row: bleManager.numberOfDevicesDetected()-1, section: 0)], with: .automatic)
        deviceTable.endUpdates()
    }
    
}

extension ViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bleManager.numberOfDevicesDetected()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        let data = bleManager.deviceAt(index: indexPath.row)
        cell.textLabel?.text = data.identifier.uuidString
        cell.detailTextLabel?.text = data.name ?? "NO NAME"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        bleManager.connectToDeviceAt(index: indexPath.row)
    }
    
    
    
}

