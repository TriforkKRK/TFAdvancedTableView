//
//  ViewContollerS.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 07.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

class ViewContoller: UIViewController, TFDynamicTableViewDataSourceDelegate, UIAlertViewDelegate {
    @IBOutlet weak var tableView: UITableView!                      // simply a reference
    @IBOutlet var dynamicDataSource: TFDynamicTableViewDataSource!    // created as an object in Stowyboard with its outlets already connected, you can also create it manually
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PRESENTATION
        // Describe the Cell and Header/Footer presentation by providing a list of configuration lambdas
        // A construct shown below laverages Swift generics so you can just specify as argument types the cell and object types being configured
        self.dynamicDataSource.presenters = [
            RowPresenter{(cell: CellWithText, vm: RowViewModel) in
                // simple setup or RX bindings
                cell.primaryLabel?.text = vm.name
                cell.backgroundColor = vm.bgdColor
            },
            HeaderFooterPresenter{ (header: HeaderViewWithTextAndSelection, vm: HeaderViewModel) in
                header.setupText(vm.title)
            
                header.tgr?.addTarget(vm.sectionViewModel!, action: "toggleFolding:")
                header.removeButton?.addTarget(vm.sectionViewModel, action: "delete:", forControlEvents: .TouchUpInside)
            }
        ]
        
        // DATA
        // "Source" is a shorthand for having an in place MVVM based FetchedResults controller, it's usefull for testing and creating simple datasets
        // Usually one will have it's own instance of TFViewModelResultsController instead
        self.dynamicDataSource.provider = Source([
            Section { (section : MyCustomSection) in // if you specify the section argument type it will instantiate your own subclass instead of the default "SectionType"
                section.rows = [
                    RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.1"),
                    RowViewModel(color: UIColor.lightGrayColor(), name: "Cell nr 1.2 with longer text, longer text, longer text, longer text, longer text, longer text \n\nNotice the height to be automatically calculated based on autolayout constraints...")
                ]
                
                print("\(section.name) added")       // indeed it is an instance of MyCustomSection
            },
            Section { section in   // default SectionType
                section.rows = [
                    RowViewModel(color: UIColor.darkGrayColor(), name: "Cell 2.1"),
                    RowViewModel(color: UIColor.darkGrayColor(), name: "Cell nr 2.2 with longer text, longer text, longer text, longer text, longer text, longer text")
                ]
                    
                let h2 = HeaderViewModel(model: nil)
                h2.title = "Section 2 header, click to fold."
                section.header = h2
            }
        ])
        
        // self.dynamicDataSource.delegate = self   // this can also be set from storyboard
    }
    
    @IBAction func editClicked(sender: AnyObject) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    @IBAction func changeDataButtonClicked(sender: AnyObject) {
        //self.viewModelController.sections = MyMVVMDao.viewModelSetNr2()
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

class MyCustomSection : ViewModelSection {
    let name = "Custom section"
}


private class MyMVVMDao {

    class func viewModelSetNr2() -> [ViewModelSection] {
//        let s1 = Section()   // TODO: rows, header
//        s1.rows = [RowViewModel(color: UIColor.lightGrayColor(), name: "New Cell nr 1.1"),
//            RowViewModel(color: UIColor.lightGrayColor(), name: "New Cell nr 1.2")]
//        
//        let h1 = HeaderViewModel(model: nil)
//        h1.title = "Section 1 header"
//        s1.header = h1
        
        return []
    }
}