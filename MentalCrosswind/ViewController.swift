//
//  ViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var runwayTextField: UITextField!
    
    var runwayWindModel : RunwayWindModel = RunwayWindModel(runway: Heading(roundedHeading: 240) )
    
    func syncModelToView() {
        self.runwayTextField.text = self.runwayWindModel.runwayHeading.runwayDescription
    }

    func syncViewToModel() {
        if let runway  = self.runwayTextField.text {
            self.runwayWindModel.runwayHeading.runwayDescription = runway
        }
    }
    
    func clearAnalysisFromView() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncModelToView()
        // Do any additional setup after loading the view.
    }

    @IBAction func windCheckButton(_ sender: Any) {
        self.syncViewToModel()
        self.runwayWindModel.randomizeWind()
        self.clearAnalysisFromView()
        
        print( self.runwayWindModel.announce)
        print( self.runwayWindModel.analyse() )
        
        self.runwayWindModel.speak() {
            self.startUpdateSequence()
        }
    }
    
    func startUpdateSequence() {
        
    }
    
}

