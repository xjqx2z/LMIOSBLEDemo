//
//  BLEControl.h
//  Lockits
//
//  Created by 李明 on 16/2/16.
//  Copyright © 2016年 李明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^ManagerState)(CBCentralManager* central);
typedef void (^PeripheraState)(CBPeripheral* central);
typedef void (^SearchPeripheral)(CBPeripheral* peripheral);
typedef void (^ConnectPeripheral)(BOOL isConn);
typedef void (^DiscoverService)(BOOL isSucc, CBPeripheral* peripheral);
typedef void (^WriteToPeripheral)(CBService* service);
typedef void (^NotifyPeripheral)(CBService* service);
typedef void (^ResponseFromPeripheral)(CBCharacteristic *characteristic);
typedef void (^ValuesChange)(CBPeripheral* peripheral, CBCharacteristic *characteristic, BOOL isWrite);
typedef void (^NotifyStateChange)(BOOL isNotify, CBPeripheral *peripheral);

@interface BLEControl : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic, strong) NSMutableArray<CBPeripheral*> *devicesArray;
@property(nonatomic, strong) NSMutableArray<CBPeripheral*> *peripheraArray;
@property(nonatomic, strong) NSString *peripheraUUID;
@property(nonatomic, strong) CBUUID *serviceUUID;
@property(nonatomic, strong) CBUUID *characteristicUUID;
@property(nonatomic, strong) NSData *message;
@property(nonatomic,strong) CBPeripheral *currentPer;

@property (nonatomic, copy) ManagerState controlStateBlock;
@property (nonatomic, copy) PeripheraState PeripheralStateBlock;
@property (nonatomic, copy) SearchPeripheral searchPeripheralBlock;
@property (nonatomic, copy) ConnectPeripheral connPeripheralBlock;
@property (nonatomic, copy) DiscoverService discoverServiceBlock;
@property (nonatomic, copy) WriteToPeripheral writePeripheralBlock;
@property (nonatomic, copy) NotifyPeripheral notifyPeripheralBlock;
@property (nonatomic, copy) ResponseFromPeripheral responseFromPeripheralBlock;
@property (nonatomic, copy) ValuesChange valuesChangeBlock;
@property (nonatomic, copy) NotifyStateChange notifyBlock;
@property(nonatomic, assign)CBCentralManagerState BLEstate;

+ (BLEControl *)sharedInstance;

- (void) scanDevices:(SearchPeripheral)searchPeripheralBlock;
- (void) scanDevicesRepeat;
- (void) stopScan;
- (void) connect:(CBPeripheral*) peripheral :(ConnectPeripheral)connBolck;
- (void) exitBluetooth;
- (void) discoverService:(CBPeripheral*) peripheral :(DiscoverService)discoverServiceBlock;
- (void) disConnect:(NSString*) uuid;
- (void)cancelPeripheralConn:(CBPeripheral *)peripheral;
- (void) writoToPeripheral:(CBPeripheral*)peripheral serviceUUID:(CBUUID*)suuid :(WriteToPeripheral)writeBolck;
- (void) readToPeripheral:(CBPeripheral*)peripheral serviceUUID:(CBUUID*)suuid :(NotifyPeripheral)readBolck;
- (void) writeToAll:(NSData *)data withSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid;
- (void) readToAllWithSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid;
- (void) notifyToAll:(BOOL)notify withSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid;
- (void) setNotifyStateChanged:(NotifyStateChange)notifyBlock andValueStateChanged:(ValuesChange)valuesBloack;
- (CBPeripheral*) getPeripheral:(NSString*)uuid;

@end
