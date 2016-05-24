//
//  OneTableViewCell.h
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/10.
//  Copyright © 2016年 liming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *uuid;

@end
