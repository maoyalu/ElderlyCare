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
    var alarms: [AlarmRecord]
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        alarms = [AlarmRecord]()
        
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
            
            self.listeners.invoke { (listener) in
                
                if(listener.listenerType == ListenerType.gps){
                    listener.onGpsChange(change: .update, gps: self.currentGps)
                }
                
//                if(listener.listenerType == ListenerType.color){
//                    listener.onColorChange(change: .update, rgb: self.currentRGB)
//                }

            }
            
        }
        
//        database.collection("Falling").addSnapshotListener { (querySnapshot, error) in
//            <#code#>
//        }
        
        alarmRef = database.collection("Falling")
        alarmRef?.addSnapshotListener({ (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseAlarmsSnapshot(snapshot: querySnapshot!)
        })
        
    }
    
    func parseAlarmsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            let documentRef = change.document.documentID
            let userid = change.document.data()["userid"] as! Int
            let time = change.document.data()["time"] as! Timestamp
            print(documentRef)
            
            if change.type == .added {
                print("New alarm: \(change.document.data())")
                let newAlarm = AlarmRecord()
                newAlarm.userid = userid
                newAlarm.time = time.dateValue()
                newAlarm.id = documentRef
                
                alarms.append(newAlarm)
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.alarm {
                listener.onAlarmChange(change: .update, alarm: alarms)
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.gps{
            listener.onGpsChange(change: .update, gps: currentGps)
        }
        
        if listener.listenerType == ListenerType.alarm {
            listener.onAlarmChange(change: .update, alarm: alarms)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    


}
