//
//  BLEDetailViewController.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "BLEDetailViewController.h"
#import "ShoppingViewController.h"

#import "SVProgressHUD.h"
#import "UIImage+Bitmap.h"
#import "HLPrinter.h"

@interface BLEDetailViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSMutableArray            *infos;  /**< 详情数组 */

@property (strong, nonatomic)   CBCharacteristic            *chatacter;  /**< 可写入数据的特性 */

@end

@implementation BLEDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"蓝牙详情";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"商品" style:UIBarButtonItemStylePlain target:self action:@selector(goToShopping)];
                                  
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _infos = [[NSMutableArray alloc] init];
    _tableView.rowHeight = 60;
    
    //连接蓝牙并展示详情
    [self loadBLEInfo];
}

- (void)goToShopping
{
    ShoppingViewController *shoppingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
    shoppingVC.printBlock = ^(NSArray *goodsArray) {
        NSLog(@"goodsArray:%@",goodsArray);
        
        NSString *title = @"测试电商";
        NSString *str1 = @"测试电商服务中心(销售单)";
        
        HLPrinter *printer = [[HLPrinter alloc] init];
        [printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
        [printer appendText:str1 alignment:HLTextAlignmentCenter];
        [printer appendBarCodeWithInfo:@"RN3456789012"];
        [printer appendSeperatorLine];
        
        [printer appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
        [printer appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
        [printer appendText:@"地址:深圳市南山区学府路东深大店" alignment:HLTextAlignmentLeft];
        
        [printer appendSeperatorLine];
        [printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
        CGFloat total = 0.0;
        for (NSDictionary *dict in goodsArray) {
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
        
        [printer appendImage:[UIImage imageNamed:@"ico180"] alignment:HLTextAlignmentCenter maxWidth:300];
        
        NSData *mainData = [printer getFinalData];
        
        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
        [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
    };
    [self.navigationController pushViewController:shoppingVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _infos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBService *service = _infos[section];
    return service.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"infoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    CBService *service = _infos[indexPath.section];
    CBCharacteristic *character = [service.characteristics objectAtIndex:indexPath.row];
    CBCharacteristicProperties properties = character.properties;
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        self.chatacter = character;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",character.description];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"第%d个服务",(section + 1)];
}

- (void)loadBLEInfo
{
    HLBLEManager *manager = [HLBLEManager sharedInstance];
    [manager connectPeripheral:_perpheral
                connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
        stopScanAfterConnected:YES
               servicesOptions:nil
        characteristicsOptions:nil
                 completeBlock:^(HLOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error) {
                     switch (stage) {
                         case HLOptionStageConnection:
                         {
                             if (error) {
                                 [SVProgressHUD showErrorWithStatus:@"连接失败"];
                                 
                             } else {
                                 [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                             }
                             break;
                         }
                         case HLOptionStageSeekServices:
                         {
                             if (error) {
                                 [SVProgressHUD showSuccessWithStatus:@"查找服务失败"];
                             } else {
                                 [SVProgressHUD showSuccessWithStatus:@"查找服务成功"];
                                 [_infos addObjectsFromArray:peripheral.services];
                                 [_tableView reloadData];
                             }
                             break;
                         }
                         case HLOptionStageSeekCharacteristics:
                         {
                             // 该block会返回多次，每一个服务返回一次
                             if (error) {
                                 NSLog(@"查找特性失败");
                             } else {
                                 NSLog(@"查找特性成功");
                                 [_tableView reloadData];
                             }
                             break;
                         }
                         case HLOptionStageSeekdescriptors:
                         {
                             // 该block会返回多次，每一个特性返回一次
                             if (error) {
                                 NSLog(@"查找特性的描述失败");
                             } else {
                                 NSLog(@"查找特性的描述成功");
                             }
                             break;
                         }
                         default:
                             break;
                     }
                     
                 }];
}


@end
