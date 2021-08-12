//
//  UIImage+Help.h
//  EveryDay
//
//  Created by "pl" on 2019/12/28.
//   All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,BitPixels) {
    BPAlpha = 0,
    BPBlue = 1,
    BPGreen = 2,
    BPRed = 3
};


@interface UIImage (Help)

/**
 *  将图片转换为点阵图数据
 *
 *  @return 转化后的点阵图数据
 */
- (NSData *)bitmapData11;

/**
 *  将图片绘制到绘图上下文中，并返回上下文
 *
 *  @return
 */
//+ (CGContextRef)bitmapRGBA8ContextFromImage:(CGImageRef)image;
- (CGContextRef)bitmapRGBA8Context;

/**
 *  缩放图片，会按照给定的最大宽度，等比缩放
 *
 *  @param maxWidth 缩放后的最大宽度
 *
 *  @return 返回缩放后的图片
 */
- (UIImage *)imageWithscaleMaxWidth:(CGFloat)maxWidth;

/**
 *  将图片转换为黑白图片
 *
 *  @return 黑白图片
 */
- (UIImage *)blackAndWhiteImage;

-(NSData *)getDataForPrint;

-(UIImage*)ScaleImageWithImage:(UIImage*)image width:(NSInteger)width height:(NSInteger)height;

+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
