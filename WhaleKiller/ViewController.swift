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
    
    var cornerViews = [UIView]()
    
    
    //setup UIDynamics and collision behaviors
    override func viewDidLoad() {
        super.viewDidLoad()
        spawnBlock()
        spawnFingerBlock()
        setupDynamicAnimator()
        setUpCornerViews()
        
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
        blockPushBehavior.magnitude = 0.30
        blockPushBehavior.angle = 0.90
        
        let blockDynamicBehavior = UIDynamicItemBehavior(items: [blockView])
        blockDynamicBehavior.elasticity = 1.0
        blockDynamicBehavior.resistance = 0.0
        blockDynamicBehavior.friction = 0.0
        
        let fingerDynamicBehavior = UIDynamicItemBehavior(items: [fingerView])
        fingerDynamicBehavior.allowsRotation = false
        fingerDynamicBehavior.density = 100000
        fingerDynamicBehavior.resistance = 0.0
        fingerDynamicBehavior.friction = 0.0
        
        
        let collisionBehavior = UICollisionBehavior(items: [blockView, fingerView])
        collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        dynamicAnimator.addBehavior(blockPushBehavior)
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(blockDynamicBehavior)
        dynamicAnimator.addBehavior(fingerDynamicBehavior)
        
    }
    
    func setUpCornerViews(){
        
        let screenOrigin = self.view.frame.origin
        
        let xOrigin = screenOrigin.x
        let yOrigin = screenOrigin.y
        let cornerSideLength = CGFloat(80)
        let adjustedScreenWidth = self.view.frame.width - cornerSideLength
        let adjustedScreenHeight = self.view.frame.height - cornerSideLength
        
        let topLeftCornerRect = CGRectMake(xOrigin, yOrigin, cornerSideLength, cornerSideLength)
        let topLeftCornerView = UIView(frame: topLeftCornerRect)
        cornerViews.append(topLeftCornerView)
        topLeftCornerView.backgroundColor = UIColor.grayColor()
        
        let topRightCornerRect = CGRectMake(xOrigin + adjustedScreenWidth , yOrigin, cornerSideLength, cornerSideLength)
        let topRightCornerView = UIView(frame: topRightCornerRect)
        cornerViews.append(topRightCornerView)
        topRightCornerView.backgroundColor = UIColor.grayColor()
        
        let bottomLeftCornerRect = CGRectMake(0, adjustedScreenHeight, cornerSideLength, cornerSideLength)
        let bottomLeftCornerView = UIView(frame: bottomLeftCornerRect)
        cornerViews.append(bottomLeftCornerView)
        bottomLeftCornerView.backgroundColor = UIColor.grayColor()
        
        let bottomRightCornerRect = CGRectMake(adjustedScreenWidth, adjustedScreenHeight, cornerSideLength, cornerSideLength)
        let bottomRightCornerView = UIView(frame: bottomRightCornerRect)
        cornerViews.append(bottomRightCornerView)
        bottomRightCornerView.backgroundColor = UIColor.grayColor()
        
        self.view.insertSubview(topLeftCornerView, atIndex: 0)
        self.view.insertSubview(topRightCornerView, atIndex: 0)
        self.view.insertSubview(bottomLeftCornerView, atIndex: 0)
        self.view.insertSubview(bottomRightCornerView, atIndex: 0)
    }
    
    @IBAction func userPanned(sender: AnyObject) {
        let panGesture = sender as! UIPanGestureRecognizer
        let coordinate = panGesture.locationInView(self.view)
        let xCoord = (coordinate.x) - (fingerBlockSideLength / 2)
        let yCoord = (coordinate.y) - (fingerBlockSideLength / 2)
        fingerView.frame = CGRectMake(xCoord, yCoord, fingerBlockSideLength, fingerBlockSideLength)
        dynamicAnimator.updateItemUsingCurrentState(fingerView)
        
        blockIsContatinedInCornerView()
    }
    
    func blockIsContatinedInCornerView() -> Bool{
        let blockCenterX = blockView.frame.origin.x + (blockSideLength / 2)
        let blockCenterY = blockView.frame.origin.y + (blockSideLength / 2)
        let blockCenterCoordinate = CGPoint(x: blockCenterX, y: blockCenterY)
        for x in cornerViews{
            if (x.frame.contains(blockCenterCoordinate)){
                println("block is in a view")
            }
        }
        return false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

