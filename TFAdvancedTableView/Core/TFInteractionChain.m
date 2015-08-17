//
//  TFInteractionChain.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 12/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "TFInteractionChain.h"


@implementation NSObject (TFResponding)

- (id)tf_responderForAction:(SEL)action ofProtocol:(Protocol *)protocol
{
    NSAssert([self conformsToProtocol:@protocol(TFResponding)], nil);
    
    if ([[(id)self tf_nextResponder] conformsToProtocol:protocol] && [(id)self respondsToSelector:action]) return self;
    
    return [[(id)self tf_nextResponder] tf_responderForAction:action ofProtocol:protocol];
}

// it should only be used  on ???
// it surpresses the selector leak warning which may be dangerous
// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
- (void)tf_sendAction:(SEL)action to:(Protocol *)protocol from:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = [self tf_responderForAction:action ofProtocol:protocol];
    [target performSelector:action withObject:sender];
#pragma clang diagnostic pop
  
    // ?
//    [[UIApplication sharedApplication] sendAction:action to:target from:sender forEvent:nil];
}

- (void)tf_sendAction:(SEL)action to:(Protocol *)protocol
{
    [self tf_sendAction:action to:protocol from:self];
}

- (void)tf_sendResponderAction:(SEL)action
{
    NSAssert([[self class] respondsToSelector:@selector(responderProtocol)], @"responderProtocol method required for this call");
    
    Protocol * protocol = [(id)[self class] responderProtocol];
    [self tf_findTargetForProtocol:protocol andPerformAction:action];
}

@end


@implementation UIViewController(TFRespondingCompilance)

- (NSObject<TFResponding> *)tf_nextResponder
{
    // next responder ?
    return self.parentViewController;
}

@end