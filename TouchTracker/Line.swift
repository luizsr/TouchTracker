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
    
    // Silver Challenge fxns
    var angleInDegrees: Double {
        // returns the line's bearing from 0-360 degrees
        let radianBearing = CDouble(atan2f(end.y - begin.y, end.x - begin.x))
        var degreeBearing = radianBearing * (CDouble(180.0) / M_PI)
        degreeBearing = (degreeBearing > 0.0 ? degreeBearing : (360.0 + degreeBearing))
        return Double(degreeBearing)
    }
    var color: UIColor {
        switch angleInDegrees {
        case 0..60:
            return UIColor.greenColor()
        case 60..120:
            return UIColor.blueColor()
        case 120..180:
            return UIColor.purpleColor()
        case 180..240:
            return UIColor.orangeColor()
        case 240..300:
            return UIColor.yellowColor()
        case 300...360:
            return UIColor.brownColor()
        default:
            return UIColor.blackColor()
        }
    }
}
