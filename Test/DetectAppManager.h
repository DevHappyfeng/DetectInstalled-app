//
//  DetectAppManager.h
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppMode : NSObject
@property (nonatomic,readonly) NSString * bundleId ;
@property (nonatomic,readonly) NSString * name ;
@property (nonatomic,readonly) NSString * version ;
@end

@interface DetectAppManager : NSObject

+ (instancetype)sharedInstance ;

- (NSArray*)detectInstalledApps ;

- (AppMode*)detectAppWithBundleId:(NSString*)bundleId ;

@end
