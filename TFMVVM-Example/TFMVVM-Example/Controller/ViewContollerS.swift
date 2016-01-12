//
//  ViewContollerS.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 07.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

@objc protocol ViewModelConfigurable: TFConfiguring {
    var viewModelClass: AnyClass { get }
}

class ViewConfigurator<View, VM where View: UIView, VM: TFViewModel>: NSObject, ViewModelConfigurable {
    let configurationBlock: (view: View, viewModel: VM) -> ()
    let viewModelClass: AnyClass
    
    init(_ block: (view: View, vm: VM) -> ()) {
        configurationBlock = block
        viewModelClass = VM.self
    }
    
    // MARK: TFConfiguring
    @objc func configure(view: UIView!, withObject object: AnyObject!) {
        // could be guard let with else return here but we assume that this would be a manifestation of important error thus its better to crash
        let vm = object as! VM
        let view = view as! View
        
        configurationBlock(view: view, viewModel: vm)
    }
}

// TODO 3. extension na array ViewModelConfigurable, protocol extension
class ViewConfiguratorBuilder {
    var configurators: [ViewModelConfigurable] = [ViewModelConfigurable]()
    
    func add<View, VM2 where View: UIView, VM2: TFViewModel>(block: (cell: View, vm: VM2) -> ()) -> ViewConfiguratorBuilder {
        configurators += [ViewConfigurator<View, VM2>(block) as ViewModelConfigurable]
        return self
    }
    
    func toDictionary() -> [String: ViewModelConfigurable] {
        return configurators.reduce([String: ViewModelConfigurable]()){(var result: [String: ViewModelConfigurable], configuration: ViewModelConfigurable) -> [String: ViewModelConfigurable] in
            result[NSStringFromClass(configuration.viewModelClass)] = configuration
            return result
        }
    }
}

// TODO 2. DeductedReuseStratedyWithMappings : CellConfigurationBuilder, TFTableViewReusing

// TODO 4 - selection
// TODO 5 - KVO
// TODO 5. Move above to TFAdvancedTableview -> Swift

// MOve todos to github
// TableviewDelegate/Datasource trampoline
// TODO Rx
// TODO nib
// TODO prototype cells

class ViewContollerS: UIViewController, TFDynamicTableViewDataSourceDelegate, UIAlertViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var dynamicDataSource: TFDynamicTableViewDataSource!

    var selectedObject: TFSectionItemInfo?
    lazy var viewModelController: TFViewModelResultsController = {
        let rc = TFViewModelResultsController.withMapping([
//            NSStringFromClass(RowViewModel.self): SelfConfigurableCellWithText.self,  // uncomment this line (and comment out the next one) to use self configurable Cell instead of viewConfigurators
            NSStringFromClass(RowViewModel.self): CellWithText.self,
            NSStringFromClass(HeaderViewModel.self): HeaderViewWithTextAndSelection.self
            ])
        
        // mapping
        rc.viewConfigurators = ViewConfiguratorBuilder().add({(cell: CellWithText, vm: RowViewModel) -> () in
            // simple setup or RX bindings
            cell.primaryLabel?.text = vm.name
            cell.backgroundColor = vm.bgdColor
        }).add({ (header: HeaderViewWithTextAndSelection, vm: HeaderViewModel) -> () in
            header.setupText(vm.title)
            
            header.tgr?.addTarget(vm.sectionViewModel!, action: "toggleFolding:")
            header.removeButton?.addTarget(vm.sectionViewModel, action: "delete:", forControlEvents: .TouchUpInside)
        }).toDictionary()
        
        // data
        rc.sections = self.viewModelSetNr1()
        return rc
    }()
    
    func viewModelSetNr1() -> [TFSectionViewModel] {
        let s1 = TFSectionViewModel()
        s1.rows = [RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.1"),
                   RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.2 with longer text, longer text, longer text, longer text, longer text, longer text \n\nNotice the height to be automatically calculated based on autolayout constraints...")]
        
        let h2 = HeaderViewModel(model: nil)
        h2.title = "Section 2 header, click to fold."
        
        let s2 = TFSectionViewModel()
        s2.header = h2
        s2.rows = [RowViewModel(color: UIColor.darkGrayColor(), name: "Cell 2.1"),
                   RowViewModel(color: UIColor.darkGrayColor(), name: "Cell nr 2.2 with longer text, longer text, longer text, longer text, longer text, longer text")]
        
        return [s1, s2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dynamicDataSource.provider = self.viewModelController
        self.dynamicDataSource.delegate = self
    }
    
    @IBAction func editClicked(sender: AnyObject) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    //MARK: - TFDynamicTableViewDataSourceDelegate
    
    func dynamicDataSource(dataSource: TFDynamicTableViewDataSource!, didSelectObject object: TFSectionItemInfo!) {
        self.selectedObject = object
        UIAlertView(title: "Selected", message: "Do you want to remove\(object)" , delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES").show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex
        {
            //self.selectedObject
            self.selectedObject = nil
        }
    }
}
