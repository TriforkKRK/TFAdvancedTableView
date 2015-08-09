/*
 * Created by Krzysztof Profic
 * Copyright (c) 2015 Trifork A/S.
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
 *
 * ABSTRACT:
 * It's a UITableViewDataSource that handles:
 * - REGISTERING of row, header/footer views based on provider.reuseStrategy
 * - DEQUEUEING those cells, headers and footers
 * - CONFIGURING cells, headers and footers with objects via. @see TFConfiguring
 *   protocol (if adopted)
 * - CELL SIZING trying to fetch row/header/footer height from corresponding objects
 *   via "height" selector. If not available it uses autolayout for calculations.
 *
 * TODO - delegation, no indexPaths
 *
 * The actual data information is being requested from @property provider.
 * That has been extracted as a separate object to favor composition over subclassing.
 * @property provider when assigned it's delegate is set to this object to track
 * updates and forward necessary inovocations to tableView 
 * UITableViewRowAnimationAutomatic is used as row animation type always.
 *
 */

@import UIKit.UITableView;
#import "TFDynamicDataProviding.h"
#import "TFSectionInfo.h"

@class TFDynamicTableViewDataSource;

@protocol TFDynamicTableViewDataSourceDelegate <NSObject>
@optional
- (void)dynamicDataSource:(TFDynamicTableViewDataSource *)dataSource didSelectObject:(id<TFSectionItemInfo, TFInteractable>)object;
#warning more delegation - each interaction ?
@end

@protocol TFUITableViewControlling <UITableViewDataSource, UITableViewDelegate>
@end


@interface TFDynamicTableViewDataSource : NSObject<TFUITableViewControlling, TFDynamicDataProvidingDelegate>
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet id<TFDynamicTableViewDataSourceDelegate> delegate;
@property (nonatomic, strong) IBOutlet id<TFDynamicDataProviding> provider;

- (instancetype)initWithProvider:(id<TFDynamicDataProviding>)provider NS_DESIGNATED_INITIALIZER;
@end
