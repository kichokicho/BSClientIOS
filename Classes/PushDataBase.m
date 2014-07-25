//
//  PushDataBase.m
//  ADFlowOfficeADFlowOfficeIphone
//
//  Created by gwangil on 2014. 6. 15..
//
//

#import "PushDataBase.h"

@implementation PushDataBase



- (void)dataBaseConnection:(sqlite3 **)tempDataBase
{
    // Document 폴더 위치를 구합니다.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    // 데이터베이스 파일경로를 구합니다.
	NSString *myPath = [documentDirectory stringByAppendingPathComponent:@"PushDB"];
    
	
    //데이터 베이스 연결
	if (sqlite3_open([myPath UTF8String], tempDataBase) != SQLITE_OK) {
		*tempDataBase = nil;
		return;
	}
	
}

- (void) insertMessage:(MessageBean *)dMsg
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    @try {
        
        NSLog(@"======  Message instert - Start ");
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO message(id, userid, ack, type, content, receivedate, category, read) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
        }
        
        NSLog(@"======  Message instert - Start ");
        
        
        // 조건을 바인딩합니다.
        sqlite3_bind_int(statement, 1, dMsg.id);
        sqlite3_bind_text(statement, 2, [dMsg.userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, dMsg.ack);
        sqlite3_bind_int(statement, 4, dMsg.type);
        sqlite3_bind_text(statement, 5, [dMsg.content UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [dMsg.receivedate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [dMsg.category UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 8, dMsg.read);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
}



- (void) getMessageList
{
    NSLog(@"======  getMessageList - Start ");
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    MessageBean *pMsg = [[MessageBean alloc]init];
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        // 검색 SQL
        const char *sql = "SELECT id, userid, ack, type, content, receivedate, category, read FROM message ORDER BY receivedate";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            pDataBase = nil;
            return;
            
        }
        
       
		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
            [pMsg setId:sqlite3_column_int(statement,0)];
			[pMsg setUserid:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]]];
            [pMsg setAck:sqlite3_column_int(statement,2)];
            [pMsg setType:sqlite3_column_int(statement,3)];
            [pMsg setContent:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]]];
            [pMsg setReceivedate:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]]];
            [pMsg setCategory:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)]]];
            [pMsg setRead:sqlite3_column_int(statement,7)];
            
            
            
            NSLog(@"Message(getMessageList) : %d, %@, %d, %d, %@, %@, %@, %d", pMsg.id, pMsg.userid,pMsg.ack,pMsg.type,pMsg.content,pMsg.receivedate, pMsg.category, pMsg.read);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
	
    
}

- (void) insertAPNSToken:(NSString *)apnsToken //APNS Token reg.
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    
    @try {
        NSLog(@"======  instert apnsToken - Start : %@", apnsToken);
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO apnstoken(tokenid) VALUES(?)";
        
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [apnsToken UTF8String], -1, SQLITE_TRANSIENT);  // Message
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
    
}
- (NSString *) getAPNSToken //APNS Token reg.
{
    NSLog(@"======  getAPNSToken - Start ");
    
	NSString *apnsToken = nil;      // Message  ID
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT tokenid FROM apnstoken";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return NULL;
            
        }
 		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
			apnsToken =  [[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
            // APNS Token
            
            NSLog(@"apnsToken : %@ ", apnsToken);
        }
        return apnsToken;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
}

- (void) allDeleteMessage //Push message All delete.
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    
    @try {
        NSLog(@"======  Push message All delete - Start ");
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM job";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
    
}



/// User Insert
- (void) insertUser:(UserBean *)user
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    @try {
        NSLog(@"======  User instert - Start");
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO user(userid, password, tokenid, currentuser) VALUES(?, ?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [user.userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [user.password UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [user.tokenid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, user.currentuser);

        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
}


// User Select
- (UserBean *) getUser
{
    NSLog(@"======  getUserList - Start ");
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    UserBean *user = [[UserBean alloc]init];
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT userid, password, tokenid, currentuser FROM user WHERE currentuser = 1";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            pDataBase = nil;
            return NULL;
            
        }
        
        
		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
			[user setUserid:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]]];
            [user setPassword:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]]];
            [user setTokenid:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]]];
            [user setCurrentuser:sqlite3_column_int(statement,3)];
            NSLog(@"Message : %@, %@, %@, %d", user.userid,user.password,user.tokenid,user.currentuser);
        }
        
        return user;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
	
    
}

/// Topic Insert
- (int) insertTopic:(TopicBean *)topic
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    @try {
        NSLog(@"======  Topic instert - Start");
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return 1000;
        }
        
        const char *sql = "INSERT INTO topic(userid, topic, subscribe) VALUES(?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return 1000;
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [topic.userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [topic.topic UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, topic.subscribe);
        
        
        
        //쿼리를 실행한다.
        int resultCode = sqlite3_step(statement);
        NSLog(@"resultCode : '%d'", resultCode);
        
        if( resultCode != SQLITE_DONE) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            
            return resultCode;
        }
        
        return resultCode;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
        return 1000;
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
}


// Topic Select
- (NSArray *) getTopicList:(NSString *)userid;
{
    NSLog(@"======  getTopicList - Start ");
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    NSMutableArray *topicList = [NSMutableArray array];
    
    
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT userid, topic, subscribe FROM topic WHERE userid=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            pDataBase = nil;
            return NULL;
            
        }
        sqlite3_bind_text(statement, 1, [userid UTF8String], -1, SQLITE_TRANSIENT);
        
		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
            TopicBean *topic = [[TopicBean alloc]init];
			[topic setUserid:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]]];
            [topic setTopic:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]]];
            [topic setSubscribe:sqlite3_column_int(statement,2)];
            
            [topicList addObject:topic];
            NSLog(@"Message : %@, %@, %d", topic.userid,topic.topic,topic.subscribe);
        }
        
        return (NSArray *) topicList;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
	
    
}

// Topic Delete
- (void) deleteTopic:(NSString *)userid whitAndTopic:(NSString *)topic
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    
    @try {
        NSLog(@"======  deleteTopic USERID:%@, TOPIC : %@ - Start ",userid, topic);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM topic WHERE userid=? AND topic=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [topic UTF8String], -1, SQLITE_TRANSIENT);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
    
}


/// Job Insert
- (void) insertJob:(JobBean *)job
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    @try {
        NSLog(@"======  Job instert - Start");
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO job(type, topic, content) VALUES(?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_int(statement, 1, job.type);
        sqlite3_bind_text(statement, 2, [job.topic UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [job.content UTF8String], -1, SQLITE_TRANSIENT);
        
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
}


// Job Select
- (NSArray *) getJobList
{
    NSLog(@"======  getJobList - Start ");
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    NSMutableArray *jobList = [NSMutableArray array];
    
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT id,type, topic, content FROM job";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            pDataBase = nil;
            return NULL;
            
        }
        
        
		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
            JobBean *job = [[JobBean alloc]init];
            
            [job setId:sqlite3_column_int(statement,0)];
            [job setType:sqlite3_column_int(statement,1)];
			[job setTopic:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]]];
            [job setContent:[[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]]];

            [jobList addObject:job];
            NSLog(@"Message : %d, %d, %@, %@", job.id,job.type,job.topic,job.content);
        }
        
        return (NSArray *) jobList;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
	
    
}

// Job Delete
- (void) deleteJob:(int)id
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    
    @try {
        NSLog(@"======  deleteJob ID:%d - Start ",id);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM job WHERE id=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_int(statement, 1, id);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"Erro Message : '%s'", sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"exceptionName %@, reason %@", [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
    
}




@end
