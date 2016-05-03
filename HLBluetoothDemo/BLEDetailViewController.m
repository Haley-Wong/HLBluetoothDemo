//
//  BLEDetailViewController.m
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import "BLEDetailViewController.h"
#import "SVProgressHUD.h"

@interface BLEDetailViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)   NSMutableArray            *infos;  /**< 详情数组 */

@end

@implementation BLEDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"蓝牙详情";
    
    _infos = [[NSMutableArray alloc] init];
    _tableView.rowHeight = 60;
    
    //连接蓝牙并展示详情
    [self loadBLEInfo];
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
                             // 该block会返回多次，每一个特性返回一次
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
                             // 该block会返回多次，每一个descriptor返回一次
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
