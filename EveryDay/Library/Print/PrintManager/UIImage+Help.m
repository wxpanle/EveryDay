//
//  UIImage+Help.m
//  EveryDay
//
//  Created by "pl" on 2019/12/28.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

#import "UIImage+Help.h"

typedef struct ARGBPixel
{
    Byte alpha;
    Byte red;
    Byte green;
    Byte blue;
    
} ARGBPixel;

@implementation UIImage (Help)

//
- (NSData *)bitmapData11
{
    CGImageRef imageRef = self.CGImage;
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self bitmapRGBA8Context];
    
    if(!context) {
        return nil;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    uint32_t *bitmapData = (uint32_t *)CGBitmapContextGetData(context);
    
    
    if(bitmapData) {
        
        uint8_t *m_imageData = (uint8_t *) malloc(width * height/8 + 8*height/8);
        memset(m_imageData, 0, width * height/8 + 8*height/8);
        int result_index = 0;
        
        for(int y = 0; (y + 24) < height; ) {
            m_imageData[result_index++] = 27;
            m_imageData[result_index++] = 51;
            m_imageData[result_index++] = 0;
            
            m_imageData[result_index++] = 27;
            m_imageData[result_index++] = 42;
            m_imageData[result_index++] = 33;
            
            m_imageData[result_index++] = width%256;
            m_imageData[result_index++] = width/256;
            for(int x = 0; x < width; x++) {
                int value = 0;
                for (int temp_y = 0 ; temp_y < 8; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[BPRed] + 0.59 * rgbaPixel[BPGreen] + 0.11 * rgbaPixel[BPBlue];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
                
                value = 0;
                for (int temp_y = 8 ; temp_y < 16; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[BPRed] + 0.59 * rgbaPixel[BPGreen] + 0.11 * rgbaPixel[BPBlue];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y%8)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
                
                value = 0;
                for (int temp_y = 16 ; temp_y < 24; ++temp_y)
                {
                    uint8_t *rgbaPixel = (uint8_t *) &bitmapData[(y+temp_y) * width + x];
                    uint32_t gray = 0.3 * rgbaPixel[BPRed] + 0.59 * rgbaPixel[BPGreen] + 0.11 * rgbaPixel[BPBlue];
                    
                    if (gray < 127)
                    {
                        value += 1<<(7-temp_y%8)&255;
                    }
                    
                }
                m_imageData[result_index++] = value;
            }
            m_imageData[result_index++] = 13;
            m_imageData[result_index++] = 10;
            y += 24;
        }
        
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
        [data appendBytes:m_imageData length:result_index];
        
        free(bitmapData);
        return data;
    }
    
    NSLog(@"Error getting bitmap pixel data\n");
    CGContextRelease(context);
    
    return nil ;
}

- (CGContextRef)bitmapRGBA8Context
{
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) {
        return NULL;
    }
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;

}

