/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Cameron Pulsford
 
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

/**
 *  This class handles the synchronization of a task that can stop and start.
 *  
 *  Delegate information:
 *      * There are three methods of using CBPTask. Subclassing, delegate based, and block based.
 *      * You must choose at least one and they may not be mixed. An exception will be thrown in the -start method if this requirement is not met.
 *
 *  Thread safety:
 *      * The stop and start methods themselves are thread safe, but they will call out to the subclass/delegate/blocks on their calling thread.
 *      * Your task must either be thread safe, or you should use some other threading methods to perform these methods on the right thread.
 *      For example:
 *    
 *          dispatch_async(mySocketQueue, ^{ [self.socketTask stop]; });
 *
 *      * If you know you'll want your task to be running on a background thread where these threading concerns are already taken care of, see CBPBackgroundTask.
 */

@import Foundation;

@protocol CBPTaskDelegate;

@interface CBPTask : NSObject


#pragma mark - Delegate based callbacks

/**
 *  Sets/retrieves the delegate.
 */
@property (weak) id<CBPTaskDelegate> delegate;

/**
 *  Sets/retrieves the start block.
 */
@property (copy) dispatch_block_t startBlock;

/**
 *  Sets/retrieves the stop block.
 */
@property (copy) dispatch_block_t stopBlock;


#pragma mark - Starting/stopping

/**
 *  Returns the number of times this task has been started.
 */
@property (readonly) NSUInteger numberOfTimesTaskWasStarted;

/**
 *  YES if the task is running, otherwise NO.
 */
@property (readonly) BOOL isRunning;

/**
 *  Starts the task.
 *
 *  @return YES if the task was started, NO if the task had already been started.
 */
- (BOOL)start;

/**
 *  Stops the task.
 *
 *  @return YES if the task was stopped, NO if the task had already been stopped.
 */
- (BOOL)stop;

@end


#pragma mark - CBPTaskSubclass methods

@interface CBPTask (CBPTaskSubclass)

/**
 *  Start the task.
 */
- (void)startTask;

/**
 *  Stop the task.
 */
- (void)stopTask;

@end


#pragma mark -

@protocol CBPTaskDelegate <NSObject>

/**
 *  Start performing your task.
 *
 *  @param task The task object that is beginning.
 */
- (void)startTask:(CBPTask *)task;

/**
 *  Stop performing your task.
 *
 *  @param task The task object that is ending.
 */
- (void)stopTask:(CBPTask *)task;

@end
