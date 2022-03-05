//
//  SettingsViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var defaultRunwayEntryText: UITextField!
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
        self.defaultRunwayEntryText.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.icaoTextField.delegate = nil
        self.defaultRunwayEntryText.delegate = nil
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true)
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
        
        self.icaoTextField.text = Settings.shared.airportIcao
        self.defaultRunwayEntryText.text = Settings.shared.heading(key: .last_runway).runwayDescription
    }
    
    //MARK: - textField delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if textField == self.icaoTextField {
                Settings.shared.airportIcao = text
            }else if textField == self.defaultRunwayEntryText {
                Settings.shared.setHeading(key: .last_runway, heading: Heading(runwayDescription: text))
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            if textField == self.icaoTextField {
                Settings.shared.airportIcao = text
            }else if textField == self.defaultRunwayEntryText {
                Settings.shared.setHeading(key: .last_runway, heading: Heading(runwayDescription: text))
            }
        }
    }
}
