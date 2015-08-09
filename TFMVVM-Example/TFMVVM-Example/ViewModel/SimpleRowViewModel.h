//
//  SimpleRowViewModel.h
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "TFBaseViewModel.h"
#import <UIKit/UIKit.h>

@interface SimpleRowViewModel : TFBaseViewModel
@property (nonatomic, strong) UIColor * bgdColor;
@property (nonatomic, strong) NSString * name;

+ (instancetype)withColor:(UIColor *)color name:(NSString *)name;
@end
