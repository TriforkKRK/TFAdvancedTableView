//
//  UITextFieldTextObserveIntention.m
//  Intentions
//
//  Created by Krzysztof Profic on 30/09/14.
//  Copyright (c) 2014 Krzysztof Profic. All rights reserved.
//

#import "UITextFieldObserveIntention.h"

@implementation UITextFieldObserveIntention

- (void)awakeFromNib
{
    [super awakeFromNib];

    // [self setup];
    // INFO: Setup code should be handled in awakeFromNib, however there is Apple Bug that causes this method to be called
    // before any IBOutlet connections are established whenever a backing store is storyboard not xib file:
    // http://www.openradar.me/18748242
    //
}

- (void)setSourceObject:(UITextField *)sourceObject
{    
    _sourceObject = sourceObject;
    
    // INFO: replaces awakeFromNib call
    [self setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:_sourceObject];
}

#pragma mark - Private

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeText:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.sourceObject];
}

#pragma mark - Notifications

- (void)textFieldDidChangeText:(id)sender
{
    if (self.targetKeyPath) {
        [self.target setValue:self.sourceObject.text forKeyPath:self.targetKeyPath];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
