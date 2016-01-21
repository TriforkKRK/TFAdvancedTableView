//
//  DSL.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 20/01/16.
//  Copyright © 2016 Trifork. All rights reserved.
//

// DSL - Domain Specific Language for Swift

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


// MARK: Private

protocol DefaultInitializable { init() }

private func DefaultInitializableBuilder<T: DefaultInitializable>(@noescape closure: (T) -> Void) -> T {
    let t = T()
    closure(t)
    return t
}

extension ViewModelSource: DefaultInitializable {}
extension TFSectionViewModel: DefaultInitializable {}