//
//  ShoppingViewController.m
//  BlueToochDemo
//
//  Created by Harvey on 16/4/26.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "ShoppingViewController.h"
#import "PreviewViewController.h"
#import "HLPrinter.h"

@interface ShoppingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSArray            *goodsArray;  /**< 商品数组 */

@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"购物车";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(printAction)];
    self.navigationItem.rightBarButtonItems = @[leftItem,rightItem];
    
    NSDictionary *dict1 = @{@"name":@"铅笔",@"amount":@"5",@"price":@"2.0"};
    NSDictionary *dict2 = @{@"name":@"橡皮",@"amount":@"1",@"price":@"1.0"};
    NSDictionary *dict3 = @{@"name":@"笔记本",@"amount":@"3",@"price":@"3.0"};
    self.goodsArray = @[dict1, dict2, dict3];
}

- (HLPrinter *)getPrinter
{
    
    HLPrinter *printer = [[HLPrinter alloc] initWithShowPreview:YES];
    NSString *title = @"测试电商";
    NSString *str1 = @"测试电商服务中心(销售单)";
    [printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
    [printer appendText:str1 alignment:HLTextAlignmentCenter];
    [printer appendBarCodeWithInfo:@"123456789012"];
    [printer appendSeperatorLine];
    
    [printer appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
    [printer appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
    [printer appendText:@"地址:深圳市南山区学府路东深大店" alignment:HLTextAlignmentLeft];
    
    [printer appendSeperatorLine];
    [printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
    CGFloat total = 0.0;
    for (NSDictionary *dict in self.goodsArray) {
        [printer appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
        total += [dict[@"price"] floatValue] * [dict[@"amount"] intValue];
    }
    
    [printer appendSeperatorLine];
    NSString *totalStr = [NSString stringWithFormat:@"%.2f",total];
    [printer appendTitle:@"总计:" value:totalStr];
    [printer appendTitle:@"实收:" value:@"100.00"];
    NSString *leftStr = [NSString stringWithFormat:@"%.2f",100.00 - total];
    [printer appendTitle:@"找零:" value:leftStr];
    
    [printer appendFooter:nil];
    
    [printer appendQRCodeWithInfo:@"www.baidu.com"];
    
    return printer;
}

- (NSArray *)printDataArray
{
    NSMutableArray *printInfoArray = [NSMutableArray array];
    
    // 你可以多行数据一起写进蓝牙，但是不要过长，否则可能会导致乱码
    HLPrinter *printer = [[HLPrinter alloc] init];
    NSString *title = @"测试电商";
    [printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
    NSString *str1 = @"测试电商服务中心(销售单)";
    [printer appendText:str1 alignment:HLTextAlignmentCenter];
    NSData *data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendSeperatorLine];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendText:@"地址:深圳市南山区学府路东深大店" alignment:HLTextAlignmentLeft];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendSeperatorLine];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
 
    printer = [[HLPrinter alloc] init];
    [printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    CGFloat total = 0.0;
    for (NSDictionary *dict in self.goodsArray) {
        printer = [[HLPrinter alloc] init];
        [printer appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
        data1 = [printer getFinalData];
        [printInfoArray addObject:data1];
 
        total += [dict[@"price"] floatValue] * [dict[@"amount"] intValue];
    }
    
    printer = [[HLPrinter alloc] init];
    [printer appendSeperatorLine];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    NSString *totalStr = [NSString stringWithFormat:@"%.2f",total];
    [printer appendTitle:@"总计:" value:totalStr];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendTitle:@"实收:" value:@"100.00"];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];

    
    printer = [[HLPrinter alloc] init];
    NSString *leftStr = [NSString stringWithFormat:@"%.2f",100.00 - total];
    [printer appendTitle:@"找零:" value:leftStr];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];

    
    printer = [[HLPrinter alloc] init];
    [printer appendFooter:nil];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];
    
    printer = [[HLPrinter alloc] init];
    [printer appendQRCodeWithInfo:@"www.baidu.com" size:12];
    data1 = [printer getFinalData];
    [printInfoArray addObject:data1];

    return printInfoArray;
}

- (void)printAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    NSArray *printInfo = [self printDataArray];
    
    if (_printBlock) {
        _printBlock(printInfo);
    }
}

- (void)leftAction
{
    HLPrinter *printer = [self getPrinter];
    PreviewViewController *previewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewViewController"];
    previewVC.previewView = [printer getPreviewView];
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.goodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSDictionary *dict = self.goodsArray[indexPath.row];
    
    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"单价: %@元-------数量：%@",dict[@"price"], dict[@"amount"]];
    
    return cell;
}


@end
