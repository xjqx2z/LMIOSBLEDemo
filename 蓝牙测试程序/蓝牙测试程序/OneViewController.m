//
//  OneViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/10.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "OneViewController.h"
#import "OneTableViewCell.h"
#import "OneServiceViewController.h"

@interface OneViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initBluetooth];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[BLEControl sharedInstance] exitBluetooth];
    [self initBluetooth];
}

- (void) initBluetooth {
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

- (void)initView {

}


- (void) scanBluetooth {
    [[BLEControl sharedInstance] scanDevices:^(CBPeripheral *peripheral) {
        [_tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [BLEControl sharedInstance].devicesArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CBPeripheral *peripheral = [[BLEControl sharedInstance].devicesArray objectAtIndex:indexPath.row];

    OneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"oneBleCell"];
    
    cell.deviceName.text = peripheral.name;
    cell.uuid.text = peripheral.identifier.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [[BLEControl sharedInstance].devicesArray objectAtIndex:indexPath.row];
    [[BLEControl sharedInstance] connect:peripheral :^(BOOL isConn) {
        if (isConn) {
            [self performSegueWithIdentifier:@"gotoService" sender:peripheral];
        }
    }];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"gotoService"]) {
        OneServiceViewController *ctr = segue.destinationViewController;
        ctr.peripheral = sender;
        
    }
}



@end
