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
 * It implements TFInteractionDelegate and sets self as interactionDelegate
 * for all row and sections that conform to TFInteractable protocol.
 * This way all actions (like section fold or cell removal) from ViewModels
 * cause corresponding actions sent to delegate (for instance reloading
 * section with rows temporarly removed when section gets folded)
 */


/**
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
#import "TFViewModelDeltaProcessing.h"
#import "TFInteractionChain.h"
#import "TFSectionViewModel.h"
#import "TFDynamicTableViewDataSource.h"

@interface TFViewModelResultsController : NSObject<TFDynamicTableViewResultsProviding, TFSectionViewModelResponding>
@property (nonatomic, strong, nullable) NSArray<TFSectionViewModel *> * sections;
@property (nonatomic, strong, nullable) id<TFViewModelDeltaProcessing> deltaProcessor;
@end
