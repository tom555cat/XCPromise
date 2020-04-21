//
//  ViewController.m
//  XCPromise
//
//  Created by tongleiming on 2020/4/21.
//  Copyright © 2020 tongleiming. All rights reserved.
//

#import "ViewController.h"
#import "XCPromise.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self test];
    //[self test1];
    //[self test2];
    //[self test3];
    [self test4];
}

- (void)test {
    XCPromise *promise = [XCPromise promiseWithTask:^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        resolve(@(100));
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"%@", value);
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
}

- (void)test1 {
    XCPromise *promise = [XCPromise promiseWithTask:^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@(100));
        });
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"%@", value);
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
}

- (void)test2 {
    XCPromise *promise = [XCPromise promiseWithTask:^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        resolve(@(100));
    }];
    
    [[promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"%@", value);
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }] thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSNumber *num = @([value integerValue] * 2);
        NSLog(@"%@", num);
        return num;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }] ;
}

// 先then先回调，后then后回调
- (void)test3 {
    XCPromise *promise = [XCPromise promiseWithTask:^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@(100));
        });
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"then 1");
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"then 2");
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"then 3");
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
}

// 先then先回调，后then后回调
- (void)test4 {
    XCPromise *promise = [XCPromise promiseWithTask:^(Resolve _Nonnull resolve, Reject _Nonnull reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@(100));
        });
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"then 1");
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
    
    [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
        NSLog(@"then 2");
        return value;
    } onRejected:^id _Nullable(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return error;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [promise thenOnResolved:^id _Nullable(id _Nonnull value) {
            NSLog(@"then 3");
            return value;
        } onRejected:^id _Nullable(NSError * _Nonnull error) {
            NSLog(@"%@", error);
            return error;
        }];
    });
}


@end
