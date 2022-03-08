//
//  SqliteObjc.m
//  MGZB_DEMO_2
//
//  Created by caosq on 14-8-18.
//  Copyright (c) 2014年 qmqj. All rights reserved.
//

#import "MGUserDefault.h"
#import "sqlite3.h"

@interface MGUserDefault()
{
    sqlite3 *m_sql;
    NSString *m_dbName;
    dispatch_queue_t _queue;
}

@property(nonatomic)sqlite3*            m_sql;
@property(nonatomic,retain)NSString*    m_dbName;

-(id)initWithDbName:(NSString*)dbname;

-(BOOL)openOrCreateDatabase:(NSString*)DbName;
-(void)closeDatabase;

-(BOOL)createTable:(NSString*)sqlCreateTable;
- (BOOL) InsertSql:(NSString *) key binaryData:(NSData *) data;
-(BOOL)DeleteSql:(NSString*)sql;

- (BOOL) queryTableWitKey:(NSString *) defaultName resultBlock:(void(^)(NSData *data))result;


@end


@implementation MGUserDefault
@synthesize m_sql;
@synthesize m_dbName;


static int specificKey;

- (id) initWithDbName:(NSString*)dbname
{
    self = [super init];
    if (self != nil) {
        _queue = dispatch_queue_create("com.tm.qmqj.dbqueue", NULL);
        CFStringRef specificValue = CFSTR("com.tm.qmqj.db.queue");
        dispatch_queue_set_specific(_queue,
                                    &specificKey,
                                    (void*)specificValue,
                                    (dispatch_function_t)CFRelease);
        
        if ([self openOrCreateDatabase:dbname]) {
            [self closeDatabase];
        }
        
    }
    return self;
}
- (id) init
{
    NSAssert(0,@"Never Use this.Please Call Use initWithDbName:(NSString*)");
    return nil;
}

- (void) dealloc
{
    self.m_sql = nil;
    self.m_dbName =nil;
}

- (void) synConvenience:(dispatch_block_t) block
{
    CFStringRef retrievedValue = dispatch_get_specific(&specificKey);
    if (retrievedValue) {
        block();
    }else{
        dispatch_sync(_queue, block);
    }
}

//-------------------创建数据库-------------------------

-(BOOL)openOrCreateDatabase:(NSString*)dbName
{
        BOOL bOK = NO;
        self.m_dbName = dbName;
        NSArray *path =NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
        NSString *documentsDirectory = [path objectAtIndex:0];
        if(sqlite3_open([[documentsDirectory stringByAppendingPathComponent:dbName]UTF8String],&m_sql) != SQLITE_OK)
        {
            NSLog(@"创建数据库失败");
            bOK =  NO;
        }else
            bOK = YES;
    
        return bOK;
}

//------------------创建表----------------------
-(BOOL)createTable:(NSString*)sqlCreateTable
{
    __block BOOL bOK = NO;
    
    dispatch_block_t block = ^{
        if ([self openOrCreateDatabase:self.m_dbName]) {
            char *errorMsg;
            if (sqlite3_exec (self.m_sql, [sqlCreateTable UTF8String],NULL,NULL, &errorMsg) != SQLITE_OK)
            {
                NSLog(@"创建数据表失败:%s",errorMsg);
                bOK = NO;
            }else
                bOK = YES;
        }
        [self closeDatabase];
    };
    [self synConvenience:block];
    return bOK;
    
}
//----------------------关闭数据库-----------------
-(void)closeDatabase
{
    sqlite3_close(self.m_sql);
}

//------------------insert-------------------

- (BOOL) InsertSql:(NSString *) key binaryData:(NSData *) data
{
    __block BOOL bOk = NO;
    
    dispatch_block_t block = ^{
        
        if ([self openOrCreateDatabase:self.m_dbName]) {
            sqlite3_stmt *start;
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO MG_db(MG_key,MG_value) VALUES(\'%@\', ?)", key];
            sqlite3_prepare(self.m_sql, [sql UTF8String], -1, &start, 0);
            sqlite3_bind_blob(start, 1, [data bytes], (int)[data length], NULL);
            int result = sqlite3_step(start);
            if (result == SQLITE_DONE) {
                bOk = YES;
            }
            sqlite3_finalize(start);
        }
        [self closeDatabase];
    };
    [self synConvenience:block];
    
    return bOk;
}


-(BOOL)DeleteSql:(NSString*)sql
{
    __block BOOL bOk = NO;
    dispatch_block_t block = ^{
        
        if ([self openOrCreateDatabase:self.m_dbName]) {
            char* errorMsg = NULL;
            bOk = sqlite3_exec(self.m_sql, [sql UTF8String], 0, NULL, &errorMsg) == SQLITE_OK;
            if (!bOk && errorMsg != NULL) {
                NSLog(@"qmqj execute sql error : %s", errorMsg);
            }
        }
        [self closeDatabase];
    };
    [self synConvenience:block];
    return bOk;
}

- (BOOL) queryTableWitKey:(NSString *) defaultName resultBlock:(void(^)(NSData *data))result
{
    __block BOOL bOk = NO;
    __block NSMutableData *MData = [NSMutableData new];
    dispatch_block_t block = ^{
      
        bOk = [self openOrCreateDatabase:self.m_dbName];
        if (bOk) {
            NSString *sql = [NSString stringWithFormat:@"select MG_value from MG_db where MG_key=\'%@\'", defaultName];
            sqlite3_stmt *start;
            bOk = sqlite3_prepare(self.m_sql, [sql UTF8String], -1, &start, NULL) == SQLITE_OK;
            if (bOk) {
                
                while (sqlite3_step(start) ==  SQLITE_ROW) {
                    
                    int bytes = sqlite3_column_bytes(start, 0);
                    const void *value = sqlite3_column_blob(start, 0);
                    if (value != NULL && bytes != 0) {
                        [MData appendBytes:value length:bytes];
                    }
                }
            }
            sqlite3_finalize(start);
        }
        [self closeDatabase];
    };
    
    [self synConvenience:block];
    
    if (bOk && result) {
        result(MData);
    }
    return bOk;
}


@end



@implementation MGUserDefault(Convenience)

+ (MGUserDefault *) defaultUserDefaults
{
    static MGUserDefault *_MGUserDefault = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MGUserDefault = [[MGUserDefault alloc] initWithDbName:@"MG_sdk_db.sql"];
        NSString *sql = @"create table if not exists MG_db(MG_key text primary key, MG_value blob)";
        [_MGUserDefault createTable:sql];
    });
    return _MGUserDefault;
}


