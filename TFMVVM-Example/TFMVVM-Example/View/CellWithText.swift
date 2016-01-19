//
//  SimpleCell.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 11.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

@objc class CellWithText: UITableViewCell {
    var primaryLabel: UILabel?
    var secondaryLabel: UILabel?
    var myConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit(){
        let font = UIFont.systemFontOfSize(16);
        
        primaryLabel = UILabel(frame: CGRectZero)
        primaryLabel?.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel?.numberOfLines = 0
        primaryLabel?.font = font
        self.contentView.addSubview(primaryLabel!)
        
        secondaryLabel = UILabel(frame: CGRectZero)
        secondaryLabel?.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel?.numberOfLines = 0
        secondaryLabel?.font = font
        self.contentView.addSubview(secondaryLabel!)
        
        self.setNeedsUpdateConstraints()
    }
    
    override func setNeedsUpdateConstraints() {
        if self.myConstraints.count > 0 {
            self.contentView.removeConstraints(self.myConstraints)
        }
        
        myConstraints = []
        super.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        if self.myConstraints.count > 0 {
            super.updateConstraints()
            return
        }
        
        myConstraints = []
        let views = ["primaryLabel": primaryLabel!, "secondaryLabel": secondaryLabel!]
        let metrics = ["Left": 0, "Top": 0, "Right": 0, "Bottom": 0]
        
        myConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-Left-[primaryLabel]-(>=10)-[secondaryLabel]-Right-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views)
        myConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-Top-[primaryLabel]-Bottom-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views)
        self.contentView.addConstraints(myConstraints)
        super.updateConstraints()
    }
}
