//
//  AudioPlayerManager.swift
//  AudioRecorder
//
//  Created by YuJungin on 2017. 12. 29..
//  Copyright © 2017년 junginin. All rights reserved.
//

import Foundation
import AVFoundation

extension Notification.Name{
    static let AudioPlayerDidFinishPlayingAudioFile = Notification.Name("AudioPlayerDidFinishPlayingAudioFile")
}

class AudioPlayerManager: NSObject{
    
    static let shared = AudioPlayerManager()
    
    override init(){
        super.init()
        
    }
    
    private var currentPlayer:AVAudioPlayer?
    var isPlaying = false
    var isFinished = false
    
    var lastPath:String?
    
    func play(path:String){
        
        if lastPath == path && isFinished == true {
            self.currentPlayer?.play()
            return
        }
        
        
        let url = URL.init(string: path)
        
        do {
            self.currentPlayer = try AVAudioPlayer(contentsOf: url!)
            self.currentPlayer?.delegate = self
            self.currentPlayer?.play()
            isPlaying = true
            self.isFinished = false
            self.lastPath = url?.path // url 카피떠놓음
            
        }
        catch{
            print("Error loading file,", error.localizedDescription)
        }
    }
    
    func pause(){
        isPlaying = false
        self.currentPlayer?.pause()
    }
    
    // 방법 1. userDocuments 폴더에서 파일을 로드한다.


    func audioFileInUserDocuments(fileName:String)->String{
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return url.appendingPathComponent(fileName+".m4a").path
    }
    // 방법 2. bundle에서 파일을 로드한다.
    func audioFileFromBundle(fileName:String)->String{
      
        return Bundle.main.path(forResource: fileName, ofType: ".mp3")!
    }
    
}

extension AudioPlayerManager:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isFinished = true
        isPlaying = false
        
        NotificationCenter.default.post(name: Notification.Name.AudioPlayerDidFinishPlayingAudioFile, object: nil)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "") //??는 nil이면 ""를 보인다는 뜻!
    }
}
