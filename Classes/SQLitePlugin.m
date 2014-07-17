/*
 * Copyright (C) 2011-2013 Chris Brody
 * Copyright (C) 2011 Davide Bertola
 *
 * This library is available under the terms of the MIT License (2008).
 * See http://opensource.org/licenses/alphabetical for full text.
 */

#import "SQLitePlugin.h"
#include <regex.h>


//LIBB64
typedef enum
{
	step_A, step_B, step_C
} base64_encodestep;

typedef struct
{
	base64_encodestep step;
	char result;
	int stepcount;
} base64_encodestate;

static void base64_init_encodestate(base64_encodestate* state_in)
{
	state_in->step = step_A;
	state_in->result = 0;
	state_in->stepcount = 0;
}

static char base64_encode_value(char value_in)
{
	static const char* encoding = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	if (value_in > 63) return '=';
	return encoding[(int)value_in];
}

static int base64_encode_block(const char* plaintext_in,
                               int length_in,
                               char* code_out,
                               base64_encodestate* state_in,
                               int line_length)
{
	const char* plainchar = plaintext_in;
	const char* const plaintextend = plaintext_in + length_in;
	char* codechar = code_out;
	char result;
	char fragment;
    
	result = state_in->result;
    
	switch (state_in->step)
	{
            while (1)
            {
            case step_A:
                if (plainchar == plaintextend)
                {
                    state_in->result = result;
                    state_in->step = step_A;
                    return codechar - code_out;
                }
                fragment = *plainchar++;
                result = (fragment & 0x0fc) >> 2;
                *codechar++ = base64_encode_value(result);
                result = (fragment & 0x003) << 4;
            case step_B:
                if (plainchar == plaintextend)
                {
                    state_in->result = result;
                    state_in->step = step_B;
                    return codechar - code_out;
                }
                fragment = *plainchar++;
                result |= (fragment & 0x0f0) >> 4;
                *codechar++ = base64_encode_value(result);
                result = (fragment & 0x00f) << 2;
            case step_C:
                if (plainchar == plaintextend)
                {
                    state_in->result = result;
                    state_in->step = step_C;
                    return codechar - code_out;
                }
                fragment = *plainchar++;
                result |= (fragment & 0x0c0) >> 6;
                *codechar++ = base64_encode_value(result);
                result  = (fragment & 0x03f) >> 0;
                *codechar++ = base64_encode_value(result);
                
                if(line_length > 0)
                {
                    ++(state_in->stepcount);
                    if (state_in->stepcount == line_length/4)
                    {
                        *codechar++ = '\n';
                        state_in->stepcount = 0;
                    }
                }
            }
	}
	/* control should not reach here */
	return codechar - code_out;
}

static int base64_encode_blockend(char* code_out,
                                  base64_encodestate* state_in)
{
	char* codechar = code_out;
    
	switch (state_in->step)
	{
        case step_B:
            *codechar++ = base64_encode_value(state_in->result);
            *codechar++ = '=';
            *codechar++ = '=';
            break;
        case step_C:
            *codechar++ = base64_encode_value(state_in->result);
            *codechar++ = '=';
            break;
        case step_A:
            break;
	}
	*codechar++ = '\n';
    
	return codechar - code_out;
}

//LIBB64---END

static void sqlite_regexp(sqlite3_context* context, int argc, sqlite3_value** values) {
    int ret;
    regex_t regex;
    char* reg = (char*)sqlite3_value_text(values[0]);
    char* text = (char*)sqlite3_value_text(values[1]);
    
    if ( argc != 2 || reg == 0 || text == 0) {
        sqlite3_result_error(context, "SQL function regexp() called with invalid arguments.\n", -1);
        return;
    }
    
    ret = regcomp(&regex, reg, REG_EXTENDED | REG_NOSUB);
    if ( ret != 0 ) {
        sqlite3_result_error(context, "error compiling regular expression", -1);
        return;
    }
    
    ret = regexec(&regex, text , 0, NULL, 0);
    regfree(&regex);
    
    sqlite3_result_int(context, (ret != REG_NOMATCH));
}


@implementation SQLitePlugin

@synthesize openDBs;
@synthesize appDocsPath;

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    [self test:@"initWithWebView - start"];
    
    
    self = (SQLitePlugin*)[super initWithWebView:theWebView];
    if (self) {
        openDBs = [NSMutableDictionary dictionaryWithCapacity:0];
#if !__has_feature(objc_arc)
        [openDBs retain];
#endif
        
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        NSLog(@"Detected docs path: %@", docs);
        [self setAppDocsPath:docs];
    }
    
    [self test:@"initWithWebView - end"];
    
    return self;
}

