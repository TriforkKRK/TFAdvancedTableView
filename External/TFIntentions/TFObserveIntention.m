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

#import "TFObserveIntention.h"

@interface TFObserveIntention ()
@end

@implementation TFObserveIntention

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // [self setup];
    // INFO: Setup code should be handled in awakeFromNib, however there is Apple Bug that causes this method to be called
    // before any IBOutlet connections are established whenever a backing store is storyboard not xib file:
    // http://www.openradar.me/18748242
    //
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:self.sourceKeyPath]) {
        [self handleValueChanged];
    }
}

- (void)dealloc
{
    [_sourceObject removeObserver:self forKeyPath:_sourceKeyPath context:nil];
}

// TODO: explicit setters should be removed as soon as http://www.openradar.me/18748242 is fixed

- (void)setSourceObject:(id)sourceObject
{
    _sourceObject = sourceObject;
    
    // INFO: replaces awakeFromNib call
    if ([self IBOutletConnectionsEstablished]) {
        [self setup];
    }
}

- (void)setSourceKeyPath:(NSString *)sourceKeyPath
{
    _sourceKeyPath = sourceKeyPath;
    
    // INFO: replaces awakeFromNib call
    if ([self IBOutletConnectionsEstablished]) {
        [self setup];
    }
}

- (void)setTarget:(id)target
{
    _target = target;
    
    // INFO: replaces awakeFromNib call
    if ([self IBOutletConnectionsEstablished]) {
        [self setup];
    }
}

- (void)setTargetKeyPath:(NSString *)targetKeyPath
{
    _targetKeyPath = targetKeyPath;
    
    // INFO: replaces awakeFromNib call
    if ([self IBOutletConnectionsEstablished]) {
        [self setup];
    }
}

#pragma mark - Private

- (BOOL)IBOutletConnectionsEstablished
{
    return self.sourceObject != nil && self.sourceKeyPath.length > 0 && self.target && self.targetKeyPath.length > 0;
}

- (void)setup
{
    [self handleValueChanged];
    [self.sourceObject addObserver:self forKeyPath:self.sourceKeyPath options:0 context:nil];
}

- (void)handleValueChanged
{
    id value = [self.sourceObject valueForKeyPath:self.sourceKeyPath];
    if (self.targetKeyPath) {
        [self.target setValue:value forKeyPath:self.targetKeyPath];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
