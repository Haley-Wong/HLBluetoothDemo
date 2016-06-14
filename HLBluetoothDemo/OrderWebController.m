//
//  OrderWebController.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/13.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "OrderWebController.h"

#import "HLBLEManager.h"
#import "UIWebView+UIImage.h"

@interface OrderWebController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation OrderWebController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *str = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
}

- (void)rightAction
{
    NSLog(@"rightAction");
    HLPrinter *printer = [[HLPrinter alloc] init];
    UIImage *image = [_webView imageForWebView];
//    [printer appendBarCodeWithInfo:@"RN3456789012"];
//    [printer appendSeperatorLine];
    [printer appendImage:image alignment:HLTextAlignmentLeft maxWidth:450];
    
    if (_printBlock) {
        _printBlock(printer);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
