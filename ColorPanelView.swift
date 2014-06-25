//
//  ColorPanelView.swift
//  TouchTracker
//
//  Created by adam on 6/24/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

protocol ColorPanelDelegate {
    
    var colorPanel: ColorPanelView? { get }
    var selectedColor: UIColor? { get }
    func changeColor(sender: UIButton)
}

import UIKit

class ColorPanelView: UIView {

    var delegate: AnyObject
    
    var selectedColor: UIColor?

    var lightBlueButton: UIButton!
    var blueGreenButton: UIButton!
    var greenButton: UIButton!
    var darkBlueButton: UIButton!
    var yellowButton: UIButton!
    var orangeButton: UIButton!
    var redButton: UIButton!
    var purpleButton: UIButton!
    
    init(frame: CGRect, delegate d: AnyObject) {
        delegate = d
        super.init(frame: frame)
        // Initialization code
        
        backgroundColor = UIColor.blackColor()
        
        let w = frame.width
        let h = frame.height
        let bsize = w / 4
        let bTopRowY = h - bsize * 2
        let bBottomRowY = h - bsize
        println(w)
        
        lightBlueButton = UIButton(frame: CGRectMake(0, 0, bsize, bsize))
        lightBlueButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        lightBlueButton.backgroundColor = UIColor.colorWithHexString("32C8F4")
        addSubview(lightBlueButton)
        
        blueGreenButton = UIButton(frame: CGRectMake(bsize, 0, bsize, bsize))
        blueGreenButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        blueGreenButton.backgroundColor = UIColor.colorWithHexString("00D7AA")
        addSubview(blueGreenButton)
        
        greenButton = UIButton(frame: CGRectMake(bsize * 2, 0, bsize, bsize))
        greenButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        greenButton.backgroundColor = UIColor.colorWithHexString("57E54E")
        addSubview(greenButton)
        
        darkBlueButton = UIButton(frame: CGRectMake(bsize * 3, 0, bsize, bsize))
        darkBlueButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        darkBlueButton.backgroundColor = UIColor.colorWithHexString("2C3E51")
        addSubview(darkBlueButton)
        
        yellowButton = UIButton(frame: CGRectMake(0, bsize, bsize, bsize))
        yellowButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        yellowButton.backgroundColor = UIColor.colorWithHexString("EAE10A")
        addSubview(yellowButton)
        
        orangeButton = UIButton(frame: CGRectMake(bsize, bsize, bsize, bsize))
        orangeButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        orangeButton.backgroundColor = UIColor.colorWithHexString("FF972D")
        addSubview(orangeButton)
        
        redButton = UIButton(frame: CGRectMake(bsize * 2, bsize, bsize, bsize))
        redButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        redButton.backgroundColor = UIColor.colorWithHexString("FF415E")
        addSubview(redButton)
        
        purpleButton = UIButton(frame: CGRectMake(bsize * 3, bsize, bsize, bsize))
        purpleButton.addTarget(delegate, action: "changeColor:", forControlEvents: UIControlEvents.TouchUpInside)
        purpleButton.backgroundColor = UIColor.colorWithHexString("BD10E0")
        addSubview(purpleButton)
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}

/*
extension UIButton {
    
    var color: Color {
    get {
        return self.color
    }
    set {
        self.color = newValue
    }
    }
    
    enum Color {
        case LightBlue
        case BlueGreen
        case Green
        case DarkBlue
        case Purple
        case Yellow
        case Red
        case Orange
    }
}
*/