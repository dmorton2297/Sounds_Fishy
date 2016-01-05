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

var gameLoopTimer = NSTimer()

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    //MARK: Variables
    let blockSideLength = CGFloat(40)
    let fingerBlockSideLength = CGFloat(20)
    var blockView : UIView!
    var fingerView : UIView!
    var dynamicAnimator : UIDynamicAnimator!
    var cornerViews = [UIView]()
    var timing = false
    var timingBeeps = false
    var backgroundView : UIView!
    var gameOver = false
    var gameStarted = false
    var blurView : UIView!
    var newGameTimer : NSTimer!
    
    //MARK: Game initializatoin
    //setup UIDynamics and collision behaviors
    override func viewDidLoad() {
        UIApplication.sharedApplication().statusBarHidden = true
        let speaker = Speaker()
        super.viewDidLoad()
        speaker.speakText("To begin the game, press and hold your home button to access Siri, and ask to turn voice over off. Later on, this feature can be turned back on, simply by going to Siri and asking for voice over on. When finished, press home and slide your finger on the screen to start.")
    }
    
    //hide the status bar on the screen
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //Create all the UIViews and Dynamic Behaviors neccessary for the game
    func createGame(){
        spawnBlock()
        spawnFingerBlock()
        setupDynamicAnimator()
        setUpAlphaAndBlurView()
    }
    
    
    //remove all views and behaviors neccessary to stage game for restart
    func destroyGame(){
        dynamicAnimator.removeAllBehaviors()
        blockView.removeFromSuperview()
        fingerView.removeFromSuperview()
        backgroundView.removeFromSuperview()
        blurView.removeFromSuperview()
        backgroundView = nil
        blockView = nil
        blurView = nil
        fingerView = nil
        for x in cornerViews{
            x.removeFromSuperview()
        }
    }
    
    //MARK: Setup views
    //creating the "fish" block
    func spawnBlock(){
        let xCenter = CGFloat((self.view.frame.width / 2))
        let yCenter = CGFloat((self.view.frame.height / 2))
        
        blockView = UIView(frame: CGRectMake(xCenter, yCenter, blockSideLength, blockSideLength))
        blockView.backgroundColor = UIColor.redColor()
        self.view.addSubview(blockView)
    }
    
    //create the block that follows the users finger
    func spawnFingerBlock(){
        fingerView = UIView(frame: CGRectMake(10.0, 10.0, fingerBlockSideLength, fingerBlockSideLength))
        fingerView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(fingerView)
    }
    
    
    //set up the corner zones (corner zones are areas
    func setUpCornerViews(){
        
        let screenOrigin = self.view.frame.origin
        
        let xOrigin = screenOrigin.x
        let yOrigin = screenOrigin.y
        let cornerSideLength = CGFloat(100)
        let adjustedScreenWidth = self.view.frame.width - cornerSideLength
        let adjustedScreenHeight = self.view.frame.height - cornerSideLength
        let pixelHangoverLength = CGFloat(10) //the amount of pixels that a view will "hangover" the boundaries
        
        let topLeftCornerRect = CGRectMake(xOrigin - pixelHangoverLength, yOrigin - pixelHangoverLength, cornerSideLength + pixelHangoverLength, cornerSideLength + pixelHangoverLength)
        let topLeftCornerView = UIView(frame: topLeftCornerRect)
        cornerViews.append(topLeftCornerView)
        topLeftCornerView.backgroundColor = UIColor.clearColor()
        
        let topRightCornerRect = CGRectMake(adjustedScreenWidth , yOrigin - pixelHangoverLength, cornerSideLength + pixelHangoverLength, cornerSideLength + pixelHangoverLength)
        let topRightCornerView = UIView(frame: topRightCornerRect)
        cornerViews.append(topRightCornerView)
        topRightCornerView.backgroundColor = UIColor.clearColor()
        
        let bottomLeftCornerRect = CGRectMake(xOrigin - pixelHangoverLength, adjustedScreenHeight, cornerSideLength + pixelHangoverLength, cornerSideLength + pixelHangoverLength)
        let bottomLeftCornerView = UIView(frame: bottomLeftCornerRect)
        cornerViews.append(bottomLeftCornerView)
        bottomLeftCornerView.backgroundColor = UIColor.clearColor()
        
        let bottomRightCornerRect = CGRectMake(adjustedScreenWidth, adjustedScreenHeight, cornerSideLength + pixelHangoverLength, cornerSideLength + pixelHangoverLength)
        let bottomRightCornerView = UIView(frame: bottomRightCornerRect)
        cornerViews.append(bottomRightCornerView)
        bottomRightCornerView.backgroundColor = UIColor.clearColor()

        
        self.view.insertSubview(topLeftCornerView, atIndex: 0)
        self.view.insertSubview(topRightCornerView, atIndex: 0)
        self.view.insertSubview(bottomLeftCornerView, atIndex: 0)
        self.view.insertSubview(bottomRightCornerView, atIndex: 0)
    }
    
    //setup blurview, and alpha for lightening and darkening throughout the game
    func setUpAlphaAndBlurView(){
        let a = CGFloat(1.0)
        backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor(red: a, green: a, blue: a, alpha: 0.0)
        self.view.insertSubview(backgroundView, atIndex: 1)
        self.view.backgroundColor = UIColor.blackColor()
        setUpCornerViews()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        
        self.view.addSubview(blurView)
    }
    
    //MARK: Setup animations
    func setupDynamicAnimator(){
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        
        let blockPushBehavior = UIPushBehavior(items: [blockView], mode: UIPushBehaviorMode.Continuous)
        blockPushBehavior.magnitude = 0.30
        blockPushBehavior.angle = randomizeAngleForNewGame()
        print(blockPushBehavior.angle)
        
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
    
    //generates an angle of force that will be applied to the block view throughout the game
    func randomizeAngleForNewGame() -> CGFloat
    {
        let a = CGFloat(arc4random_uniform(UInt32(628)))
        return (a / 100)
    }
    
    
    //MARK: Gestures, and beginning of game control
    //this event will restart the game
    @IBAction func userLongPressed(sender: AnyObject) {
        if (gameOver){
            self.gameOver = false
            let speaker = Speaker()
            newGameTimer.invalidate()
            speaker.speakText("Begin game")
            self.createGame()
            gameLoopTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateGame", userInfo: nil, repeats: true)
            
        }
    }
    
    //this event controls the location of the finger view
    //it also will start the game if the user has not done so yet
    @IBAction func userPanned(sender: AnyObject) {
        //MARK: game loop starts here
        if ((fingerView == nil || blockView == nil) && gameStarted){ return }
        if (!gameStarted) {
            gameStarted = true
            createGame()
            gameLoopTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateGame", userInfo: nil, repeats: true)
        }
        else{
            let panGesture = sender as! UIPanGestureRecognizer
            let coordinate = panGesture.locationInView(self.view)
            let xCoord = (coordinate.x) - (fingerBlockSideLength / 2)
            let yCoord = (coordinate.y) - (fingerBlockSideLength / 2)
            fingerView.frame = CGRectMake(xCoord, yCoord, fingerBlockSideLength, fingerBlockSideLength)
            dynamicAnimator.updateItemUsingCurrentState(fingerView)
            updateGame()
            
            
            if (blockIsContatinedInCornerView()){
                if (!timing){
                    timing = true
                    var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "timerFinished", userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    //MARK: Game logic
    //checks to see if the winningTimer should start. This method infers that the block is in one of the cornerviews
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
    
    //if the timer is finished and the block is still in a cornerview, communicate to the user that they have won the game
    func timerFinished(){
        if (blockIsContatinedInCornerView()){
            self.destroyGame()
            gameOver = true
            promptUserToLongPressForNewGame()
            newGameTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "promptUserToLongPressForNewGame", userInfo: nil, repeats: true)
            
        }
        
        timing = false
    }
    
    //This method is called by the gameLoopTimer to update the beeping, and alpha of the screen
    func updateGame(){
        if (dynamicAnimator.behaviors.count != 0){
            let fingerLocation = fingerView.frame.origin
            let blockLocation = blockView.frame.origin
            let delX = abs(fingerLocation.x - blockLocation.x)
            let delY = abs(fingerLocation.y - blockLocation.y)
            let square = pow(delX, 2.0)+pow(delY, 2.0)
            let distance = sqrt(square)
            
            
            var percentAlpha = distance / 150.0
            percentAlpha = 1.0 - percentAlpha
            
            if (percentAlpha > 1.0){
                percentAlpha = 1.0
            }
            
            print(percentAlpha)
            
            let a = CGFloat(1.0)
            backgroundView.backgroundColor = UIColor(red: a, green: a, blue: a, alpha: percentAlpha)
            
            let beepInterval = distance / 400
            
            if (!timingBeeps){
                let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(beepInterval), target: self, selector: "beep", userInfo: nil, repeats: false)
                timingBeeps = true
            }
        }
    }
    
    //MARK: Sound
    //vibrate the phone if the users finger collides with the block
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if (item1.isEqual(fingerView) && item2.isEqual(blockView) || item1.isEqual(blockView) && item2.isEqual(fingerView)){
            let speaker = Speaker()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //speaker.speakText("Collision")
            
        }
    }
    
    //this beep sound is used for the "sonar" effect of the game
    func beep(){
        let soundURL = NSBundle.mainBundle().URLForResource("beep", withExtension: "wav")
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL!, &mySound)
        AudioServicesPlaySystemSound(mySound)
        timingBeeps = false
    }
    
    //After the game is over, prompt the user to long press to restart the game. This is a selector of the timer "timer" in updategame
    func promptUserToLongPressForNewGame(){
        let speaker = Speaker()
        speaker.speakText("You won! Long press to start a new game.")
        
    }
}