#pragma mark-- objectforkey

- (BOOL) boolValueForKey:(NSString *) defaultName
{
    id obj = [self objectForKey:defaultName];
    if ([obj isKindOfClass:[NSData class]]) {
        NSData *value = (NSData *) obj;
        NSInteger bReturn = NO;
        [value getBytes:&bReturn length:sizeof(bReturn)];
        return bReturn;
    }else if ([obj isKindOfClass:[NSNumber class]]){
        return [obj boolValue];
    }else
        return NO;
}

- (NSInteger) intValueForKey:(NSString *) defaultName
{
    id obj  = [self objectForKey:defaultName];
    if ([obj isKindOfClass:[NSData class]]) {
        NSData *value = (NSData *) obj;
        NSInteger bReturn = NSNotFound;
        [value getBytes:&bReturn length:sizeof(bReturn)];
        return bReturn;
    }else
        return NSNotFound;
}

- (NSString *) stringValueForKey:(NSString *)defaultName
{
    id obj = [self objectForKey:defaultName];
    if ([obj isKindOfClass:[NSData class]]) {
        NSData *value = (NSData *) obj;
        NSString *str = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        return str;
    }else if([obj isKindOfClass:[NSString class]]){
        return obj;
    }else
        return nil;
}

- (id) objectForKey:(NSString *)defaultName
{
    __block NSData *rData = nil;
    
    BOOL bSuccess = [self queryTableWitKey:defaultName  resultBlock:^(NSData *data) {
        rData = data;
    }];
    
    if (bSuccess) {   // 无错误 从sqlite中获取数据
        
        if ([rData length] == 0) {  //可能存在userdefault中
            MG_LOG(@"qmqj MGuserdefault rData = nil");
            id obj = [self objectForKeyX:defaultName];
            if (obj != nil) {
                return obj;
            }else
                return nil;
        }else
            return rData;
        
    }else{  // 有错误， 从nsuserdefault中获取数据
        NSLog(@"qmqj objectforkey sql error defaultName：%@ 失败", defaultName);
        return [self objectForKeyX:defaultName];
    }
}


- (id) objectForKeyX:(NSString *)defaultName
{
    MG_LOG(@"qmqj defaultName:%@ from nsuserdefault", defaultName);
   return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
}


#pragma mark-- setobj

- (void) insertData:(NSData *) data forKey:(NSString *) key
{
    BOOL bOk = [self InsertSql:key binaryData:data];
    if (bOk) {
        [self setObjectX:data forKey:key];
    }
}

- (void) setBoolValue:(BOOL)aBoolValue forKey:(NSString *) defaultName
{
    NSData *data = [NSData dataWithBytes:&aBoolValue length:sizeof(aBoolValue)];
    [self insertData:data forKey:defaultName];
}

- (void) setIntVaule:(NSInteger)aIntValue forKey:(NSString *) defaultName
{
    NSData *data = [NSData dataWithBytes:&aIntValue length:sizeof(aIntValue)];
    [self insertData:data forKey:defaultName];
    
}


- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    BOOL bAnotherType = NO;
    NSData *data;
    if ([value isKindOfClass:[NSString class]]) {
        data = [value dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([value isKindOfClass:[NSData class]]){
        data = value;
    }else{        
        bAnotherType = YES;   // sqlite中做data string int bool类型存储 其他类型存到nsuserdefault中
    }
    
    if (bAnotherType) {
        [self setObjectX:value forKey:defaultName];
    }else
        [self insertData:data forKey:defaultName];
}


// nsuserdefault 保存一份
- (void) setObjectX:(id)value forKey:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark-- remove

- (void)removeObjectForKey:(NSString *)defaultName
{
    NSString *sql = [NSString stringWithFormat:@"delete from MG_db where MG_key=\'%@\'", defaultName];
    BOOL bOK = [self DeleteSql:sql];
    if (bOK) {  //  若sqlite执行失败，userdefault也不执行，避免数据不一致，错也要错一致
        [self removeObjectForKeyX:defaultName];
    }
}

- (void) removeObjectForKeyX:(NSString *)defaultName
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end

