//
//  Box.swift
//  MVVMBox
//
//  Created by anoop mohanan on 22/12/17.
//  Copyright © 2017 anoop. All rights reserved.
//

import Foundation

class Box<T> {
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T{
        
        didSet{
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?){
        
        self.listener = listener
        listener?(value)
    }
    
}
