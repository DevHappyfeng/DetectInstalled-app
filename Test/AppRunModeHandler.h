//
//  AppRunModeHandler.h
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppRunModeHandler : NSObject

+ (instancetype)sharedInstance ;

- (void)setRuningWhenEnterBackground:(BOOL)isRuning;

@end
