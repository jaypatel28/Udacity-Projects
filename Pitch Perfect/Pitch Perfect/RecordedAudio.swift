//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Jay Patel on 10/22/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String! = "my_audio.wav"
    
    init(title: String,filePathUrl: NSURL) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}