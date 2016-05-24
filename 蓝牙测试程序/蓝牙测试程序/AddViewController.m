//
//  AddViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/12.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "AddViewController.h"
#import "AddTableViewCell.h"

@interface AddViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddViewController
{
    NSMutableString *uuids;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    uuids = [[NSMutableString alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[BLEControl sharedInstance] exitBluetooth];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveGroundAction:(id)sender {
    UIAlertController *saveAlert = [UIAlertController alertControllerWithTitle:nil message:@"保存分组" preferredStyle:UIAlertControllerStyleAlert];
    [saveAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"ground name";
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *temp = saveAlert.textFields.firstObject.text;
        if(temp.length == 0 || uuids.length == 0){
            return;
        } else {
            [[PlistManager sharedInstance] addGround:temp :uuids];
        }
        
    }];
        
    [saveAlert addAction:okAction];
    
    [self presentViewController:saveAlert animated:YES completion:nil];
}

- (void) scanBluetooth {
    [[BLEControl sharedInstance] scanDevices:^(CBPeripheral *peripheral) {
        [_tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [BLEControl sharedInstance].devicesArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheral = [[BLEControl sharedInstance].devicesArray objectAtIndex:indexPath.row];
    
    AddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addBleCell"];
    
    cell.bleName.text = peripheral.name;
    cell.uuid.text = peripheral.identifier.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [[BLEControl sharedInstance].devicesArray objectAtIndex:indexPath.row];
    [uuids insertString:[NSString stringWithFormat:@"%@,",peripheral.identifier.UUIDString] atIndex:0];
    NSLog(@"uuid为%@", uuids);
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) {
    CBPeripheral *peripheral = [[BLEControl sharedInstance].devicesArray objectAtIndex:indexPath.row];
    [uuids replaceOccurrencesOfString:[NSString stringWithFormat:@"%@,",peripheral.identifier.UUIDString]
                           withString:@""
                              options:NSCaseInsensitiveSearch
                                range:NSMakeRange(0, [uuids length])];
     NSLog(@"uuid为%@", uuids);
    
}

@end
