//
//  GroundViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/13.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "GroundViewController.h"

@interface GroundViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *serviceText;
@property (weak, nonatomic) IBOutlet UITextField *characText;
@property (weak, nonatomic) IBOutlet UITextField *valuesText;

@end

@implementation GroundViewController
{
    NSMutableArray *msgArray;
    NSArray *uuids;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    msgArray = [[NSMutableArray alloc] init];
    NSString *uuidStr = [_group objectForKey:KEY_GROUND_UUIDS];
    uuids = [uuidStr componentsSeparatedByString:@","];
    [self initView];
}

- (void)initView {
    
    NSString *service_uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"service_uuid"];
    NSString *character_uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"character_uuid"];
    NSString *value_send = [[NSUserDefaults standardUserDefaults] objectForKey:@"value_send"];
    
    
    if (!service_uuid) {
        _serviceText.text = @"fff0";
    } else {
        _serviceText.text = service_uuid;
    }
    if (!character_uuid) {
        _characText.text = @"fff6";
    } else {
        _characText.text = character_uuid;
    }
    if (!value_send) {
        _valuesText.text = @"123456";
    } else {
        _valuesText.text = value_send;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [BLEControl sharedInstance].controlStateBlock = ^(CBCentralManager* central) {
        switch (central.state) {
            case CBCentralManagerStatePoweredOff:
            {
                NSLog(@"蓝牙关闭");
                [[BLEControl sharedInstance].devicesArray removeAllObjects];
                [_tableView reloadData];
            }
                break;
            case CBCentralManagerStatePoweredOn:
            {
                [self scanBluetooth];
            }
                break;
                
            default:
                break;
        }
    };
    if ([BLEControl sharedInstance].BLEstate == CBCentralManagerStatePoweredOn) {
        [self scanBluetooth];
    }
    [[BLEControl sharedInstance] setNotifyStateChanged:^(BOOL isNotify, CBPeripheral *peripheral)
    {
        [msgArray insertObject:[NSString stringWithFormat:@"订阅%@%@",peripheral.name, isNotify?@"成功":@"失败或关闭"] atIndex:0];
        [_tableView reloadData];
    } andValueStateChanged:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, BOOL isWrite)
    {
        if (!isWrite) {
            [msgArray insertObject:[NSString stringWithFormat:@"%@%@数据：0x%@", @"读到", peripheral.name, [characteristic.value hexadecimalString]] atIndex:0];
            [_tableView reloadData];
        }
    }];
}

- (void) scanBluetooth {
    [msgArray insertObject:@"正在搜索设备" atIndex:0];
    [_tableView reloadData];
    [[BLEControl sharedInstance] scanDevices:^(CBPeripheral *peripheral) {
        for (NSString *uuid in uuids) {
            if ([uuid isEqualToString:peripheral.identifier.UUIDString]) {
                [self connectBluetooth:peripheral];
            }
        }
    }];
}

- (void) connectBluetooth:(CBPeripheral *)peripheral {
    [msgArray insertObject:[NSString stringWithFormat:@"找到设备%@，正在连接", [self removeSpaceAndNewline:peripheral.name]] atIndex:0];
    [_tableView reloadData];
    [[BLEControl sharedInstance] connect:peripheral :^(BOOL isConn) {
        if (isConn) {
            [msgArray insertObject:[NSString stringWithFormat:@"连接%@成功", [self removeSpaceAndNewline:peripheral.name]] atIndex:0];
            [_tableView reloadData];
        }
    } ];
}

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}


- (IBAction)serviceEdit:(UITextField *)sender {
    switch (sender.tag) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"service_uuid"];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"character_uuid"];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"value_send"];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellids = @"cellids";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellids];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellids];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = msgArray[indexPath.row];
    
    return cell;
}

- (IBAction)readAction:(id)sender {
    [[BLEControl sharedInstance] readToAllWithSerive:_serviceText.text withCharacuuid:_characText.text];
}
- (IBAction)writeAction:(id)sender {
    [[BLEControl sharedInstance] writeToAll:[NSData dataWithHexString:_valuesText.text] withSerive:_serviceText.text withCharacuuid:_characText.text];
    
}
- (IBAction)notifyChange:(UISwitch *)sender {
    [[BLEControl sharedInstance] notifyToAll:sender.on withSerive:_serviceText.text withCharacuuid:_characText.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@",string);
    if (textField.tag == 2) {
        return YES;
    }
    if (textField.text.length >=4) {
        textField.text = [textField.text substringToIndex:3];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



@end
