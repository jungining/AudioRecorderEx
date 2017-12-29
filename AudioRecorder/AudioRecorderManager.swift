//
//  AudioRecorderManager.swift
//  AudioRecorder
//
//  Created by YuJungin on 2017. 12. 29..
//  Copyright © 2017년 junginin. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorderManager : NSObject {
    
    static let shared = AudioRecorderManager()
    
    var recordingSession : AVAudioSession!
    var recorder : AVAudioRecorder?
    
    
    func setup(){
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do{
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            //권한 요청
            recordingSession.requestRecordPermission( { (allowed:Bool) in
                
                if allowed {
                    print("Mic authorized")
                }
                else{
                    print("Mic not authorized")
                }
                
                })
        }
        catch{
            print("Failed to set category", error.localizedDescription)
        }
        
    }
    
    var meterTimer: Timer?
    var recorderApc0 : Float = 0
    var recorderPeak0 : Float = 0
    
    
    // 녹음 세션 시작
    func record(fileName:String) -> Bool {
        let url = getUserPath().appendingPathComponent(fileName+".m4a")
        let audioURL = URL.init(fileURLWithPath: url.path)
        
        let recordSettings: [String:Any] = [
            AVFormatIDKey:NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey:12000.0,
            AVNumberOfChannelsKey:1,
            AVSampleRateKey:44100.0
        ]
        
        do{
            recorder = try AVAudioRecorder(url: audioURL, settings: recordSettings) // 이코드 좋다.
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            recorder?.record()
            
            self.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer:Timer) in
                
                //녹음 미터 값을 항상 업데이트 해줘야 함.
                
            if let recorder = self.recorder{
                recorder.updateMeters()
                self.recorderApc0 = recorder.averagePower(forChannel: 0)
                self.recorderPeak0 = recorder.peakPower(forChannel: 0)
                }
            })
            
            print("Recording")
            
            return true
        }
        catch{
            print("Error Recording")
            return false
        }
        
    }
    
    //recorder 멈추기
    
    func finishRecording(){
        self.recorder?.stop()
        self.meterTimer?.invalidate()
    }
    
    
    // 파일 저장할 path얻기
    func getUserPath() -> URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}



//AVAudioRecorder 딜리게이트 달기


extension AudioRecorderManager:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio KManager did finish recording")
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error encoding ",error?.localizedDescription ?? "")
    }
}


