/*
* Created by Krzysztof Profic
* Copyright (c) 2016 Trifork A/S.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

class CellConfigurator<View, VM where View: UITableViewCell, VM: TFViewModel>: ViewConfigurator<View, VM> {
    init(_ block: (view: View, vm: VM) -> ()) {
        super.init(block, type: ViewConfiguratorType.Cell)
    }
}

class HeaderFooterConfigurator<View, VM where View: UITableViewHeaderFooterView, VM: TFViewModel>: ViewConfigurator<View, VM> {
    init(_ block: (view: View, vm: VM) -> ()) {
        super.init(block, type: ViewConfiguratorType.HeaderFooter)
    }
}



@objc enum ViewConfiguratorType: Int {
    case Unknown
    case Cell
    case HeaderFooter
}

@objc protocol ViewModelConfigurable: TFConfiguring {
    var viewModelClass: AnyClass { get }
    var viewClass: AnyClass { get }
    var configuratorType: ViewConfiguratorType { get }
}

class ViewConfigurator<View, VM where View: UIView, VM: TFViewModel>: NSObject, ViewModelConfigurable {
    var configurationBlock: (view: View, viewModel: VM) -> ()
    let viewModelClass: AnyClass = VM.self
    let viewClass: AnyClass = View.self
    var configuratorType: ViewConfiguratorType = .Unknown
    
    private init(_ block: (view: View, vm: VM) -> (), type: ViewConfiguratorType) {
        configurationBlock = block
        configuratorType = type
    }
    
    // MARK: TFConfiguring
    @objc func configure(view: UIView, withObject object: AnyObject) {
        // could be guard let with else return here but we assume that this would be a manifestation of important error thus its better to crash
        let vm = object as! VM
        let view = view as! View
        
        configurationBlock(view: view, viewModel: vm)
    }
    
    // MARK: Builder pattern
    func and<View2, VM2 where View2: UITableViewCell, VM2: TFViewModel>(block: (cell: View2, vm: VM2) -> ()) -> Array<ViewModelConfigurable> {
        return [self].and(block)
    }
    func and<View2, VM2 where View2: UITableViewHeaderFooterView, VM2: TFViewModel>(block: (cell: View2, vm: VM2) -> ()) -> Array<ViewModelConfigurable> {
        return [self].and(block)
    }
}

extension Array where Element: ViewModelConfigurable {
    func and<View, VM where View: UITableViewCell, VM: TFViewModel>(block: (cell: View, vm: VM) -> ()) -> Array {
        return self + [CellConfigurator<View, VM>(block) as! Element]
    }
    func and<View, VM where View: UITableViewHeaderFooterView, VM: TFViewModel>(block: (cell: View, vm: VM) -> ()) -> Array {
        return self + [HeaderFooterConfigurator<View, VM>(block) as! Element]
    }
}
