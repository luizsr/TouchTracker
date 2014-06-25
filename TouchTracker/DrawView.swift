//
//  DrawView.swift
//  TouchTracker
//
//  Created by adam on 6/23/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var colorPanel: ColorPanelView?
    var selectedColor: UIColor?
    var moveRecognizer = UIPanGestureRecognizer()
    var linesInProgress: Dictionary<NSValue, Line> = Dictionary()
    var finishedLines: Array<Line> = Line[]()
    var circlesInProgress: Dictionary<NSValue, (NSValue, CGRect)> = Dictionary()
    var finishedCircles: Array<CGRect> = CGRect[]()
    weak var selectedLine: Line?
    
    init(frame: CGRect) {
        println("DrawView: init")
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        multipleTouchEnabled = true
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        // Stops from drawing a line/circle on accident
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        // Stops from drawing a line/circle on accident
        tapRecognizer.delaysTouchesBegan = true
        // tapRecognizer must wait for Double Tap recognizer to fail before it can
        // assume that a single tap isn't just the first of a double tap
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer) //
        addGestureRecognizer(tapRecognizer)
        
        // By default a touch must be held for 0.5 seconds to be a long press
        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        addGestureRecognizer(pressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: "moveLine:")
        moveRecognizer.delegate = self
        // Makes it so users can still draw lines
        // The gesture that the pan recognizer recognizes is the same kind of touch
        // that the view handles to draw lines using the UIResponder methods. When
        // the below is set to "false", touches the gesture recognizer recognizes
        // also get delivered to the view via the UIResponder methods, allowing
        // the lines to still be drawn
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
        
        let tripleSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "tripleSwipe:")
        tripleSwipeRecognizer.numberOfTouchesRequired = 3
        tripleSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        addGestureRecognizer(tripleSwipeRecognizer)
    }
    
    
    
    // Custom view classes that need to become the first responder must override
    // this method
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func strokeLine(line: Line) {
        //println("DrawView: strokeLine")
        let bp = UIBezierPath()
        bp.lineWidth = CGFloat(line.thickness)
        //println("drawing line with thickness:\(line.thickness)")
        bp.lineCapStyle = kCGLineCapRound
        
        bp.moveToPoint(line.begin)
        bp.addLineToPoint(line.end)
        bp.stroke()
    }
    
    func strokeCircle(circleRect: CGRect) {
        //println("DrawView: strokeCircle")
        let bp = UIBezierPath()
        bp.lineWidth = 10
        bp.lineCapStyle = kCGLineCapRound
        
        let circleRadius = CGFloat(hypot(CDouble(circleRect.size.width), CDouble(circleRect.size.height)) / CDouble(2.0))
        let circleCenter = CGPoint(x: CGRectGetMidX(circleRect), y: CGRectGetMidY(circleRect))
        
        bp.moveToPoint(CGPointMake(circleCenter.x + circleRadius, circleCenter.y))
        bp.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        //println("drawing circle... x:\(circleCenter.x)   y:\(circleCenter.y)   radius:\(circleRadius)")
        bp.stroke()
    }
    
    func lineAtPoint(p: CGPoint) -> Line? {
        // Find a line close to p
        for line in finishedLines {
            let start = line.begin
            let end = line.end
            
            // Check a few points on the line
            for var t: CGFloat = 0.0; t <= 1.0; t += 0.05 {
                let x = start.x + t * (end.x - start.x)
                let y = start.y + t * (end.y - start.y)
                
                // If the tapped point is within 20 points, return this line
                let distance = Double(hypot(CDouble(x) - CDouble(p.x), CDouble(y) - CDouble(p.y)))
                if (distance < 20.0) {
                    println("DrawView: found a line to select")
                    return line
                }
            }
        }
        // If nothing is close enough to the tapped point, then no line was selected
        return nil
    }
    
    func moveLine(gr: UIPanGestureRecognizer) {
        // If a line isn't selected or the menu is visible, don't do anything here
        if !selectedLine || UIMenuController.sharedMenuController().menuVisible == true {
            return
        }
        
        // When the pan recognizer changes its position...
        if gr.state == UIGestureRecognizerState.Changed {
            // How far has the pan moved?
            let translation = gr.translationInView(self)
            
            // Add the translation to the current beginning and end points of the line
            var begin = selectedLine!.begin
            var end = selectedLine!.end
            begin.x += translation.x
            begin.y += translation.y
            end.x += translation.x
            end.y += translation.y
            
            // Set the new beginning and end points of the line
            selectedLine!.begin = begin
            selectedLine!.end = end
            
            // Redraw the screen
            setNeedsDisplay()
            
            // Set the translation back to the zero point after every time it reports a change
            // Stops the line from being moved WAY to far
            gr.setTranslation(CGPointZero, inView: self)
        }
    }
    
    func deleteLine(sender: AnyObject) {
        println("DrawView: deleteLine")
        // Remove the selected line from the list of finishedLines
        finishedLines.removeAtIndex(finishedLines.indexOf(object: selectedLine!))
        selectedLine = nil
        // Redraw everything
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        //println("DrawView: drawRect")
       
        UIColor.blackColor().set()
        for circle in finishedCircles {
            strokeCircle(circle)
        }
        
        // If the Draw finished lines in the color based on their angle (defaults to black)
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
        
        // The selected line will be in Cyan
        if selectedLine {
            UIColor.cyanColor().set()
            strokeLine(selectedLine!)
        }
    }
}


extension DrawView {
    // MARK: gesture events
    
