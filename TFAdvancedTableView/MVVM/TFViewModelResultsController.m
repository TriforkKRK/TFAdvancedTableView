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

#import "TFViewModelResultsController.h"
#import "TFSectionInfo.h"
#import "TFReuseStrategyObjectClassToViewClass.h"
#import "TFSectionViewModel.h"
@import ObjectiveC.runtime;
@import UIKit.UINib;
@import UIKit.UITableViewHeaderFooterView;

// Onlt used for folding changes so far
@interface TFMutableSimpleDeltaResult : NSObject<TFViewModelDeltaResult>
@property (nonatomic, strong) NSMutableIndexSet * deletedSectionsIndexSet;
@property (nonatomic, strong) NSMutableIndexSet * insertedSectionsIndexSet;
@property (nonatomic, strong) NSMutableIndexSet * refreshedSectionsIndexSet;
@property (nonatomic, strong) NSMutableArray * deletedRowsIndexPaths;
@property (nonatomic, strong) NSMutableArray * insertedRowsIndexPaths;
@property (nonatomic, strong) NSMutableArray * refreshedRowsIndexPaths;
@end

@implementation TFMutableSimpleDeltaResult

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deletedSectionsIndexSet = [[NSMutableIndexSet alloc] init];
        _insertedSectionsIndexSet = [[NSMutableIndexSet alloc] init];
        _refreshedSectionsIndexSet = [[NSMutableIndexSet alloc] init];
        _deletedRowsIndexPaths = [[NSMutableArray alloc] init];
        _insertedRowsIndexPaths = [[NSMutableArray alloc] init];
        _refreshedRowsIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)hasRowUpdates
{
    return self.deletedRowsIndexPaths.count > 0 || self.refreshedRowsIndexPaths.count > 0 || self.insertedRowsIndexPaths.count > 0;
}

@end


@implementation TFViewModelResultsController
@synthesize tf_nextResponder = _nextInteractor;

@synthesize delegate;

- (NSObject<TFResponding> *)tf_nextResponder
{
    return self.delegate;
}

- (instancetype)initWithReuseStrategy:(id<TFTableViewReusing, NSObject>)strategy
{
    NSParameterAssert([strategy conformsToProtocol:@protocol(TFTableViewReusing)]);
    self = [super init];
    if (self) {
        _reuseStrategy = strategy;
    }
    
    return self;
}

+ (instancetype)withMapping:(NSDictionary *)mapping
{
    id<TFTableViewReusing> reuseStrategy = [[TFReuseStrategyObjectClassToViewClass alloc] initWithObjectToViewsMapping:mapping];
    TFViewModelResultsController * viewModelController = [[self alloc] initWithReuseStrategy:reuseStrategy];
    return viewModelController;
}

- (void)setSections:(NSArray<TFSectionViewModel *> *)sections
{
    NSArray * oldSections = _sections;
    [sections enumerateObjectsUsingBlock:^(TFSectionViewModel * section, NSUInteger idx, BOOL *stop) {
        section.tf_nextResponder = self;
    }];
    _sections = sections;
    
    id<TFViewModelDeltaResult> delta = [self.deltaProcessor findDeltaFrom:oldSections to:sections error:nil];
    if (!delta || ![self delegateSupportsBatchSectionUpdates] || ([delta hasRowUpdates] && ![self delegateSupportsBatchRowUpdates])){
        [self.delegate providerDidReload:self];
        return;
    }
    [self applyDelta:delta];
}

- (BOOL)delegateSupportsBatchSectionUpdates
{
    return ([self.delegate respondsToSelector:@selector(provider:performBatchUpdate:complete:)] &&
            [self.delegate respondsToSelector:@selector(provider:didRemoveSections:)] &&
            [self.delegate respondsToSelector:@selector(provider:didRefreshSections:)] &&
            [self.delegate respondsToSelector:@selector(provider:didInsertSections:)]);
}

- (BOOL)delegateSupportsBatchRowUpdates
{
    return ([self.delegate respondsToSelector:@selector(provider:performBatchUpdate:complete:)] &&
            [self.delegate respondsToSelector:@selector(provider:didRemoveItemsAtIndexPaths:)] &&
            [self.delegate respondsToSelector:@selector(provider:didRemoveItemsAtIndexPaths:)] &&
            [self.delegate respondsToSelector:@selector(provider:didInsertItemsAtIndexPaths:)]);
}

