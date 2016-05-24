//
//  PlistDBControl.h
//  Lockits
//
//  Created by 李明 on 16/2/18.
//  Copyright © 2016年 李明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PlistManager : NSObject

@property(nonatomic, strong) NSMutableArray *groundArray;

+ (PlistManager *)sharedInstance;
- (void)addGround:(NSString *)groundName :(NSString *)uuids;
- (NSMutableDictionary*)getLockit:(CBPeripheral *)peripheral;

@end
