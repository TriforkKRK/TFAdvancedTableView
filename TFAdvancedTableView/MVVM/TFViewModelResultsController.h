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
 * Inspired by NSFetchedResultsController
 *
 * It implements TFInteractionDelegate and sets self as interactionDelegate
 * for all row and sections that conform to TFInteractable protocol.
 * This way all actions (like section fold or cell removal) from ViewModels
 * cause corresponding actions sent to delegate (for instance reloading
 * section with rows temporarly removed when section gets folded)
 */

@import Foundation;
#import "TFDynamicDataProviding.h"
#import "TFTableViewReusing.h"
#import "TFViewModelDeltaProcessing.h"
#import "TFInteractionChain.h"
#import "TFSectionViewModel.h"

@interface TFViewModelResultsController : NSObject<TFDynamicDataProviding, TFSectionViewModelResponding>
@property (nonatomic, strong) NSArray * sections;
@property (nonatomic, strong) id<TFTableViewReusing> reuseStrategy;
@property (nonatomic, strong) id<TFViewModelDeltaProcessing> deltaProcessor;

/** creates TFViewModelResultsController with TFReuseStrategyObjectClassToViewClass instance */
+ (instancetype)withMapping:(NSDictionary *)mapping;
- (instancetype)initWithReuseStrategy:(id<TFTableViewReusing>)strategy NS_DESIGNATED_INITIALIZER;
@end
