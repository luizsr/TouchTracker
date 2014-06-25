//
//  Line.swift
//  TouchTracker
//
//  Created by adam on 6/23/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

import UIKit

class Line: NSObject {
   
    var begin: CGPoint = CGPoint()
    var end: CGPoint = CGPoint()
    var thickness = 10.0
    var color = UIColor.blackColor()
    
    // Silver Challenge fxns
    var angleInDegrees: Double {
        // returns the line's bearing from 0-360 degrees
        let radianBearing = CDouble(atan2(Double(end.y) - Double(begin.y), Double(end.x) - Double(begin.x)))
        var degreeBearing = radianBearing * (CDouble(180.0) / M_PI)
        degreeBearing = (degreeBearing > 0.0 ? degreeBearing : (360.0 + degreeBearing))
        return Double(degreeBearing)
    }
    func setColorFromAngle() {
        switch angleInDegrees {
        case 0..60:
            color = UIColor.greenColor()
        case 60..120:
            color = UIColor.blueColor()
        case 120..180:
            color = UIColor.purpleColor()
        case 180..240:
            color = UIColor.orangeColor()
        case 240..300:
            color = UIColor.yellowColor()
        case 300...360:
            color = UIColor.brownColor()
        default:
            color = UIColor.blackColor()
        }
    }
    
    // Gold challenge from chapter 13
    func setThicknessFromVelocity(velocity: Double) {
        switch velocity {
        case let v where v > 2000:
            thickness = 1.0
        case let v where v > 1500:
            thickness = 2.0
        case let v where v > 1000:
            thickness = 3.0
        case let v where v > 800:
            thickness = 4.0
        case let v where v > 600:
            thickness = 5.0
        case let v where v > 400:
            thickness = 6.0
        case let v where v > 200:
            thickness = 7.0
        case let v where v > 100:
            thickness = 8.0
        case let v where v > 50:
            thickness = 9.0
        default:
            thickness = 10.0
        }
    }
    
}
