//
//  HLPrinter.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/3.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIImage+Bitmap.h"

typedef NS_ENUM(NSInteger, HLPrinterStyle) {
    HLPrinterStyleDefault,
    HLPrinterStyleCustom
};

/** 文字对齐方式 */
typedef NS_ENUM(NSInteger, HLTextAlignment) {
    HLTextAlignmentLeft = 0x00,
    HLTextAlignmentCenter = 0x01,
    HLTextAlignmentRight = 0x02
};

/** 字号 */
typedef NS_ENUM(NSInteger, HLFontSize) {
    HLFontSizeTitleSmalle = 0x00,
    HLFontSizeTitleMiddle = 0x11,
    HLFontSizeTitleBig = 0x22
};

@interface HLPrinter : NSObject

/**
 *  添加单行标题,默认字号是小号字体
 *
 *  @param title     标题名称
 *  @param alignment 标题对齐方式
 */
- (void)appendText:(NSString *)text alignment:(HLTextAlignment)alignment;

/**
 *  添加单行标题
 *
 *  @param title     标题名称
 *  @param alignment 标题对齐方式
 *  @param fontSize  标题字号
 */
- (void)appendText:(NSString *)text alignment:(HLTextAlignment)alignment fontSize:(HLFontSize)fontSize;

/**
 *  添加单行信息，左边名称(左对齐)，右边实际值（右对齐）,默认字号是小号。
 *  @param title    名称
 *  @param value    实际值
 *  警告:因字号和字体与iOS中字体不一致，计算出来有误差，可以用[-appendTitle:value:valueOffset:]或[-appendTitle:value:valueOffset:fontSize:]
 */
- (void)appendTitle:(NSString *)title value:(NSString *)value;

/**
 *  添加单行信息，左边名称(左对齐)，右边实际值（右对齐）。
 *  @param title    名称
 *  @param value    实际值
 *  @param fontSize 字号大小
 *  警告:因字号和字体与iOS中字体不一致，计算出来有误差,所以建议用在价格方面
 */
- (void)appendTitle:(NSString *)title value:(NSString *)value fontSize:(HLFontSize)fontSize;

/**
 *  设置单行信息，左标题，右实际值
 *  @提醒 该方法的预览效果与实际效果误差较大，请以实际打印小票为准
 *
 *  @param title    标题
 *  @param value    实际值
 *  @param offset   实际值偏移量
 */
- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset;

/**
 *  设置单行信息，左标题，右实际值
 *  @提醒 该方法的预览效果与实际效果误差较大，请以实际打印小票为准
 *
 *  @param title    标题
 *  @param value    实际值
 *  @param offset   实际值偏移量
 *  @param fontSize 字号
 */
- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset fontSize:(HLFontSize)fontSize;

/**
 *  添加选购商品信息标题,一般是三列，名称、数量、单价
 *
 *  @param LeftText   左标题
 *  @param middleText 中间标题
 *  @param rightText  右标题
 */
- (void)appendLeftText:(NSString *)left middleText:(NSString *)middle rightText:(NSString *)right isTitle:(BOOL)isTitle;

/**
 *  添加图片，一般是添加二维码或者条形码
 *  ⚠️提醒：这种打印图片的方式，是自己生成图片，然后用位图打印
 *
 *  @param image     图片
 *  @param alignment 图片对齐方式
 *  @param maxWidth  图片的最大宽度，如果图片过大，会等比缩放
 */
- (void)appendImage:(UIImage *)image alignment:(HLTextAlignment)alignment maxWidth:(CGFloat)maxWidth;

/**
 *  添加条形码图片
 *  ⚠️提醒：这种打印条形码的方式，是自己生成条形码图片，然后用位图打印图片
 *
 *  @param info 条形码中包含的信息，默认居中显示，最大宽度为300。如果大于300,会等比缩放。
 */
- (void)appendBarCodeWithInfo:(NSString *)info;

/**
 *  添加条形码图片
 *  ⚠️提醒：这种打印条形码的方式，是自己生成条形码图片，然后用位图打印图片
 *
 *  @param info      条形码中的信息
 *  @param alignment 图片对齐方式
 *  @param maxWidth  图片最大宽度
 */
- (void)appendBarCodeWithInfo:(NSString *)info alignment:(HLTextAlignment)alignment maxWidth:(CGFloat)maxWidth;

/**
 *  添加二维码
 *  ✅推荐：这种方式使用的是打印机的指令生成二维码并打印机，所以比较推荐这种方式
 *
 *  @param info 二维码中的信息
 *  @param size 二维码的大小 取值范围1 <= size <= 16
 */
- (void)appendQRCodeWithInfo:(NSString *)info size:(NSInteger)size;

/**
 *  添加二维码
 *  ✅推荐：这种方式使用的是打印机的指令生成二维码并打印机，所以比较推荐这种方式
 *
 *  @param info      二维码中的信息
 *  @param size      二维码大小，取值范围 1 <= size <= 16
 *  @param alignment 设置图片对齐方式
 */
- (void)appendQRCodeWithInfo:(NSString *)info size:(NSInteger)size alignment:(HLTextAlignment)alignment;

/**
 *  添加二维码图片
 *  ⚠️提醒：这种打印条二维码的方式，是自己生成二维码图片，然后用位图打印图片
 *
 *  @param info 二维码中的信息
 */
- (void)appendQRCodeWithInfo:(NSString *)info;

/**
 *  添加二维码图片
 *  ⚠️提醒：这种打印条二维码的方式，是自己生成二维码图片，然后用位图打印图片
 *
 *  @param info        二维码中的信息
 *  @param centerImage 二维码中间的图片
 *  @param alignment   对齐方式
 *  @param maxWidth    二维码的最大宽度
 */
- (void)appendQRCodeWithInfo:(NSString *)info centerImage:(UIImage *)centerImage alignment:(HLTextAlignment)alignment maxWidth:(CGFloat )maxWidth;

/**
 *  添加一条分割线，like this:---------------------------
 */
- (void)appendSeperatorLine;

/**
 *  添加底部信息
 *
 *  @param footerInfo 不填默认为 谢谢惠顾，欢迎下次光临！
 */
- (void)appendFooter:(NSString *)footerInfo;

/**
 添加自定义的data

 @param data 自定义的data
 */
- (void)appendCustomData:(NSData *)data;

/**
 *  获取最终的data
 *
 *  @return 最终的data
 */
- (NSData *)getFinalData;

@end
