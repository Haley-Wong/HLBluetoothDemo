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
        
        HLBLEManager *bleManager = [HLBLEManager sharedInstance];
        
        for (NSData *printData in printArray) {
            if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [bleManager writeValue:printData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse];
            } else if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
                [bleManager writeValue:printData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
                    if (!error) {
                        NSLog(@"写入成功");
                    }
                }];
            }
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
