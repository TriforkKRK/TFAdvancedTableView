//
//  ViewContollerS.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 07.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit


// TODO 2. DeductedReuseStratedyWithMappings : CellConfigurationBuilder, TFTableViewReusing

// TODO 4 - selection
// TODO 5 - KVO
// TODO 5. Move above to TFAdvancedTableview -> Swift

// MOve todos to github
// TableviewDelegate/Datasource trampoline
// TODO Rx
// TODO nib
// TODO prototype cells

// renderer

// https://github.com/yukiasai/Shoyu
// https://github.com/mamaral/Organic/tree/master/Organic/Source
// https://github.com/fastred/ConfigurableTableViewController/blob/master/Framework/CellConfigurator.swift

class ViewContollerS: UIViewController, TFDynamicTableViewDataSourceDelegate, UIAlertViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var dynamicDataSource: TFDynamicTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: self.tableView.dynamicDataSource.delegate = self   // lazy loaded TFDynamicTableViewDataSource <MVVM>
        // self.tableView.makeDynamic(provider: self.viewModelController)
        self.dynamicDataSource.provider = self.viewModelController
        self.dynamicDataSource.delegate = self
    }
    
    lazy var viewModelController: TFViewModelResultsController = {
        
        let configurators = [ViewConfigurator({(cell: CellWithText, vm: RowViewModel) -> () in
            // simple setup or RX bindings
            cell.primaryLabel?.text = vm.name
            cell.backgroundColor = vm.bgdColor
        })]
        //        ).and({ (header: HeaderViewWithTextAndSelection, vm: HeaderViewModel) -> () in
        //            header.setupText(vm.title)
        //
        //            header.tgr?.addTarget(vm.sectionViewModel!, action: "toggleFolding:")
        //            header.removeButton?.addTarget(vm.sectionViewModel, action: "delete:", forControlEvents: .TouchUpInside)
        //        })
        
        let rc = TFViewModelResultsController(reuseStrategy: AutomaticReuseStrategy(configurators: configurators))  // TODO default
        
        //            .withMapping([
        ////            NSStringFromClass(RowViewModel.self): SelfConfigurableCellWithText.self,  // uncomment this line (and comment out the next one) to use self configurable Cell instead of viewConfigurators
        //            NSStringFromClass(RowViewModel.self): CellWithText.self,
        //            NSStringFromClass(HeaderViewModel.self): HeaderViewWithTextAndSelection.self
        //            ])
        
        // mapping
        rc.viewConfigurators = configurators.dictionaryRepresentation() // TODO: delete!
        
        // data
        rc.sections = self.viewModelSetNr1()
        return rc
    }()
    
    // TODO move ViewModelDao
    func viewModelSetNr1() -> [TFSectionViewModel] {
        let s1 = TFSectionViewModel()   // TODO: rows, header
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
    
    
    @IBAction func editClicked(sender: AnyObject) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    //MARK: - TFDynamicTableViewDataSourceDelegate
    
    var selectedObject: TFSectionItemInfo?
    func dynamicDataSource(dataSource: TFDynamicTableViewDataSource!, didSelectObject object: TFSectionItemInfo!) {
        self.selectedObject = object
        UIAlertView(title: "Selected", message: "Do you want to remove\(object)" , delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES").show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex
        {
            self.selectedObject = nil
        }
    }
}
