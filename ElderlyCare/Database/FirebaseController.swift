//
//  FirebaseController.swift
//  ElderlyCare
//
//  Created by Lu Yang on 3/11/19.
//  Copyright © 2019 Lu Yang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    
    var gpsRef: CollectionReference?
    var alarmRef: CollectionReference?
    
    var currentGps = GPSLocation()
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
        
        authController.signInAnonymously { (authResult, error) in
            guard authResult != nil else{
                fatalError("Firebase authentication failed")
            }
            
            self.setUpListeners()
        }
    }
    
    func setUpListeners(){
//        docRef = database.collection("RGB")
        
        database.collection("GPS").limit(to: 1)
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
            print("Error fetching document: \(error!)")
            return
          }
            guard let data = documents.first?.data() else {
            print("Document data was empty.")
            return
          }
            print("Current data: \(data)")
            self.currentGps.latitude = documents.first!.data()["latitude"] as? Double
            self.currentGps.longitude = documents.first!.data()["longitude"] as? Double
//            self.currentRGB.g = documents.first!.data()["G"] as! Double
//            self.currentRGB.b = documents.first!.data()["B"] as! Double
//            self.currentRGB.r = documents.first!.data()["R"] as! Double
//            self.currentPresseure = documents.first!.data()["Pressure"] as! Double
//            self.currentTemperatureC = documents.first!.data()["TempC"] as! Double
//            self.currentTemperatureF = documents.first!.data()["TempF"] as! Double
//            self.currentAltitude = documents.first!.data()["Altitude"] as! Double
            
            
//            print("Current RGB: \(self.currentRGB.r) \(self.currentRGB.g) \(self.currentRGB.b)")
            
            self.listeners.invoke { (listener) in
                
                if(listener.listenerType == ListenerType.gps){
                    listener.onGpsChange(change: .update, gps: self.currentGps)
                }
                
//                if(listener.listenerType == ListenerType.color){
//                    listener.onColorChange(change: .update, rgb: self.currentRGB)
//                }

            }
            
        }
        
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.gps{
            listener.onGpsChange(change: .update, gps: currentGps)
        }
        
//        if listener.listenerType == ListenerType.color {
//            listener.onColorChange(change: .update, rgb: currentRGB)
//        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    


}
