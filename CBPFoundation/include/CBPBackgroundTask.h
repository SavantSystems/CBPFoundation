/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Cameron Pulsford
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <CBPFoundation/CBPFoundation.h>

/**
 *  This class controls the stopping and starting of a background task. It is similar to an NSOperation, but more appropriate for a long running task that can stopped and restarted.
 *
 *  There are two ways of using this class, either delegate based or block based. Mixing the two or not using at least one will cause an NSInternalInconsistencyException when -start is called.
 *
 *  Whichever approach is used, both the start and stop implementation must not block. The -start and -stop methods will not return until the respective start and stop implementations return. This is so that the 'object' and 'thread' properties are always read in a consistent state.
 */

/**
 *  Start a long running task.
 *
 *  @return When applicable, you may choose to return the object that you started. For example, an NSStream subclass. The background task will own the object until the task is stopped. This can prevent dealing with weakSelf things. If this is not applicable or desired, just return nil.
 */
typedef id (^CBPBackgroundTaskStartBlock)(void);

/**
 *  Stop a long running task.
 *
 *  @param object The object that was returned (started) by the start block. The object will be released after this block is performed and the "object" property will return nil.
 */
typedef void (^CBPBackgroundTaskStopBlock)(id object);

@protocol CBPBackgroundTaskDelegate;

@interface CBPBackgroundTask : NSObject

/**
 *  Sets/retrieves the delegate.
 */
@property (weak) id<CBPBackgroundTaskDelegate> delegate;

/**
 *  A block to start your task. It will be performed on a dedicated background thread. This block must not block.
 */
@property (copy) CBPBackgroundTaskStartBlock startBlock;

/**
 *  A block to end your task and prepare for reuse. It will be performed on a dedicated background thread. This block must not block.
 */
@property (copy) CBPBackgroundTaskStopBlock stopBlock;

/**
 *  The dedicated background thread.
 */
@property (readonly) NSThread *thread;

/**
 *  The object returned by either the start block or the start delegate method.
 */
@property (readonly) id object;

/**
 *  Start the background task.
 */
- (void)start;

/**
 *  Stop the background task.
 */
- (void)stop;


@end

@protocol CBPBackgroundTaskDelegate <NSObject>

@optional

/**
 *  Start your task here. This method will be performed from the background thread. This method must not block.
 *
 *  @param task The task that is starting
 *
 *  @return When applicable, you may choose to return the object that you started. For example, an NSStream subclass. The background task will own the object until the task is stopped. If this is not applicable or desired, just return nil.
 */
- (id)startBackgroundTask:(CBPBackgroundTask *)task;

/**
 *  End your task here and prepare for reuse.
 *
 *  @param task   The task that is ending
 *  @param object The object returned by the start implementation, or nil
 */
- (void)stopBackgroundTask:(CBPBackgroundTask *)task withObject:(id)object;

@end
