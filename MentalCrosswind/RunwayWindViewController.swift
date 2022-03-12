//
//  ViewController.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit
import CoreLocation
import OSLog

extension Notification {
    static let SettingsChangedNotificationName  = Notification.Name(rawValue: "SettingsChangedNotification")
}

class RunwayWindViewController: UIViewController {
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
    
    private let locationManager = CLLocationManager()
    private var locationCallback : ((_ : CLLocationCoordinate2D?) -> Void)? = nil
    
    //MARK: - Synchronize

    func syncModelToView() {
        self.headingIndicatorView.model = self.runwayWindModel
        
        if let windSource = self.runwayWindModel.windSource {
            var sourceText = windSource
            if let windSourceDate = self.runwayWindModel.windSourceDate {
                let ageInMinutes = Int(Date().timeIntervalSince1970 - windSourceDate.timeIntervalSince1970) / 60
                // < 0 disable for now, as not updating in realtime
                if ageInMinutes < 60 {
                    self.startUpdateTimer()
                    sourceText = sourceText + " (\(ageInMinutes)m)"
                }else{
                    self.stopUpdateTimer()
                    sourceText = sourceText + " (old)"
                }
            }
            
            self.windSourceLabel.text = sourceText
            self.windSourceLabel.isEnabled = true
        }else{
            self.windSourceLabel.text = Settings.shared.airportIcao
            self.windSourceLabel.isEnabled = false
        }
        
        if displayWindLabel {
            self.windLabel.text = runwayWindModel.windDisplay
            self.windLabel.isHidden = false
            self.windSourceLabel.isHidden = false
        }else{
            self.windLabel.isHidden = true
            self.windSourceLabel.isHidden = false
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
        
    func syncSettingsToView() {
        
        if Settings.shared.analysisIsDisplayed {
            self.displayWindSpeed = true
            self.displayWindComponent = true
            self.displayWindLabel = true
            self.displayHideButton.setTitle("Hide", for: .normal)
            self.headingIndicatorView.displayWind = .wind
            self.headingIndicatorView.displayCrossWind = .speed

        }else{
            self.displayWindSpeed = false
            self.displayWindComponent = false
            self.displayWindLabel = false
            self.displayHideButton.setTitle("Display", for: .normal)
            self.headingIndicatorView.displayWind = .hidden
            self.headingIndicatorView.displayCrossWind = .hidden;
        }
    }
    
    func clearAnalysisFromView() {
        Settings.shared.analysisIsDisplayed = false
        self.syncSettingsToView()
        self.syncModelToView()
        self.view.setNeedsDisplay()
    }
    
    func refreshModel(airport : Airport){
        Metar.metar(icao: airport.icao){ metar,icao in
            if let metar = metar {
                self.runwayWindModel.setupFrom(metar: metar, icao: icao)
                self.runwayWindModel.updateRunwayHeading(heading: airport.bestRunway(wind: self.runwayWindModel.windHeading))
                DispatchQueue.main.async {
                    self.syncModelToView()
                }
            }
        }
    }
    
    func refreshWindFromMetar(){
        if Settings.shared.updateMethod == .custom {
            let icao = Settings.shared.airportIcao
            Airport.at(icao: icao){ airport in
                if let airport = airport {
                    self.refreshModel(airport: airport)
                }
            }
        }else if Settings.shared.updateMethod == .nearest {
            self.startTracking() { coord in
                if let coord = coord {
                    Airport.near(coord: coord){ airports in
                        Settings.shared.lastNearestList = airports.map{ $0.icao }
                        
                        if let first = airports.first {
                            self.refreshModel(airport: first)
                        }
                    }
                }
            }
        }
    }
    
    func updateFromSettings(){
        self.runwayWindModel.updateFromSettings()
        self.syncSettingsToView()
    }
    
    func saveToSettings(){
        self.runwayWindModel.saveToSettings()

    }
    
    //MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.headingIndicatorView.labelAttribute = [ .foregroundColor: UIColor.label]

        // on load update starting display if necessary
        switch Settings.shared.startingMode {
        case .analysis:
            Settings.shared.analysisIsDisplayed = true
        case .practice:
            Settings.shared.analysisIsDisplayed = false
        case .last:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateFromSettings()
        self.syncModelToView()
        self.refreshWindFromMetar()
        NotificationCenter.default.addObserver(forName: Notification.BackgroundNotificationName, object: nil, queue: nil) { _ in
            self.runwayWindModel.saveToSettings()
        }
        NotificationCenter.default.addObserver(forName: Notification.SettingsChangedNotificationName, object: nil, queue: nil) {
            _ in
            DispatchQueue.main.async {
                self.updateFromSettings()
                self.syncModelToView()
                self.refreshWindFromMetar()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.saveToSettings()
        self.stopUpdateTimer()
        NotificationCenter.default.removeObserver(self)
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
        let distanceTo = center.distance(to: location)
        
        //let coord = CGPoint(x: location.x - center.x, y: location.y - center.y)
        //print( "Loc: \(location) coord: \(coord) angle: \(angleTo) to: \(location.distance(to: center)) " )

        if distanceTo < self.headingIndicatorView.geometry.runwayTargetLength {
            self.runwayWindModel.opposingRunway()
        }else{
            self.runwayWindModel.runwayHeading = Heading(heading: angleTo)
        }
        self.syncModelToView()
        
    }
    
    @IBAction func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        
    }
        
    //MARK: - Buttons and sequences
    
    
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
        Logger.app.info("Toggled DisplayHide by button")
        Settings.shared.analysisIsDisplayed.toggle()
        self.syncSettingsToView()
        self.syncModelToView()
        self.saveToSettings()
        self.view.setNeedsDisplay()
    }
    
    @IBAction func practiceButton(_ sender: Any) {
        self.runwayWindModel.randomizeWind()
        self.clearAnalysisFromView()
        self.runwayWindModel.speak() {
            self.startUpdateSequence()
        }
    }
    
    weak var timer : Timer? = nil
    
    func startUpdateTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true){
            [weak self] _ in
            // will force redraw, and update time
            self?.syncModelToView()
        }
    }
    
    func stopUpdateTimer() {
        timer?.invalidate()
    }
}


extension RunwayWindViewController : CLLocationManagerDelegate {
    func startTracking(callback : @escaping (_ : CLLocationCoordinate2D?) -> Void) {
        locationManager.delegate = self
        self.locationCallback = callback
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced;
        locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        if let cb = self.locationCallback {
            cb(first.coordinate)
            self.locationCallback = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.app.error("failed to locate \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            Logger.app.info("Authorization always")
        case .authorizedWhenInUse:
            Logger.app.info("Authorization wheninused")
        case .denied, .restricted:
            Logger.app.info("Authorization changed denied/restricted")
        case .notDetermined:
            Logger.app.info("Authorization changed notDetermined")
        default:
            Logger.app.info("Authorization changed default")
        }
        
    }

    
}
