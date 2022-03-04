//
//  SettingsViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var defaultRunwayEntryText: UITextField!
    @IBOutlet weak var updateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var icaoTextField: UITextField!
    @IBOutlet weak var airportLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func updateSegmentChanged(_ sender: UISegmentedControl) {
        
        
        if sender.selectedSegmentIndex == 0 {
            self.airportLabel.isEnabled = true
            self.icaoTextField.isEnabled = true;
        }else{
            self.airportLabel.isEnabled = false
            self.icaoTextField.isEnabled = false;
        }
        
        
    }
    

    func syncSettingsToView(){
        
    }
    
}
