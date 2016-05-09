//
//  SEPreviewViewController.m
//  SEBLEPrinter
//
//  Created by Harvey on 16/5/6.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

/**< 打印小票预览容器视图 */
@property (strong, nonatomic)  UIScrollView            *scrollView;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    
    self.title = @"预览";
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        CGRect rect = self.view.frame;
        rect.origin.y += 64;
        rect.size.height -= 64;
        _scrollView = [[UIScrollView alloc] initWithFrame:rect];
        _scrollView.backgroundColor = [UIColor grayColor];
        _scrollView.scrollEnabled = YES;
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (void)setPreviewView:(UIView *)previewView
{
    _previewView = previewView;
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _previewView.frame.size.height);
    
    [self.scrollView addSubview:_previewView];
  
}

@end
