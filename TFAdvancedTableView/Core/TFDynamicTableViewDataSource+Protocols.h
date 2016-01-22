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
 * Inspired by NSFetchedResultsSectionInfo
 *
 * header & footer:
 * Abstract objects supposed to visualy describe section header and footer.
 * They can simply be NSStings giving header/footer names
 * or some more sophisticated structures like ViewModels.
 *
 * ABSTRACT:
 * Inspired by NSFetchedResultsControllerDelegate and AAPLDataSourceDelegate
 * Protocol for an object that will provide updates about data changing
 * in @see TFDynamicDataProviding
 */

@import CoreGraphics.CGBase;
@import UIKit.UITableView;
#import "TFInteractionChain.h"
@protocol TFDynamicTableViewResultsProvidingDelegate;
@protocol TFSectionInfo;
@protocol TFSectionItemInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Reuse Strategy

@protocol TFDynamicTableViewReusing
- (NSString *)reuseIdentifierForObject:(id<NSObject>)obj;
- (void)registerReusableViewsOnTableView:(UITableView *)tableView;
@end



#pragma mark - Results Provider

@protocol TFDynamicTableViewResultsProviding <TFResponding>
@property (nonatomic, readonly) NSArray<NSObject<TFSectionInfo> *> * sections;
@property (nonatomic, readwrite, nullable) id<TFDynamicTableViewResultsProvidingDelegate> delegate;  /**< all the delegate methods are supposed to be called on MainThread */

- (nullable id<TFSectionItemInfo>)objectAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForObject:(id<TFSectionItemInfo>)object;

@optional
- (IBAction)refresh:(nullable id)sender;
@end


@protocol TFSectionItemInfo <NSObject>
@optional
@property (nonatomic, readonly) CGFloat height;
- (IBAction)remove:(nullable id)sender;
@end


@protocol TFSectionInfo <NSObject>
@property (nonatomic, readonly) NSUInteger numberOfObjects;
- (nullable id<TFSectionItemInfo>)objectAtIndex:(NSUInteger)index;

@optional
@property (nonatomic, readonly, nullable) id<TFSectionItemInfo> header;
@property (nonatomic, readonly, nullable) id<TFSectionItemInfo> footer;

- (IBAction)remove:(nullable id)sender;
@end


@protocol TFDynamicTableViewResultsProvidingDelegate <TFResponding>
@required
// reload
- (void)providerDidReload:(id<TFDynamicTableViewResultsProviding>)provider;
@optional
// items
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didRemoveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didRefreshItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didInsertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath;
// sections
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didRemoveSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didRefreshSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didInsertSections:(NSIndexSet *)sections;
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;
// batch
- (void)provider:(id<TFDynamicTableViewResultsProviding>)provider performBatchUpdate:(dispatch_block_t)update complete:(nullable dispatch_block_t)complete;
@end



#pragma mark - Presenters

typedef NS_ENUM(NSUInteger, TFTableViewItemPresenterType) {
    TFTableViewItemPresenterTypeUnknown,
    TFTableViewItemPresenterTypeCell,
    TFTableViewItemPresenterTypeHeaderFooter,
};

// Views (Cells, Headers and Footers) that want to be self configurable should implement this
@protocol TFDynamicTableViewItemPresenting <NSObject>
/**
 *  Method required by TFConfiguring protocol, should implement configuring an object
 *  with @param object.
 *  Example: TFConfiguring is adopted by some UITableViewCell class, configure:withObject:
 *  does all the required configurations of the cell based on the values passed in @param object.
 *  @param view - in case the protocol is implemented straight by the cell this will simply be self
 *  however it is sometimes usefull to have other objects performing such configuration (eg. ViewController)
 *  so this param is also provided for higher flexibility.
 */
- (void)prepare:(UIView *)view forPresentationWithObject:(id)object;
@end


// A generic Presenter<O, V> means presentation of O as V
@protocol TFDynamicTableViewItemGenericPresenting <TFDynamicTableViewItemPresenting>
@property (nonatomic, readonly) Class objectClass;
@property (nonatomic, readonly) Class viewClass;
@property (nonatomic, readonly) TFTableViewItemPresenterType type;
@end


NS_ASSUME_NONNULL_END
