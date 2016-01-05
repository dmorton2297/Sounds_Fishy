//
//  Speaker.swift
//  WhaleKiller
//
//  Created by Dan Morton on 7/11/15.
//  Copyright (c) 2015 Dan Morton. All rights reserved.
//

import Foundation
import AVFoundation

class Speaker {
    func speakText(str: String){
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: str)
        utterance.rate = 0.1
        synth.speakUtterance(utterance)
    }
}