//
//  DetectAppManager.m
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import "DetectAppManager.h"
#import <objc/runtime.h>
#import <sys/sysctl.h>

@interface AppMode()

@property (nonatomic,strong)NSString * bundleId ;
@property (nonatomic,strong)NSString * name ;
@property (nonatomic,strong)NSString * version ;

@property (nonatomic,weak)dispatch_queue_t detectqueue ;

@end
@implementation AppMode
@end

static id _detectAppManager = nil ;
@interface DetectAppManager()
//preAppListDic 和 curAppListDic  用来做对比
// 之前列表
@property (nonatomic,strong) NSDictionary * preAppListDic ;
// 当前最新app列表
@property (nonatomic,strong) NSDictionary * curAppListDic ;

@end
@implementation DetectAppManager
#if __has_feature(objc_arc)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
//含警告的代码,如下,btn为UIButton类型的指针

+ (instancetype)sharedInstance
{
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        _detectAppManager = [[[self class] alloc] init];
    });
    
    return _detectAppManager ;
}
- (id) init
{
    self = [super init];
    if (self) {
        [self appIsRunning];
    }
    return self ;
}
// 启动以定时器，该定时器不停扫描 app列表的变化，该定时器在子线程中run
- (void)initlizeDetectTimer
{
//  dispatch_queue_create(<#const char *label#>, <#dispatch_queue_attr_t attr#>)
}

- (void)appIsRunning
{
    NSLog(@"run pross: %@",[self runningProcesses]);
}
//selector: installedApplications
//2015-05-26 23:02:57.761 Test[4446:60b] selector: allInstalledApplications
//2015-05-26 23:02:57.763 Test[4446:60b] selector: placeholderApplications
//2015-05-26 23:02:57.765 Test[4446:60b] selector: allApplications
//2015-05-26 23:02:57.766 Test[4446:60b] selector: publicURLSchemes
//2015-05-26 23:02:57.768 Test[4446:60b] selector: installApplication:withOptions:

- (NSArray*)detectInstalledApps
{
     Class applicationWorkspace_class = objc_getClass("LSApplicationWorkspace") ;
     id workspace = [applicationWorkspace_class performSelector:@selector(defaultWorkspace)];
     id  appDics = [workspace performSelector:@selector(allApplications)];
     Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    
     NSMutableArray * installedApps = nil ;
     for(LSApplicationProxy_class in appDics) {

         NSString * app_version = [LSApplicationProxy_class performSelector:@selector(shortVersionString)];
         NSString * app_identifer = [LSApplicationProxy_class performSelector:@selector(applicationIdentifier)];
         NSLog(@"app_version:%@ app_identifer: %@",app_version,app_identifer);
         if (installedApps == nil) {
             installedApps = [NSMutableArray new];
         }
         AppMode * app = [[AppMode alloc] init];
         app.version = app_version ;
         app.bundleId = app_identifer ;
         app.name = app_identifer ;
         
         [installedApps addObject:app];
         app = nil ;
     }
    
    return installedApps ;
}

-(NSArray *)calcInstalledApps:(NSArray*)inCurrentAppList withPrevAppList:(NSArray*)inPreAppList outIncrease:(NSArray**)outIncreaseApps
{
    NSMutableArray * mutaInCurrentAppList = [NSMutableArray arrayWithArray:inCurrentAppList];
    NSMutableArray * mutaInPreAppList = [NSMutableArray arrayWithArray:inPreAppList];
    
    NSMutableArray * mutaSameInCurrentAppList =[NSMutableArray new];
    NSMutableArray * mutaSameInPreAppList = [NSMutableArray new];
    
    for (AppMode * currentapp in mutaInCurrentAppList) {
        for (AppMode * preapp in mutaInPreAppList) {
            if ([preapp.bundleId isEqualToString:currentapp.bundleId]) {
                if (![mutaSameInPreAppList containsObject:preapp]) {
                    [mutaSameInPreAppList addObject:preapp];
                }
                
                if (![mutaSameInCurrentAppList containsObject:currentapp]) {
                    [mutaSameInCurrentAppList addObject:currentapp];
                }
            }
        }
    }
    
    [mutaInCurrentAppList removeObjectsInArray:mutaSameInCurrentAppList];
    [mutaInPreAppList removeObjectsInArray:mutaSameInPreAppList];
    
    NSMutableArray * reducedApps = mutaInPreAppList ;
    *outIncreaseApps = mutaInCurrentAppList ;
    
    return reducedApps ;
}

- (NSDictionary *)mapAppsWithbundleIdAsKey:(NSArray*)apps
{
    __block NSMutableDictionary * appMaps = nil;
    [apps enumerateObjectsUsingBlock:^(AppMode * obj, NSUInteger idx, BOOL *stop) {
        if (appMaps == nil) {
            appMaps = [NSMutableDictionary new];
        }
        [appMaps setObject:obj forKey:obj.bundleId];
    }];
    
    return appMaps ;
}

- (NSArray *)runningProcesses {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--){
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];
                    [array addObject:dict];
                }
                free(process);
                return array;
            }
        }
    }
    
    return nil;
}
- (AppMode*)detectAppWithBundleId:(NSString *)bundleId
{
    return nil ;
}
#pragma clang diagnostic pop

#else
#error "you should compile this in with arc"
#endif
@end
