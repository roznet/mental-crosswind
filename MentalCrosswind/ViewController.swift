//
//  ViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var runwayTextField: UITextField!
    @IBOutlet weak var headingIndicatorView: HeadingIndicatorView!
    
    var runwayWindModel : RunwayWindModel = RunwayWindModel(runway: Heading(roundedHeading: 240) )
    
    func syncModelToView() {
        self.runwayTextField.text = self.runwayWindModel.runwayHeading.runwayDescription
        self.headingIndicatorView.model = self.runwayWindModel
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
        self.headingIndicatorView.labelAttribute = [ .foregroundColor: UIColor.label]
    }

    //MARK: - Actions
    
    enum PanMode {
        case heading
        case windHeading
        case windSpeed
    }
    
    private var panLastPoint : CGPoint? = nil
    private var panMode : PanMode = .heading
    
    
    @IBAction func handlePan( _ gesture : UIPanGestureRecognizer){
        let location = gesture.location(in: self.headingIndicatorView).rounded
        let translation = gesture.translation(in: self.headingIndicatorView).rounded
        let locationTo = CGPoint( x: location.x + translation.x, y: location.y + translation.y ).rounded
            
        if gesture.state == .began {
            
            if let _ = self.headingIndicatorView.headingInWindCone(point: location){
                self.panMode = .windHeading
            }else{
                self.panMode = .heading
            }

            if let _ = self.headingIndicatorView.headingInCircle(point: location) {
                self.panLastPoint = location
            }else{
                if self.panMode == .windHeading {
                    self.panMode = .windSpeed
                    self.panLastPoint = location
                }else{
                    self.panLastPoint = nil
                }
            }
        }
        
        if let panLastPoint = self.panLastPoint {
            let angleFrom = self.headingIndicatorView.heading(point: panLastPoint)
            let angleTo = self.headingIndicatorView.heading(point: locationTo)
            
            let radiusFrom = self.headingIndicatorView.radiusPercent(point: panLastPoint)
            let radiusTo = self.headingIndicatorView.radiusPercent(point: locationTo)
            
            switch panMode {
            case .windHeading:
                self.headingIndicatorView.rotateWind(degree: (angleTo - angleFrom))
            case .heading:
                self.headingIndicatorView.rotateHeading(degree: (angleTo - angleFrom))
            case .windSpeed:
                self.headingIndicatorView.increaseWindSpeed(percent: (radiusFrom-radiusTo) )
            }
            
            self.headingIndicatorView.setNeedsDisplay()
            
            self.panLastPoint = locationTo
            gesture.setTranslation(.zero, in: self.headingIndicatorView)
        }
        
        if gesture.state == .ended {
            self.panLastPoint = nil
        }
    }
    
    @IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.headingIndicatorView)

        let center = self.headingIndicatorView.geometry.center
        let angleTo = self.headingIndicatorView.heading(point: location)
        
        let coord = CGPoint(x: location.x - center.x, y: location.y - center.y)
        print( "Loc: \(location) coord: \(coord) angle: \(angleTo) to: \(location.distance(to: center)) " )

        
    }
    
    @IBAction func handleRotation(_ gesture: UIRotationGestureRecognizer) {
    }
    
    
    @IBAction func windCheckButton(_ sender: Any) {
        self.syncViewToModel()
        self.runwayWindModel.randomizeWind()
        self.clearAnalysisFromView()
                
        self.runwayWindModel.speak() {
            self.startUpdateSequence()
        }
    }
    
    func startUpdateSequence() {
        
    }
    
}

