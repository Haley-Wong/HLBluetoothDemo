//
//  OrderWebController.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/13.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLPrinter.h"

@interface OrderWebController : UIViewController

@property (copy, nonatomic) void(^printBlock)(HLPrinter *printer);    /**< 打印block */

@end
