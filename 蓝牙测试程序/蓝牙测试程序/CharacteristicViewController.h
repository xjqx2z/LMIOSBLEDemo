//
//  CharacteristicViewController.h
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/11.
//  Copyright © 2016年 liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacteristicViewController : UIViewController

@property(nonatomic, weak)CBPeripheral *peripheral;
@property(nonatomic, weak)CBCharacteristic *characteristic;

@end
