//
//  LocationViewController.swift
//  ElderlyCare
//
//  Created by Lu Yang on 3/11/19.
//  Copyright © 2019 Lu Yang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func copyAddressButton(_ sender: Any) {
        UIPasteboard.general.string = addressLabel.text
        showCopyDone()
    }
    
    func showCopyDone() {
        let alert = UIAlertController(title: "Done", message: "You have copied the address", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    @IBAction func NavigateButton(_ sender: Any) {
        guard userCurrentCoordinate != nil else {
            return
        }
        
        // Show Navigation
        let startingLocation = MKPlacemark(coordinate: userCurrentCoordinate!)
        let destinationLocation = MKPlacemark(coordinate: currentLocation.coordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        // Reset map
        mapView.removeOverlays(mapView.overlays)
        let _ = directionArray.map{ $0.cancel() }
        directionArray = []
        directionArray.append(directions)
        
        // Add to map
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else {
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    
    var listenerType = ListenerType.gps
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var databaseController: DatabaseProtocol?
    private let locationManager = CLLocationManager()
    var userCurrentCoordinate: CLLocationCoordinate2D?
    var directionArray: [MKDirections] = []
    
    // Initialize the device location at Flinder Street Station
    var currentLocation = LocationAnnotation(newTitle: "Device", lat: -37.8183, long: 144.9671)
    private var previousLocation = CLLocation(latitude: -37.8183, longitude: 144.9671)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        databaseController = appDelegate.databaseController
        
        mapView.delegate = self
        
        configureLocationServices()
        
        mapView.addAnnotation(currentLocation)
        focusOn(annotation: currentLocation)

    }
    
    private func configureLocationServices(){
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onGpsChange(change: DatabaseChange, gps: GPSLocation) {
        mapView.removeAnnotation(currentLocation)
        currentLocation.coordinate.latitude = gps.latitude!
        currentLocation.coordinate.longitude = gps.longitude!
        mapView.addAnnotation(currentLocation)
        focusOn(annotation: currentLocation)
        
//        rgbLabel.text = "R: \(currentRGB.r)    G: \(currentRGB.g)    B: \(currentRGB.b)"
//        colorBlock.backgroundColor = UIColor(red: CGFloat(currentRGB.r/255), green: CGFloat(currentRGB.g/255), blue: CGFloat(currentRGB.b/255), alpha: 1.0)
//        colorHexLabel.text = String(format: "#%02X%02X%02X", Int(rgb.r), Int(rgb.g), Int(rgb.b))
    }
    
    func onAlarmChange(change: DatabaseChange, alarm: [AlarmRecord]) {
        //
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            return
        }
        userCurrentCoordinate = latestLocation.coordinate
    }

}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let geoCoder = CLGeocoder()
        let current = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        guard current.distance(from: previousLocation) > 50 else {
            return
        }
        previousLocation = current
        
        geoCoder.reverseGeocodeLocation(current) { [weak self] (placemarks, error) in
            guard self != nil else {
                return
            }
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let code = placemark.postalCode ?? ""
            
            DispatchQueue.main.async {
                self!.addressLabel.text = "\(streetNumber) \(streetName), \(city), \(state) \(code)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}
