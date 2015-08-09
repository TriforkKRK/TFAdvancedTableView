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

#import "TFTargetMultiplexerIntention.h"

@implementation TFTargetMultiplexerIntention

#pragma mark - Interface Properties

- (void)setPolicySetting:(NSString *)policySetting
{
    TFTargetMultiplexingPolicy policy = TFTargetMultiplexingPolicyToAll;
    if ([policySetting isEqualToString:@"ToAll"] || policySetting.length == 0) {    // default
        policy = TFTargetMultiplexingPolicyToAll;
    }
    else if ([policySetting isEqualToString:@"ToResponding"]) {
        policy = TFTargetMultiplexingPolicyToResponding;
    }
    else if ([policySetting isEqualToString:@"ToOnlyOne"]) {
        policy = TFTargetMultiplexingPolicyToOnlyOne;
    }
    else {
        NSAssert1(NO, @"Policy: %@ is not supported", policySetting);
    }
    
    _policy = policy;
}

#pragma mark - Overriden

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    if (!sig) {
        for (id obj in self.targets) {
            if ((sig = [obj methodSignatureForSelector:sel])) {
                break;
            }
        }
    }
    return sig;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) return YES;

    for (id obj in self.targets) {
        if ([obj respondsToSelector:aSelector]) return YES;
    }
    
    return NO;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    BOOL responded = NO;
    
    switch (self.policy) {
        case TFTargetMultiplexingPolicyToAll:
            for (id obj in self.targets)
            {
                NSAssert2([obj respondsToSelector:anInvocation.selector], @"Multiplexing policy is set to <All> but one of the targets: %@ doesn't respond to this selector: %@", obj, NSStringFromSelector(anInvocation.selector));
                
                [anInvocation invokeWithTarget:obj];
                responded = YES;
            }
            break;
        
        case TFTargetMultiplexingPolicyToResponding:
            for (id obj in self.targets)
            {
                if ([obj respondsToSelector:anInvocation.selector]) {
                    [anInvocation invokeWithTarget:obj];
                    responded = YES;
                }
            }
            break;
            
        case TFTargetMultiplexingPolicyToOnlyOne:

            for (id obj in self.targets)
            {
                if ([obj respondsToSelector:anInvocation.selector]) {
                    NSAssert1(!responded, @"Multiplexing policy is set to <OnlyOne> whereas more than one target responds to selector: %@", NSStringFromSelector(anInvocation.selector));
                    
                    [anInvocation invokeWithTarget:obj];
                    responded = YES;
                }
            }
            break;

        default:
            break;
    }

    NSAssert1(responded, @"There was no target that would respond to: %@", NSStringFromSelector(anInvocation.selector));
}

@end