    func tripleSwipe(gr: UISwipeGestureRecognizer) {
        println("Draw View: recognized triple swipe up")
        
        let w = bounds.width
        let h = bounds.height
        let cpWidth = w
        let cpHeight = w / 2
        let cpOriginX = 0
        let cpOriginY = h - cpHeight
        
        let cpOffScreenFrame = CGRectMake(0, h, cpWidth, cpHeight)
        let cpOnScreenFrame = CGRectMake(0, cpOriginY, cpWidth, cpHeight)
        
        colorPanel = ColorPanelView(frame: cpOffScreenFrame, delegate: self)
        addSubview(colorPanel)
        
        weak var cp = colorPanel
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { cp!.frame = cpOnScreenFrame }, completion: nil)
    }
    
    func tap(gr: UIGestureRecognizer) {
        println("Draw View: Recognized Tap")
        
        // If the color panel is here, get rid of it and then do nothing
        if colorPanel {
            let w = bounds.width
            let h = bounds.height
            let cpWidth = w
            let cpHeight = w / 2
            let cpOffScreenFrame = CGRectMake(0, h, cpWidth, cpHeight)
            
            weak var cp = colorPanel
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { cp!.frame = cpOffScreenFrame }, completion: nil)

            delayOnMainQueueFor(numberOfSeconds: 0.5, action: {
                cp!.removeFromSuperview()
            })
            colorPanel = nil
            return
        }
        
        // Try finding a line near the point that was tapped. An optional Line
        // value will be returned to selectedLine, which drawInRect will draw
        // in Cyan if a line (and not nil) is returned
        let point = gr.locationInView(self)
        selectedLine = lineAtPoint(point)
        
        if selectedLine {
            // Make this view the target of menu item action messages
            becomeFirstResponder()
            
            // Grab the menu controller
            let menu = UIMenuController.sharedMenuController()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: "deleteLine:")
            
            menu.menuItems = [deleteItem]
            
            // Tell the menu where it should come from and show it
            menu.setTargetRect(CGRectMake(point.x, point.y, 2, 2), inView: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            // Hide the menu if no line is selected
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    func doubleTap(gr: UIGestureRecognizer) {
        println("DrawView: Recognized Double Tap")
        linesInProgress.removeAll(keepCapacity: false)
        circlesInProgress.removeAll(keepCapacity: false)
        finishedLines.removeAll(keepCapacity: false)
        finishedCircles.removeAll(keepCapacity: false)
        setNeedsDisplay()
    }
    
    func longPress(gr: UIGestureRecognizer) {
        if gr.state == UIGestureRecognizerState.Began {
            println("DrawView: longPress has begun")
            let point = gr.locationInView(self)
            selectedLine = lineAtPoint(point)
            
            if selectedLine {
                linesInProgress.removeAll(keepCapacity: false)
            }
        } else if gr.state == UIGestureRecognizerState.Ended {
            println("DrawView: longPress has ended")
            selectedLine = nil
        }
        
        setNeedsDisplay()
    }
}


extension DrawView: UIGestureRecognizerDelegate {
    
    // called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
    // return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        // When the user begins a long press, the UIPanGestureRecognizer will be allowed to
        // keep track of that touch/finger too
        // Allows the pan recognizer to transition to its Begin state, rather than
        // never hetting there because of the long press recognizer starting
        if gestureRecognizer == moveRecognizer {
            return true
        }
        return false
    }
}


extension DrawView {
    // MARK: touch events

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        println("DrawView: touchesBegan")
        
        /*
        // If the color panel is here, get rid of it
        if colorPanel {
            let w = bounds.width
            let h = bounds.height
            let cpWidth = w
            let cpHeight = w / 2
            let cpOffScreenFrame = CGRectMake(0, h, cpWidth, cpHeight)
            
            weak var cp = colorPanel
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { cp!.frame = cpOffScreenFrame }, completion: nil)
            
            delayOnMainQueueFor(numberOfSeconds: 0.5, action: {
                cp!.removeFromSuperview()
                })
            colorPanel = nil
        }
        */
        
        // If the menu is visible, don't do anything here
        if UIMenuController.sharedMenuController().menuVisible == true {
            return
        }
        
        // If there are two active touches, draw a circle. Otherwise draw a line
        if event.touchesForView(self).count == 2 {
            println("DrawView: Recognized two active touches; start a Circle")
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
            println("DrawView: Recognized one active touch; start a Line")
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
        //println("DrawView: touchesMoved")
        
        // If there are two active touches, draw a circle. Otherwise draw a line
        if event.touchesForView(self).count == 2 {
            let touchesArray = event.touchesForView(self).allObjects as UITouch[]
            let touch1 = touchesArray[0]
            let touch2 = touchesArray[1]
            let t1Point = touch1.locationInView(self)
            let t2Point = touch2.locationInView(self)
            
            let circleRectSize = CGSizeMake(abs(t2Point.x - t1Point.x), abs(t2Point.y - t1Point.y))
            //println("width:\(circleRectSize.width)   height:\(circleRectSize.height)")
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
                
                if line {
                    let vVector = moveRecognizer.velocityInView(self)
                    let velocitySquared = (vVector.x * vVector.x) + (vVector.y * vVector.y)
                    let velocity = sqrt(CDouble(velocitySquared))
                    //println(velocity)
                    line!.setThicknessFromVelocity(velocity)
                    //println("line thickness:\(line!.thickness)")
                    
                    line!.end = touch.locationInView(self)
                }
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
                    if selectedColor {
                        line!.color = selectedColor
                    } else {
                        line!.setColorFromAngle()
                    }
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


extension DrawView: ColorPanelDelegate {
    
    func changeColor(sender: UIButton) {
        println("DrawView: Change color")
        selectedColor = sender.backgroundColor
    }
}

