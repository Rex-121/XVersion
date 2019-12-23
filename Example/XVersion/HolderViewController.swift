//
//  HolderViewController.swift
//  XVersion_Example
//
//  Created by Tyrant on 2019/12/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import ReactiveSwift

import XVersion

class HolderViewController: UIViewController {
    
    let topVersion = MutableProperty<Version?>(nil)
    
    let bottomVersion = MutableProperty<Version?>(nil)
    
    @IBOutlet weak var compareLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let top = topVersion.producer.skipNil()
        let bottom = bottomVersion.producer.skipNil()
        
        
        compareLabel.reactive.text <~ top.combineLatest(with: bottom).map { (first, second) -> String in
            if first == second { return "=" }
            if first >= second { return ">, >=" }
            if first <= second { return "<, <=" }
            return "?"
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destination as? PickViewController else { return }
        
        if let iden = segue.identifier {
            
            switch iden {
            case "topVersion":
                topVersion <~ vc.version
            case "bottomVersion":
                bottomVersion <~ vc.version
            default: break
            }
            
            
        }
        
    }
    
}
