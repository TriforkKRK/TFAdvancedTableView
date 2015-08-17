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
 * Inspired by NSFetchedResultsController
 *
 * Its a protocol describing objects that are supposed to serve DataSources by
 * providing them with:
 * - section data as an array of @protocol SectionInfo objects @see sections
 * - data updates via @see delegate
 * - reuse strategy
 *
 * @property sections
 * it returns an array of objects that implement the TFSectionInfo protocol.
 * It's expected that developers use the returned array when implementing the
 * following methods of the UITableViewDataSource protocol:
 * - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
 * - (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
 *
 * It extends TFInteractionDelegate to support common actions like:
 * - removal
 * - folding
 */

@import Foundation;
@import UIKit.UITableView;
#import "TFDynamicDataProvidingDelegate.h"
#import "TFTableViewReusing.h"
#import "TFSectionInfo.h"
#import "TFInteractionChain.h"

@protocol TFDynamicDataProviding <TFResponding>
@property (nonatomic, readonly) NSArray * sections;
@property (nonatomic, readwrite) id<TFDynamicDataProvidingDelegate, TFResponding> delegate;  /**< all the delegate methods are supposed to be called on MainThread */
@property (nonatomic, readonly) id<TFTableViewReusing> reuseStrategy;

- (id<TFSectionItemInfo>)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

@optional
- (IBAction)refresh:(id)sender;
@end
