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

#import "TFIntention.h"

typedef NS_ENUM(NSUInteger, TFTargetMultiplexingPolicy) {
    TFTargetMultiplexingPolicyToAll,
    TFTargetMultiplexingPolicyToResponding,
    TFTargetMultiplexingPolicyToOnlyOne,
};

IB_DESIGNABLE
@interface TFTargetMultiplexerIntention : TFIntention

@property (nonatomic, strong) IBOutletCollection(id) NSArray *targets;
@property (nonatomic, assign) TFTargetMultiplexingPolicy policy;         /**< TFTargetMultiplexingPolicyToAll is a default value **/
@property (nonatomic, strong) IBInspectable NSString * policySetting;    /**< It is InterfaceBuilder convenience setter (only writable), one can use: "ToAll", "ToResponding" or "ToOnlyOne" **/

@end
