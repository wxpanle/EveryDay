//
//  NSObject+NSObject_Extension.m
//  EveryDay
//
//  Created by SF-潘乐 on 2021/7/13.
//

#import "NSObject+NSObject_Extension.h"

@implementation NSObject (NSObject_Extension)

- (void)printRetainCount {
    NSLog(@"Obj.RetainCount %lu", (unsigned long)[self retainCount]);
    
    // OC 动态语言 运行时
    
    // Swift 静态语言 安全
    
    // OC
}

@end
