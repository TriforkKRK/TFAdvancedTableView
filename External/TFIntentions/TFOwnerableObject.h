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

@import Foundation;

//
// Setting up object owner manually has to be made when object is put into xib file because top level objects are not retained by default
// When using storyboards on the other hand you don't need this - top level object livetimes seem to be in sync with scene vc.
//
@interface TFOwnerableObject : NSObject

// Object that this object lifetime will be bound to
@property(nonatomic, weak) IBOutlet id owner;

+ (void)bindLifetimeOfObject:(id)object toObject:(id)owner;

@end


@interface NSObject(tf_owned)

- (id)tf_currentOwner;
- (void)tf_setCurrentOwner:(id)owner;                  /**< only sets the value */

- (void)tf_bindLifetimeToObject:(id)object;
- (void)tf_releaseLifetimeFromObject:(id)object;

@end