//
//  OneTableViewCell.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/10.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "OneTableViewCell.h"

@implementation OneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editName:(id)sender {
    NSLog(@"修改名字");
}

@end
