import UIKit
import CoreBluetooth
import PlaygroundBluetooth
import PlaygroundSupport

let BATTERY_MODE = false

private let serviceUuid:CBUUID?
private let characteristicUuid:CBUUID?

if BATTERY_MODE {
    serviceUuid = CBUUID(string: "180F")
    characteristicUuid = CBUUID(string: "2A19")
}else{
    serviceUuid = CBUUID(string: "1111")
    characteristicUuid = CBUUID(string: "2222")
}

class MyLiveView: UIView{}

class ViewController: UIViewController  {
    
    private var myTextView  = UITextView()
    private var myInputText = UITextView()
    private var myUIButton  = UIButton()
    private var vstring = String()
    //private var customHeadColor = UIColor()
    private let centralManager = PlaygroundBluetoothCentralManager(services: nil, queue: .main)
    private var connectionView: PlaygroundBluetoothConnectionView?
    
    
    private var myCharacteristic: CBCharacteristic!
    private var myPeripheral: CBPeripheral!
    //let liveview = MyLiveView()
    
    override func loadView() {
        super.loadView()
        //let live
        view = MyLiveView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customHeadColor = #colorLiteral(red: 0.254901975393295, green: 0.274509817361832, blue: 0.301960796117783, alpha: 1.0) 
        view.backgroundColor = customHeadColor
        // disable auto layout
        view.translatesAutoresizingMaskIntoConstraints = false
        // TextView layout
        myTextView.isEditable = false
        myInputText.isEditable = true
        
        myTextView.translatesAutoresizingMaskIntoConstraints  = false
        myInputText.translatesAutoresizingMaskIntoConstraints = false
        myUIButton.translatesAutoresizingMaskIntoConstraints  = false
        
        myTextView.backgroundColor  = #colorLiteral(red: 0.803921580314636, green: 0.803921580314636, blue: 0.803921580314636, alpha: 1.0)
        myInputText.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        myUIButton.backgroundColor  = #colorLiteral(red: 0.803921580314636, green: 0.803921580314636, blue: 0.803921580314636, alpha: 1.0)
        
        view.addSubview(myTextView)
        view.addSubview(myInputText)
        view.addSubview(myUIButton)
        
        
        
        
        // UITextViews layout
        NSLayoutConstraint.activate([
            myTextView.topAnchor.constraint(equalTo: view.topAnchor,constant:80.0),
            myTextView.bottomAnchor.constraint(equalTo: myInputText.topAnchor,constant: -10.0),
            myTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            myTextView.trailingAnchor.constraint(equalTo:  view.layoutMarginsGuide.trailingAnchor),
            myInputText.heightAnchor.constraint(equalToConstant: 50.0),
            myInputText.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant : -10.0),
            myInputText.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10.0),
            myInputText.trailingAnchor.constraint(equalTo: myUIButton.leadingAnchor, constant: -10.0),
            myUIButton.topAnchor.constraint(equalTo: myTextView.bottomAnchor, constant: 10.0),
            myUIButton.heightAnchor.constraint(equalToConstant: 50.0),
            myUIButton.widthAnchor.constraint(equalToConstant: 50.0),
            myUIButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor,constant: -10.0)
            
            ])
        
        // UIBotton
        myUIButton.addTarget(self, action: "db", for: .touchDown)
        myUIButton.addTarget(self, action: "pb", for: .touchUpInside)
        myUIButton.layer.shadowOpacity = 0.0
        myUIButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        myInputText.layer.cornerRadius = 5.0
        myUIButton.layer.cornerRadius = 25.0
        myUIButton.setTitle("▲", for: UIControlState.normal)
        myUIButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControlState.normal) 
        myUIButton.setTitle("▲", for: UIControlState.highlighted)
        myUIButton.setTitleColor(#colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), for: UIControlState.highlighted)
        myUIButton.isEnabled = false
        // connectionView settings
        centralManager.delegate = self
        
        let connectionView = PlaygroundBluetoothConnectionView(centralManager: centralManager)
        connectionView.delegate = self
        connectionView.dataSource = self
        
        view.addSubview(connectionView)
        NSLayoutConstraint.activate([
            connectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
            connectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
            ])
        connectionView.layer.borderColor = customHeadColor.cgColor
        connectionView.layer.borderWidth = 1.0
        connectionView.layer.cornerRadius = 20.0
        
        self.connectionView = connectionView
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    @objc func db(){
        myUIButton.layer.shadowOpacity = 0.0
        
    }
    
    @objc func pb(){
        print("push button")
        
        if myPeripheral != nil && myCharacteristic != nil {
            if myCharacteristic.properties.contains(.read) {
                myPeripheral.readValue(for: myCharacteristic)
            }
            if myCharacteristic.properties.contains(.notify) {
                myPeripheral.setNotifyValue(true, for: myCharacteristic)
                
            }
            if myInputText.text.characters.count != 0 {
                let data: Data? = myInputText.text.data(using: String.Encoding.utf8)
                if myCharacteristic.properties.contains(.write) {
                    myPeripheral.writeValue(data!, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
                }
                if myCharacteristic.properties.contains(.writeWithoutResponse) {
                    myPeripheral.writeValue(data!, for: myCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
                }
                myUIButton.layer.shadowOpacity = 1.0
                
            }
        }
    }
}

extension ViewController: PlaygroundBluetoothConnectionViewDelegate {
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldDisplayDiscovered peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        return true
    }
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldConnectTo peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        return true
    }
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, willDisconnectFrom peripheral: CBPeripheral) {
    }
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        return "\(state)"
    }
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        return #function
    }
}

