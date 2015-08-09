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

#import "TFIntention.h"

@class TFUITableViewDelegateSizingIntention;

@protocol TFUITableViewDelegateCellSizingIntentionDelegate <NSObject>
- (void)cellSizingIntetion:(TFUITableViewDelegateSizingIntention *)intention configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellSizingIntention:(TFUITableViewDelegateSizingIntention *)intention reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath;
@end

/**
 *  Adds the missing iOS7 feature that we already have on iOS8
 *  To automatically calculate UITableView row heights based on autolayout constraints and cell content.
 *  Supports only one row type at the moment.
 */
@interface TFUITableViewDelegateSizingIntention : TFIntention<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet id<TFUITableViewDelegateCellSizingIntentionDelegate> delegate;
@end
