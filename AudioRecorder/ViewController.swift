//
//  ViewController.swift
//  AudioRecorder
//
//  Created by YuJungin on 2017. 12. 29..
//  Copyright © 2017년 junginin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var micBtn: UIButton!
    
    @IBOutlet weak var recoredView: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBAction func playFile(_ sender: Any) {
        
        if AudioPlayerManager.shared.isPlaying{
            
            AudioPlayerManager.shared.pause()
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        }else{
            
            let path = AudioPlayerManager.shared.audioFileInUserDocuments(fileName: "TestFile")
            self.playBtn.setImage(#imageLiteral(resourceName: "play-1"), for: .normal)
            
            AudioPlayerManager.shared.play(path: path)
        }
        
    }
    
    
    
    
    //MARK:
    //MARK: VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.buildVoiceCirlce()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerDidFinishPlaying), name: NSNotification.Name.AudioPlayerDidFinishPlayingAudioFile, object: nil)
        
    }
    
    
    @objc func audioPlayerDidFinishPlaying(){
        
        print("Audio player did finish")
        
        DispatchQueue.main.async {
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Timer to update the status of our recording
    var nonObservablePropertiesUpdateTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    
    //MARK:
    //MARK: Recored Button
    
    @IBAction func StartRecording(_ sender: UIButton) {
        
        if AudioRecorderManager.shared.record(fileName: "TestFile") {
            nonObservablePropertiesUpdateTimer.resume()
        }
        //            .record(fileName: "TestFile"){
        //
        //        }
        
        
        //날짜 포매터 만들기
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.minute, .second]
        formatter.calendar = Calendar.current
        
        nonObservablePropertiesUpdateTimer.setEventHandler { [weak self] in
            //Audio recording circle animations here
            
            
            guard AudioRecorderManager.shared.recorder != nil else{
                return
            }
            
            self?.durationLabel.text = formatter.string(from: AudioRecorderManager.shared.recorder!.currentTime)
            
            let percent = (Double(AudioRecorderManager.shared.recorderPeak0) + 160) / 160
            
            let final = CGFloat(percent) + 0.3
            
            UIView.animate(withDuration: 0.15, animations: {
                self?.WaveAnimationView.transform = CGAffineTransform(scaleX: final, y: final)
                
            })
            
        }
        
        nonObservablePropertiesUpdateTimer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.milliseconds(100))
        
        
        
        
        UIView.animate(withDuration: 0.15, animations: {
            self.WaveAnimationView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Release to stop recording"
            self.statusLabel.textColor = UIColor.orange
        }
        
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        
        
        AudioRecorderManager.shared.finishRecording()
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        nonObservablePropertiesUpdateTimer.suspend()
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Press & hold to start"
            self.statusLabel.textColor = UIColor.green
        }
    }
    
    
    //MARK:
    //MARK: Build Wave Cricle
    var WaveAnimationView:UIView!
    func buildVoiceCirlce(){
        
        let size = CGSize(width: 200, height: 200)
        
        let newPoint = CGPoint(x:self.recoredView.frame.size.width / 2 - 100 , y: self.recoredView.frame.size.height / 2 - 100)
        WaveAnimationView = UIView(frame: CGRect(origin:newPoint , size: size))
        WaveAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        WaveAnimationView.layer.cornerRadius = 100
        WaveAnimationView.backgroundColor = UIColor.clear
        WaveAnimationView.layer.borderColor = UIColor.green.cgColor
        WaveAnimationView.layer.borderWidth = 1.0
        self.recoredView.addSubview(WaveAnimationView)
        
        self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        
    }
    
    


}

