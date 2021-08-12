//
//  ARCLearnViewController.m
//  EveryDay
//
//  Created by SF-潘乐 on 2021/7/12.
//

#import "ARCLearnViewController.h"
#import "NSObject+NSObject_Extension.h"

@interface ARCLearnViewController ()

@end

@implementation ARCLearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"ARC";
    
    id obj = [[NSObject alloc] init];
    [obj printRetainCount]; //1
    [obj autorelease];
    [obj printRetainCount]; //1
    [obj retain];
    [obj printRetainCount]; //2
    [obj release];
    [obj printRetainCount]; //1
    
    //
    // 总的思维 - 细节
    
    // 19 11
    // Android  20.6 iOS
    
    // Android（博哥） iOS（图） 大概的逻辑
    // 对比 基础  优势

//    [obj printRetainCount];
//
//    [obj printRetainCount];
//
//    NSObject *obj1 = [[NSObject alloc] init]; //自己生成并持有一个对象 =1
//    [obj1 release];
//    NSArray *array = [NSArray array];
    
//    [obj ]  // alloc/init/copy/mutableCopy
//    [obj retain];  // +1  持有对象
//    [obj release]; // -1  释放对象
//    //dealloc   对象回收
    
    // 引用计数
    
    // 内存管理
    
    // MRC(手动管理内存)  ARC(自动管理内存 iOS5 编译)
    
    // 自动释放
    
    //属性
    
    // 自动释放池  自动释放池
}

+ (NSArray *)array {
    id obj = [[NSArray alloc] init]; //1
    [obj autorelease];  //  延迟释放
    return obj;
    
    // runloop
}

- (void)dealloc {
    // 释放
    // auto release
}

- (void)test1 {
    // 堆 和 栈
}

@end
