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

// TODO decouple from ViewModel

class RowPresenter<View, VM where View: UITableViewCell, VM: TFViewModel>: TableViewItemPresenter<View, VM> {
    init(_ lambda: (view: View, vm: VM) -> ()) {
        super.init(lambda, type: TFTableViewItemPresenterType.Cell)
    }
}

class HeaderFooterPresenter<View, VM where View: UITableViewHeaderFooterView, VM: TFViewModel>: TableViewItemPresenter<View, VM> {
    init(_ lambda: (view: View, vm: VM) -> ()) {
        super.init(lambda, type: TFTableViewItemPresenterType.HeaderFooter)
    }
}

// MARK: Private

class TableViewItemPresenter<View, VM where View: UIView, VM: TFViewModel>: NSObject, TFTableViewItemPresenting {
    var configurationBlock: (view: View, viewModel: VM) -> ()
    let objectClass: AnyClass = VM.self
    let viewClass: AnyClass = View.self
    var type: TFTableViewItemPresenterType = .Unknown
    
    private init(_ lambda: (view: View, vm: VM) -> (), type _type: TFTableViewItemPresenterType) {
        configurationBlock = lambda
        type = _type
    }
    
    // MARK: TFConfiguring
    @objc func configure(view: UIView, withObject object: AnyObject) {
        // could be guard let with else return here but we assume that this would be a manifestation of important error thus its better to crash
        let vm = object as! VM
        let view = view as! View
        
        configurationBlock(view: view, viewModel: vm)
    }
}
