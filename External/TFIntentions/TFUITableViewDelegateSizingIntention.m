/*
 * Created by Krzysztof Profic on 17/10/14.
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

#import "TFUITableViewDelegateSizingIntention.h"

#define DEFAULT_ROW_HEIGHT 44
#define DEFAULT_HEADER_FOOTER_HEIGHT 60

@interface TFUITableViewDelegateSizingIntention()
@property (nonatomic, strong) NSMutableDictionary * sizingCells;
@property (nonatomic, strong) NSMutableDictionary * sizingCellWidthConstraints;
@end

@implementation TFUITableViewDelegateSizingIntention

#pragma mark - Overrriden

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
     
- (void)didRecieveMemoryWarning
{
    _sizingCells = nil;
    _sizingCellWidthConstraints = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat separatorHeight = (self.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) ? (1.0f / [[UIScreen mainScreen] scale]) : 0.f;
    CGFloat cellHeight = [self heightForBasicCellAtIndexPath:indexPath];
    if (cellHeight < 5.0f) {
        NSLog(@"Warning: cell height for indexPath: %@ seem too small: %f, using default instead", indexPath, cellHeight);
        cellHeight = DEFAULT_ROW_HEIGHT;
    }
    CGFloat height = cellHeight + separatorHeight;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
// TODO
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
// TODO
    return 44;
}

#pragma mark - Private Properties

- (NSMutableDictionary *)sizingCells
{
    if (_sizingCells == nil) {
        _sizingCells = [NSMutableDictionary dictionary];
    }
    return _sizingCells;
}

- (NSMutableDictionary *)sizingCellWidthConstraints
{
    if (_sizingCellWidthConstraints == nil) {
        _sizingCellWidthConstraints = [NSMutableDictionary dictionary];
    }
    return _sizingCellWidthConstraints;
}


#pragma mark - Private Methods

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.tableView, @"TableView can not be nil");
    NSAssert([self.delegate conformsToProtocol:@protocol(TFUITableViewDelegateCellSizingIntentionDelegate)], @"dataSource needs to conform to TFUITableViewCellSizing protocol");
    
    id sizingCell = [self sizingCellAtIndexPath:indexPath];
    [self.delegate cellSizingIntetion:self configureCell:sizingCell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    // base layout system calculations on a contentView instead of a cell
    // this makes it independent of what UIKit does with table view cell (e.g. adds standard size constraints 320x44)
    [sizingCell.contentView setNeedsLayout];
    [sizingCell.contentView layoutIfNeeded];
    
    return [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (id)sizingCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * reuseId = [self.delegate cellSizingIntention:self reuseIdentifierAtIndexPath:indexPath];
    id sizingCell = self.sizingCells[reuseId];
    if (sizingCell == nil) {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:reuseId];
        NSAssert(sizingCell, @"Can't be nil");
        self.sizingCells[reuseId] = sizingCell;
        
        NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:((UITableViewCell *)sizingCell).contentView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:0];
        
        UIView * contentView = ((UITableViewCell *)sizingCell).contentView;
        contentView.translatesAutoresizingMaskIntoConstraints = NO; // disregard constraints generated from mask
        [contentView addConstraint:constraint]; // add constraints on the lowest level view possible
        
        self.sizingCellWidthConstraints[reuseId] = constraint;
    }
    
    NSLayoutConstraint * constraint = (NSLayoutConstraint *)self.sizingCellWidthConstraints[reuseId];
    constraint.constant = self.tableView.bounds.size.width;
    
    return sizingCell;
}

@end
