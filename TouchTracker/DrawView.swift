//
//  DrawView.swift
//  TouchTracker
//
//  Created by adam on 6/23/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

import UIKit

class DrawView: UIView {
   
    var linesInProgress: Dictionary<NSValue, Line> = Dictionary()
    var finishedLines: Array<Line> = Line[]()
    var circlesInProgress: Dictionary<NSValue, (NSValue, CGRect)> = Dictionary()
    var finishedCircles: Array<CGRect> = CGRect[]()
    
    init(frame: CGRect) {
        println("DrawView: init")
        super.init(frame: frame)
        backgroundColor = UIColor.grayColor()
        multipleTouchEnabled = true
    }
    
    func strokeLine(line: Line) {
        println("DrawView: strokeLine")
        let bp = UIBezierPath()
        bp.lineWidth = 10
        bp.lineCapStyle = kCGLineCapRound
        
        bp.moveToPoint(line.begin)
        bp.addLineToPoint(line.end)
        bp.stroke()
    }
    
    func strokeCircle(circleRect: CGRect) {
        println("DrawView: strokeCircle")
        let bp = UIBezierPath()
        bp.lineWidth = 10
        bp.lineCapStyle = kCGLineCapRound
        
        let circleRadius = CGFloat(hypot(CDouble(circleRect.size.width), CDouble(circleRect.size.height)) / CDouble(2.0))
        let circleCenter = CGPoint(x: CGRectGetMidX(circleRect), y: CGRectGetMidY(circleRect))
        
        bp.moveToPoint(CGPointMake(circleCenter.x + circleRadius, circleCenter.y))
        bp.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        println("drawing circle... x:\(circleCenter.x)   y:\(circleCenter.y)   radius:\(circleRadius)")
        bp.stroke()
    }
    
    override func drawRect(rect: CGRect) {
        println("DrawView: drawRect")
       
        UIColor.blackColor().set()
        for circle in finishedCircles {
            strokeCircle(circle)
        }
        
        // Draw finished lines in the color based on their angle (defaults to black)
        for line in finishedLines {
            line.color.set()
            strokeLine(line)
        }
        
        UIColor.redColor().set()
        // Draw circles in progress in red
        for tuple in circlesInProgress.values {
            strokeCircle(tuple.1)
        }
        
        // Draw lines in progress in red
        for line in linesInProgress.values {
            strokeLine(line)
        }
    }
}

extension DrawView {
    // MARK: touch events

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        println("DrawView: touchesBegan")
        
        // If there are two active touches, draw a circle. Otherwise draw a line
        if event.touchesForView(self).count == 2 {
            let touchesArray = event.touchesForView(self).allObjects as UITouch[]
            
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            let t1Point = touch1.locationInView(self)
            let t2Point = touch2.locationInView(self)
            
            let circleRectSize = CGSizeMake(abs(t2Point.x - t1Point.x), abs(t2Point.y - t1Point.y))
            println("width:\(circleRectSize.width)   height:\(circleRectSize.height)")
            let circleRect = CGRect(origin: t1Point, size: circleRectSize)
            
            let key = NSValue(nonretainedObject: touch1)
            let touch2Value = NSValue(nonretainedObject: touch2)
            
            circlesInProgress[key] = (touch2Value, circleRect)
            
            // Sometimes before the second touch in the view is recognized a 
            // line would be added to linesInProgress; make sure that touch is
            // removed
            linesInProgress.removeValueForKey(key)
            linesInProgress.removeValueForKey(touch2Value)
            
        } else if event.touchesForView(self).count == 1 {
            // It's possible that more than one touch can begin at the same time,
            // although typically touches begin at different times and the DrawView
            // will get multiple touchesBegan:withEvent: messages
            for touch in touches.allObjects as UITouch[] {
                let location = touch.locationInView(self)
                
                let line = Line()
                line.begin = location
                line.end = location
                
                let key = NSValue(nonretainedObject: touch)
                linesInProgress[key] = line
            }
        }
        
        // Marks the receiver’s entire bounds rectangle as needing to be redrawn.
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        println("DrawView: touchesMoved")
        
        // If there are two active touches, draw a circle. Otherwise draw a line
        if event.touchesForView(self).count == 2 {
            let touchesArray = event.touchesForView(self).allObjects as UITouch[]
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            let t1Point = touch1.locationInView(self)
            let t2Point = touch2.locationInView(self)
            
            let circleRectSize = CGSizeMake(abs(t2Point.x - t1Point.x), abs(t2Point.y - t1Point.y))
            println("width:\(circleRectSize.width)   height:\(circleRectSize.height)")
            let circleRect = CGRect(origin: t1Point, size: circleRectSize)
            
            let touch1Key = NSValue(nonretainedObject: touch1)
            let touch2Key = NSValue(nonretainedObject: touch2)
            
            if circlesInProgress[touch1Key] {
                circlesInProgress[touch1Key] = (touch2Key, circleRect)
            } else if circlesInProgress[touch2Key] {
                circlesInProgress[touch2Key] = (touch1Key, circleRect)
            }
            
        } else if event.touchesForView(self).count == 1 {
            
            for touch in touches.allObjects as UITouch[] {
                let key = NSValue(nonretainedObject: touch)
                let line = linesInProgress[key]
                
                if line { line!.end = touch.locationInView(self) }
            }
        }

        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        println("DrawView: touchesEnded")
        
        // If there are two active touches, draw a circle. Otherwise draw a line
        if event.touchesForView(self).count == 2 {
            let touchesArray = event.touchesForView(self).allObjects as UITouch[]
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            
            let touch1Key = NSValue(nonretainedObject: touch1)
            let touch2Key = NSValue(nonretainedObject: touch2)
            
            if circlesInProgress[touch1Key] {
                finishedCircles.append(circlesInProgress[touch1Key]!.1)
                circlesInProgress.removeValueForKey(touch1Key)
            } else if circlesInProgress[touch2Key] {
                finishedCircles.append(circlesInProgress[touch2Key]!.1)
                circlesInProgress.removeValueForKey(touch2Key)
            }
            
        } else if event.touchesForView(self).count == 1 {
            
            for touch in touches.allObjects as UITouch[] {
                let key = NSValue(nonretainedObject: touch)
                let line = linesInProgress[key]
                
                if line {
                    finishedLines.append(line!)
                    linesInProgress.removeValueForKey(key)
                }
            }
        }
        
        setNeedsDisplay()
    }
    
    // Any state a touch set before being cancelled should be reverted
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        println("DrawView: touchesCancelled")
        
        for touch in touches.allObjects as UITouch[] {
            let key = NSValue(nonretainedObject: touch)
            linesInProgress.removeValueForKey(key)
            circlesInProgress.removeValueForKey(key)
        }
        
        setNeedsDisplay()
    }
}

