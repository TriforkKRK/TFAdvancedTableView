//
//  SimpleRowViewModel.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

import UIKit

class SimpleRowViewModel: TFBaseViewModel {
    var bgdColor: UIColor?
    var name: String?
    
    init(color: UIColor, name: String) {
        self.name = name
        self.bgdColor = color
        super.init(model:nil)
    }
}