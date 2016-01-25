//
//  SelfConfigurableSimpleCell.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 12.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

class SelfConfigurableCellWithText: CellWithText {
    
}

extension SelfConfigurableCellWithText: TFDynamicTableViewItemPresenting {
    
    func prepare(view: UIView, forPresentationWithObject object: AnyObject) {
        guard let vm = object as? RowViewModel else { return }
        
        if let name = vm.name {
            self.primaryLabel?.text = "Self configurable cell with name: \(name)"
        }
    }
}
