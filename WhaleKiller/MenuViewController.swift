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
        speaker.speakText("This is where the directions will go")
    }
}
