//
//  SimpleCell.m
//  TFMVVM-Example
//
//  Created by Krzysztof on 08/08/2015.
//  Copyright (c) 2015 Trifork. All rights reserved.
//

#import "SimpleCell.h"
#import "TFMVVM_Example-Swift.h"


@interface SimpleCell ()
@property (nonatomic, strong, readwrite) UILabel *primaryLabel;
@property (nonatomic, strong, readwrite) UILabel *secondaryLabel;
@property (nonatomic, strong) NSMutableArray *constraints;
@end

@implementation SimpleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self)
        return nil;
    
    [self setup];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    [self setup];
    return self;
}

- (void)setup
{
    UIView *contentView = self.contentView;
    UIFont *defaultFont = [UIFont systemFontOfSize:22];
    
    _primaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _primaryLabel.numberOfLines = 0;
    _primaryLabel.font = defaultFont;
    [contentView addSubview:_primaryLabel];
    
    _secondaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _secondaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _secondaryLabel.numberOfLines = 0;
    _secondaryLabel.font = defaultFont;
    [contentView addSubview:_secondaryLabel];
    
    [self setNeedsUpdateConstraints]; // will call updateConstraints at the right time
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }
    
    UIView *contentView = self.contentView;
    
    _constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_primaryLabel, _secondaryLabel);
    NSDictionary *metrics = @{
                              @"Left" : @(0),
                              @"Top" : @(0),
                              @"Right" : @(0),
                              @"Bottom" : @(0)
                              };
    
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-Left-[_primaryLabel]-(>=10)-[_secondaryLabel]-Right-|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:views]];
    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-Top-[_primaryLabel]-Bottom-|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:views]];
//    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-Top-[_secondaryLabel]-Bottom-|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:views]];

    [contentView addConstraints:_constraints];
    [super updateConstraints];
}

- (void)setNeedsUpdateConstraints
{
    if (_constraints)
        [self.contentView removeConstraints:_constraints];
    _constraints = nil;
    [super setNeedsUpdateConstraints];
}


- (void)configureWith:(SimpleRowViewModel *)rowViewModel
{
    NSParameterAssert([rowViewModel isKindOfClass:[SimpleRowViewModel class]]);
    
    self.backgroundColor = rowViewModel.bgdColor;
    self.primaryLabel.text = rowViewModel.name;
}

@end
