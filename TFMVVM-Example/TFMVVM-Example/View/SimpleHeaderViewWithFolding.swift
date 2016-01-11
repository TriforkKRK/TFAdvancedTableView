//
//  SimpleHeaderViewWithFolding.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 11.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

// TODO rename "withSelection
class SimpleHeaderViewWithFolding: UITableViewHeaderFooterView, TFConfiguring {
    var primaryLabel: UILabel?
    var tgr: UITapGestureRecognizer?
    var observedSection: TFSectionViewModel?
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
        self.observedSection?.removeObserver(self, forKeyPath: "folded", context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard object as? TFSectionViewModel == self.observedSection else { return }
        guard keyPath == "folded" else { return }
        
        self.setupText(self.observedSection!)
    }
    
    // MARK: TFConfiguring
    func configureWith(object: AnyObject!) {
        guard let vm = object as? SimpleHeaderViewModel else { return }
        
        if (self.observedSection != nil) {
            self.observedSection?.removeObserver(self, forKeyPath: "folded", context: nil)
        }
        
        self.observedSection = vm.sectionViewModel
        self.observedSection?.addObserver(self, forKeyPath: "folded", options: .New, context: nil)
        self.setupText(vm.sectionViewModel!)
        
        // folded
        self.tgr?.removeTarget(nil, action: nil)
        self.tgr?.addTarget(vm.sectionViewModel!, action: "toggleFolding:")
        
        // removing
        self.removeButton?.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
        self.removeButton?.addTarget(vm.sectionViewModel, action: "delete:", forControlEvents: .TouchUpInside)
    }
    
    private func setupText(vm: TFSectionViewModel) {
        UIView.transitionWithView(self.primaryLabel!, duration:0.4, options:.TransitionCrossDissolve, animations:{
            self.primaryLabel!.text = vm.folded ? "Closed with \(vm.rows.count) elements, click to unfold" : (vm.header as! SimpleHeaderViewModel).title;
        }, completion:nil)
    }
}