extension ViewController: PlaygroundBluetoothConnectionViewDataSource {
    
    func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) ->  PlaygroundBluetoothConnectionView.Item {
        let name = peripheral.name ?? "Unknown"
        let icon = UIImage()
        
        let item = PlaygroundBluetoothConnectionView.Item(name: name, icon: icon, issueIcon: icon)
        return item
    }
}

extension ViewController: PlaygroundBluetoothCentralManagerDelegate {
    
    func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        if centralManager.state == CBManagerState.poweredOff {
            print("turn on iPad's Bluetooth.")
        }
        
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) {
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
        print("Connect Start: \((peripheral.name))")
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUuid!])
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        myPeripheral = nil
        myCharacteristic = nil
        myUIButton.backgroundColor = #colorLiteral(red: 0.803921580314636, green: 0.803921580314636, blue: 0.803921580314636, alpha: 1.0)
        myUIButton.layer.shadowOpacity = 0.0
        myUIButton.isEnabled = false
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUuid }) {
            peripheral.discoverCharacteristics([characteristicUuid!], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUuid }) {
            myPeripheral = peripheral
            myCharacteristic = characteristic
            myUIButton.backgroundColor = #colorLiteral(red: 0.807843148708344, green: 0.0274509806185961, blue: 0.333333343267441, alpha: 1.0)
            myUIButton.layer.shadowOpacity = 1.0
            myUIButton.isEnabled = true
            if BATTERY_MODE {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            /*
             if characteristic.properties.contains(.write) {
             let data: Data! = "WriteWithResp".data(using: String.Encoding.utf8)
             peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
             }
             if characteristic.properties.contains(.writeWithoutResponse) {
             let data: Data! = "writeWithoutResp".data(using: String.Encoding.utf8)
             peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
             }*/
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueForCharacteristics characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if BATTERY_MODE {
            if let value = characteristic.value?.first {
                connectionView?.setBatteryLevel(Double(value) / 100, forPeripheral: peripheral)}
        }else{
            let val = characteristic.value
            if val != nil {
                vstring = String(data:(val)!, encoding:String.Encoding.utf8)!
                if vstring != nil {
                    print (vstring)  
                    myTextView.isScrollEnabled = false
                    myTextView.text = myTextView.text + vstring
                    //scroll to bottom
                    myTextView.selectedRange = _NSRange(location: myTextView.text.characters.count, length: 0)
                    myTextView.isScrollEnabled = true
                    let scrollY = myTextView.contentSize.height - myTextView.bounds.height
                    let scrollPoint = CGPoint(x: 0, y: scrollY > 0 ? scrollY: 0)
                    myTextView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
    }
}


// Present the view controller in the Live View window
//PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = ViewController()
