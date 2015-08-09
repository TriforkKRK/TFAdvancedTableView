//
//  SimpleRowViewModel.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "SimpleRowViewModel.h"

@implementation SimpleRowViewModel

+ (instancetype)withColor:(UIColor *)color name:(NSString *)name
{
    SimpleRowViewModel * vm = [[[self class] alloc] initWithModel:nil];
    vm.bgdColor = color;
    vm.name = name;
    return vm;
}

@end
