//
//  BLEControl.m
//  Lockits
//
//  Created by 李明 on 16/2/16.
//  Copyright © 2016年 李明. All rights reserved.
//

#import "BLEControl.h"
#import "NSData+Hex.h"

@implementation BLEControl
{
    CBCentralManager *manager;
}
+ (BLEControl *)sharedInstance
{
    static BLEControl *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _devicesArray = [[NSMutableArray alloc] init];
        _peripheraArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma 搜索蓝牙单次
-(void)scanDevices:(SearchPeripheral)searchPeripheralBlock
{
    _searchPeripheralBlock = searchPeripheralBlock;
    [_devicesArray removeAllObjects];
    if (manager) {
        [manager stopScan];
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma 不停搜索蓝牙
- (void) scanDevicesRepeat
{
    [_devicesArray removeAllObjects];
    if (manager) {
        [manager stopScan];
        [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFF0"]]  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
}

#pragma 停止扫描
- (void) stopScan
{
    if(manager){
        [manager stopScan];
    }
}

#pragma 连接设备
- (void) connect:(CBPeripheral*) peripheral :(ConnectPeripheral)connBolck
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 原代码块二
        while (_connPeripheralBlock) {
            [NSThread sleepForTimeInterval:0.2];
            NSLog(@"阻塞,前一个连接操作没有完成");
        }
       NSLog(@"阻塞完毕");
        _connPeripheralBlock = connBolck;
            // 原代码块三
            dispatch_async(dispatch_get_main_queue(), ^{
                if(manager)
                {
                    NSLog(@"开始连接");
                    if (peripheral.state == CBPeripheralStateConnected) {
                        _connPeripheralBlock(YES);
                        _connPeripheralBlock = nil;
                        return;
                    }
                    [manager connectPeripheral:peripheral
                                       options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                                                 CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                                                 CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
                }
            });
       
    });
}

- (void) discoverService:(CBPeripheral*) peripheral :(DiscoverService)discoverServiceBlock {
    _discoverServiceBlock = discoverServiceBlock;
    [peripheral discoverServices:nil];
}


#pragma 断开连接设备
- (void) disConnect:(NSString*) uuid
{
    if(manager)
    {
        
        for (CBPeripheral *p in _peripheraArray) {
            if([p.identifier.UUIDString isEqualToString:uuid])
            {
                [manager cancelPeripheralConnection:p];
            }
        }
    }
}

#pragma 断开已连接设备
- (void) exitBluetooth {
    for (CBPeripheral *p in _peripheraArray) {
        [self cancelPeripheralConn:p];
    }
}

-(void)cancelPeripheralConn:(CBPeripheral *)peripheral{
    if (manager)
    {
        [manager cancelPeripheralConnection:peripheral];
    }
}

#pragma 向服务中写数据
- (void) writoToPeripheral:(CBPeripheral*)peripheral serviceUUID:(CBUUID*)suuid :(WriteToPeripheral)writeBolck
{
    @synchronized(_serviceUUID) {
        _writePeripheralBlock = writeBolck;
        _serviceUUID = suuid;
        [peripheral discoverServices:@[_serviceUUID]];
    }
}


#pragma 读数据
- (void) readToPeripheral:(CBPeripheral*)peripheral serviceUUID:(CBUUID*)suuid :(NotifyPeripheral)readBolck
{
    @synchronized(_serviceUUID) {
        _notifyPeripheralBlock = readBolck;
        _serviceUUID = suuid;
        [peripheral discoverServices:@[_serviceUUID]];
    }
    
}


#pragma 向所有已连接设备写数据
- (void) writeToAll:(NSData *)data withSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid
{
    for (CBPeripheral *peripheral in _peripheraArray)
    {
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceuuid]])
            {
                for (CBCharacteristic *ct in service.characteristics)
                {
                    if ([ct.UUID isEqual:[CBUUID UUIDWithString:characuuid]])
                    {
                        if (((ct.properties >> 2) & 1) == 1) {
                            NSLog(@"写入数据");
                            [peripheral writeValue:data forCharacteristic:ct type:CBCharacteristicWriteWithoutResponse];
                        }
                        if (((ct.properties >> 3) & 1) == 1) {
                            [peripheral writeValue:data forCharacteristic:ct type:CBCharacteristicWriteWithResponse];
                        }
                    }
                }
            }
        }
    }
}

