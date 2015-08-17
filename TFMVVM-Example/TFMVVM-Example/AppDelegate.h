//
//  AppDelegate.h
//  TFMVVM-Example
//
//  Created by Krzysztof on 01/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end




@interface UIView (fr)
- (id)findFirstResponder;
@end
