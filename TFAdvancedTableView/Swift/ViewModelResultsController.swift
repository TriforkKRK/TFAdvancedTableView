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

class ViewModelResultsController: TFViewModelResultsController {

    init(configurators: [ViewModelConfigurable]) {
        super.init(reuseStrategy: ConfiguratorsDerivedReuseStrategy(configurators: configurators))
        
        // map configurators to a dictionary required by superclass
        self.viewConfigurators = configurators.reduce([String: ViewModelConfigurable]()){ var result = $0
            result[ConfiguratorsDerivedReuseStrategy.reuseIdentifierForClass($1.viewModelClass)] = $1
            return result
        }
    }
    
    override func viewConfiguratorForObjectType(type: AnyClass) -> TFConfiguring? {
        let rs =  super.reuseStrategy as! ConfiguratorsDerivedReuseStrategy
        return rs._configurators.filter({$0.viewModelClass === type}).first
    }
    
    private class ConfiguratorsDerivedReuseStrategy: TFTableViewReusing {
        let _configurators: [ViewModelConfigurable]
        
        init(configurators: [ViewModelConfigurable]) {
            _configurators = configurators
        }
        
        class func reuseIdentifierForClass(type: AnyClass) -> String {
            return NSStringFromClass(type)
        }
        
        // MARK: TFTableViewReusing
        @objc func reuseIdentifierForObject(obj: NSObjectProtocol) -> String {
            // _stdlib_getDemangledTypeName could also be used to identify the dynamic type
            return self.dynamicType.reuseIdentifierForClass(obj.dynamicType)
        }
        
        @objc func registerReusableViewsOnTableView(tableView: UITableView) {
            _configurators.forEach{
                switch $0.configuratorType {
                case .Cell:
                    tableView.registerClass($0.viewClass, forCellReuseIdentifier: self.dynamicType.reuseIdentifierForClass($0.viewModelClass))
                case .HeaderFooter:
                    tableView.registerClass($0.viewClass, forHeaderFooterViewReuseIdentifier: self.dynamicType.reuseIdentifierForClass($0.viewModelClass))
                default:
                    fatalError("Unsupported configurator type, only UITableView Cells and Headers/Footers are supported.")
                }
            }
        }
    }
}
