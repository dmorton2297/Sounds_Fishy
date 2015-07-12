//
//  MenuViewController.swift
//  WhaleKiller
//
//  Created by Dan Morton on 7/11/15.
//  Copyright (c) 2015 Dan Morton. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func directionsButtonClicked(sender: AnyObject) {
        let speaker = Speaker()
        speaker.speakText("Locate the fish by pressing and holding your finger on the screen and then moving it around.  You will hear beeps that increase in frequency as you get closer to the fish. You win when you corral the fish into the corner for two seconds. Press start to begin.")
    }
}
