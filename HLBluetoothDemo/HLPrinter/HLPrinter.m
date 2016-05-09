//
//  HLPrinter.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/3.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "HLPrinter.h"

#define kHLMargin 20
#define kHLPadding 2
#define kHLPreviewWidth 320

@interface HLPrinter ()

/** 将要打印的排版后的数据 */
@property (strong, nonatomic)   NSMutableData            *printerData;


/** 预览视图 */
@property (strong, nonatomic)   UIView            *previewView;
/** 预览视图高度 */
@property (assign, nonatomic)   CGFloat             height;

@end

@implementation HLPrinter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (instancetype)initWithShowPreview:(BOOL)showPreview
{
    self = [super init];
    if (self) {
        if (showPreview) {
            _previewView = [[UIView alloc] init];
            _previewView.frame = CGRectMake(0, 0, kHLPreviewWidth, 0);
            _previewView.backgroundColor = [UIColor whiteColor];
        }
        
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting
{
    _printerData = [[NSMutableData alloc] init];
    
    _height += kHLPadding;
    
    // 1.初始化打印机
    Byte initBytes[] = {0x1B,0x40};
    [_printerData appendBytes:initBytes length:sizeof(initBytes)];
    // 2.设置行间距为1/6英寸，约34个点
    // 另一种设置行间距的方法看这个 @link{-setLineSpace:}
    Byte lineSpace[] = {0x1B,0x32};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
    // 3.设置字体:标准0x00，压缩0x01;
    Byte fontBytes[] = {0x1B,0x4D,0x00};
    [_printerData appendBytes:fontBytes length:sizeof(fontBytes)];
    
}

#pragma mark - -------------基本操作----------------
/**
 *  换行
 */
- (void)appendNewLine
{
    Byte nextRowBytes[] = {0x0A};
    [_printerData appendBytes:nextRowBytes length:sizeof(nextRowBytes)];
}

/**
 *  回车
 */
- (void)appendReturn
{
    Byte returnBytes[] = {0x0D};
    [_printerData appendBytes:returnBytes length:sizeof(returnBytes)];
}

/**
 *  设置对齐方式
 *
 *  @param alignment 对齐方式：居左、居中、居右
 */
- (void)setAlignment:(HLTextAlignment)alignment
{
    Byte alignBytes[] = {0x1B,0x61,alignment};
    [_printerData appendBytes:alignBytes length:sizeof(alignBytes)];
}

/**
 *  设置字体大小
 *
 *  @param fontSize 字号
 */
- (void)setFontSize:(HLFontSize)fontSize
{
    Byte fontSizeBytes[] = {0x1D,0x21,fontSize};
    [_printerData appendBytes:fontSizeBytes length:sizeof(fontSizeBytes)];
}

/**
 *  添加文字，不换行
 *
 *  @param text 文字内容
 */
- (void)setText:(NSString *)text
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    [_printerData appendData:data];
}

/**
 *  设置偏移文字
 *
 *  @param text 文字
 */
- (void)setOffsetText:(NSString *)text
{
    // 1.计算偏移量,因字体和字号不同，所以计算出来的宽度与实际宽度有误差(小字体与22字体计算值接近)
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:22.0]};
    NSAttributedString *valueAttr = [[NSAttributedString alloc] initWithString:text attributes:dict];
    int valueWidth = valueAttr.size.width;
    
    // 2.设置偏移量
    [self setOffset:368 - valueWidth];
    
    // 3.设置文字
    [self setText:text];
}

/**
 *  设置偏移量
 *
 *  @param offset 偏移量
 */
- (void)setOffset:(NSInteger)offset
{
    NSInteger remainder = offset % 256;
    NSInteger consult = offset / 256;
    Byte spaceBytes2[] = {0x1B, 0x24, remainder, consult};
    [_printerData appendBytes:spaceBytes2 length:sizeof(spaceBytes2)];
}

/**
 *  设置行间距
 *
 *  @param points 多少个点
 */
- (void)setLineSpace:(NSInteger)points
{
    //最后一位，可选 0~255
    Byte lineSpace[] = {0x1B,0x33,60};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
}

#pragma mark - ------------function method ----------------
#pragma mark  文字
- (void)appendText:(NSString *)text alignment:(HLTextAlignment)alignment
{
    [self appendText:text alignment:alignment fontSize:HLFontSizeTitleSmalle];
}

