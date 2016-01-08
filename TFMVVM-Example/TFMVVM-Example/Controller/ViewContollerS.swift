//
//  ViewContollerS.swift
//  TFMVVM-Example
//
//  Created by Krzysztof Profic on 07.01.2016.
//  Copyright © 2016 Trifork. All rights reserved.
//

import UIKit

class ViewContollerS: UIViewController, TFDynamicTableViewDataSourceDelegate, UIAlertViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var dynamicDataSource: TFDynamicTableViewDataSource!

    var selectedObject: TFSectionItemInfo?
    lazy var viewModelController: TFViewModelResultsController = {
        let rc = TFViewModelResultsController.withMapping([NSStringFromClass(SimpleRowViewModel.self): SimpleCell.self,
            NSStringFromClass(SimpleHeaderViewModel.self): SimpleHeaderViewWithFolding.self])
        
        let s1 = TFSectionViewModel()
        s1.rows = [SimpleRowViewModel(color: UIColor.redColor(), name: "c1"),
                   SimpleRowViewModel(color: UIColor.blueColor(), name: "c2 dhasdhsajkd ad ahd asjh")]
        
        let h2 = SimpleHeaderViewModel(model: nil)
        h2.title = "header 2, click to fold"
        
        let s2 = TFSectionViewModel()
        s2.header = h2
        s2.rows = [SimpleRowViewModel(color: UIColor.redColor(), name: "d1"),
                    SimpleRowViewModel(color: UIColor.blueColor(), name: "d2 dhasdhsajkd ad ahd asjh")]
        
        rc.sections = [s1, s2]
        return rc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dynamicDataSource.provider = self.viewModelController;
        self.dynamicDataSource.delegate = self
    }
    
    @IBAction func editClicked(sender: AnyObject) {
        self.tableView.editing = !self.tableView.editing
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
