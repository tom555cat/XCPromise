//
//  XCPromise.h
//  Hook
//
//  Created by tongleiming on 2020/4/20.
//  Copyright © 2020 tongleiming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^OnResolved)(id);
typedef id _Nullable (^OnRejected)(NSError *);
typedef void(^Resolve)(id);
typedef void(^Reject)(NSError *);
typedef void(^Task)(Resolve, Reject);

@interface Handler : NSObject

@property (nonatomic, copy) OnResolved onResolved;
@property (nonatomic, copy) OnRejected onRejected;
@property (nonatomic, copy) Resolve resolve;
@property (nonatomic, copy) Reject reject;

@end

@interface XCPromise : NSObject

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) id value;

//@property (nonatomic, strong) Handler* deferred;

+ (instancetype)promiseWithTask:(__nonnull Task)task;
- (void)resolve:(id)newValue;
- (void)reject:(NSError *)error;
- (void)handle:(Handler *)handler;
- (XCPromise *)thenOnResolved:(OnResolved)onResolved onRejected:(OnRejected)onRejected;

@end

NS_ASSUME_NONNULL_END