- (void)appendText:(NSString *)text alignment:(HLTextAlignment)alignment fontSize:(HLFontSize)fontSize
{
    // 1.文字对齐方式
    [self setAlignment:alignment];
    // 2.设置字号
    [self setFontSize:fontSize];
    // 3.设置标题内容
    [self setText:text];
    // 4.换行
    [self appendNewLine];
    if (fontSize != HLFontSizeTitleSmalle) {
        [self appendNewLine];
    }
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.numberOfLines = 0;
    textLabel.text = text;
    CGFloat offsetY = kHLPadding;
    if (fontSize == HLFontSizeTitleMiddle) {
        textLabel.font = [UIFont systemFontOfSize:30];
        offsetY = kHLPadding * 2;
    } else if (fontSize == HLFontSizeTitleBig) {
        textLabel.font = [UIFont systemFontOfSize:48];
        offsetY = kHLPadding * 2;
    }
    CGSize size = [textLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, size.height);
    _height += (offsetY + size.height);
    if (alignment == HLTextAlignmentLeft) {
        textLabel.textAlignment = NSTextAlignmentLeft;
    } else if (alignment == HLTextAlignmentCenter) {
        textLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        textLabel.textAlignment = NSTextAlignmentRight;
    }
    
    [_previewView addSubview:textLabel];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value
{
    [self appendTitle:title value:value fontSize:HLFontSizeTitleSmalle];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value fontSize:(HLFontSize)fontSize
{
    // 1.设置对齐方式
    [self setAlignment:HLTextAlignmentLeft];
    // 2.设置字号
    [self setFontSize:fontSize];
    // 3.设置标题内容
    [self setText:title];
    // 4.设置实际值
    [self setOffsetText:value];
    // 5.换行
    [self appendNewLine];
    if (fontSize != HLFontSizeTitleSmalle) {
        [self appendNewLine];
    }
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    UILabel *textLabel = [[UILabel alloc] init];
    UILabel *valueLabel = [[UILabel alloc] init];
    textLabel.numberOfLines = 0;
    valueLabel.numberOfLines = 0;
    textLabel.text = title;
    valueLabel.text = value;
    CGFloat offsetY = kHLPadding;
    if (fontSize == HLFontSizeTitleMiddle) {
        textLabel.font = [UIFont systemFontOfSize:30];
        valueLabel.font = [UIFont systemFontOfSize:30];
        offsetY = kHLPadding * 2;
    } else if (fontSize == HLFontSizeTitleBig) {
        textLabel.font = [UIFont systemFontOfSize:48];
        valueLabel.font = [UIFont systemFontOfSize:48];
        offsetY = kHLPadding * 2;
    }
    CGSize size = [textLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, size.height);
    textLabel.textAlignment = NSTextAlignmentLeft;
    
    CGSize valueSize = [valueLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    valueLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, valueSize.height);
    
    _height += (offsetY + size.height > valueSize.height ? size.height:valueSize.height);
    valueLabel.textAlignment = NSTextAlignmentRight;
    
    [_previewView addSubview:textLabel];
    
    [_previewView addSubview:valueLabel];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset
{
    [self appendTitle:title value:value valueOffset:offset fontSize:HLFontSizeTitleSmalle];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset fontSize:(HLFontSize)fontSize
{
    // 1.设置对齐方式
    [self setAlignment:HLTextAlignmentLeft];
    // 2.设置字号
    [self setFontSize:fontSize];
    // 3.设置标题内容
    [self setText:title];
    // 4.设置内容偏移量
    [self setOffset:offset];
    // 5.设置实际值
    [self setText:value];
    // 6.换行
    [self appendNewLine];
    if (fontSize != HLFontSizeTitleSmalle) {
        [self appendNewLine];
    }
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    UILabel *textLabel = [[UILabel alloc] init];
    UILabel *valueLabel = [[UILabel alloc] init];
    textLabel.numberOfLines = 0;
    valueLabel.numberOfLines = 0;
    textLabel.text = title;
    valueLabel.text = value;
    CGFloat offsetY = kHLPadding;
    if (fontSize == HLFontSizeTitleMiddle) {
        textLabel.font = [UIFont systemFontOfSize:30];
        valueLabel.font = [UIFont systemFontOfSize:30];
        offsetY = kHLPadding * 2;
    } else if (fontSize == HLFontSizeTitleBig) {
        textLabel.font = [UIFont systemFontOfSize:48];
        valueLabel.font = [UIFont systemFontOfSize:48];
        offsetY = kHLPadding * 2;
    }
    CGSize size = [textLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, size.height);
    textLabel.textAlignment = NSTextAlignmentLeft;
    
    CGSize valueSize = [valueLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    valueLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, valueSize.height);
    
    _height += (offsetY + MAX(size.height, valueSize.height));
    valueLabel.textAlignment = NSTextAlignmentRight;
    
    [_previewView addSubview:textLabel];
    
    [_previewView addSubview:valueLabel];
}

- (void)appendLeftText:(NSString *)left middleText:(NSString *)middle rightText:(NSString *)right isTitle:(BOOL)isTitle
{
    [self setAlignment:HLTextAlignmentLeft];
    [self setFontSize:HLFontSizeTitleSmalle];
    NSInteger offset = 0;
    if (!isTitle) {
        offset = 10;
    }
    
    if (left) {
        [self setText:left];
    }
    
    if (middle) {
        [self setOffset:150 + offset];
        [self setText:middle];
    }
    
    if (right) {
        [self setOffset:300 + offset];
        [self setText:right];
    }
    
    [self appendNewLine];
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    CGFloat labelWidth = (kHLPreviewWidth - kHLMargin *2) / 3;
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.numberOfLines = 0;
    textLabel.text = left;
    CGFloat offsetY = kHLPadding;
    CGSize size = [textLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(kHLMargin, _height, labelWidth, size.height);
    
    [_previewView addSubview:textLabel];
    
    UILabel *middleLabel = [[UILabel alloc] init];
    middleLabel.textAlignment = NSTextAlignmentCenter;
    middleLabel.numberOfLines = 0;
    middleLabel.text = middle;
    CGSize middleSize = [middleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    middleLabel.frame = CGRectMake(kHLMargin + labelWidth, _height, labelWidth, middleSize.height);
    [_previewView addSubview:middleLabel];
    
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.numberOfLines = 0;
    rightLabel.text = right;
    CGSize rightsize = [rightLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    rightLabel.frame = CGRectMake(kHLMargin + labelWidth * 2, _height, labelWidth, rightsize.height);
    
    CGFloat maxHeight = MAX(MAX(size.height,middleSize.height), rightsize.height);
    [_previewView addSubview:rightLabel];
    
    _height += (offsetY + maxHeight);
}

#pragma mark 图片
- (void)appendImage:(UIImage *)image alignment:(HLTextAlignment)alignment maxWidth:(CGFloat)maxWidth
{
    if (!image) {
        return;
    }
    
    // 1.设置图片对齐方式
    [self setAlignment:alignment];
    
    // 2.设置图片
    UIImage *newImage = [image imageWithscaleMaxWidth:maxWidth];
    newImage = [newImage blackAndWhiteImage];
    
    NSData *imageData = [newImage bitmapData];
    [_printerData appendData:imageData];
    
    // 3.换行
    [self appendNewLine];
    
    // 4.打印图片后，恢复文字的行间距
    Byte lineSpace[] = {0x1B,0x32};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
    imageView.backgroundColor = [UIColor redColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat offsetY = kHLPadding;
    CGFloat imageX = (kHLPreviewWidth - newImage.size.width * 0.7) * 0.5;
    imageView.frame = CGRectMake(imageX, _height, newImage.size.width * 0.7, newImage.size.height * 0.7);
    _height += (offsetY + newImage.size.height * 0.7);
    
    [_previewView addSubview:imageView];
}

- (void)appendBarCodeWithInfo:(NSString *)info
{
    [self appendBarCodeWithInfo:info alignment:HLTextAlignmentCenter maxWidth:300];
}

- (void)appendBarCodeWithInfo:(NSString *)info alignment:(HLTextAlignment)alignment maxWidth:(CGFloat)maxWidth
{
    UIImage *barImage = [UIImage barCodeImageWithInfo:info];
    [self appendImage:barImage alignment:alignment maxWidth:maxWidth];
}

- (void)appendQRCodeWithInfo:(NSString *)info
{
    [self appendQRCodeWithInfo:info centerImage:nil alignment:HLTextAlignmentCenter maxWidth:300];
}

- (void)appendQRCodeWithInfo:(NSString *)info centerImage:(UIImage *)centerImage alignment:(HLTextAlignment)alignment maxWidth:(CGFloat )maxWidth
{
    UIImage *QRImage = [UIImage qrCodeImageWithInfo:info centerImage:centerImage width:maxWidth];
    [self appendImage:QRImage alignment:alignment maxWidth:300];
}

#pragma mark 其他
- (void)appendSeperatorLine
{
    // 1.设置分割线居中
    [self setAlignment:HLTextAlignmentCenter];
    // 2.设置字号
    [self setFontSize:HLFontSizeTitleSmalle];
    // 3.添加分割线
    NSString *line = @"- - - - - - - - - - - - - - - -";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [line dataUsingEncoding:enc];
    [_printerData appendData:data];
    // 4.换行
    [self appendNewLine];
    
    //-------------预览视图------------------
    if (!_previewView) {
        return;
    }
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"- - - - - - - - - - - - - - - - - - - - - - ";;
    CGFloat offsetY = kHLPadding;
    CGSize size = [textLabel sizeThatFits:CGSizeMake(kHLPreviewWidth - kHLMargin *2, CGFLOAT_MAX)];
    textLabel.frame = CGRectMake(kHLMargin, _height, kHLPreviewWidth - kHLMargin *2, size.height);
    _height += (offsetY + size.height);
    
    [_previewView addSubview:textLabel];
}

- (void)appendFooter:(NSString *)footerInfo
{
    [self appendSeperatorLine];
    if (!footerInfo) {
        footerInfo = @"谢谢惠顾，欢迎下次光临！";
    }
    [self appendText:footerInfo alignment:HLTextAlignmentCenter];
}

- (NSData *)getFinalData
{
    return _printerData;
}

- (UIView *)getPreviewView
{
    _previewView.frame = CGRectMake(0, 0, kHLPreviewWidth, _height);
    return _previewView;
}

@end