-(id) getDBPath:(id)dbFile {
    [self test:@"getDBPath - start"];
    
    if (dbFile == NULL) {
        return NULL;
    }
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", appDocsPath, dbFile];
    
    [self test:@"getDBPath - end"];
    
    return dbPath;
}

-(void)open: (CDVInvokedUrlCommand*)command
{
    [self test:@"open - start"];
    
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    NSString *dbname = [self getDBPath:[options objectForKey:@"name"]];
    NSValue *dbPointer;
    
    [self test:@"open - 1"];
    
    if (dbname == NULL) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"You must specify database name"];
        [self test:@"open - 2"];
    }
    else {
        [self test:@"open - 3"];
        
        dbPointer = [openDBs objectForKey:dbname];
        
        [self test:@"open - 4"];
        if (dbPointer != NULL) {
            // NSLog(@"Reusing existing database connection");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Database opened"];
            [self test:@"open - 5"];
        }
        else {
            const char *name = [dbname UTF8String];
            // NSLog(@"using db name: %@", dbname);
            sqlite3 *db;
            
            [self test:@"open - 6"];
            
            if (sqlite3_open(name, &db) != SQLITE_OK) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to open DB"];
                [self test:@"open - 7"];
                return;
            }
            else {
                // Extra for SQLCipher:
                // const char *key = [@"your_key_here" UTF8String];
                // if(key != NULL) sqlite3_key(db, key, strlen(key));
                
                [self test:@"open - 8"];
                sqlite3_create_function(db, "regexp", 2, SQLITE_ANY, NULL, &sqlite_regexp, NULL, NULL);
                
                [self test:@"open - 9"];
                // Attempt to read the SQLite master table (test for SQLCipher version):
                if(sqlite3_exec(db, (const char*)"SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL) == SQLITE_OK) {
                    [self test:@"open - 10"];
                    dbPointer = [NSValue valueWithPointer:db];
                    [openDBs setObject: dbPointer forKey: dbname];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Database opened"];
                    int b;
                    @try {
                        //테이블이 없으면 테이블 생성.
                        int tableOK = sqlite3_exec(db, (const char*)"SELECT count(*) FROM user;", NULL, NULL, NULL);
                        if (tableOK == 1) {
                            int createOK = sqlite3_exec(db, (const char*)"CREATE TABLE user(userid text primary key, password text,tokenid text, currentuser integer);", NULL, NULL, NULL);
                            if (createOK == 0) {
                                NSLog(@"user 테이블 생성이 완료 되었습니다.");
                            } else {
                                NSLog(@"user 테이블 생성이 실패 되었습니다.");
                            }
                            b = sqlite3_exec(db, (const char*)"CREATE TABLE topic (userid TEXT, topic TEXT, subscribe INTEGER, PRIMARY KEY(userid, topic));", NULL, NULL, NULL);
                            if (createOK == 0) {
                                NSLog(@"topic 테이블 생성이 완료 되었습니다.");
                            } else {
                                NSLog(@"topic 테이블 생성이 실패 되었습니다.");
                            }
                            b = sqlite3_exec(db, (const char*)"CREATE TABLE message (id integer, userid text, ack integer,type integer, content text, receivedate text, category TEXT, read INTEGER, primary key (id, userid));", NULL, NULL, NULL);
                            if (createOK == 0) {
                                NSLog(@"message 테이블 생성이 완료 되었습니다.");
                            } else {
                                NSLog(@"message 테이블 생성이 실패 되었습니다.");
                            }
                            b = sqlite3_exec(db, (const char*)"CREATE TABLE job ( id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER, topic TEXT, content TEXT);", NULL, NULL, NULL);
                            if (createOK == 0) {
                                NSLog(@"job 테이블 생성이 완료 되었습니다.");
                            } else {
                                NSLog(@"job 테이블 생성이 실패 되었습니다.");
                            }
                            b = sqlite3_exec(db, (const char*)"CREATE TABLE apnstoken (tokenid text primary key);", NULL, NULL, NULL);
                            if (createOK == 0) {
                                NSLog(@"apnstoken 테이블 생성이 완료 되었습니다.");
                            } else {
                                NSLog(@"apnstoken 테이블 생성이 실패 되었습니다.");
                            }

                        }
                        
//                        b = sqlite3_exec(db, (const char*)"CREATE TABLE IF NOT EXISTS test_table (id integer primary key, data text, data_num integer);", NULL, NULL, NULL);
//                        c = sqlite3_exec(db, (const char*)"SELECT count(*) FROM test_table;", NULL, NULL, NULL);
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"DB  exceptionName %@, reason %@", [exception name], [exception reason]);
                    }
                    @finally {
                        
                    }
                    [self test:@"open - 11"];
                } else {
                    [self test:@"open - 12"];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to encrypt DB"];
                    [self test:@"open - 13"];
                }
            }
        }
    }
    
    [self test:@"open - 14"];
    
    if (sqlite3_threadsafe()) {
        NSLog(@"Good news: SQLite is thread safe!");
    }
    else {
        NSLog(@"Warning: SQLite is not thread safe.");
    }
    
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    
    [self test:@"open - 15"];
    
    // NSLog(@"open cb finished ok");
    
    [self test:@"open - end"];
    
}

