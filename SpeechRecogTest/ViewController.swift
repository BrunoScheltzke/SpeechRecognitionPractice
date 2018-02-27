//
//  ViewController.swift
//  SpeechRecogTest
//
//  Created by Bruno Scheltzke on 26/02/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit
import Speech

struct Light {
    var id: String
    var name: String
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    let formatter = NumberFormatter()
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    let audionEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var lightToModify: String = ""
    var lightCommand: String = ""
    
    var currentLights: [Light] = [Light(id: "1", name: "first"), Light(id: "2", name: "kitchen"), Light(id: "3", name: "third")]
    
    var mostRecentlyProcessedSegmentDuration: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.numberStyle = .spellOut
    }
    
    func recordAndRecognizeSpeech() {
        lightToModify = ""
        lightCommand = ""
        
        let recordingFormat = audionEngine.inputNode.outputFormat(forBus: 0)
        audionEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audionEngine.prepare()
        do{
            try audionEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                self.checkForLightsOrCommands(from: bestString)

            } else if let error = error {
                print(error)
            }
        })
    }
    
    func checkForLightsOrCommands(from sentence: String) {
        let wordsSpoken = sentence.split(separator: " ")
        let lastWordSpoken = wordsSpoken.last!
        var secondToLastWordSpoken = ""
        
        if wordsSpoken.count > 1 {
           secondToLastWordSpoken = String(wordsSpoken[wordsSpoken.count - 2])
        }
        
        if lastWordSpoken.last! == "%" {
            let possibleNumber = String(lastWordSpoken).split(separator: "%").first!
            
            if let percentage = Int(possibleNumber), percentage >= 0 && percentage <= 100 {
                lightCommand = String(percentage)
            }
        }
        
        switch lastWordSpoken {
        case "light":
            self.currentLights.forEach { (light) in
                if light.name.lowercased() == secondToLastWordSpoken.lowercased() {
                    lightToModify = light.id
                }
            }
        case "lights":
            lightToModify = "all"
        case "every":
            lightToModify = "all"
        case "all":
            lightToModify = "all"
        case "on":
            lightCommand = "100"
        case "off":
            lightCommand = "0"
        default:
            break
        }
        
        switch secondToLastWordSpoken {
        case "light":
            self.currentLights.forEach { (light) in
                if light.name.lowercased() == lastWordSpoken.lowercased() {
                    lightToModify = light.id
                }
            }
        default:
            break
        }
        
        if !lightToModify.isEmpty && !lightCommand.isEmpty {
            stopRecording()
        }
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
    }
    
    @IBAction func doneRecognizingVoice(_ sender: Any) {
        stopRecording()
    }
    
    func stopRecording() {
        detectedTextLabel.text = "Command: \(lightCommand); Light: \(lightToModify)"
        
        audionEngine.inputNode.removeTap(onBus: 0)
        audionEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}
