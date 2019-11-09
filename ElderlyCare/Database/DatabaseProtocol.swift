//
//  DatabaseProtocol.swift
//  ElderlyCare
//
//  Created by Lu Yang on 3/11/19.
//  Copyright © 2019 Lu Yang. All rights reserved.
//

import Foundation

enum DatabaseChange{
    case add
    case update
}

enum ListenerType{
    case alarm
    case gps
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType{get set}
    func onGpsChange(change: DatabaseChange, gps: GPSLocation)
    func onAlarmChange(change: DatabaseChange, alarm: [AlarmRecord])
}
