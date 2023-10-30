//
//  TimerViewController.swift
//  firstApp
//
//  Created by Paul James on 19.11.2023.
//

import Foundation
import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    
    var onSelection: ((Int) -> Void)?
    var countdownTimer: Timer?
    var remainingTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSlider()
        setupButton()
        
        updateLabel()
        startTimer()
        
    }
    
    func setupSlider() {
        slider.minimumValue = 0
        slider.maximumValue = 60
        
        //блокирую слайдер, пока человек не нажмет reset
        if remainingTime != 0 {
            slider.isUserInteractionEnabled = false
        }
    }
    
    func setupButton() {
        confirmButton.layer.cornerRadius = 20
        resetButton.layer.cornerRadius = 20
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        updateLabel()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        let selectedMinutes = Int(slider.value)
        onSelection?(selectedMinutes)
        dismiss(animated: true)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        onSelection?(0)
        remainingTime = 0
        updateLabel()
        confirmButton.titleLabel?.text = "Подтвердить"
    }
    
    func updateLabel() {
        let selectedMinutes = Int(slider.value)
        minutesLabel.text = "Выбрано \(selectedMinutes) минут"
        
        let remainMin = remainingTime / 60
        let remainSec = remainingTime % 60
        
        remainingTimeLabel.text = "Осталось \(String(format: "%02d : %02d", remainMin, remainSec))"
    }
    
    func startTimer() {
        stopTimer()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateLabel()
        } else {
            stopTimer()
        }
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
    }
}
