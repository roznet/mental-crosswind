//
//  SettingsViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var startingModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var updateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var icaoTextField: UITextField!
    @IBOutlet weak var airportLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if textField == self.icaoTextField {
                Settings.shared.airportIcao = text
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            if textField == self.icaoTextField {
                Settings.shared.airportIcao = text
            }
        }
    }
}
