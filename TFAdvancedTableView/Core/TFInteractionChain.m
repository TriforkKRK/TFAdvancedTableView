//
//  TFInteractionChain.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 12/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "TFInteractionChain.h"


@implementation NSObject (TFResponding)

- (nullable id)tf_responderForAction:(nonnull SEL)action ofProtocol:(nonnull Protocol *)protocol
{
    NSAssert([self conformsToProtocol:@protocol(TFResponding)], nil);
    
    if ([(id)self conformsToProtocol:protocol] && [(id)self respondsToSelector:action]) return self;
    
    return [[(id)self tf_nextResponder] tf_responderForAction:action ofProtocol:protocol];
}

// it should only be used  on ???
// it surpresses the selector leak warning which may be dangerous
// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
- (void)tf_sendAction:(nonnull SEL)action to:(nonnull Protocol *)protocol from:(nullable id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id target = [self tf_responderForAction:action ofProtocol:protocol];
    [target performSelector:action withObject:sender];
#pragma clang diagnostic pop
}

- (void)tf_sendAction:(nonnull SEL)action to:(nonnull Protocol *)protocol
{
    [self tf_sendAction:action to:protocol from:self];
}

- (void)tf_sendAction:(nonnull SEL)action
{
    NSAssert([[self class] respondsToSelector:@selector(responderProtocol)], @"responderProtocol method required for this call");
    
    Protocol * protocol = [(id)[self class] responderProtocol];
    [self tf_sendAction:action to:protocol];
}

@end


@implementation UIViewController(TFRespondingCompilance)

- (NSObject<TFResponding> *)tf_nextResponder
{
    // next responder ?
    return self.parentViewController;
}

@end