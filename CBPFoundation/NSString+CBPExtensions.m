//
//  NSString+CBPExtensions.m
//  CBPFoundation
//
//  Created by Cameron Pulsford on 3/16/14.
//  Copyright (c) 2014 SMD. All rights reserved.
//

#import "NSString+CBPExtensions.h"

@implementation NSString (CBPExtensions)

- (BOOL)containsString:(NSString *)aString
{
    return [self rangeOfString:aString].location != NSNotFound;
}

- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)mask
{
    return [self rangeOfString:aString options:mask].location != NSNotFound;
}

- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
    return [self rangeOfString:aString options:mask range:searchRange].location != NSNotFound;
}

@end
