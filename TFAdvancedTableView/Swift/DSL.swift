//
//  DSL.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 20/01/16.
//  Copyright © 2016 Trifork. All rights reserved.
//

// MARK: DSL - Domain Specific Language for Swift
// MARK: - Presentation

class RowPresenter<View, VM where View: UITableViewCell, VM: NSObjectProtocol>: TFTableViewItemBlockPresenter {  // https://forums.developer.apple.com/thread/7394
    init(_ lambda: (view: View, vm: VM) -> Void) {
        super.init(objectClass: VM.self, viewClass: View.self, type: TFTableViewItemPresenterType.Cell, block:{v,m in
            lambda(view: v as! View, vm: m as! VM)
        })
    }
}

class HeaderFooterPresenter<View, VM where View: UITableViewHeaderFooterView, VM: NSObjectProtocol>: TFTableViewItemBlockPresenter {
    init(_ lambda: (header: View, vm: VM) -> Void) {
        super.init(objectClass: VM.self, viewClass: View.self, type: TFTableViewItemPresenterType.HeaderFooter, block:{v,m in
            lambda(header: v as! View, vm: m as! VM)
        })
    }
}


// MARK: - Data

// Source
typealias ViewModelSource = TFViewModelResultsController
func Source<T: ViewModelSource>(@noescape closure: (T) -> Void) -> T { return DefaultInitializableBuilder(closure) }
func Source<T: ViewModelSource>(sections: [TFSectionViewModel]) -> T { return Source { source in source.sections = sections }}

// Section
typealias ViewModelSection = TFSectionViewModel
func Section<T: ViewModelSection>(@noescape closure: (T) -> Void) -> T { return DefaultInitializableBuilder(closure) }

typealias Row = TFSectionItemViewModel
typealias Header = TFSectionItemViewModel
typealias Footer = TFSectionItemViewModel



// MARK: - Private

protocol DefaultInitializable { init() }

private func DefaultInitializableBuilder<T: DefaultInitializable>(@noescape closure: (T) -> Void) -> T {
    let t = T()
    closure(t)
    return t
}

extension ViewModelSource: DefaultInitializable {}
extension TFSectionViewModel: DefaultInitializable {}

