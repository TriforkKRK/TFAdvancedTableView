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

#import "TFBaseViewModel.h"
#import "TFSectionViewModel.h"

@interface TFBaseViewModel()
@property (nonatomic, readwrite, getter=isSelected) BOOL selected;
@end

@implementation TFBaseViewModel
@synthesize sectionViewModel;
@synthesize tf_nextResponder = _nextInteractor;

- (instancetype)initWithModel:(id)model
{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithModel:nil];
}

- (id<TFResponding>)tf_nextResponder
{
    return self.sectionViewModel;
}

+ (Protocol *)responderProtocol
{
    return @protocol(TFViewModelResponding);
}

#pragma mark - TFInteractable
//
//- (void)select:(id)sender
//{
//    if (self.isSelected) return;
//    
//    [self toggleSelection:sender];
//}
//
//- (void)deselect:(id)sender
//{
//    if (!self.isSelected) return;
//    
//    [self toggleSelection:sender];
//}
//
//- (void)toggleSelection:(id)sender
//{
//    self.selected = !self.selected;
//    
//    if ([self.interactionDelegate respondsToSelector:@selector(interactable:requestsSelectionWithSender:)]) {
//        [self.interactionDelegate interactable:self requestsSelectionWithSender:sender];
//    }
//}

- (IBAction)delete:(id)sender
{
    [self tf_sendAction:@selector(removeViewModel:)];
}

@end
