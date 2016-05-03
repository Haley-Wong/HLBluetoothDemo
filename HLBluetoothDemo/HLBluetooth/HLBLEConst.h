//
//  HLBLEConst.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#ifndef HLBLEConst_h
#define HLBLEConst_h

typedef NS_ENUM(NSInteger, HLOptionStage) {
    HLOptionStageConnection,            //蓝牙连接阶段
    HLOptionStageSeekServices,          //搜索服务阶段
    HLOptionStageSeekCharacteristics,   //搜索特性阶段
    HLOptionStageSeekdescriptors,        //搜索描述信息阶段
};

#pragma mark ------------------- 通知的定义 --------------------------
/** 蓝牙状态改变的通知 */
#define kCentralManagerStateUpdateNoticiation @"kCentralManagerStateUpdateNoticiation"

#pragma mark ------------------- block的定义 --------------------------
/** 蓝牙状态改变的block */
typedef void(^HLStateUpdateBlock)(CBCentralManager *central);

/** 发现一个蓝牙外设的block */
typedef void(^HLDiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

/** 连接完成的block,失败error就不为nil */
typedef void(^HLConnectCompletionBlock)(CBPeripheral *peripheral, NSError *error);

/** 搜索到连接上的蓝牙外设的服务block */
typedef void(^HLDiscoveredServicesBlock)(CBPeripheral *peripheral, NSArray *services, NSError *error);

/** 搜索某个服务的子服务 的回调 */
typedef void(^HLDiscoveredIncludedServicesBlock)(CBPeripheral *peripheral,CBService *service, NSArray *includedServices, NSError *error);

/** 搜索到某个服务中的特性的block */
typedef void(^HLDiscoverCharacteristicsBlock)(CBPeripheral *peripheral, CBService *service, NSArray *characteristics, NSError *error);

/** 收到某个特性值更新的回调 */
typedef void(^HLNotifyCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);

/** 查找到某个特性的描述 block */
typedef void(^HLDiscoverDescriptorsBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSArray *descriptors, NSError *error);

/** 统一返回使用的block */
typedef void(^HLBLECompletionBlock)(HLOptionStage stage, CBPeripheral *peripheral,CBService *service, CBCharacteristic *character, NSError *error);

/** 获取特性中的值 */
typedef void(^HLValueForCharacteristicBlock)(CBCharacteristic *characteristic, NSData *value, NSError *error);

/** 获取描述中的值 */
typedef void(^HLValueForDescriptorBlock)(CBDescriptor *descriptor,NSData *data,NSError *error);

/** 往特性中写入数据的回调 */
typedef void(^HLWriteToCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);

/** 往描述中写入数据的回调 */
typedef void(^HLWriteToDescriptorBlock)(CBDescriptor *descriptor, NSError *error);

/** 获取蓝牙外设信号的回调 */
typedef void(^HLGetRSSIBlock)(CBPeripheral *peripheral,NSNumber *RSSI, NSError *error);

#endif /* HLBLEConst_h */
