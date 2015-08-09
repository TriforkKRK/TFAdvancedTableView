//
//  SimpleHeaderFooterWithFolding.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "SimpleHeaderViewWithFolding.h"
#import "SimpleHeaderViewModel.h"
#import "TFSectionViewModel.h"

@interface SimpleHeaderViewWithFolding()
@property (nonatomic, strong) UILabel * primaryLabel;
@property (nonatomic, strong) UITapGestureRecognizer * tgr;
@property (nonatomic, strong) TFSectionViewModel * observedSection;
@property (nonatomic, strong) UIButton * removeButton;
@end

@implementation SimpleHeaderViewWithFolding

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setup];
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    [self setup];
    return self;
}

- (void)setup
{
    _tgr = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [self addGestureRecognizer:_tgr];
    
    self.contentView.backgroundColor = [UIColor blackColor];
    
    // Label
    _primaryLabel = [[UILabel alloc] init];
    _primaryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    _primaryLabel.textColor = [UIColor whiteColor];
    _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_primaryLabel];
    
    _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeButton setTitle:@"[Remove]" forState:UIControlStateNormal];
    [_removeButton sizeToFit];
    [self.contentView addSubview:_removeButton];
    _removeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.contentView.frame = CGRectMake(0, 0, 100, 44); // in order to don't get layout warnings
    
    NSDictionary * dic = NSDictionaryOfVariableBindings(_primaryLabel);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_primaryLabel]|" options:0 metrics:nil views:dic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_primaryLabel]|" options:0 metrics:nil views:dic]];
}

- (void)configureWith:(SimpleHeaderViewModel *)headerViewModel
{
    NSParameterAssert([headerViewModel conformsToProtocol:@protocol(TFSectionItemViewModel)]);

    if (self.observedSection) {
        [self.observedSection removeObserver:self forKeyPath:@"folded" context:NULL];
    }
    self.observedSection = headerViewModel.sectionViewModel;
    [self.observedSection addObserver:self forKeyPath:@"folded" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self setupText:headerViewModel.sectionViewModel];
    
    // folding
    [self.tgr removeTarget:nil action:nil];
    [self.tgr addTarget:headerViewModel.sectionViewModel action:@selector(toggleFolding:)];
    
    // removing
    [self.removeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.removeButton addTarget:headerViewModel.sectionViewModel action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupText:(TFSectionViewModel *)vm
{
    [UIView transitionWithView:self.primaryLabel duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.primaryLabel.text = vm.isFolded ?
            [NSString stringWithFormat:@"Closed with %lu elements, click to unfold", (unsigned long)[vm rows].count] :
            ((SimpleHeaderViewModel*)vm.header).title;
    } completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != self.observedSection) return;
    if (![keyPath isEqualToString:@"folded"]) return;
    
    [self setupText:object];
}


- (void)dealloc
{
    [self.tgr removeTarget:nil action:nil];
    [self.removeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    
    if (self.observedSection) {
        [self.observedSection removeObserver:self forKeyPath:@"folded" context:NULL];
    }
}
@end
