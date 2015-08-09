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

// Implementation is based on https://github.com/krzysztofzablocki/BehavioursExample

#import "TFOwnerableObject.h"
#import <objc/runtime.h>

@implementation TFOwnerableObject

- (void)setOwner:(id)owner
{
    [[self class] bindLifetimeOfObject:self toObject:owner];
}

- (id)owner
{
    return [self tf_currentOwner];
}

+ (void)bindLifetimeOfObject:(id)object toObject:(id)owner
{
    id oldOwner = [object tf_currentOwner];
    if (oldOwner == owner) return;  // same object, do nothing
    
    [object tf_releaseLifetimeFromObject:oldOwner];
    [object tf_bindLifetimeToObject:owner];
}

@end


@implementation NSObject(tf_owned)

- (id)tf_currentOwner
{
    return objc_getAssociatedObject(self, (__bridge void *)self);
}

- (void)tf_setCurrentOwner:(id)owner
{
    objc_setAssociatedObject(self, (__bridge void *)self, owner, OBJC_ASSOCIATION_ASSIGN);
}

- (void)tf_bindLifetimeToObject:(id)owner
{
    objc_setAssociatedObject(owner, (__bridge void *)self, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self tf_setCurrentOwner:owner];
}

- (void)tf_releaseLifetimeFromObject:(id)owner
{
    objc_setAssociatedObject(owner, (__bridge void *)self, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self tf_setCurrentOwner:nil];
}

@end