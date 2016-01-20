//
//  ViewContollerS.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 07.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

typealias Section = TFSectionViewModel
typealias Row = TFSectionItemViewModel
typealias Header = TFSectionItemViewModel
typealias Footer = TFSectionItemViewModel

class ViewContoller: UIViewController, TFDynamicTableViewDataSourceDelegate, UIAlertViewDelegate {
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
        let rc = MyResultsController()
        rc.sections = MyMVVMDao.viewModelSetNr1()
        return rc
    }()
    
    @IBAction func editClicked(sender: AnyObject) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    @IBAction func changeDataButtonClicked(sender: AnyObject) {
        self.viewModelController.sections = MyMVVMDao.viewModelSetNr2()
    }
    //MARK: - TFDynamicTableViewDataSourceDelegate
    
    var selectedObject: TFSectionItemInfo?
    func dynamicDataSource(dataSource: TFDynamicTableViewDataSource, didSelectObject object: TFSectionItemInfo) {
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

private class MyResultsController: ViewModelResultsController {
    init() {
        super.init(configurators: CellConfigurator({(cell: CellWithText, vm: RowViewModel) -> () in
            // simple setup or RX bindings
            cell.primaryLabel?.text = vm.name
            cell.backgroundColor = vm.bgdColor
        }).and({ (header: HeaderViewWithTextAndSelection, vm: HeaderViewModel) -> () in
            header.setupText(vm.title)
            
            header.tgr?.addTarget(vm.sectionViewModel!, action: "toggleFolding:")
            header.removeButton?.addTarget(vm.sectionViewModel, action: "delete:", forControlEvents: .TouchUpInside)
        }))
        
        // TODO add SelfConfigurableCell, where Cell conforms to TFConfiguring
        //            .withMapping([
        ////            NSStringFromClass(RowViewModel.self): SelfConfigurableCellWithText.self,  // uncomment this line (and comment out the next one) to use self configurable Cell instead of viewConfigurators
        //            NSStringFromClass(RowViewModel.self): CellWithText.self,
        //            NSStringFromClass(HeaderViewModel.self): HeaderViewWithTextAndSelection.self
        //            ])
    }
}

private class MyMVVMDao {
    class func viewModelSetNr1() -> [Section] {
        let s1 = Section()   // TODO: rows, header
        s1.rows = [RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.1"),
            RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.2 with longer text, longer text, longer text, longer text, longer text, longer text \n\nNotice the height to be automatically calculated based on autolayout constraints...")]
        
        let h2 = HeaderViewModel(model: nil)
        h2.title = "Section 2 header, click to fold."
        
        let s2 = Section()
        s2.header = h2
        s2.rows = [RowViewModel(color: UIColor.darkGrayColor(), name: "Cell 2.1"),
            RowViewModel(color: UIColor.darkGrayColor(), name: "Cell nr 2.2 with longer text, longer text, longer text, longer text, longer text, longer text")]
        
        return [s1, s2]
    }

    class func viewModelSetNr2() -> [Section] {
        let s1 = Section()   // TODO: rows, header
        s1.rows = [RowViewModel(color: UIColor.lightGrayColor(), name: "New Cell nr 1.1"),
            RowViewModel(color: UIColor.lightGrayColor(), name: "New Cell nr 1.2")]
        
        let h1 = HeaderViewModel(model: nil)
        h1.title = "Section 1 header"
        s1.header = h1
        
        return [s1]
    }
}