-(void) close: (CDVInvokedUrlCommand*)command
{
    [self test:@"close - start"];
    
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    NSString *dbPath = [self getDBPath:[options objectForKey:@"path"]];
    if (dbPath == NULL) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"You must specify database path"];
    }
    else {
        NSValue *val = [openDBs objectForKey:dbPath];
        sqlite3 *db = [val pointerValue];
        if (db == NULL) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Specified db was not open"];
        }
        else {
            sqlite3_close (db);
            [openDBs removeObjectForKey:dbPath];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"DB closed"];
        }
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    
    [self test:@"close - end"];
    
}

-(void) delete: (CDVInvokedUrlCommand*)command
{
    [self test:@"delete - start"];
    
    CDVPluginResult* pluginResult = nil;
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    NSString *dbPath = [self getDBPath:[options objectForKey:@"path"]];
    if(dbPath==NULL) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"You must specify database path"];
    } else {
        if([[NSFileManager defaultManager]fileExistsAtPath:dbPath]) {
            [[NSFileManager defaultManager]removeItemAtPath:dbPath error:nil];
            [openDBs removeObjectForKey:dbPath];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"DB deleted"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The database does not exist on that path"];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [self test:@"delete - end"];
}


-(void) backgroundExecuteSqlBatch: (CDVInvokedUrlCommand*)command
{
    [self test:@"backgroundExecuteSqlBatch - start"];
    
    [self.commandDelegate runInBackground:^{
        [self executeSqlBatch: command];
    }];
    [self test:@"backgroundExecuteSqlBatch - end"];
}

-(void) executeSqlBatch: (CDVInvokedUrlCommand*)command
{
    [self test:@"executeSqlBatch - start"];
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *dbargs = [options objectForKey:@"dbargs"];
    NSMutableArray *executes = [options objectForKey:@"executes"];
    
    CDVPluginResult* pluginResult;
    
    @synchronized(self) {
        for (NSMutableDictionary *dict in executes) {
            CDVPluginResult *result = [self executeSqlWithDict:dict andArgs:dbargs];
            if ([result.status intValue] == CDVCommandStatus_ERROR) {
                /* add error with result.message: */
                NSMutableDictionary *r = [NSMutableDictionary dictionaryWithCapacity:0];
                [r setObject:[dict objectForKey:@"qid"] forKey:@"qid"];
                [r setObject:@"error" forKey:@"type"];
                [r setObject:result.message forKey:@"error"];
                [r setObject:result.message forKey:@"result"];
                [results addObject: r];
            } else {
                /* add result with result.message: */
                NSMutableDictionary *r = [NSMutableDictionary dictionaryWithCapacity:0];
                [r setObject:[dict objectForKey:@"qid"] forKey:@"qid"];
                [r setObject:@"success" forKey:@"type"];
                [r setObject:result.message forKey:@"result"];
                [results addObject: r];
            }
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:results];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [self test:@"executeSqlBatch - end"];
}

-(void) backgroundExecuteSql: (CDVInvokedUrlCommand*)command
{
    [self test:@"backgroundExecuteSql - start"];
    
    [self.commandDelegate runInBackground:^{
        [self executeSql:command];
    }];
    [self test:@"backgroundExecuteSql - end"];
}

-(void) executeSql: (CDVInvokedUrlCommand*)command
{
    [self test:@"executeSql - start"];
    
    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    NSMutableDictionary *dbargs = [options objectForKey:@"dbargs"];
    NSMutableDictionary *ex = [options objectForKey:@"ex"];
    
    CDVPluginResult* pluginResult;
    @synchronized (self) {
        pluginResult = [self executeSqlWithDict: ex andArgs: dbargs];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    [self test:@"executeSql - end"];
}

-(CDVPluginResult*) executeSqlWithDict: (NSMutableDictionary*)options andArgs: (NSMutableDictionary*)dbargs
{
    [self test:@"executeSqlWithDict - start"];
    
    NSString *dbPath = [self getDBPath:[dbargs objectForKey:@"dbname"]];
    
    NSMutableArray *query_parts = [options objectForKey:@"query"];
    NSString *query = [query_parts objectAtIndex:0];
    
    if (dbPath == NULL) {
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"You must specify database path"];
    }
    if (query == NULL) {
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"You must specify a query to execute"];
    }
    
    NSValue *dbPointer = [openDBs objectForKey:dbPath];
    if (dbPointer == NULL) {
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No such database, you must open it first"];
    }
    sqlite3 *db = [dbPointer pointerValue];
    
    const char *sql_stmt = [query UTF8String];
    NSDictionary *error = nil;
    sqlite3_stmt *statement;
    int result, i, column_type, count;
    int previousRowsAffected, nowRowsAffected, diffRowsAffected;
    long long previousInsertId, nowInsertId;
    BOOL keepGoing = YES;
    BOOL hasInsertId;
    NSMutableDictionary *resultSet = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *resultRows = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *entry;
    NSObject *columnValue;
    NSString *columnName;
    NSObject *insertId;
    NSObject *rowsAffected;
    
    hasInsertId = NO;
    previousRowsAffected = sqlite3_total_changes(db);
    previousInsertId = sqlite3_last_insert_rowid(db);
    
    if (sqlite3_prepare_v2(db, sql_stmt, -1, &statement, NULL) != SQLITE_OK) {
        error = [SQLitePlugin captureSQLiteErrorFromDb:db];
        keepGoing = NO;
    } else {
        for (int b = 1; b < query_parts.count; b++) {
            [self bindStatement:statement withArg:[query_parts objectAtIndex:b] atIndex:b];
        }
    }
    
    while (keepGoing) {
        result = sqlite3_step (statement);
        switch (result) {
                
            case SQLITE_ROW:
                i = 0;
                entry = [NSMutableDictionary dictionaryWithCapacity:0];
                count = sqlite3_column_count(statement);
                
                while (i < count) {
                    columnValue = nil;
                    columnName = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
                    
                    column_type = sqlite3_column_type(statement, i);
                    switch (column_type) {
                        case SQLITE_INTEGER:
                            columnValue = [NSNumber numberWithDouble: sqlite3_column_double(statement, i)];
                            break;
                        case SQLITE_TEXT:
                            columnValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                            break;
                        case SQLITE_BLOB:
                            //LIBB64
                            columnValue = [SQLitePlugin getBlobAsBase64String: sqlite3_column_blob(statement, i)
                                                                   withlength: sqlite3_column_bytes(statement, i) ];
                            //LIBB64---END
                            break;
                        case SQLITE_FLOAT:
                            columnValue = [NSNumber numberWithFloat: sqlite3_column_double(statement, i)];
                            break;
                        case SQLITE_NULL:
                            columnValue = [NSNull null];
                            break;
                    }
                    
                    if (columnValue) {
                        [entry setObject:columnValue forKey:columnName];
                    }
                    
                    i++;
                    
                }
                [resultRows addObject:entry];
                break;
                
            case SQLITE_DONE:
                nowRowsAffected = sqlite3_total_changes(db);
                diffRowsAffected = nowRowsAffected - previousRowsAffected;
                rowsAffected = [NSNumber numberWithInt:diffRowsAffected];
                nowInsertId = sqlite3_last_insert_rowid(db);
                if (previousInsertId != nowInsertId) {
                    hasInsertId = YES;
                    insertId = [NSNumber numberWithLongLong:sqlite3_last_insert_rowid(db)];
                }
                keepGoing = NO;
                break;
                
            default:
                error = [SQLitePlugin captureSQLiteErrorFromDb:db];
                keepGoing = NO;
        }
    }
    
    sqlite3_finalize (statement);
    
    if (error) {
        return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:error];
    }
    
    [resultSet setObject:resultRows forKey:@"rows"];
    [resultSet setObject:rowsAffected forKey:@"rowsAffected"];
    if (hasInsertId) {
        [resultSet setObject:insertId forKey:@"insertId"];
    }
    
    [self test:@"executeSqlWithDict - end"];
    
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultSet];
}

