//
//  SimpleHeaderViewModel.swift
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

class HeaderViewModel: TFBaseViewModel {
    var titleStorage : String = "Empty title"
    
    var title : String {
        get {
            return self.sectionViewModel!.folded ? "Closed with \(self.sectionViewModel!.rows?.count) elements, click to unfold" : titleStorage;
        }
        set {
            titleStorage = newValue
        }
    }
}
