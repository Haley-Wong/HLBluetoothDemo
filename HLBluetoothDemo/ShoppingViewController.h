//
//  ShoppingViewController.h
//  BlueToochDemo
//
//  Created by Harvey on 16/4/26.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PrintBlock)(NSArray *goodsArray);

@interface ShoppingViewController : UIViewController

@property (copy, nonatomic) PrintBlock            printBlock;    /**< 打印block */

@end
