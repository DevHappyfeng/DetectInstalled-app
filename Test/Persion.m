//
//  Persion.m
//  Test
//
//  Created by whf on 15/5/23.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import "Persion.h"
@interface Persion()
{
    Student * _stu ;
}
@end

@implementation Persion

//+ (void)load{
//    
//    NSLog(@"load:%@",[self class]);
//}
+ (void)initialize{
    
    NSLog(@"initialize:%@",[self class]);
    
}
- (id)init
{
    self = [super init];
    if (self) {
        _stu = [[Student alloc] init];
    }
    return self ;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature * signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [_stu methodSignatureForSelector:aSelector];
    }
    return signature ;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    if ([_stu respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:_stu];
    }
}
@end

@implementation Student

+ (void)initialize{
    
    NSLog(@"initialize:%@",[self class]);
}

- (void)myNamePrint
{
    NSLog(@"hello my name");
}

@end
