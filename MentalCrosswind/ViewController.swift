//
//  ViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var headingIndicatorView: HeadingIndicatorView!
    @IBOutlet weak var displayHideButton: UIButton!
    
    // Wind Compoent View
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var headWindSpeedLabel: UILabel!
    @IBOutlet weak var crossWindSpeedLabel: UILabel!
    @IBOutlet weak var windRunwayOffsetLabel: UILabel!
    @IBOutlet weak var headWindComponentLabel: UILabel!
    @IBOutlet weak var crossWindComponentLabel: UILabel!
    
    @IBOutlet weak var headWindDirectionImage: UIImageView!
    @IBOutlet weak var crossWindDirectionImage: UIImageView!

    @IBOutlet weak var windSourceLabel: UILabel!
    
    var displayWindLabel : Bool = true
    var displayWindSpeed : Bool = true
    var displayWindComponent : Bool = true
    
    var displaySomething : Bool { return displayWindLabel || displayWindSpeed || displayWindComponent }
    
    var runwayWindModel : RunwayWindModel = RunwayWindModel(runway: Heading(roundedHeading: 240) )
    
    //MARK: - Synchronize

    func syncModelToView() {
        self.headingIndicatorView.model = self.runwayWindModel
        
        if let windSource = self.runwayWindModel.windSource {
            self.windSourceLabel.text = windSource
            self.windSourceLabel.isEnabled = true
        }else{
            self.windSourceLabel.isEnabled = false
        }
        
        if displayWindLabel {
            self.windLabel.text = runwayWindModel.windDisplay
            self.windLabel.isHidden = false
            self.windSourceLabel.isHidden = false
        }else{
            self.windLabel.isHidden = true
            self.windSourceLabel.isHidden = true
        }
        if displayWindSpeed {
            self.crossWindSpeedLabel.text = runwayWindModel.crossWindSpeed.descriptionWithUnit
            self.headWindSpeedLabel.text = runwayWindModel.headWindSpeed.descriptionWithUnit
            self.headWindSpeedLabel.isHidden = false
            self.crossWindSpeedLabel.isHidden = false
        }else{
            self.headWindSpeedLabel.isHidden = true
            self.crossWindSpeedLabel.isHidden = true
        }
        if displayWindComponent {
            self.crossWindComponentLabel.text = runwayWindModel.crossWindComponent.description
            self.headWindComponentLabel.text = runwayWindModel.headWindComponent.description
            self.windRunwayOffsetLabel.text = runwayWindModel.windRunwayOffset.descriptionWithUnit
            self.headWindComponentLabel.isHidden = false
            self.crossWindComponentLabel.isHidden = false
            self.windRunwayOffsetLabel.isHidden = false

        }else{
            self.headWindComponentLabel.isHidden = true
            self.crossWindComponentLabel.isHidden = true
            self.windRunwayOffsetLabel.isHidden = true
        }
        if displayWindComponent || displayWindSpeed {
            self.crossWindDirectionImage.image = runwayWindModel.crossWindDirection.image
            self.headWindDirectionImage.image = runwayWindModel.directWindDirection.image
            self.crossWindDirectionImage.isHidden = false
            self.headWindDirectionImage.isHidden = false

        }else{
            self.crossWindDirectionImage.isHidden = true
            self.headWindDirectionImage.isHidden = true
        }
        self.headingIndicatorView.setNeedsDisplay()
    }

    func syncViewToModel() {
        
    }
        
    func clearAnalysisFromView() {
        self.displayWindLabel = false
        self.displayWindSpeed = false
        self.displayWindComponent = false
        self.headingIndicatorView.displayWind = .hidden
        self.headingIndicatorView.displayCrossWind = .hidden;
        self.displayHideButton.setTitle("Display", for: .normal)
        self.syncModelToView()
        self.view.setNeedsDisplay()
    }
    
    func refreshWindFromMetar(){
        if let icao = UserDefaults.standard.string(forKey: "default-airport-icao") {
            Metar.metar(icao: icao){ metar,icao in
                if let metar = metar {
                    self.runwayWindModel.setupFromMetar(metar: metar, icao: icao)
                    DispatchQueue.main.async {
                        self.syncModelToView()
                    }
                    
                }
            }
        }
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
        self.refreshWindFromMetar()
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
        
    //MARK: - Buttons
    
    
    @IBAction func refreshWindButton(_ sender: Any) {
        self.refreshWindFromMetar()
    }
    
    @IBAction func windCheckButton(_ sender: Any) {
        self.syncViewToModel()
                
        self.runwayWindModel.speak(which: .windcheck) {
        }
    }
    
    func startUpdateSequence() {
        
    }
    
    @IBAction func displayHideButton(_ sender: Any) {
        if displayWindSpeed {
            self.displayWindSpeed = false
            self.displayWindComponent = false
            self.displayWindLabel = false
            self.displayHideButton.setTitle("Display", for: .normal)
            self.headingIndicatorView.displayWind = .hidden
            self.headingIndicatorView.displayCrossWind = .hidden;

        }else{
            self.displayWindSpeed = true
            self.displayWindComponent = true
            self.displayWindLabel = true
            self.displayHideButton.setTitle("Hide", for: .normal)
            self.headingIndicatorView.displayWind = .wind
            self.headingIndicatorView.displayCrossWind = .speed
        }
        self.syncModelToView()
        self.view.setNeedsDisplay()
    }
    
    @IBAction func practiceButton(_ sender: Any) {
        self.runwayWindModel.randomizeWind()
        self.clearAnalysisFromView()
        self.runwayWindModel.speak() {
            self.startUpdateSequence()
        }

    }
    
}

