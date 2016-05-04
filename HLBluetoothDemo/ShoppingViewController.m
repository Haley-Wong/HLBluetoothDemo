//
//  ShoppingViewController.m
//  BlueToochDemo
//
//  Created by Harvey on 16/4/26.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "ShoppingViewController.h"

@interface ShoppingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSArray            *goodsArray;  /**< 商品数组 */

@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(printAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSDictionary *dict1 = @{@"name":@"铅笔",@"amount":@"5",@"price":@"2.0"};
    NSDictionary *dict2 = @{@"name":@"橡皮",@"amount":@"1",@"price":@"1.0"};
    NSDictionary *dict3 = @{@"name":@"笔记本",@"amount":@"3",@"price":@"3.0"};
    self.goodsArray = @[dict1, dict2, dict3];
}

- (void)printAction
{
    [self.navigationController popViewControllerAnimated:YES];
    if (_printBlock) {
        _printBlock(self.goodsArray);
    }
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
