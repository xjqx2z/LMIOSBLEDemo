//
//  MoreViewController.m
//  蓝牙测试程序
//
//  Created by jmg-mac 0sx on 16/5/12.
//  Copyright © 2016年 liming. All rights reserved.
//

#import "MoreViewController.h"
#import "GroundViewController.h"

@interface MoreViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PlistManager sharedInstance].groundArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *ground = [[PlistManager sharedInstance].groundArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groundCell"];
    
    cell.textLabel.text = [ground objectForKey:KEY_GROUND_NAME];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSDictionary *ground = [[PlistManager sharedInstance].groundArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"gotoGroundControl" sender:ground];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoGroundControl"]) {
        GroundViewController *ctr = segue.destinationViewController;
        ctr.group = sender;
        
    }
}

@end
