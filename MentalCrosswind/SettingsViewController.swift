//
//  SettingsViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import UIKit
import DropDown
import OSLog

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var startingModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var updateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var icaoTextField: UITextField!
    @IBOutlet weak var airportLabel: UILabel!
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var choices : [String] {
        var rv = Settings.shared.lastAirportsList
        rv.append(contentsOf: Settings.shared.lastNearestList )
        return rv
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dropDown.anchorView = icaoTextField
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.icaoTextField.text = item
            Settings.shared.airportIcao = item
          }
    
        dropDown.direction = .bottom
        self.syncSettingsToView()
        self.icaoTextField.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.icaoTextField.delegate = nil
    }
    
    @IBAction func doneButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.SettingsChangedNotificationName, object: nil)
        self.dismiss(animated: true)
    }

    @IBAction func startingModeSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            Settings.shared.startingMode = .practice
        }else if sender.selectedSegmentIndex == 1 {
            Settings.shared.startingMode = .analysis
        }else if sender.selectedSegmentIndex == 2 {
            Settings.shared.startingMode = .last
        }
    }
    
    @IBAction func updateSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.airportLabel.isEnabled = true
            self.icaoTextField.isEnabled = true;
            Settings.shared.updateMethod = .custom
        }else{
            self.airportLabel.isEnabled = false
            self.icaoTextField.isEnabled = false;
            if sender.selectedSegmentIndex == 1 {
                Settings.shared.updateMethod = .nearest
            }else{
                Settings.shared.updateMethod = .none
            }
        }
    }
    

    func syncSettingsToView(){
        switch Settings.shared.updateMethod {
        case .none:
            updateSegmentedControl.selectedSegmentIndex = 2
        case .nearest:
            updateSegmentedControl.selectedSegmentIndex = 1
        case .custom:
            updateSegmentedControl.selectedSegmentIndex = 0
        }
        
        switch Settings.shared.startingMode {
        case .practice:
            startingModeSegmentedControl.selectedSegmentIndex = 0
        case .analysis:
            startingModeSegmentedControl.selectedSegmentIndex = 1
        case .last:
            startingModeSegmentedControl.selectedSegmentIndex = 2
        }
        
        self.icaoTextField.text = Settings.shared.airportIcao
    }
    
    //MARK: - textField delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let set = Set<String>(choices)

        dropDown.dataSource = Array(set)
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.show()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if textField == self.icaoTextField {
                Logger.app.info("Selected new airport \(text)")
                if !Settings.shared.airportIcao.contains(text) {
                    Settings.shared.airportIcao = text
                    var last = Settings.shared.lastAirportsList
                    last.insert(text, at: 0)
                    if last.count > 5 {
                        last.removeLast(last.count-5)
                    }
                    Settings.shared.lastNearestList = Array( Set( last ) )
                }
                dropDown.hide()
            }
        }
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.icaoTextField {
            dropDown.show()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dropDown.hide()
        return false
    }
}
