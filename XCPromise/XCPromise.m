//
//  XCPromise.m
//  Hook
//
//  Created by tongleiming on 2020/4/20.
//  Copyright © 2020 tongleiming. All rights reserved.
//

#import "XCPromise.h"

@implementation Handler

@end

@interface XCPromise ()

@property (nonatomic, strong) NSMutableArray *deferredArray;

@property (nonatomic, strong) dispatch_queue_t promiseQueue;

@end

@implementation XCPromise

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = @"pending";
        self.deferredArray = [NSMutableArray array];
        self.promiseQueue = dispatch_queue_create("xc.promiseKit.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)promiseWithTask:(Task)task {
    XCPromise *promise = [[XCPromise alloc] init];
    
    Resolve resolve = ^(id value) {
        [promise resolve:value];
    };
    
    Reject reject = ^(NSError *error) {
        [promise reject:error];
    };
    
    task(resolve, reject);
    
    return promise;
}

- (void)resolve:(id)newValue {
    if (newValue && [newValue isKindOfClass:[XCPromise class]]) {
        OnResolved resolve = (id)^(id value) {
            return [self resolve:value];
        };
        
        OnRejected reject = (id)^(NSError *error) {
            return [self reject:error];
        };
        
        [newValue thenOnResolved:resolve onRejected:reject];
        
        return;
    }
    
    self.value = newValue;
    self.state = @"resolved";
    [self handleAllHandler];
}

- (void)reject:(NSError *)error {
    self.state = @"rejected";
    self.value = error;
    [self handleAllHandler];
}

- (void)handleAllHandler {
    dispatch_async(self.promiseQueue, ^{
        for (Handler *handler in self.deferredArray) {
            [self handle:handler];
        }
    });
}

- (void)handle:(Handler *)handler {
    if ([self.state isEqualToString:@"pending"]) {
        dispatch_barrier_sync(self.promiseQueue, ^{
            [self.deferredArray addObject:handler];
        });
        return;
    }
    
    id(^handlerCallback)(id);
    if ([self.state isEqualToString:@"resolved"]) {
        handlerCallback = handler.onResolved;
    } else {
        handlerCallback = handler.onRejected;
    }
    
    if (!handlerCallback) {
        if ([self.state isEqualToString:@"resolved"]) {
            handler.resolve(self.value);
        } else {
            handler.reject(self.value);
        }
        return;
    }
    
    id ret = handlerCallback(self.value);
    handler.resolve(ret);
}

- (XCPromise *)thenOnResolved:(OnResolved)onResolved onRejected:(OnRejected)onRejected {

    XCPromise *promise = [[XCPromise alloc] init];
    
    Resolve resolve = ^(id value) {
        [promise resolve:value];
    };
    
    Reject reject = ^(NSError *error) {
        [promise reject:error];
    };
    
    Task task = ^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        Handler *handler = [Handler new];
        handler.onResolved = onResolved;
        handler.onRejected =  onRejected;
        handler.resolve = ^(id _Nonnull value) {
            [promise resolve:value];
        };
        handler.reject = ^(NSError * _Nonnull error) {
            [promise reject:error];
        };
        [self handle:handler];
    };
    
    task(resolve, reject);
    
    return promise;
}

@end
