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

#import "TFReuseStrategyObjectClassToViewClass.h"
@import ObjectiveC.runtime;
@import UIKit.UINib;
@import UIKit.UITableViewHeaderFooterView;

@implementation TFReuseStrategyObjectClassToViewClass

- (instancetype)initWithObjectToViewsMapping:(NSDictionary<NSString *, Class>  *)mappings
{
    self = [super init];
    if (self) {
        _objectToViewMappings = mappings;
    }
    
    return self;
}

#pragma mark - TFCellReusing

- (NSString *)reuseIdentifierForObject:(id)obj
{
    Class class = [obj class];
    id cellClassName = [self objectToViewMappings][NSStringFromClass(class)];
    if (cellClassName == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't find mapping for class: %@", NSStringFromClass(class)];
        return nil;
    }
    
    if ([cellClassName isKindOfClass:[NSString class]]) {
        return cellClassName;
    }
    
    return NSStringFromClass(cellClassName);
}

- (void)registerReusableViewsOnTableView:(UITableView *)tableView
{
    [self.objectToViewMappings enumerateKeysAndObjectsUsingBlock:^(NSString * viewModelClassName, id cellClassOrNibName, BOOL *stop) {
        if ([cellClassOrNibName isKindOfClass:[NSString class]]) {      // cell nib
            [tableView registerNib:[UINib nibWithNibName:cellClassOrNibName bundle:nil] forCellReuseIdentifier:cellClassOrNibName];
            return;
        }
        
        Class superClass = class_getSuperclass(cellClassOrNibName);
        while (superClass != [NSObject class]) {
            if (superClass == [UITableViewHeaderFooterView class]) {    // header/footer class
                [tableView registerClass:cellClassOrNibName forHeaderFooterViewReuseIdentifier:NSStringFromClass(cellClassOrNibName)];
                return;
            }
            
            superClass = class_getSuperclass(superClass);
        }
        
        // cell class
        [tableView registerClass:cellClassOrNibName forCellReuseIdentifier:NSStringFromClass(cellClassOrNibName)];
    }];
}

@end
