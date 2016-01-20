//
//  SimpleHeaderViewWithFolding.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 11.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

@objc class HeaderViewWithTextAndSelection: UITableViewHeaderFooterView {
    var primaryLabel: UILabel?
    var tgr: UITapGestureRecognizer?
    var removeButton: UIButton?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit(){
        tgr = UITapGestureRecognizer(target: nil, action: nil)
        self.addGestureRecognizer(tgr!)
        
        self.contentView.backgroundColor = UIColor.blackColor()
        primaryLabel = UILabel()
        primaryLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16);
        primaryLabel?.textColor = UIColor.whiteColor()
        primaryLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(primaryLabel!)
        
        removeButton = UIButton(type: .Custom)
        removeButton?.setTitle("[Remove]", forState: .Normal)
        removeButton?.translatesAutoresizingMaskIntoConstraints = false
        removeButton?.sizeToFit()
        self.contentView.addSubview(removeButton!)
        
        self.contentView.frame = CGRectMake(0, 0, 100, 44)
        
        let dic = ["primaryLabel": primaryLabel!, "removeButton": removeButton!]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryLabel]|", options:.AlignAllBaseline, metrics:nil, views:dic))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[removeButton]|", options:.AlignAllBaseline, metrics:nil, views:dic))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[primaryLabel]-[removeButton]|", options:.AlignAllBaseline, metrics:nil, views:dic))
    }

    deinit {
        self.tgr?.removeTarget(nil, action: nil)
        self.removeButton?.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
    }
    
    override func prepareForReuse() {
        self.tgr?.removeTarget(nil, action: nil)
        self.removeButton?.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
    }
    
    func setupText(text: String) {
        UIView.transitionWithView(self.primaryLabel!, duration:0.4, options:.TransitionCrossDissolve, animations:{
            self.primaryLabel!.text = text
        }, completion:nil)
    }
}
