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
 * A container ViewModel to represent a section.
 * It contains of rows each of which is a TFViewModel and header/footer objects
 * of the same type. If any of those items conforms to TFSectionItemViewModel
 * then sectionViewModel property is set to such objects.
 *
 * This class implements TFFoldable protocol by simply changing @property rows
 * to be an empty array when folded.
 *
 * The most common way of implementing section folding requires:
 * 1) using header ViewModel that conforms TFSectionItemViewModel protocol
 * 2) Implementing action on section header view that will call:
 *      - header.sectionViewModel toggleFolding:(id)sender
 */

@import Foundation;
#import "TFViewModel.h"
#import "TFSectionInfo.h"
#import "TFInteractionChain.h"

@interface TFSectionViewModel : NSObject <TFViewModel, TFSectionInfo>
@property (nonatomic, strong) id<TFViewModel, TFSectionItemInfo> header;
@property (nonatomic, strong) id<TFViewModel, TFSectionItemInfo> footer;
@property (nonatomic, strong) NSArray * rows;       // holds id<TFViewModel, TFSectionItemInfo>

// folding
@property (nonatomic, readonly, getter=isFolded) BOOL folded;
@property (nonatomic, assign) NSUInteger numberOfObjectsWhenFolded;
- (IBAction)fold:(id)sender;
- (IBAction)unfold:(id)sender;
- (IBAction)toggleFolding:(id)sender;

// deletion
- (IBAction)delete:(id)sender NS_REQUIRES_SUPER;    // you have to call super at the end of your implementation
@end


// whoever in the interaction chain is implementing that protocol will be used
@protocol TFSectionViewModelResponding <TFViewModelResponding>
@optional
- (void)foldingDidChangeOnSectionViewModel:(TFSectionViewModel *)sectionViewModel;
@end