-(void)bindStatement:(sqlite3_stmt *)statement withArg:(NSObject *)arg atIndex:(NSUInteger)argIndex
{
    [self test:@"bindStatement - start"];
    if ([arg isEqual:[NSNull null]]) {
        sqlite3_bind_null(statement, argIndex);
    } else if ([arg isKindOfClass:[NSNumber class]]) {
        NSNumber *numberArg = (NSNumber *)arg;
        const char *numberType = [numberArg objCType];
        if (strcmp(numberType, @encode(int)) == 0) {
            sqlite3_bind_int(statement, argIndex, [numberArg integerValue]);
        } else if (strcmp(numberType, @encode(long long int)) == 0) {
            sqlite3_bind_int64(statement, argIndex, [numberArg longLongValue]);
        } else if (strcmp(numberType, @encode(double)) == 0) {
            sqlite3_bind_double(statement, argIndex, [numberArg doubleValue]);
        } else {
            sqlite3_bind_text(statement, argIndex, [[NSString stringWithFormat:@"%@", arg] UTF8String], -1, SQLITE_TRANSIENT);
        }
    } else {
        sqlite3_bind_text(statement, argIndex, [[NSString stringWithFormat:@"%@", arg] UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    [self test:@"bindStatement - end"];
}

-(void)dealloc
{
    [self test:@"dealloc - start"];
    
    int i;
    NSArray *keys = [openDBs allKeys];
    NSValue *pointer;
    NSString *key;
    sqlite3 *db;
    
    /* close db the user forgot */
    for (i=0; i<[keys count]; i++) {
        key = [keys objectAtIndex:i];
        pointer = [openDBs objectForKey:key];
        db = [pointer pointerValue];
        sqlite3_close (db);
    }
    
#if !__has_feature(objc_arc)
    [openDBs release];
    [appDocsPath release];
    [super dealloc];
#endif
    
    [self test:@"dealloc - end"];
}

+(NSDictionary *)captureSQLiteErrorFromDb:(sqlite3 *)db
{
    int code = sqlite3_errcode(db);
    int webSQLCode = [SQLitePlugin mapSQLiteErrorCode:code];
#if INCLUDE_SQLITE_ERROR_INFO
    int extendedCode = sqlite3_extended_errcode(db);
#endif
    const char *message = sqlite3_errmsg(db);
    
    NSMutableDictionary *error = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [error setObject:[NSNumber numberWithInt:webSQLCode] forKey:@"code"];
    [error setObject:[NSString stringWithUTF8String:message] forKey:@"message"];
    
#if INCLUDE_SQLITE_ERROR_INFO
    [error setObject:[NSNumber numberWithInt:code] forKey:@"sqliteCode"];
    [error setObject:[NSNumber numberWithInt:extendedCode] forKey:@"sqliteExtendedCode"];
    [error setObject:[NSString stringWithUTF8String:message] forKey:@"sqliteMessage"];
#endif
    
    return error;
}

+(int)mapSQLiteErrorCode:(int)code
{
    // map the sqlite error code to
    // the websql error code
    switch(code) {
        case SQLITE_ERROR:
            return SYNTAX_ERR;
        case SQLITE_FULL:
            return QUOTA_ERR;
        case SQLITE_CONSTRAINT:
            return CONSTRAINT_ERR;
        default:
            return UNKNOWN_ERR;
    }
}

+(id) getBlobAsBase64String:(const char*) blob_chars
                 withlength: (int) blob_length
{
    
    base64_encodestate b64state;
    
    base64_init_encodestate(&b64state);
    
    //2* ensures 3 bytes -> 4 Base64 characters + null for NSString init
    char* code = malloc (2*blob_length*sizeof(char));
    
    int codelength;
    int endlength;
    
    codelength = base64_encode_block(blob_chars,blob_length,code,&b64state,0);
    
    endlength = base64_encode_blockend(&code[codelength], &b64state);
    
    //Adding in a null in order to use initWithUTF8String, expecting null terminated char* string
    code[codelength+endlength] = '\0';
    
    NSString* result = [NSString stringWithUTF8String: code];
    
    free(code);
    
    return result;
}

- (void) test:(NSString *)msg
{
	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	
//	NSString *documentDirectory = [paths objectAtIndex:0];
//	NSString *myPath = [documentDirectory stringByAppendingPathComponent:@"PushDB"];
//    
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	
//	BOOL exist = [fileManager fileExistsAtPath:myPath];
//	
//    NSLog(@"========== : %@", msg);
//	if (exist) {
//		NSLog(@"=====####  DB가 존재합니다. : %@", msg);
//		return;
//	}
	

	
}



@end