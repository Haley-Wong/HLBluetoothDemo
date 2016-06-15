//
//  UIImage+Bitmap.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/3.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,BitPixels) {
    BPAlpha = 0,
    BPBlue = 1,
    BPGreen = 2,
    BPRed = 3
};

@interface UIImage (Bitmap)

/**
 *  将图片转换为点阵图数据
 *
 *  @return 转化后的点阵图数据
 */
- (NSData *)bitmapData;

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

@end

#pragma mark - -----------制作二维码 条形码------------
@interface UIImage (QRCode)

/**
 *  创建条形码
 *
 *  @param info 字符串信息
 *
 *  @return 条形码图片
 */
+ (UIImage *)barCodeImageWithInfo:(NSString *)info;

/**
 *  创建二维码
 *
 *  @param info  二维码内的信息
 *  @param image 二维码中心的logo图片
 *  @param width 二维码的宽度
 *
 *  @return 二维码图片
 */
+ (UIImage *)qrCodeImageWithInfo:(NSString *)info centerImage:(UIImage *)image  width:(CGFloat)width;

/**
 *  将CIImage 放大显示，并转换为UIImage。
 *
 *  @param image 原始CIImage
 *  @param size  最终尺寸的宽度
 *
 *  @return UIImage
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

/**
 *  将原图转变为背景色透明，图片为设置的颜色
 *
 *  @param image 要改变的图片
 *  @param red   red
 *  @param green green
 *  @param blue  blue
 *
 *  @return 返回修改后的图片
 */
+ (UIImage*)imageBgColorToTransparentWith:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
