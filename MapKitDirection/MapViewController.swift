//
//  MapViewController.swift
//  MapKitDirection
//
//  Created by Simon Ng on 6/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    @IBAction func showDirection(sender: UIButton) {
        // - Unwrap currentPlacemark
        guard let currentPlacemark = currentPlacemark else { return }
        // - directionRequest
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.forCurrentLocation()
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(placemark: currentPlacemark))
        directionsRequest.transportType = .automobile
        // - MKDirections
        let directions = MKDirections(request: directionsRequest)
        // - .calculate()
        directions.calculate { (directionsResponse, error) in
            guard let directionsResponse = directionsResponse else {
                if let error = error {
                    print("Calculating directions Error: \(error)")
                }
                return
            }
            let route = directionsResponse.routes[0]
            // MARK: - self.mapView.add()
            // Auto-sizing
            let rect = route.polyline.boundingMapRect
            
            let shrunkRect = MKMapRect(origin: rect.origin, size: MKMapSize(width: rect.size.width * 1.5, height: rect.size.height * 1.5))
            self.mapView.setRegion(MKCoordinateRegionForMapRect(shrunkRect), animated: true)
            
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            // .aboveLabels: label above annotation
            // .aboveRoads: annotation above label
        }
        
    }
    
    let locationManager = CLLocationManager()
    
    var restaurant: Restaurant!
    var currentPlacemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Show Current location
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location, completionHandler: { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                self.currentPlacemark = placemark
            
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.restaurant.name
                annotation.subtitle = self.restaurant.type
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        })
        
        mapView.delegate = self
        if #available(iOS 9.0, *) {
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.showsTraffic = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.purple
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView: MKAnnotationView?
        
        if #available(iOS 11.0, *) {
            var markerAnnotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if markerAnnotationView == nil {
                markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                markerAnnotationView?.canShowCallout = true
            }
            
            markerAnnotationView?.glyphText = "😋"
            markerAnnotationView?.markerTintColor = UIColor.blue
        
            annotationView = markerAnnotationView
            
        } else {
            
            var pinAnnotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinAnnotationView?.canShowCallout = true
                pinAnnotationView?.pinTintColor = UIColor.orange
            }
            
            annotationView = pinAnnotationView
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
        leftIconView.image = UIImage(named: restaurant.image)
        annotationView?.leftCalloutAccessoryView = leftIconView
            
        return annotationView
    }
    
}
