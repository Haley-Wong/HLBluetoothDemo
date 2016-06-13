//
//  BLEDetailViewController.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "BLEDetailViewController.h"
#import "ShoppingViewController.h"
#import "OrderWebController.h"

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
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"网络订单" style:UIBarButtonItemStylePlain target:self action:@selector(goToOrder)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _infos = [[NSMutableArray alloc] init];
    _tableView.rowHeight = 60;
    
    //连接蓝牙并展示详情
    [self loadBLEInfo];
}

- (HLPrinter *)getPrinter
{
    HLPrinter *printer = [[HLPrinter alloc] initWithShowPreview:YES];
    NSString *title = @"测试电商";
    NSString *str1 = @"测试电商服务中心(销售单)";
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
    NSDictionary *dict1 = @{@"name":@"铅笔测试一下哈哈",@"amount":@"5",@"price":@"2.0"};
    NSDictionary *dict2 = @{@"name":@"abcdefghijfdf",@"amount":@"1",@"price":@"1.0"};
    NSDictionary *dict3 = @{@"name":@"abcde笔记本啊啊",@"amount":@"3",@"price":@"3.0"};
    NSArray *goodsArray = @[dict1, dict2, dict3];
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
    
    [printer appendQRCodeWithInfo:@"www.baidu.com"];
    
    [printer appendImage:[UIImage imageNamed:@"ico180"] alignment:HLTextAlignmentCenter maxWidth:300];
    
    // 你也可以利用UIWebView加载HTML小票的方式，这样可以在远程修改小票的样式和布局。
    // 注意点：需要等UIWebView加载完成后，再截取UIWebView的屏幕快照，然后利用添加图片的方法，加进printer
    // 截取屏幕快照，可以用UIWebView+UIImage中的catogery方法 - (UIImage *)imageForWebView
    
    
    return printer;
}

- (void)goToOrder
{
    OrderWebController  *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderWebController"];
    orderVC.printBlock = ^(HLPrinter *printer) {
        NSData *mainData = [printer getFinalData];
        
#warning 如果打印出来乱码或者打印没反应，可能是您的打印机不支持大量数据写入。重启打印机，然后用其他方式写入数据
        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
        if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse];
        } else if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
                if (!error) {
                    NSLog(@"写入成功");
                }
            }];
        }

    };
    [self.navigationController pushViewController:orderVC animated:YES];
}

- (void)goToShopping
{
    ShoppingViewController *shoppingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
    shoppingVC.printBlock = ^(NSArray *printArray) {
        
//        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
//        
//        for (NSData *printData in printArray) {
//            if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
//                [bleManager writeValue:printData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse];
//            } else if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
//                [bleManager writeValue:printData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
//                    if (!error) {
//                        NSLog(@"写入成功");
//                    }
//                }];
//            }
//        }
        HLPrinter *printer = [self getPrinter];
        
        NSData *mainData = [printer getFinalData];
        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
        if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse];
        } else if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
            [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
                if (!error) {
                    NSLog(@"写入成功");
                }
            }];
        }
    };
    [self.navigationController pushViewController:shoppingVC animated:YES];
}

- (NSString *)hexStringFromData:(NSData *)printerData{
    
    Byte *bytes = (Byte *)[printerData bytes];
    
    NSString *hexStr = @"";
    for(int i = 0; i < [printerData length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        newHexStr = [newHexStr uppercaseString];
        if([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@ 0%@",hexStr,newHexStr];
        } else  {
            hexStr = [NSString stringWithFormat:@"%@ %@",hexStr,newHexStr];
        }
    }
    
    NSLog(@"%@",hexStr);
    
    return hexStr;
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
    //CBCharacteristicPropertyWrite和CBCharacteristicPropertyWriteWithoutResponse类型的特性都可以写入数据，但是后者不会返回写入结果
    if (properties & CBCharacteristicPropertyWrite) {
        if (self.chatacter == nil) {
            self.chatacter = character;
        }
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
//                                 NSLog(@"查找特性的描述成功");
                             }
                             break;
                         }
                         default:
                             break;
                     }
                     
                 }];
}


@end
