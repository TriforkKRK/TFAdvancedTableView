//
//  SelfConfigurableSimpleCell.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 12.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

class SelfConfigurableCellWithText: CellWithText {
    
}

extension SelfConfigurableCellWithText: TFTableViewItemSelfPresenting {
    func prepareForPresentationWithObject(object: AnyObject) {
        guard let vm = object as? RowViewModel else { return }
        
        self.primaryLabel?.text = vm.name
    }
}
