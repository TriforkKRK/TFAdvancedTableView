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
 */

#import "TFDynamicTableViewDataSource.h"
#import "TFConfiguring.h"
#import "TFSectionInfo.h"
#import "TFInteractable.h"
#import "TFUITableViewDelegateSizingIntention.h"
@import UIKit.UITableViewHeaderFooterView;


#define TF_ASSERT_MAIN_THREAD NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

@interface TFDynamicTableViewDataSource()<TFUITableViewDelegateCellSizingIntentionDelegate, TFInteractionDelegate>
@property (nonatomic, strong) TFUITableViewDelegateSizingIntention * sizingIntention;
@property (nonatomic, assign) BOOL reusableViewsRegistered;
@end


@implementation TFDynamicTableViewDataSource

#pragma mark - Interface Methods

- (instancetype)initWithProvider:(id<TFDynamicDataProviding>)provider
{
    self = [super init];
    if (self) {
        [self setProvider:provider];
    }
    
    return self;
}

- (void)setProvider:(id<TFDynamicDataProviding, TFTableViewReusing>)provider
{
    _provider = provider;
    _provider.delegate = self;
}

- (void)registerReusableViewsIfNeeded:(UITableView *)tableView
{
    NSParameterAssert(self.provider.reuseStrategy);
    if (self.reusableViewsRegistered) return;
    
    self.reusableViewsRegistered = YES;
    [self.provider.reuseStrategy registerReusableViewsOnTableView:tableView];
}

#pragma mark - TFUITableViewDelegateCellSizingIntentionDelegate

- (void)cellSizingIntetion:(TFUITableViewDelegateSizingIntention *)intention configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell conformsToProtocol:@protocol(TFConfiguring)]) {
        [cell configureWith:[self.provider objectAtIndexPath:indexPath]];
    }
}

- (NSString *)cellSizingIntention:(TFUITableViewDelegateSizingIntention *)intention reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.provider.reuseStrategy reuseIdentifierForObject:[self.provider objectAtIndexPath:indexPath]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(self.provider);
    [self registerReusableViewsIfNeeded:tableView];
    
    return self.provider.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<TFSectionInfo> sectionInfo = self.provider.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.provider objectAtIndexPath:indexPath];
    UITableViewCell<TFConfiguring> * cell = [tableView dequeueReusableCellWithIdentifier:[self.provider.reuseStrategy reuseIdentifierForObject:obj]];
    if ([cell conformsToProtocol:@protocol(TFConfiguring)]) {
        [cell configureWith:obj];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.provider objectAtIndexPath:indexPath];
    return [object conformsToProtocol:@protocol(TFInteractable)];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id<TFInteractable> object = (id<TFInteractable>)[self.provider objectAtIndexPath:indexPath];
        if ([object respondsToSelector:@selector(remove:)]) {
            [object remove:self];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TFSectionItemInfo> object = [self.provider objectAtIndexPath:indexPath];
    if ([object respondsToSelector:@selector(height)]) {
        return object.height;
    }
    
    return [self.sizingIntention tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    id<TFSectionInfo> sectionInfo = self.provider.sections[section];
    if (sectionInfo.header == nil) return CGFLOAT_MIN;  // no header
    
    if ([sectionInfo.header respondsToSelector:@selector(height)]) {
        return sectionInfo.header.height;
    }
    
    return [self.sizingIntention tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    id<TFSectionInfo> sectionInfo = self.provider.sections[section];
    if (sectionInfo.footer == nil) return CGFLOAT_MIN;  // no footer

    if ([sectionInfo.footer respondsToSelector:@selector(height)]) {
        return sectionInfo.footer.height;
    }
    
    return [self.sizingIntention tableView:tableView heightForFooterInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id<TFSectionInfo> sectionInfo = self.provider.sections[section];
    if (sectionInfo.header == nil) return nil;
    
    UITableViewHeaderFooterView<TFConfiguring> * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self.provider.reuseStrategy reuseIdentifierForObject:sectionInfo.header]];
    if ([headerView conformsToProtocol:@protocol(TFConfiguring)]) {
        [headerView configureWith:sectionInfo.header];
    }
        
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    id<TFSectionInfo> sectionInfo = self.provider.sections[section];
    if (sectionInfo.footer == nil) return nil;
    
    UITableViewHeaderFooterView<TFConfiguring> * footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self.provider.reuseStrategy reuseIdentifierForObject:sectionInfo.footer]];
    if ([footerView conformsToProtocol:@protocol(TFConfiguring)]) {
        [footerView configureWith:sectionInfo.footer];
    }
    
    return footerView;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TFInteractable> object = (id<TFInteractable>)[self.provider objectAtIndexPath:indexPath];
    BOOL supportsSelection = [object conformsToProtocol:@protocol(TFInteractable)] && [object respondsToSelector:@selector(select:)];
    if (!supportsSelection) return nil; // disable selection
    
    [object select:self];
    return indexPath;
}

#pragma mark - TFDynamicDataProvidingDelegate

- (void)provider:(id<TFDynamicDataProviding>)provider didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:newIndexPath];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didInsertSections:(NSIndexSet *)sections
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didRemoveSections:(NSIndexSet *)sections
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didMoveSection:(NSInteger)section toSection:(NSInteger)newSection
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView moveSection:section toSection:newSection];
}

- (void)provider:(id<TFDynamicDataProviding>)provider didRefreshSections:(NSIndexSet *)sections
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)providerDidReload:(id<TFDynamicDataProviding>)provider
{   TF_ASSERT_MAIN_THREAD;
    [self.tableView reloadData];
}

- (void)provider:(id<TFDynamicDataProviding>)provider performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{   TF_ASSERT_MAIN_THREAD;
    if (!update) return;
    
    [self.tableView beginUpdates];
    update();
    [self.tableView endUpdates];

    if (complete) complete();
}

#pragma mark - TFInteractionDelegate

- (void)interactable:(id<TFInteractable>)interactable requestsSelectionWithSender:(id)sender
{
    NSIndexPath * indexPath = [self.provider indexPathForObject:interactable];
    if ([interactable isSelected]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

        [self.delegate dynamicDataSource:self didSelectObject:(id)interactable];
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Private

- (TFUITableViewDelegateSizingIntention *)sizingIntention
{
    if (_sizingIntention == nil) {
        _sizingIntention = [[TFUITableViewDelegateSizingIntention alloc] init];
        _sizingIntention.tableView = self.tableView;
        _sizingIntention.delegate = self;
    }
    
    return _sizingIntention;
}

@end
