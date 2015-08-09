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
 * Inspired by NSFetchedResultsControllerDelegate and AAPLDataSourceDelegate
 * Protocol for an object that will provide updates about data changing
 * in @see TFDynamicDataProviding
 */

@import Foundation;
@protocol TFDynamicDataProviding;

@protocol TFDynamicDataProvidingDelegate <NSObject>
@required
// reload
- (void)providerDidReload:(id<TFDynamicDataProviding>)provider;
@optional
// items
- (void)provider:(id<TFDynamicDataProviding>)provider didRemoveItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)provider:(id<TFDynamicDataProviding>)provider didRefreshItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)provider:(id<TFDynamicDataProviding>)provider didInsertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)provider:(id<TFDynamicDataProviding>)provider didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath;
// sections
- (void)provider:(id<TFDynamicDataProviding>)provider didRemoveSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicDataProviding>)provider didRefreshSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicDataProviding>)provider didInsertSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicDataProviding>)provider didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;
// batch
- (void)provider:(id<TFDynamicDataProviding>)provider performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;
@end
