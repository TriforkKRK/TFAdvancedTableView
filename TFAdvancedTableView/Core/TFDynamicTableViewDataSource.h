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
#import "TFSectionInfo.h"
#import "TFInteractionChain.h"

/**
*
* ABSTRACT:
* Inspired by NSFetchedResultsControllerDelegate and AAPLDataSourceDelegate
* Protocol for an object that will provide updates about data changing
* in @see TFDynamicDataProviding
*/
@protocol TFDynamicDataProviding;
@protocol TFDynamicDataProvidingDelegate <NSObject>
@required
// reload
- (void)providerDidReload:(nonnull id<TFDynamicDataProviding>)provider;
@optional
// items
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didRemoveItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didRefreshItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didInsertItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didMoveItemAtIndexPath:(nonnull NSIndexPath *)fromIndexPath toIndexPath:(nonnull NSIndexPath *)newIndexPath;
// sections
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didRemoveSections:(nonnull NSIndexSet *)sections;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didRefreshSections:(nonnull NSIndexSet *)sections;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didInsertSections:(nonnull NSIndexSet *)sections;
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;
// batch
- (void)provider:(nonnull id<TFDynamicDataProviding>)provider performBatchUpdate:(nonnull dispatch_block_t)update complete:(nullable dispatch_block_t)complete;
@end



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

@protocol TFDynamicDataProviding <TFResponding>
@property (nonatomic, readonly, nonnull) NSArray<NSObject<TFSectionInfo> *> * sections;
@property (nonatomic, readwrite, nullable) id<TFDynamicDataProvidingDelegate, TFResponding> delegate;  /**< all the delegate methods are supposed to be called on MainThread */

- (nullable id<TFSectionItemInfo>)objectAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForObject:(nonnull id<TFSectionItemInfo>)object;

@optional
- (IBAction)refresh:(nullable id)sender;
@end


@class TFDynamicTableViewDataSource;
@protocol TFDynamicTableViewDataSourceDelegate <NSObject>
@optional
- (void)dynamicDataSource:(nonnull TFDynamicTableViewDataSource *)dataSource didSelectObject:(nonnull id<TFSectionItemInfo>)object;
// warning more delegation - each interaction
@end




@protocol TFTableViewReusing
- (nonnull NSString *)reuseIdentifierForObject:(nonnull id<NSObject>)obj;
- (void)registerReusableViewsOnTableView:(nonnull UITableView *)tableView;
@end



typedef NS_ENUM(NSUInteger, TFTableViewItemPresenterType) {
    TFTableViewItemPresenterTypeUnknown,
    TFTableViewItemPresenterTypeCell,
    TFTableViewItemPresenterTypeHeaderFooter,
};

@protocol TFTableViewItemPresenting <NSObject>
// A generic Presenter<O, V> means presentation of O as V
@property (nonatomic, readonly, nonnull) Class objectClass;
@property (nonatomic, readonly, nonnull) Class viewClass;
@property (nonatomic, readonly) TFTableViewItemPresenterType type;

/**
 *  Method required by TFConfiguring protocol, should implement configuring an object
 *  with @param object.
 *  Example: TFConfiguring is adopted by some UITableViewCell class, configure:withObject:
 *  does all the required configurations of the cell based on the values passed in @param object.
 *  @param view - in case the protocol is implemented straight by the cell this will simply be self
 *  however it is sometimes usefull to have other objects performing such configuration (eg. ViewController)
 *  so this param is also provided for higher flexibility.
 */
- (void)prepare:(nonnull UIView *)view forPresentationWithObject:(nonnull id)object;
@end

// TODO
@protocol TFTableViewItemSelfPresenting <NSObject>
- (void)prepareForPresentationWithObject:(nonnull id)object;
@end


@interface TFTableViewItemBlockPresenter<__covariant View:UIView *, VM> : NSObject<TFTableViewItemPresenting>
@property (nonatomic, readonly, nonnull) Class objectClass;
@property (nonatomic, readonly, nonnull) Class viewClass;
@property (nonatomic, readonly) TFTableViewItemPresenterType type;
@property (nonatomic, copy, nullable) void (^configurationBlock)( View _Nonnull  , VM _Nonnull);

// objectClass has to be equal to VM
// viewClass has to be equal to View
- (nonnull instancetype)initWithObjectClass:(nonnull Class)objectClass viewClass:(nonnull Class)viewClass type:(TFTableViewItemPresenterType)type block:( void (^ _Nonnull )(View _Nonnull, VM _Nonnull))configurationBlock;
@end



// TableView Presenter (P from VIPER)
// jest TableViewDataSourcem
@interface TFDynamicTableViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate, TFDynamicDataProvidingDelegate, TFResponding>
@property (nonatomic, weak, nullable) IBOutlet UITableView * tableView;
@property (nonatomic, weak, nullable) IBOutlet id<TFDynamicTableViewDataSourceDelegate> delegate;
@property (nonatomic, strong, nullable) IBOutlet id<TFDynamicDataProviding> provider;               // rename FRC
@property (nonatomic, strong, nonnull) id<TFTableViewReusing> reuseStrategy;
@property (nonatomic, strong, nullable) NSArray<id<TFTableViewItemPresenting>> * presenters;

- (nonnull instancetype)initWithPresenters:(nullable NSArray<id<TFTableViewItemPresenting>> *)presenters NS_DESIGNATED_INITIALIZER;    // object class string to presenter instance
- (nonnull instancetype)init NS_UNAVAILABLE;

@end