- (UIImage *)imageWithscaleMaxWidth:(CGFloat)maxWidth
{
    CGFloat width = self.size.width;
    if (width > maxWidth)
    {
        CGFloat height = self.size.height;
        CGFloat maxHeight = maxWidth * height / width;

        CGSize size = CGSizeMake(maxWidth, maxHeight);
        UIGraphicsBeginImageContext(size);
        [self drawInRect:CGRectMake(0, 0, maxWidth, maxHeight)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }

    return self;
}

-(NSData *)getDataForPrint {

     CGImageRef cgImage = [self CGImage];
     int32_t width = CGImageGetWidth(cgImage);
     int32_t height = CGImageGetHeight(cgImage);
     NSInteger psize = sizeof(ARGBPixel);
     ARGBPixel * pixels = malloc(width * height * psize);
     NSMutableData* data = [[NSMutableData alloc] init];
     [self ManipulateImagePixelDataWithCGImageRef:cgImage imageData:pixels];
     for (int h = 0; h < height; h++) {
         for (int w = 0; w < width; w++) {
             int pIndex = [self PixelIndexWithX:w y:h width:width];
             ARGBPixel pixel = pixels[pIndex];
             if ([self PixelBrightnessWithRed:pixel.red green:pixel.green blue:pixel.blue] <= 127) {
                 u_int8_t ch = 0x01;
                 [data appendBytes:&ch length:1];
             }
             else{
                  u_int8_t ch = 0x00;
                 [data appendBytes:&ch length:1];
             }
         }
     }

    const char* bytes = data.bytes;
    NSMutableData* dd = [[NSMutableData alloc] init];
    //横向点数计算需要除以8
    NSInteger w8 = width / 8;
    //如果有余数，点数+1
    NSInteger remain8 = width % 8;
    if (remain8 > 0) {
        w8 = w8 + 1;
    }

 /**
    根据公式计算出 打印指令需要的参数
    指令:十六进制码 1D 76 30 m xL xH yL yH d1...dk
     m为模式，如果是58毫秒打印机，m=1即可
     xL 为宽度/256的余数，由于横向点数计算为像素数/8，因此需要 xL = width/(8*256)
     xH 为宽度/256的整数
     yL 为高度/256的余数
     yH 为高度/256的整数
    **/
    NSInteger xL = w8 % 256;
    NSInteger xH = width / (8 * 256);
    NSInteger yL = height % 256;
    NSInteger yH = height / 256;
    const char cmd[] = {0x1d,0x76,0x30,3,xL,xH,yL,yH};
    [dd appendBytes:cmd length:8];

    for (int h = 0; h < height; h++) {
        for (int w = 0; w < w8; w++) {
            u_int8_t n = 0;
            for (int i=0; i<8; i++) {
                int x = i + w * 8;
                u_int8_t ch;
                if (x < width) {
                    int pindex = h * width + x;
                    ch = bytes[pindex];
                }
                 else{
                     ch = 0x00;
                 }
                 n = n << 1;
                 n = n | ch;
             }
             [dd appendBytes:&n length:1];
         }
     }
     return dd;
 }

 -(void)ManipulateImagePixelDataWithCGImageRef:(CGImageRef)inImage imageData:(void*)oimageData
 {
     // Create the bitmap context
     CGContextRef cgctx = [self CreateARGBBitmapContextWithCGImageRef:inImage];
     if (cgctx == NULL)
     {
         // error creating context
         return;
     }

     // Get image width, height. We'll use the entire image.
     size_t w = CGImageGetWidth(inImage);
     size_t h = CGImageGetHeight(inImage);
     CGRect rect = {{0,0},{w,h}};

     // Draw the image to the bitmap context. Once we draw, the memory
     // allocated for the context for rendering will then contain the
     // raw image data in the specified color space.
     CGContextDrawImage(cgctx, rect, inImage);

     // Now we can get a pointer to the image data associated with the bitmap
     // context.
     void *data = CGBitmapContextGetData(cgctx);
     if (data != NULL)
     {
         CGContextRelease(cgctx);
         memcpy(oimageData, data, w * h * sizeof(u_int8_t) * 4);
         free(data);
         return;
     }

     // When finished, release the context
     CGContextRelease(cgctx);
     // Free image data memory for the context

      if (data)
         {
             free(data);
         }

         return;
     }

 // 参考 http://developer.apple.com/library/mac/#qa/qa1509/_index.html
 -(CGContextRef)CreateARGBBitmapContextWithCGImageRef:(CGImageRef)inImage
 {
     CGContextRef    context = NULL;
     CGColorSpaceRef colorSpace;
     void *          bitmapData;
     int             bitmapByteCount;
     int             bitmapBytesPerRow;

     // Get image width, height. We'll use the entire image.
     size_t pixelsWide = CGImageGetWidth(inImage);
     size_t pixelsHigh = CGImageGetHeight(inImage);
     // Declare the number of bytes per row. Each pixel in the bitmap in this
     // example is represented by 4 bytes; 8 bits each of red, green, blue, and
     // alpha.
     bitmapBytesPerRow   = (pixelsWide * 4);
     bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);

     // Use the generic RGB color space.
     colorSpace =CGColorSpaceCreateDeviceRGB();
     if (colorSpace == NULL)
     {
         return NULL;
     }
     // Allocate memory for image data. This is the destination in memory
     // where any drawing to the bitmap context will be rendered.
     bitmapData = malloc( bitmapByteCount );
     if (bitmapData == NULL)
     {
         CGColorSpaceRelease( colorSpace );
         return NULL;
     }
     // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        context = CGBitmapContextCreate (bitmapData,
                                         pixelsWide,
                                         pixelsHigh,
                                         8,      // bits per component
                                         bitmapBytesPerRow,
                                         colorSpace,
                                         kCGImageAlphaPremultipliedFirst);
         if (context == NULL)
         {
             free (bitmapData);
         }

         // Make sure and release colorspace before returning
         CGColorSpaceRelease( colorSpace );

         return context;
     }

 -(u_int8_t)PixelBrightnessWithRed:(u_int8_t)red green:(u_int8_t)green blue:(u_int8_t)blue
 {
     int level = ((int)red + (int)green + (int)blue)/3;
     return level;
 }


 -(u_int32_t)PixelIndexWithX:(u_int32_t)x y:(u_int32_t)y width:(u_int32_t)width
 {
     return (x + (y * width));
 }

 -(UIImage*)ScaleImageWithImage:(UIImage*)image width:(NSInteger)width height:(NSInteger)height
 {
     CGSize size;
     size.width = width;
     size.height = height;
     UIGraphicsBeginImageContext(size);
     [image drawInRect:CGRectMake(0, 0, width, height)];
     UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     return scaledImage;
 }


//! 生成条形码
+ (UIImage *)generateCode128:(NSString *)code size:(CGSize)size {
    
    NSData *codeData = [code dataUsingEncoding:NSASCIIStringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator" withInputParameters:@{@"inputMessage": codeData, @"inputQuietSpace": @.0}];
    /* @{@"inputMessage": codeData, @"inputQuietSpace": @(.0), @"inputBarcodeHeight": @(size.width / 3)} */
    UIImage *codeImage = [self scaleImage:filter.outputImage toSize:size];
    
    return codeImage;
}


#pragma mark - Util functions

// 缩放图片(生成高质量图片）
+ (UIImage *)scaleImage:(CIImage *)image toSize:(CGSize)size {
    
    //! 将CIImage转成CGImageRef
    CGRect integralRect = image.extent;// CGRectIntegral(image.extent);// 将rect取整后返回，origin取舍，size取入
    CGImageRef imageRef = [[CIContext context] createCGImage:image fromRect:integralRect];
    
    //! 创建上下文
    CGFloat sideScale = fminf(size.width / integralRect.size.width, size.width / integralRect.size.height) * [UIScreen mainScreen].scale;// 计算需要缩放的比例
    size_t contextRefWidth = ceilf(integralRect.size.width * sideScale);
    size_t contextRefHeight = ceilf(integralRect.size.height * sideScale);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextRefWidth, contextRefHeight, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);// 灰度、不透明
    CGColorSpaceRelease(colorSpaceRef);
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);// 设置上下文无插值
    CGContextScaleCTM(contextRef, sideScale, sideScale);// 设置上下文缩放
    CGContextDrawImage(contextRef, integralRect, imageRef);// 在上下文中的integralRect中绘制imageRef
    CGImageRelease(imageRef);
    
    //! 从上下文中获取CGImageRef
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    
    //! 将CGImageRefc转成UIImage
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(scaledImageRef);
    
    return scaledImage;
}


@end
