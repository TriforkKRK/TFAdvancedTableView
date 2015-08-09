/*
 * Created by Krzysztof Profic on 06/11/14.
 * Copyright (c) 2014 Trifork A/S.
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

#import "TFDataSourceCompositeIntention.h"
#import <objc/runtime.h>

NSString * const kTFDataSourceModeMerge = @"merge";
NSString * const kTFDataSourceModeChain = @"chain";

@interface TFDataSourceCompositeIntention()
@property (nonatomic, strong) NSObject<TFDataSourceComposing> *implementation;
@end


@interface TFCompositeDataSourceMergeSectionsImpl : NSObject<TFDataSourceComposing>
@property (strong, nonatomic) NSArray * dataSources;
@end

@interface TFCompositeDataSourceChainSectionsImpl : NSObject<TFDataSourceComposing>
@property (strong, nonatomic) NSArray * dataSources;
@end


#pragma clang push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation TFDataSourceCompositeIntention

#pragma mark - Interface Methods

- (void)setMode:(NSString *)mode
{
    NSParameterAssert([mode isEqualToString:kTFDataSourceModeMerge] || [mode isEqualToString:kTFDataSourceModeChain]);
    
    if (mode == _mode) return;

    _mode = mode;
    _implementation = [self createImplementationForMode:mode];
}

- (void)setDataSources:(NSArray *)dataSources
{
    if (dataSources == _dataSources) return;
    
    for (NSObject * ds in dataSources) {
        [ds setCompositionDelegate:self];
    }
    _dataSources = dataSources;
    _implementation.dataSources = dataSources;
}

- (void)setNeedsReload:(id)dataSource
{
    // TODO: be more clever and reload only dataSource not the whole tableView
    [self.tableView reloadData];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * outIndexPath = nil;
    id ds = [self dataSourceAtIndexPath:indexPath view:nil outIndexPath:&outIndexPath];
    SEL sel = @selector(itemAtIndexPath:);
    if ([ds respondsToSelector:sel] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Underlying dataSource: %@ doesn't implement %@", ds, NSStringFromSelector(sel)];
        return nil;
    }
    
    return [ds itemAtIndexPath:outIndexPath];
}

#pragma mark - Overriden

- (instancetype)init
{
    self = [super init];
    if  (self) {
        [self setMode:kTFDataSourceModeMerge];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setMode:kTFDataSourceModeMerge];
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if (sig) return sig;
    
    return [self.implementation methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) return YES;

    return [self.implementation respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:self.implementation];
}

#pragma mark - Overriden (UITableViewDataSource)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:tableView cellAtIndexPath:indexPath];
}

#pragma mark - Overriden (UICollectionViewDataSource)

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self view:collectionView cellAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate - Cell Height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self.implementation dataSourceAtIndexPath:indexPath view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    NSAssert([ds respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)], @"Whenever CompositeDataSource is set as tableView.delegate it will handle cell heights, but for this feature to work, all the child datasources need to implement this method");
        
    return [ds tableView:tableView heightForRowAtIndexPath:shiftedIndexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self.implementation dataSourceAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        if (![ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            return nil; // no header
        }
        
        UITableViewHeaderFooterView * view = [[UITableViewHeaderFooterView alloc] init];  // try a default header
        view.textLabel.text = [ds tableView:tableView titleForHeaderInSection:section];
        return view;
    }
    
    return [ds tableView:tableView viewForHeaderInSection:shiftedIndexPath.section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self.implementation dataSourceAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        if (![ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            return CGFLOAT_MIN; // no header
        }
        
        return 20.0f; // default height
    }
    
    return [ds tableView:tableView heightForHeaderInSection:shiftedIndexPath.section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self.implementation dataSourceAtIndexPath:indexPath view:tableView outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if (![ds respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        return;
    }
    
    [ds tableView:tableView willDisplayCell:cell forRowAtIndexPath:shiftedIndexPath];
}

#pragma mark - Private Methods

- (id<TFDataSourceComposing>)createImplementationForMode:(NSString *)mode
{
    Class implClass = [mode isEqualToString:kTFDataSourceModeMerge] ? TFCompositeDataSourceMergeSectionsImpl.class : TFCompositeDataSourceChainSectionsImpl.class;
    
    NSObject<TFDataSourceComposing> * impl = [[implClass alloc] init];
    impl.dataSources = self.dataSources;
    return impl;
}

- (id)view:(id)view cellAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * shiftedIndexPath = nil;
    id ds = [self.implementation dataSourceAtIndexPath:indexPath view:view outIndexPath:&shiftedIndexPath];
    NSAssert(ds != nil && shiftedIndexPath != nil, @"Underlying data source nor indexPath can't be unknown at this point");
    
    if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
        return [ds tableView:view cellForRowAtIndexPath:shiftedIndexPath];
    }
    if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
        return [ds collectionView:view cellForItemAtIndexPath:shiftedIndexPath];
    }
    
    NSAssert(NO, @"Data source has to be either UITableViewDataSource or UICollectionViewDataSource");
    return nil;
}

@end

#pragma clang diagnostic pop



#pragma mark - Concrete Implementations

@implementation TFCompositeDataSourceMergeSectionsImpl

#pragma mark TFDataSourceComposing

- (id<UITableViewDataSource, UICollectionViewDataSource>)dataSourceAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath *__autoreleasing *)outIndexPath
{
    NSParameterAssert(view == nil || [view isKindOfClass:UITableView.class] || [view isKindOfClass:UICollectionView.class]);
    
    NSInteger previousObjectsCount = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger rows = 0;
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
            rows = [ds tableView:view numberOfRowsInSection:indexPath.section];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            rows = [ds collectionView:view numberOfItemsInSection:indexPath.section];
        }
        
        if (indexPath.row < previousObjectsCount + rows) {
            NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row-previousObjectsCount inSection:indexPath.section];
            if (outIndexPath != NULL) {
                *outIndexPath = shiftedIndexPath;
            }
            return ds;
        }
        
        previousObjectsCount += rows;
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Invalid indexPath: %@, can't locate underlying dataSource", indexPath];
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self view:tableView numberOfRowsInSection:section];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSectionsInView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self view:collectionView numberOfRowsInSection:section];
}

#pragma mark - Private Methods

- (NSInteger)numberOfSectionsInView:(id)view
{
    NSInteger maxNumSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:view];
        }
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [ds numberOfSectionsInCollectionView:view];
        }
        maxNumSections = MAX(maxNumSections, sections);
    }
    
    return maxNumSections;
}

- (NSInteger)view:(id)view numberOfRowsInSection:(NSInteger)section
{
    NSInteger sum = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (section >= sections) continue;
        
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]) {
            sum += [ds tableView:view numberOfRowsInSection:section];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            sum += [ds collectionView:view numberOfItemsInSection:section];
        }
    }

    return sum;
}

@end


@implementation TFCompositeDataSourceChainSectionsImpl

#pragma mark TFDataSourceComposing

- (NSInteger)numberOfSectionsBeforeDataSource:(id)dataSource inView:(id)view
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        if (ds == dataSource) break;
        
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        previousSections += sections;
    }
    
    return previousSections;
}

- (id<UITableViewDataSource, UICollectionViewDataSource>)dataSourceAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath *__autoreleasing *)outIndexPath
{
    NSParameterAssert(view == nil || [view isKindOfClass:UITableView.class] || [view isKindOfClass:UICollectionView.class]);
    
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (indexPath.section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSIndexPath * shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-previousSections];
        if (outIndexPath != NULL) {
            *outIndexPath = shiftedIndexPath;
        }
        return ds;
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Invalid indexPath: %@, can't locate underlying dataSource", indexPath];
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self view:tableView numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:tableView];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSString * title = nil;
        if ([ds respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
            title = [ds tableView:tableView titleForHeaderInSection:section-previousSections];
        }
        
        return title;
    }
    
    NSAssert(NO, @"Should never happen");
    return nil;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSectionsInView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self view:collectionView numberOfRowsInSection:section];
}

#pragma mark - Private Methods

- (NSInteger)numberOfSectionsInView:(id)view
{
    NSInteger numSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [ds numberOfSectionsInTableView:view];
        }
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [ds numberOfSectionsInCollectionView:view];
        }
        numSections += sections;
    }
    
    return numSections;
}

- (NSInteger)view:(id)view numberOfRowsInSection:(NSInteger)section
{
    NSInteger previousSections = 0;
    for (id<UITableViewDataSource, UICollectionViewDataSource> ds in self.dataSources) {
        NSInteger sections = 1;
        if ([ds respondsToSelector:@selector(numberOfSectionsInTableView:)]) sections = [ds numberOfSectionsInTableView:view];
        if ([ds respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) sections = [ds numberOfSectionsInCollectionView:view];
        
        if (section >= previousSections + sections)  {
            previousSections += sections;
            continue;
        }
        
        NSInteger rows = NSNotFound;
        if ([ds conformsToProtocol:@protocol(UITableViewDataSource)]){
            rows = [ds tableView:view numberOfRowsInSection:section-previousSections];
        }
        if ([ds conformsToProtocol:@protocol(UICollectionViewDataSource)]) {
            rows = [ds collectionView:view numberOfItemsInSection:section-previousSections];
        }

        return rows;
    }
    
    NSAssert(NO, @"Should never happen");
    return 0;
}

@end



@implementation NSObject (TFDataSourceComposing)

static void * compositionDelegateKey = &compositionDelegateKey;

- (void)setCompositionDelegate:(id<TFDataSourceComposing>)compositionDelegate
{
    objc_setAssociatedObject(self, compositionDelegateKey, compositionDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<TFDataSourceComposing>)compositionDelegate
{
    return objc_getAssociatedObject(self, compositionDelegateKey);
}

- (void)setNeedsReload
{
    [self.compositionDelegate setNeedsReload:self];
}

@end


