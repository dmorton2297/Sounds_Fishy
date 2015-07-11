//
//  ViewController.swift
//  WhaleKiller
//
//  Created by Dan Morton on 7/11/15.
//  Copyright (c) 2015 Dan Morton. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    let blockSideLength = CGFloat(40)
    let fingerBlockSideLength = CGFloat(20)
    var blockView : UIView!
    var fingerView : UIView!
    var dynamicAnimator : UIDynamicAnimator!
    var cornerViews = [UIView]()
    var timing = false
    var timingBeeps = false
    var backgroundView : UIView!
    
    //setup UIDynamics and collision behaviors
    override func viewDidLoad() {
        //MARK: Game loop starts
        let speaker = Speaker()
        super.viewDidLoad()
        createGame()
        var gameLoopTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateAlphaAndBeatRate", userInfo: nil, repeats: true)
        
        speaker.speakText("The game has started")
        //var a = SinePlayer()
        
        
    }
    
    func createGame(){
        self.view.accessibilityDecrement()
        spawnBlock()
        spawnFingerBlock()
        setupDynamicAnimator()
        setUpAlphaAndBlurView()
    }
    
    func destroyGame(){
        blockView.removeFromSuperview()
        fingerView.removeFromSuperview()
        backgroundView.removeFromSuperview()
        backgroundView = nil
        dynamicAnimator = nil
        blockView = nil
        fingerView = nil
        for x in cornerViews{
            x.removeFromSuperview()
        }
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
        
        let blockPushBehavior = UIPushBehavior(items: [blockView], mode: UIPushBehaviorMode.Continuous)
        blockPushBehavior.magnitude = 0.30
        blockPushBehavior.angle = 0.90
        
        let blockDynamicBehavior = UIDynamicItemBehavior(items: [blockView])
        blockDynamicBehavior.elasticity = 1.0
        blockDynamicBehavior.resistance = 0.0
        blockDynamicBehavior.friction = 0.02
        
        let fingerDynamicBehavior = UIDynamicItemBehavior(items: [fingerView])
        fingerDynamicBehavior.allowsRotation = false
        fingerDynamicBehavior.density = 100000
        fingerDynamicBehavior.resistance = 0.0
        fingerDynamicBehavior.friction = 0.0
        
        
        let collisionBehavior = UICollisionBehavior(items: [blockView, fingerView])
        collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        
        dynamicAnimator.addBehavior(blockPushBehavior)
        dynamicAnimator.addBehavior(collisionBehavior)
        dynamicAnimator.addBehavior(blockDynamicBehavior)
        dynamicAnimator.addBehavior(fingerDynamicBehavior)
        
    }
    
    func setUpAlphaAndBlurView(){
        let a = CGFloat(1.0)
        backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor(red: a, green: a, blue: a, alpha: 0.0)
        self.view.insertSubview(backgroundView, atIndex: 1)
        self.view.backgroundColor = UIColor.blackColor()
        setUpCornerViews()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        
        self.view.addSubview(blurView)
    }
    
    func setUpCornerViews(){
        
        let screenOrigin = self.view.frame.origin
        
        let xOrigin = screenOrigin.x
        let yOrigin = screenOrigin.y
        let cornerSideLength = CGFloat(150)
        let adjustedScreenWidth = self.view.frame.width - cornerSideLength
        let adjustedScreenHeight = self.view.frame.height - cornerSideLength
        
        let topLeftCornerRect = CGRectMake(xOrigin, yOrigin, cornerSideLength, cornerSideLength)
        let topLeftCornerView = UIView(frame: topLeftCornerRect)
        cornerViews.append(topLeftCornerView)
        topLeftCornerView.backgroundColor = UIColor.clearColor()
        
        let topRightCornerRect = CGRectMake(xOrigin + adjustedScreenWidth , yOrigin, cornerSideLength, cornerSideLength)
        let topRightCornerView = UIView(frame: topRightCornerRect)
        cornerViews.append(topRightCornerView)
        topRightCornerView.backgroundColor = UIColor.clearColor()
        
        let bottomLeftCornerRect = CGRectMake(0, adjustedScreenHeight, cornerSideLength, cornerSideLength)
        let bottomLeftCornerView = UIView(frame: bottomLeftCornerRect)
        cornerViews.append(bottomLeftCornerView)
        bottomLeftCornerView.backgroundColor = UIColor.clearColor()
        
        let bottomRightCornerRect = CGRectMake(adjustedScreenWidth, adjustedScreenHeight, cornerSideLength, cornerSideLength)
        let bottomRightCornerView = UIView(frame: bottomRightCornerRect)
        cornerViews.append(bottomRightCornerView)
        bottomRightCornerView.backgroundColor = UIColor.clearColor()
        
        self.view.insertSubview(topLeftCornerView, atIndex: 0)
        self.view.insertSubview(topRightCornerView, atIndex: 0)
        self.view.insertSubview(bottomLeftCornerView, atIndex: 0)
        self.view.insertSubview(bottomRightCornerView, atIndex: 0)
    }
    
    @IBAction func userPanned(sender: AnyObject) {
        if (fingerView == nil || blockView == nil){ return }
        let panGesture = sender as! UIPanGestureRecognizer
        let coordinate = panGesture.locationInView(self.view)
        let xCoord = (coordinate.x) - (fingerBlockSideLength / 2)
        let yCoord = (coordinate.y) - (fingerBlockSideLength / 2)
        fingerView.frame = CGRectMake(xCoord, yCoord, fingerBlockSideLength, fingerBlockSideLength)
        dynamicAnimator.updateItemUsingCurrentState(fingerView)
        updateAlphaAndBeatRate()
        
        
        if (blockIsContatinedInCornerView()){
            if (!timing){
                timing = true
                var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "timerFinished", userInfo: nil, repeats: false)
            }
        }
    }
    
    func blockIsContatinedInCornerView() -> Bool{
        let blockCenterX = blockView.frame.origin.x + (blockSideLength / 2)
        let blockCenterY = blockView.frame.origin.y + (blockSideLength / 2)
        let blockCenterCoordinate = CGPoint(x: blockCenterX, y: blockCenterY)
        for x in cornerViews{
            if (x.frame.contains(blockCenterCoordinate)){
                return true
            }
        }
        return false
    }
    
    func timerFinished(){
        let speaker = Speaker()
        
        if (blockIsContatinedInCornerView()){
            self.destroyGame()
            let alert = UIAlertController(title: "You won!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Yay!", style: UIAlertActionStyle.Default){(alert) -> Void in
                self.createGame()
            }
            speaker.speakText("You won")
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        timing = false
    }
    
    func updateAlphaAndBeatRate(){
        let fingerLocation = fingerView.frame.origin
        let blockLocation = blockView.frame.origin
        let delX = abs(fingerLocation.x - blockLocation.x)
        let delY = abs(fingerLocation.y - blockLocation.y)
        let square = pow(delX, 2.0)+pow(delY, 2.0)
        let distance = sqrt(square)
        
        var percentAlpha = distance / 200.0
        percentAlpha = 1.0 - percentAlpha
        
        if (percentAlpha > 1.0){
            percentAlpha = 1.0
        }
        
        let a = CGFloat(1.0)
        backgroundView.backgroundColor = UIColor(red: a, green: a, blue: a, alpha: percentAlpha)
        
        let beepInterval = distance / 400
        println(beepInterval)
        
        if (!timingBeeps){
            let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(beepInterval), target: self, selector: "beep", userInfo: nil, repeats: false)
            timingBeeps = true
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if (item1.isEqual(fingerView) && item2.isEqual(blockView) || item1.isEqual(blockView) && item2.isEqual(fingerView)){
            let speaker = Speaker()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            speaker.speakText("Collision")
            
        }
    }
    
    func beep(){
        let soundURL = NSBundle.mainBundle().URLForResource("beep", withExtension: "wav")
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL, &mySound)
        AudioServicesPlaySystemSound(mySound)
        timingBeeps = false
    }
    
    
    
}

