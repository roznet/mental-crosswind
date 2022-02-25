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
    
    // Wind Compoent View
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var headWindSpeedLabel: UILabel!
    @IBOutlet weak var crossWindSpeedLabel: UILabel!
    @IBOutlet weak var windRunwayOffsetLabel: UILabel!
    @IBOutlet weak var headWindComponentLabel: UILabel!
    @IBOutlet weak var crossWindComponentLabel: UILabel!
    
    @IBOutlet weak var headWindDirectionImage: UIImageView!
    @IBOutlet weak var crossWindDirectionImage: UIImageView!
    @IBOutlet weak var windRunwayOffsetImage: UIImageView!
    
    var displayWindLabel : Bool = true
    var displayWindSpeed : Bool = true
    var displayWindComponent : Bool = true
    
    var displaySomething : Bool { return displayWindLabel || displayWindSpeed || displayWindComponent }
    
    var runwayWindModel : RunwayWindModel = RunwayWindModel(runway: Heading(roundedHeading: 240) )
    
    //MARK: - Synchronize

    func syncModelToView() {
        self.runwayTextField.text = self.runwayWindModel.runwayHeading.runwayDescription
        self.headingIndicatorView.model = self.runwayWindModel
        
        if displayWindLabel {
            self.windLabel.text = runwayWindModel.windDisplay
            self.windLabel.isHidden = false
            self.windRunwayOffsetLabel.text = runwayWindModel.windRunwayOffset.description
            self.windRunwayOffsetImage.image = runwayWindModel.crossWindDirection.image
        }else{
            self.windLabel.isHidden = true
        }
        if displayWindSpeed {
            self.crossWindSpeedLabel.text = runwayWindModel.crossWindSpeed.description
            self.headWindSpeedLabel.text = runwayWindModel.headWindSpeed.description
            self.headWindSpeedLabel.isHidden = false
            self.crossWindSpeedLabel.isHidden = false
        }else{
            self.headWindSpeedLabel.isHidden = true
            self.crossWindSpeedLabel.isHidden = true
        }
        if displayWindComponent {
            self.crossWindComponentLabel.text = runwayWindModel.crossWindComponent.description
            self.headWindComponentLabel.text = runwayWindModel.headWindComponent.description
            self.headWindComponentLabel.isHidden = false
            self.crossWindComponentLabel.isHidden = false

        }else{
            self.headWindComponentLabel.isHidden = true
            self.crossWindComponentLabel.isHidden = true
            
        }
        if displayWindComponent || displayWindSpeed {
            self.crossWindDirectionImage.image = runwayWindModel.crossWindDirection.image
            self.crossWindDirectionImage.isHidden = false
            self.headWindDirectionImage.isHidden = false

        }else{
            self.crossWindDirectionImage.isHidden = true
            self.headWindDirectionImage.isHidden = true
        }

    }

    func syncViewToModel() {
        if let runway  = self.runwayTextField.text {
            self.runwayWindModel.runwayHeading.runwayDescription = runway
        }
        
    }
        
    func clearAnalysisFromView() {
        
    }
    
    //MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncModelToView()
        // Do any additional setup after loading the view.
        self.headingIndicatorView.labelAttribute = [ .foregroundColor: UIColor.label]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.syncModelToView()
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
            self.syncModelToView()
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

