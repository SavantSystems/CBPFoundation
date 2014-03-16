//
//  NSString+CBPExtensions.h
//  CBPFoundation
//
//  Created by Cameron Pulsford on 3/16/14.
//  Copyright (c) 2014 SMD. All rights reserved.
//

@import Foundation;

@interface NSString (CBPExtensions)

- (BOOL)containsString:(NSString *)aString;

- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)mask;

- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange;

@end