- (void)applyDelta:(id<TFViewModelDeltaResult>)delta
{
    NSParameterAssert(delta);
    //  there is a delta processor, it has produced delta results and delegate supports all of these updates
    //  Inspired by http://ios-blog.co.uk/tutorials/updating-uitableview-with-a-dynamic-data-source/
    __weak typeof(self) weakSelf = self;
    [self.delegate provider:self performBatchUpdate:^{
        if ([delta deletedSectionsIndexSet].count > 0) {
            [weakSelf.delegate provider:weakSelf didRemoveSections:[delta deletedSectionsIndexSet]];
        }
        if ([delta deletedRowsIndexPaths].count > 0){
            [weakSelf.delegate provider:weakSelf didRemoveItemsAtIndexPaths:[delta deletedRowsIndexPaths]];
        }
        
        if ([delta refreshedSectionsIndexSet].count > 0) {
            [weakSelf.delegate provider:weakSelf didRefreshSections:[delta refreshedSectionsIndexSet]];
        }
        if ([delta refreshedRowsIndexPaths].count > 0){
            [weakSelf.delegate provider:weakSelf didRefreshItemsAtIndexPaths:[delta refreshedRowsIndexPaths]];
        }
        
        if ([delta insertedSectionsIndexSet].count > 0) {
            [weakSelf.delegate provider:weakSelf didInsertSections:[delta insertedSectionsIndexSet]];
        }
        if ([delta insertedRowsIndexPaths].count > 0){
            [weakSelf.delegate provider:weakSelf didInsertItemsAtIndexPaths:[delta insertedRowsIndexPaths]];
        }
    } complete:nil];
}

- (id<TFViewModelDeltaResult>)foldingDeltaForSection:(TFSectionViewModel *)section
{
    NSUInteger sectionIndex = [self.sections indexOfObject:section];
    NSAssert(sectionIndex != NSNotFound, @"Section: %@ not found on provider", section);
    
    TFMutableSimpleDeltaResult * delta = [[TFMutableSimpleDeltaResult alloc] init];
    
    for (NSUInteger i = [section numberOfObjectsWhenFolded]; i < [section rows].count; i++){
        NSIndexPath * ip = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
        if (section.isFolded) {
            [delta.deletedRowsIndexPaths addObject:ip];
        }
        else {
            [delta.insertedRowsIndexPaths addObject:ip];
        }
    }
    
    for (NSUInteger i = 0; i < [section numberOfObjectsWhenFolded]; i++){
        [delta.refreshedRowsIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
    }
    
    return delta;
}

#pragma mark - TFDynamicDataProviding

- (id<TFConfiguring>)viewConfiguratorForObjectType:(Class)type
{
    return self.viewConfigurators[NSStringFromClass(type)];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sections[indexPath.section] objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
    for (TFSectionViewModel * section in self.sections) {
        for (NSUInteger i = 0; i < [section numberOfObjects]; i++) {
            if (object == [section objectAtIndex:i]) {
                return [NSIndexPath indexPathForRow:i inSection:[self.sections indexOfObject:section]];
            }
        }
    }
    
    return nil;
}

#pragma mark - TFSectionViewModelResponding

- (void)foldingDidChangeOnSectionViewModel:(TFSectionViewModel *)sectionViewModel
{
    NSParameterAssert([sectionViewModel isKindOfClass:[TFSectionViewModel class]]);
    
    [self applyDelta:[self foldingDeltaForSection:sectionViewModel]];
}

//- (void)interactable:(id<TFFoldable>)interactable requestsSelectionWithSender:(id)sender
//{
//#warning hmm, śliski temat.. może responder chain ?
//    if ([self.delegate respondsToSelector:@selector(interactable:requestsSelectionWithSender:)]) {
//        [(id)self.delegate interactable:interactable requestsSelectionWithSender:sender];
//    }
//}
//

// TODO: In Swift this would be 2 generic methods
- (void)removeViewModel:(id<TFViewModel>)viewModel
{
    if ([viewModel isKindOfClass:[TFSectionViewModel class]]){
        NSUInteger sectionIndex = [self.sections indexOfObject:(TFSectionViewModel *)viewModel];
        NSAssert(sectionIndex != NSNotFound, @"Section: %@ not found on provider", viewModel);
        if (![self.delegate respondsToSelector:@selector(provider:didRemoveSections:)]) return;
        
        NSMutableArray * sections = [self.sections mutableCopy];
        [sections removeObject:viewModel];
        _sections = [sections copy];    // we could call setter if we had deltaProcessor
        [self.delegate provider:self didRemoveSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        return;
    }
    else if ([viewModel conformsToProtocol:@protocol(TFSectionItemInfo)])
    {
        NSIndexPath * indexPath = [self indexPathForObject:(id<TFSectionItemInfo>)viewModel];
        
        // indexPath may be nil for headers/footers for example
        if (indexPath != nil && [self.delegate respondsToSelector:@selector(provider:didRemoveItemsAtIndexPaths:)]) {
            NSMutableArray * sections = [self.sections mutableCopy];
            TFSectionViewModel * sectionViewModel = sections[indexPath.section];
            NSMutableArray * rows = [sectionViewModel.rows mutableCopy];
            [rows removeObject:viewModel];
            sectionViewModel.rows = [rows copy];
            [self.delegate provider:self didRemoveItemsAtIndexPaths:@[indexPath]];
            return;
        }
    }
    
    // looks like this case is it's not supported here, pass up
    [self tf_sendAction:@selector(removeViewModel:) to:@protocol(TFSectionViewModelResponding)];
}

@end
