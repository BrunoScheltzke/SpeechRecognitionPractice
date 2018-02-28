//
//  SpeechRecognizingController.swift
//  SpeechRecogTest
//
//  Created by Bruno Scheltzke on 28/02/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizingController {
    var delegate: SpeechRecognizable!
    
    let audionEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var lampToModify: String = ""
    var lampCommand: String = ""
    
    func recordAndRecognizeSpeech() {
        lampToModify = ""
        lampCommand = ""
        
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
                lampCommand = String(percentage)
            }
        }
        
        switch lastWordSpoken {
        case "light":
            self.delegate.currentLamp.forEach { (light) in
                if light.name.lowercased() == secondToLastWordSpoken.lowercased() {
                    lampToModify = light.id
                }
            }
        case "lamp":
            self.delegate.currentLamp.forEach { (light) in
                if light.name.lowercased() == secondToLastWordSpoken.lowercased() {
                    lampToModify = light.id
                }
            }
        case "lights":
            lampToModify = "all"
        case "lamps":
            lampToModify = "all"
        case "every":
            lampToModify = "all"
        case "all":
            lampToModify = "all"
        case "on":
            lampCommand = "100"
        case "off":
            lampCommand = "0"
        default:
            break
        }
        
        switch secondToLastWordSpoken {
        case "light":
            self.delegate.currentLamp.forEach { (light) in
                if light.name.lowercased() == lastWordSpoken.lowercased() {
                    lampToModify = light.id
                }
            }
        case "lamp":
            self.delegate.currentLamp.forEach { (light) in
                if light.name.lowercased() == lastWordSpoken.lowercased() {
                    lampToModify = light.id
                }
            }
        default:
            break
        }
        
        if !lampToModify.isEmpty && !lampCommand.isEmpty {
            stopRecording()
            delegate.didFind(command: lampCommand, forLampId: lampToModify)
        }
    }
    
    func stopRecording() {
        audionEngine.inputNode.removeTap(onBus: 0)
        audionEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}

protocol SpeechRecognizable {
    var currentLamp: [Lamp] { get set }
    
    func didFind(command: String, forLampId id: String)
    
    //TODO: error understanding command method
    //TODO: timeout method
}
