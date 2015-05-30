//
//  UIDevice+io_Extern.h
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (io_Extern)

// 获取IMEI
- (NSString *) imei;
//设备序列号
- (NSString *) serialNumber;
// 背光灯亮度
- (NSString *) backlightLevel;
// mac 地址
- (NSString *)macAddress ;

@end
