# HLBluetoothDemo
蓝牙操作库，block方式操作蓝牙。<br>
因为系统的蓝牙操作库是用delegate实现的，步骤比较繁多，操作很零散，需要写一堆的代理方法，特别麻烦 <br>
所以我在使用的时候将常用的一些代理用block方式实现<br>
# 介绍
用block改写后，使用大致分为三步：
* 获取蓝牙模块的状态
* 扫描蓝牙外设
* 连接、扫描服务、扫描特性、扫描描述。
因为连接、扫描服务、扫描特性、扫描描述也是属于不同的阶段，所以在block返回时，也有阶段值返回。<br>

~~---------------------------------------------------------------------------------------------------------~~<br>
除了上面这些代理方法改写的block API之外，还有一些操作性方法，
比如：
* 读取特性值
* 读取描述值
* 往特性中写入数据
* 往描述中写入数据
* 读取信号数据
* 取消蓝牙连接
...


以上这些方法也提供block方式和一般的调用方式。<br>
# 使用方式

创建蓝牙管理单例,扫描蓝牙设备：
```
HLBLEManager *manager = [HLBLEManager sharedInstance];
    manager.stateUpdateBlock = ^(CBCentralManager *central) {
        NSString *info = nil;
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:
                info = @"蓝牙已打开，并且可用";
                [central scanForPeripheralsWithServices:nil options:nil];
                break;
            case CBCentralManagerStatePoweredOff:
                info = @"蓝牙可用，未打开";
                break;
            case CBCentralManagerStateUnsupported:
                info = @"SDK不支持";
                break;
            case CBCentralManagerStateUnauthorized:
                info = @"程序未授权";
                break;
            case CBCentralManagerStateResetting:
                info = @"CBCentralManagerStateResetting";
                break;
            case CBCentralManagerStateUnknown:
                info = @"CBCentralManagerStateUnknown";
                break;
        }
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showInfoWithStatus:info ];
    };
```
设置扫描到蓝牙设备的block，因为蓝牙每次扫描到一个设备后都会返回一次，同一个蓝牙外设可能会返回多次。
```
/** 发现一个蓝牙外设的回调 */
@property (copy, nonatomic) HLDiscoverPeripheralBlock               discoverPeripheralBlcok;
```

然后就可以获取其扫描到的蓝牙外设了
```
    manager.discoverPeripheralBlcok = ^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheral.name.length <= 0) {
            return ;
        }
        
        if (self.deviceArray.count == 0) {
            NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
            [self.deviceArray addObject:dict];
        } else {
            BOOL isExist = NO;
            for (int i = 0; i < self.deviceArray.count; i++) {
                NSDictionary *dict = [self.deviceArray objectAtIndex:i];
                CBPeripheral *per = dict[@"peripheral"];
                if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                    isExist = YES;
                    NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                    [_deviceArray replaceObjectAtIndex:i withObject:dict];
                }
            }
            
            if (!isExist) {
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [self.deviceArray addObject:dict];
            }
        }
        
        [self.tableView reloadData];
        
    };
 ```
 
 然后连接蓝牙外设,查询服务、特性、特性描述：
 ```
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
```
若想查询特性的值：
```
/**
 *  读取某个特性的值
 *
 *  @param characteristic 要读取的特性
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  读取某个特性的值
 *
 *  @param characteristic  要读取的特性
 *  @param completionBlock 读取完后的回调
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic completionBlock:(HLValueForCharacteristicBlock)completionBlock;
```
若想查询特性描述的值：
```
/**
 *  读取某特性的描述信息
 *
 *  @param descriptor 描述对象
 */
- (void)readValueForDescriptor:(CBDescriptor *)descriptor;

/**
 *  读取某特性的描述信息
 *
 *  @param descriptor      描述对象
 *  @param completionBlock 读取结果返回时的回调
 */
- (void)readValueForDescriptor:(CBDescriptor *)descriptor completionBlock:(HLValueForDescriptorBlock)completionBlock;
```
我们也可以在获取到蓝牙管理的单例后，就设置好各种block回调，后面操作就不用再设置completionBlock了。<br>
demo中也有一个使用的例子<br>

如有使用错误或者更好的建议，请issues我。
