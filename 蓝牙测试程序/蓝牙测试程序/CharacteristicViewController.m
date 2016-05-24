//
//  CharacteristicViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/11.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "CharacteristicViewController.h"

@interface CharacteristicViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *properLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UITextField *writeText;
@property (weak, nonatomic) IBOutlet UIButton *writeBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnRead;

@end

@implementation CharacteristicViewController
{
    NSMutableArray *msgArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    msgArray = [[NSMutableArray alloc] init];
    [self initView];
    [BLEControl sharedInstance].valuesChangeBlock = ^(CBPeripheral* peripheral, CBCharacteristic *characteristic, BOOL isWrite) {
        if (isWrite) {
            [msgArray insertObject:[NSString stringWithFormat:@"向%@发送数据0x%@", peripheral.name, [characteristic.value hexadecimalString]] atIndex:0];
        } else {
            [msgArray insertObject:[NSString stringWithFormat:@"从%@接收数据0x%@", peripheral.name, [characteristic.value hexadecimalString]] atIndex:0];
        }
        [_tableView reloadData];
    };
}

- (void) initView {
    _uuidLabel.text = [NSString stringWithFormat:@"Characteristic: %@", _characteristic.UUID.UUIDString ];
    _writeText.delegate = self;
    
    _notifyLabel.hidden = YES;
    _notifySwitch.hidden = YES;
    _writeText.hidden = YES;
    _writeBtn.hidden = YES;
    _tableView.hidden = YES;
    _btnRead.hidden = YES;
    
    NSMutableString *desc = [[NSMutableString alloc] init];
    if ((_characteristic.properties & 1) == 1) {
        [desc insertString:@"_BROADCAST" atIndex:0];
    }
    if (((_characteristic.properties >> 1) & 1) == 1) {
        [desc insertString:@"_READ" atIndex:0];
        _btnRead.hidden = NO;
        _tableView.hidden = NO;
    }
    if (((_characteristic.properties >> 2) & 1) == 1) {
        [desc insertString:@"_WRITE_NO_RESPONSE" atIndex:0];
        _writeBtn.hidden = NO;
        _writeText.hidden = NO;
        _tableView.hidden = NO;
    }
    if (((_characteristic.properties >> 3) & 1) == 1) {
        [desc insertString:@"_WRITE" atIndex:0];
        _writeBtn.hidden = NO;
        _writeText.hidden = NO;
        _tableView.hidden = NO;
    }
    if (((_characteristic.properties >> 4) & 1) == 1) {
        [desc insertString:@"_NOTIFY" atIndex:0];
        _notifyLabel.hidden = NO;
        _notifySwitch.hidden = NO;
    }
    if (((_characteristic.properties >> 5) & 1) == 1) {
        [desc insertString:@"_INDICATE" atIndex:0];
    }
    if (((_characteristic.properties >> 6) & 1) == 1) {
        [desc insertString:@"_SIGNED_WRITE" atIndex:0];
    }
    if (((_characteristic.properties >> 7) & 1) == 1) {
        [desc insertString:@"_EXTENDED_PROPS" atIndex:0];
    }
    
    _properLabel.text = [NSString stringWithFormat:@"Properties: %@", desc ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return msgArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
    }
    cell.textLabel.text = msgArray[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor lightGrayColor];

    return cell;
}


- (IBAction)notifyAction:(id)sender {
    [_peripheral setNotifyValue:_notifySwitch.on forCharacteristic:_characteristic];
}


- (IBAction)writeAction:(id)sender {
    NSString *message = _writeText.text;
    if (!message) {
        return;
    }
    if (((_characteristic.properties >> 2) & 1) == 1) {
        [_peripheral writeValue:[NSData dataWithHexString:message] forCharacteristic:_characteristic type:CBCharacteristicWriteWithoutResponse];
        [msgArray insertObject:[NSString stringWithFormat:@"向%@发送数据0x%@", _peripheral.name, message] atIndex:0];
    }
    
    if (((_characteristic.properties >> 3) & 1) == 1) {
        [_peripheral writeValue:[NSData dataWithHexString:message] forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
    }
    
    [_tableView reloadData];
    
}
- (IBAction)readAction:(id)sender {
    [_peripheral readValueForCharacteristic:_characteristic];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *message = _writeText.text;
    if (!message) {
        return NO;
    }
    if (message.length%2 != 0 && message.length != 1) {
        message = [message substringToIndex:message.length - 1];
    }
    if (((_characteristic.properties >> 2) & 1) == 1) {
        [_peripheral writeValue:[NSData dataWithHexString:message] forCharacteristic:_characteristic type:CBCharacteristicWriteWithoutResponse];
        [msgArray insertObject:[NSString stringWithFormat:@"向%@发送数据0x%@", _peripheral.name, message] atIndex:0];
    }
    
    if (((_characteristic.properties >> 3) & 1) == 1) {
        [_peripheral writeValue:[NSData dataWithHexString:message] forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
    }
    
    [_tableView reloadData];
    
    [textField canResignFirstResponder];
    
    return YES;
}


@end
