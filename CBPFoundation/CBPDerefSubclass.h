//
//  CBPDerefSubclass.h
//  CBPFoundation
//
//  Created by Cameron Pulsford on 1/3/14.
//  Copyright (c) 2014 SMD. All rights reserved.
//

#import "CBPDeref.h"

@interface CBPDeref ()

- (BOOL)assignValue:(id)value criticalBlock:(void (^)(void))criticalBlock;

- (BOOL)valueHasBeenAssigned;

@end
