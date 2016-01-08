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
 * An implementation of TFCellReusing protocol with a simple mapping from object
 * class names (represented as NSStrings) to view classes (Class). All the mappings are stored in
 * @property objectToViewMappings dictionary
 * It works with an assumption that there is one reuseId per object class.
 *
 * @property objectToViewMappings
 * it holds a mapping from Object classes to either:
 * 1) UITableViewCell or UITableViewHeaderFooterView class
 * 2) Nib name (NSString *) of file containing a subclass of UITableViewCell
 * Both cell/header classes and cells defined by Nib files need to conform to
 * @see TFConfiguring protocol.
 */

#import <Foundation/Foundation.h>
#import "TFTableViewReusing.h"

@interface TFReuseStrategyObjectClassToViewClass : NSObject<TFTableViewReusing>
@property (nonatomic, strong) NSDictionary<NSString *, Class> * objectToViewMappings;

- (instancetype)initWithObjectToViewsMapping:(NSDictionary<NSString *, Class> *)mappings NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end
