//
//  ViewController.swift
//  WhaleKiller
//
//  Created by Dan Morton on 7/11/15.
//  Copyright (c) 2015 Dan Morton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let blockSideLength = CGFloat(40)
    let fingerBlockSideLength = CGFloat(20)
    
    var blockView : UIView!
    var fingerView : UIView!
    
    var dynamicAnimator : UIDynamicAnimator!
    
    //setup UIDynamics and collision behaviors
    override func viewDidLoad() {
        super.viewDidLoad()
        spawnBlock()
        spawnFingerBlock()
        setupDynamicAnimator()
    }
    
    func spawnBlock(){
        let xCenter = CGFloat((self.view.frame.width / 2))
        let yCenter = CGFloat((self.view.frame.height / 2))
        
        blockView = UIView(frame: CGRectMake(xCenter, yCenter, blockSideLength, blockSideLength))
        blockView.backgroundColor = UIColor.redColor()
        self.view.addSubview(blockView)
    }
    
    func spawnFingerBlock(){
        fingerView = UIView(frame: CGRectMake(10.0, 10.0, fingerBlockSideLength, fingerBlockSideLength))
        fingerView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(fingerView)
    }
    
    func setupDynamicAnimator(){
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        let blockPushBehavior = UIPushBehavior(items: [blockView], mode: UIPushBehaviorMode.Instantaneous)
        blockPushBehavior.magnitude = 0.25
        blockPushBehavior.angle = 0.90
        
        let blockDynamicBehavior = UIDynamicItemBehavior(items: [blockView])
        blockDynamicBehavior.elasticity = 1.0
        blockDynamicBehavior.resistance = 0.0
        blockDynamicBehavior.friction = 0.0
        
        
        let collisionBehavior = UICollisionBehavior(items: [blockView])
        collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        dynamicAnimator.addBehavior(blockPushBehavior)
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(blockDynamicBehavior)
        
    }
    
    @IBAction func userPanned(sender: AnyObject) {
        let panGesture = sender as! UIPanGestureRecognizer
        let coordinate = panGesture.locationInView(self.view)
        let xCoord = (coordinate.x) - (fingerBlockSideLength / 2)
        let yCoord = (coordinate.y) - (fingerBlockSideLength / 2)
        
        fingerView.frame = CGRectMake(xCoord, yCoord, fingerBlockSideLength, fingerBlockSideLength)
        
    }
}

