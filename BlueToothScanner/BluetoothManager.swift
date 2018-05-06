//
//  BluetoothManager.swift
//  BlueToothScanner
//
//  Created by anoop mohanan on 18/01/18.
//  Copyright © 2018 anoop. All rights reserved.
//

import Foundation
import CoreBluetooth

enum ScanState: Int{
    
    case stopped = 0
    case inprogress
}
class BluetoothManager: NSObject{
    
    var message:Box<String> = Box("")
    weak var presenter:UIPresenterProtocol?
    fileprivate var centralManager:CBCentralManager!
    fileprivate var discoverPeripherals = [CBPeripheral]()
    var isBluetoothOn:Bool = false
    var scanState:ScanState = .stopped
    private static let shared = BluetoothManager()
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    class func sharedManager() ->BluetoothManager{
        
        return shared
    }
    func startScanning(){
        
        if(!isBluetoothOn){
            
            return
        }
        
        scanState = .inprogress
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning(){
        
        scanState = .stopped
        centralManager.stopScan()
    }
    
    fileprivate func addInfo(text: String){
        
        let msg = "\(text)\(String(describing: message.value))"
        
        message.value = msg
        
    }
    
    func numberOfDevicesDetected() -> Int{
        
        return discoverPeripherals.count
    }
    func deviceAt(index:Int) -> CBPeripheral{
    
        return discoverPeripherals[index]
    }
    func connectToDeviceAt(index:Int){
        let device = discoverPeripherals[index]
        print("Connecting to...\(device.identifier.uuidString)")
        centralManager.connect(discoverPeripherals[index], options: nil)
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state != .poweredOn{
            isBluetoothOn = false
        }else{
            isBluetoothOn = true
        }
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        let info = "Discovered Device \(advertisementData["kCBAdvDataLocalName"] ?? ""), RSSI:\(RSSI)"
        addInfo(text: info)
        discoverPeripherals.append(peripheral)
        presenter?.updateUI()
        //centralManager.connect(discoverPeripheral, options: nil)
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        
        let message = "Failed to connect"
        addInfo(text: message)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        
        print("Connected to \(peripheral.identifier)")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let err = error{
            addInfo(text: err.localizedDescription)
            return
        }
        
        if let services = peripheral.services{
            for service in services{
                addInfo(text: service.description)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let err = error{
            addInfo(text: err.localizedDescription)
            return
        }
        
        if let characteristics = service.characteristics{
            for characteristic in characteristics{
                addInfo(text: "Characteristic found \(characteristic.description)")
                if characteristic.uuid == CBUUID.init(string: Constant.characteristics_Id){
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let err = error{
            addInfo(text: err.localizedDescription)
            return
        }
        guard let dataValue = characteristic.value else {
            return
        }
        let str = String(data: dataValue, encoding: .utf8)
        addInfo(text: str!)
        
    }
}
