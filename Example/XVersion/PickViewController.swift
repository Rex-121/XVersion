//
//  PickViewController.swift
//  XVersion_Example
//
//  Created by Tyrant on 2019/12/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import ReactiveSwift
import XVersion
import ReactiveCocoa

final class PickViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let major = MutableProperty<Int?>(nil)
    let minor = MutableProperty<Int?>(nil)
    let patch = MutableProperty<Int?>(nil)
    
    lazy var version: SignalProducer<Version, Never> = {
       return SignalProducer.combineLatest(major, minor, patch).map { Version(major: $0, minor: $1, patch: $2) }
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
    let values = [0,1,2,3,4,5,6,7,8,9,10]
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            major.swap(values[row])
        case 1:
            minor.swap(values[row])
        case 2:
            patch.swap(values[row])
        default: break
        }
    }
    
    @IBOutlet weak var pickView: UIPickerView!
    
    @IBOutlet weak var versionLabel: UILabel!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickView.dataSource = self
        
        pickView.delegate = self

        versionLabel.reactive.text <~ version.map { $0.description }

    }
    
    
    
    
}
