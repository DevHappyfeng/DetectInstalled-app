//
//  ViewController.m
//  Test
//
//  Created by whf on 15/5/23.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import "ViewController.h"
#import "Persion.h"
#import <objc/runtime.h>

#import "DetectAppManager.h"
#import "UIDevice+io_Extern.h"

@interface Node:NSObject
@property (nonatomic ,strong)Node * next ;
@property (nonatomic ,strong)id data ;
+ (Node*)nodeWithData:(id)data ;

@end
@implementation Node
+ (Node*)nodeWithData:(id)data
{
    Node * node = [[Node alloc] init];
    node.next = nil ;
    node.data = data ;
    return node ;
}
@end


@interface List : NSObject
{
    @private
    Node * _header ;
}
- (void)creadList:(Node**)header ;
- (void)addNode:(Node*)node ;
- (int)length;
- (void)insertNode:(Node*)node atIndex:(int)index ;
- (void)traverseWithBlock:(void(^)(Node * node))block ;

- (void)reverse ;

@end


@implementation List


- (void)creadList:(Node *__autoreleasing *)node
{
    *node = [[Node alloc] init];
    (*node).data = @"header";
    (*node).next = nil ;
    _header = *node ;
}
- (int)length{
    
    int length = 0;
    Node *  p = _header ;
    while (p) {
        length++ ;
        p = p.next ;
    }
    return length ;
}
- (void)addNode:(Node *)node
{
    Node * p = _header ;
    while (p.next) {
        p = p.next ;
    }
    p.next =node ;
    node.next = nil ;
}
- (void)insertNode:(Node *)node atIndex:(int)index
{

    Node * p = _header ;
    int i = 0 ;
    while (i<index&&p.next) {
        p = p.next ;
        i++ ;
    }
    if (i<index) {
        NSLog(@"the length is not enough") ;
        return ;
    }
    
    if (p.next == nil) {
        p.next = node ;
        node.next = nil ;
        return ;
    }
    
    Node * q = p.next ;
    p.next = node ;
    node.next = q ;
    
}

- (void)traverseWithBlock:(void (^)(Node *))block
{
    Node * p = _header ;
    while (p) {
        block(p);
        p = p.next ;
    }
}

- (void)reverse
{
    Node * header = _header ;
    Node * p1 = _header.next  ;
    header.next = nil ;
    while (p1) {
        Node * p2 = p1.next ;
        p1.next = header ;
        header = p1 ;
        p1 = p2 ;
    }
    _header = header ;
}

@end

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[DetectAppManager sharedInstance] detectInstalledApps];
    
    NSLog(@"the imei is %@ \n",[[UIDevice currentDevice] imei]);
    NSLog(@"the serial is %@\n",[[UIDevice currentDevice] serialNumber]);
    NSLog(@"the backlightLevel is %@\n",[[UIDevice currentDevice] backlightLevel]);

    NSLog(@"the macAddress is %@\n",[[UIDevice currentDevice] macAddress]);

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50 ;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100 ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cell_id = @"cell_id";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        
    }
    
    cell.backgroundColor = indexPath.row%2?[UIColor blueColor]:[UIColor yellowColor] ;
    
    return cell ;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
