//
//  ViewController.swift
//  SpeechRecogTest
//
//  Created by Bruno Scheltzke on 26/02/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

struct Light {
    var id: String
    var name: String
}

extension ViewController: SpeechRecognizable {
    func didFind(command: String, forLampId id: String) {
        detectedTextLabel.text = "Command: \(command); Light: \(id)"
    }
}

class ViewController: UIViewController {
    let speechController = SpeechRecognizingController()
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    var currentLights: [Light] = [Light(id: "1", name: "first"), Light(id: "2", name: "kitchen"), Light(id: "3", name: "third")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechController.delegate = self
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        speechController.recordAndRecognizeSpeech()
    }
    
    @IBAction func doneRecognizingVoice(_ sender: Any) {
        speechController.stopRecording()
    }
}
