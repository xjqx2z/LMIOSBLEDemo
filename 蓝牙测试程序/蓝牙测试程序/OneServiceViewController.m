//
//  OneServiceViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/11.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "OneServiceViewController.h"
#import "OneServiceTableViewCell.h"
#import "CharacteristicViewController.h"

@interface OneServiceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSArray<CBService *> *services;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OneServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BLEControl sharedInstance] discoverService:_peripheral :^(BOOL isSucc, CBPeripheral *peripheral) {
        if (isSucc) {
        _services = _peripheral.services;
        [_tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _services.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _services[section].characteristics.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBService *service = [_services objectAtIndex:indexPath.section];
    CBCharacteristic *character = [service.characteristics objectAtIndex:indexPath.row];
    OneServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"oneServiceCell"];
    
    
    NSMutableString *desc = [[NSMutableString alloc] init];
    if ((character.properties & 1) == 1) {
        [desc insertString:@"_BROADCAST" atIndex:0];
    }
    if (((character.properties >> 1) & 1) == 1) {
        [desc insertString:@"_READ" atIndex:0];
    }
    if (((character.properties >> 2) & 1) == 1) {
        [desc insertString:@"_WRITE_NO_RESPONSE" atIndex:0];
    }
    if (((character.properties >> 3) & 1) == 1) {
        [desc insertString:@"_WRITE" atIndex:0];
    }
    if (((character.properties >> 4) & 1) == 1) {
        [desc insertString:@"_NOTIFY" atIndex:0];
    }
    if (((character.properties >> 5) & 1) == 1) {
        [desc insertString:@"_INDICATE" atIndex:0];
    }
    if (((character.properties >> 6) & 1) == 1) {
        [desc insertString:@"_SIGNED_WRITE" atIndex:0];
    }
    if (((character.properties >> 7) & 1) == 1) {
        [desc insertString:@"_EXTENDED_PROPS" atIndex:0];
    }
    
    cell.uuid.text = [NSString stringWithFormat:@"%@ ( %@ )",character.UUID.UUIDString, desc ];
    cell.chatactName.text = [NSString stringWithFormat:@"%@",character.UUID ];
    
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CBService *service = [_services objectAtIndex:section];
    return [NSString stringWithFormat:@"Service: %@",service.UUID.UUIDString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    CBService *service = [_services objectAtIndex:indexPath.section];
    CBCharacteristic *character = [service.characteristics objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"gotoCharacteristic" sender:character];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoCharacteristic"]) {
        CharacteristicViewController *ctr = segue.destinationViewController;
        ctr.peripheral = _peripheral;
        ctr.characteristic = sender;        
    }
   
}

@end
