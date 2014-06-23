//
//  DrawViewController.swift
//  TouchTracker
//
//  Created by adam on 6/23/14.
//  Copyright (c) 2014 Adam Schoonmaker. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
   
    override func loadView() {
        println("DrawViewController: loadView")
        super.loadView()
        view = DrawView(frame: CGRectZero)
    }
}
