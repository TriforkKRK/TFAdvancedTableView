//
//  Core.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 19.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import Foundation

@objc protocol ViewModelConfigurable: TFConfiguring {
    var viewModelClass: AnyClass { get }
    var viewClass: AnyClass { get }
}

class ViewConfigurator<View, VM where View: UIView, VM: TFViewModel>: NSObject, ViewModelConfigurable {
    let configurationBlock: (view: View, viewModel: VM) -> ()
    let viewModelClass: AnyClass = VM.self
    let viewClass: AnyClass = View.self
    
    init(_ block: (view: View, vm: VM) -> ()) {
        configurationBlock = block
    }
    
    // MARK: TFConfiguring
    @objc func configure(view: UIView, withObject object: AnyObject) {
        // could be guard let with else return here but we assume that this would be a manifestation of important error thus its better to crash
        let vm = object as! VM
        let view = view as! View
        
        configurationBlock(view: view, viewModel: vm)
    }
    
    // MARK: Builder pattern
    func and<View2, VM2 where View2: UIView, VM2: TFViewModel>(block: (cell: View2, vm: VM2) -> ()) -> Array<ViewModelConfigurable> {
        return [self].and(block)
    }
}

extension Array where Element: ViewModelConfigurable {
    func and<View, VM where View: UIView, VM: TFViewModel>(block: (cell: View, vm: VM) -> ()) -> Array {
        return self + [ViewConfigurator<View, VM>(block) as! Element]
    }
    
    func dictionaryRepresentation() -> [String: ViewModelConfigurable] {
        return self.reduce([String: ViewModelConfigurable]()){(var result: [String: ViewModelConfigurable], configuration: ViewModelConfigurable) -> [String: ViewModelConfigurable] in
            result[NSStringFromClass(configuration.viewModelClass)] = configuration
            return result
        }
    }
}

class AutomaticReuseStrategy: TFTableViewReusing {
    let _configurators: [ViewModelConfigurable]
    
    init(configurators: [ViewModelConfigurable]) {
        _configurators = configurators
    }
    
    private func reuseIdentifierForClass(type: AnyClass) -> String {
        return String(type)
    }
    
    // MARK: TFTableViewReusing
    @objc func reuseIdentifierForObject(obj: NSObjectProtocol) -> String {
        // _stdlib_getDemangledTypeName could also be used to identify the dynamic type
        return self.reuseIdentifierForClass(obj.dynamicType)
    }
    
    @objc func registerReusableViewsOnTableView(tableView: UITableView) {
        _configurators.forEach{ tableView.registerClass($0.viewClass, forCellReuseIdentifier: self.reuseIdentifierForClass($0.viewModelClass)) }
    }
}