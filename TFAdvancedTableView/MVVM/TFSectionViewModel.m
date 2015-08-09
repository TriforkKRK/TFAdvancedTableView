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

#import "TFSectionViewModel.h"
#import "TFSectionItemViewModel.h"

@interface TFSectionViewModel()
@property (nonatomic, readwrite, getter=isFolded) BOOL folded;
@end

@implementation TFSectionViewModel
@synthesize foldingDelegate;
@synthesize rows=_rows;

#pragma mark - Interface Properties

- (void)setRows:(NSArray *)rows
{
    _rows = rows;
    
    [rows enumerateObjectsUsingBlock:^(id<TFSectionItemViewModel> row, NSUInteger idx, BOOL *stop) {
        if ([row conformsToProtocol:@protocol(TFSectionItemViewModel)]) {
            row.sectionViewModel = self;
        }
    }];
}

- (void)setHeader:(id<TFSectionItemViewModel>)header
{
    _header = header;
    
    if ([header conformsToProtocol:@protocol(TFSectionItemViewModel)]) {
        header.sectionViewModel = self;
    }
}

- (NSUInteger)numberOfObjectsWhenFolded
{
    return 0;
}

#pragma mark - TFSectionInfo

- (NSUInteger)numberOfObjects
{
    if (self.isFolded) return [self numberOfObjectsWhenFolded];
    
    return self.rows.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return self.rows[index];
}

#pragma mark - TFSectionFolding

- (IBAction)fold:(id)sender
{
    if (self.isFolded) return;
    
    [self toggleFolding:sender];
}

- (void)unfold:(id)sender
{
    if (!self.isFolded) return;
    
    [self toggleFolding:sender];
}

- (void)toggleFolding:(id)sender
{
    self.folded = !self.folded;
    
    if ([self.foldingDelegate respondsToSelector:@selector(sectionFoldingDidChange:)]){
        [self.foldingDelegate sectionFoldingDidChange:self];
    }
}

@end
