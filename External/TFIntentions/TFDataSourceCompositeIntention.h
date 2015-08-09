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

#import "TFIntention.h"

@protocol TFDataSourceComposing <UITableViewDataSource, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray * dataSources;

- (id<UITableViewDataSource, UICollectionViewDataSource>)dataSourceAtIndexPath:(NSIndexPath *)indexPath view:(id)view outIndexPath:(out NSIndexPath **)outIndexPath;
- (NSInteger)numberOfSectionsBeforeDataSource:(id)dataSource inView:(id)view;
- (void)setNeedsReload:(id)dataSource;
@end


@protocol TFComposableDataSource <UITableViewDataSource, UICollectionViewDataSource>

@optional   // UITableViewDataSource methods responsible for cell height calculations, if implemented all child datasources need to implement that
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

extern NSString * const kTFDataSourceModeMerge; // =  @"merge"
extern NSString * const kTFDataSourceModeChain;  // =  @"chain"

IB_DESIGNABLE
@interface TFDataSourceCompositeIntention : TFIntention<TFDataSourceComposing>
@property (weak, nonatomic) IBOutlet UITableView * tableView;
/**
 * Underlying dataSources must use dequeueReusableCellWithIdentifier:kCellIdentifier instead of dequeueReusableCellWithIdentifier:forIndexPath:
 * the later one may cause crash as the indexPath passed is sometimes different on the data source comparing to the tableView.
 */
@property (strong, nonatomic) IBOutletCollection(id) NSArray * dataSources; // should be a list of TFComposableDataSource
@property (strong, nonatomic) IBInspectable NSString * mode;    // @see kTFDataSourceModeMerge (default), kTFDataSourceModeJoin

/**
 *  This method is supported as long as all underlying @see dataSources also implement it
 *  IMPORTANT: it will pass nil as tableView / collectionView when talking to dataSources
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface NSObject (TFDataSourceComposing)
@property (nonatomic, weak) id<TFDataSourceComposing> compositionDelegate;

- (void)setNeedsReload;
@end