#pragma 读已连接设备数据
- (void) readToAllWithSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid
{
    for (CBPeripheral *peripheral in _peripheraArray)
    {
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceuuid]])
            {
                for (CBCharacteristic *ct in service.characteristics)
                {
                    if ([ct.UUID isEqual:[CBUUID UUIDWithString:characuuid]])
                    {
                        [peripheral readValueForCharacteristic:ct];
                    }
                }
            }
        }
    }
}

#pragma 订阅所有已连接
- (void) notifyToAll:(BOOL)notify withSerive:(NSString *)serviceuuid withCharacuuid:(NSString *)characuuid
{
    for (CBPeripheral *peripheral in _peripheraArray)
    {
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceuuid]])
            {
                for (CBCharacteristic *ct in service.characteristics)
                {
                    if ([ct.UUID isEqual:[CBUUID UUIDWithString:characuuid]])
                    {
                        [peripheral setNotifyValue:notify forCharacteristic:ct];
                    }
                }
            }
        }
    }
}

- (void) setNotifyStateChanged:(NotifyStateChange)notifyBlock andValueStateChanged:(ValuesChange)valuesBloack {
    _notifyBlock = notifyBlock;
    _valuesChangeBlock = valuesBloack;
}

- (CBPeripheral*) getPeripheral:(NSString*)uuid
{
    for (CBPeripheral *peripheral in _peripheraArray) {
        if([uuid isEqualToString:peripheral.identifier.UUIDString]){
            return peripheral;
        }
    }
    
    return nil;
}

// 蓝牙是否开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    _BLEstate = central.state;
}

//查到外设
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if([_devicesArray containsObject:peripheral] == NO)
    {
        [_devicesArray addObject:peripheral];
       
        if(_searchPeripheralBlock)
        {
            _searchPeripheralBlock(peripheral);
        }
    }
}

//连接设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //NSLog(@"连接成功");
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    if (![_peripheraArray containsObject:peripheral])
    {
        [_peripheraArray addObject:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //NSLog(@"蓝牙连接失败");
    if(_connPeripheralBlock)
    {
        _connPeripheralBlock(NO);
        _connPeripheralBlock = nil;
    }
}

//蓝牙断开
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral
{
    NSLog(@"cancelPeripheralConnection");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSInteger index = [_peripheraArray indexOfObject:peripheral];
    [_peripheraArray removeObjectAtIndex:index];
    
    if (_PeripheralStateBlock) {
        _PeripheralStateBlock(peripheral);
    }
    
}

//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
//     NSLog(@"发现服务");
    if (error)
    {
        if (_discoverServiceBlock) {
            _discoverServiceBlock(NO, peripheral);
        }
        return;
    }
    
    if (_discoverServiceBlock) {
        _discoverServiceBlock(YES, peripheral);
    }
    
    
    for (CBService *service in peripheral.services)
    {
        
        if(_connPeripheralBlock)
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
        if ([service.UUID isEqual:_serviceUUID])
        {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
        
    }
    
}


//发现特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        //NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        
        return;
    }
    
    if(_connPeripheralBlock)
    {
        _connPeripheralBlock(YES);
        _connPeripheralBlock = nil;
    }
    
    if (_writePeripheralBlock)
    {
        _writePeripheralBlock(service);
    }
    
    if (_notifyPeripheralBlock) {
        _notifyPeripheralBlock(service);
        _notifyPeripheralBlock = nil;
    }
    
}

//订阅回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {

    if (_notifyBlock) {
        _notifyBlock(characteristic.isNotifying, peripheral);
    }
}


//特征值写
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"发送数据了");
    if (_valuesChangeBlock) {
        _valuesChangeBlock(peripheral, characteristic, YES);
    }
    if(error){
        NSLog(@"发送数据错误回调%@",[error domain]);
        return;
        
    }
    
}

//特征值读
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"收到数据了%@", [characteristic.value hexadecimalString]);
    //    Byte *testByte = (Byte *)[characteristic.value bytes];
    
    if (_responseFromPeripheralBlock) {
        _responseFromPeripheralBlock(characteristic);
    }
    if (_valuesChangeBlock) {
        _valuesChangeBlock(peripheral, characteristic, NO);
    }
    
    
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        
        return;
    }
    
    
}

@end
