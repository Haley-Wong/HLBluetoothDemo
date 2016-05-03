//
//  BLEDetailViewController.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/4/29.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLBLEManager.h"

@interface BLEDetailViewController : UIViewController

@property (strong, nonatomic)   CBPeripheral            *perpheral;

@end
