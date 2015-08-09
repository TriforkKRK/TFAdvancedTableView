//
//  UITextFieldTextObserveIntention.h
//  Intentions
//
//  Created by Krzysztof Profic on 30/09/14.
//  Copyright (c) 2014 Krzysztof Profic. All rights reserved.
//

#import "TFIntention.h"

/**
 *  UITextField observe that updates target objects' value stored under "targetKeyPath" with content of sourceObject text
 *  It also sends UIControlEventValueChanged whenever a change is detected
 */
IB_DESIGNABLE
@interface UITextFieldObserveIntention : TFIntention

// All the following properties should be set only once
@property (strong, nonatomic) IBOutlet UITextField * sourceObject;
@property (strong, nonatomic) IBOutlet id target;
@property (copy, nonatomic) IBInspectable NSString *targetKeyPath;

@end
