//
//  PlistDBControl.m
//  Lockits
//
//  Created by 李明 on 16/2/18.
//  Copyright © 2016年 李明. All rights reserved.
//

#import "PlistManager.h"

@implementation PlistManager
{
    NSString *plistPath;
}

+ (PlistManager *)sharedInstance
{
    static PlistManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        [sharedAccountManagerInstance initData];
    });
    return sharedAccountManagerInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void) initData
{
    //获取本地沙盒路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取完整路径
    NSString *documentsPath = [path objectAtIndex:0];
    plistPath = [documentsPath stringByAppendingPathComponent:@"ground.plist"];
    _groundArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    if(!_groundArray){
        _groundArray = [[NSMutableArray alloc] init];
    }
}

//保存分组
- (void)addGround:(NSString *)groundName :(NSString *)uuids {
    NSMutableDictionary *ground = [[NSMutableDictionary alloc] init];
    [ground setObject:groundName forKey:KEY_GROUND_NAME];
    [ground setObject:uuids forKey:KEY_GROUND_UUIDS];
    [_groundArray addObject:ground];
    [_groundArray writeToFile:plistPath atomically:YES];
}


//获取组
- (NSMutableDictionary*)getLockit:(NSString *)groundName
{
    for (int i = 0; i < _groundArray.count; i++) {
        NSMutableDictionary *ground = [_groundArray objectAtIndex:i];
        if ([groundName isEqualToString:[ground objectForKey:KEY_GROUND_NAME]]) {
            return ground;
        }
    }
    return nil;
}

//删除组
- (void)deleteGround:(NSString *)groundName {
    
    for (int i = 0; i < _groundArray.count; i++) {
        NSMutableDictionary *ground = [_groundArray objectAtIndex:i];
        if ([groundName isEqualToString:[ground objectForKey:KEY_GROUND_NAME]]) {
            [_groundArray removeObject:ground];
        }
    }
    [_groundArray writeToFile:plistPath atomically:YES];
}







@end
