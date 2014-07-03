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
        
        NSLog(@"%s:%d ======  Message instert - Start ",__func__, __LINE__);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO message(id, userid, ack, type, content, receivedate) VALUES(?, ?, ?, ?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_int(statement, 1, dMsg.id);
        sqlite3_bind_text(statement, 2, [dMsg.userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, dMsg.ack);
        sqlite3_bind_int(statement, 4, dMsg.type);
        sqlite3_bind_text(statement, 5, [dMsg.content UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [dMsg.receivedate UTF8String], -1, SQLITE_TRANSIENT);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
    NSLog(@"%s:%d ======  getMessageList - Start ",__func__, __LINE__);
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    MessageBean *pMsg = [[MessageBean alloc]init];
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        // 검색 SQL
        const char *sql = "SELECT id, userid, ack, type, content, receivedate FROM message ORDER BY receivedate";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            
            
            
            NSLog(@"%s:%d Message(getMessageList) : %d, %@, %d, %d, %@, %@",__func__, __LINE__, pMsg.id, pMsg.userid,pMsg.ack,pMsg.type,pMsg.content,pMsg.receivedate);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  instert apnsToken - Start : %@",__func__, __LINE__, apnsToken);
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO apnstoken(tokenid) VALUES(?)";
        
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [apnsToken UTF8String], -1, SQLITE_TRANSIENT);  // Message
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
    NSLog(@"%s:%d ======  getAPNSToken - Start ",__func__, __LINE__);
    
	NSString *apnsToken;      // Message  ID
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT tokenid FROM apnstoken";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return NULL;
            
        }
 		
		//쿼리를 실행한다.
        while(sqlite3_step(statement) == SQLITE_ROW) {
			apnsToken =  [[NSString alloc] initWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
            // APNS Token
            
            NSLog(@"%s:%d apnsToken : %@ ",__func__, __LINE__, apnsToken);
        }
        return apnsToken;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  Push message All delete - Start ",__func__, __LINE__);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM job";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  User instert - Start",__func__, __LINE__);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO user(userid, password, tokenid, currentuser) VALUES(?, ?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
    NSLog(@"%s:%d ======  getUserList - Start ",__func__, __LINE__);
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    
    UserBean *user = [[UserBean alloc]init];
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT userid, password, tokenid, currentuser FROM user WHERE currentuser = 1";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            NSLog(@"%s:%d Message : %@, %@, %@, %d",__func__, __LINE__, user.userid,user.password,user.tokenid,user.currentuser);
        }
        
        return user;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
    }
    @finally {
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
	
    
}

/// Topic Insert
- (void) insertTopic:(TopicBean *)topic
{
    sqlite3_stmt *statement = nil;
    sqlite3 *pDataBase;
    @try {
        NSLog(@"%s:%d ======  Topic instert - Start",__func__, __LINE__);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO topic(userid, topic, subscribe) VALUES(?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [topic.userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [topic.topic UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 3, topic.subscribe);
        
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
    NSLog(@"%s:%d ======  getTopicList - Start ",__func__, __LINE__);
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    NSMutableArray *topicList = [NSMutableArray array];
    
    
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT userid, topic, subscribe FROM topic WHERE userid=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            NSLog(@"%s:%d Message : %@, %@, %d",__func__, __LINE__, topic.userid,topic.topic,topic.subscribe);
        }
        
        return (NSArray *) topicList;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  deleteTopic USERID:%@, TOPIC : %@ - Start ",__func__, __LINE__,userid, topic);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM topic WHERE userid=? AND topic=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_text(statement, 1, [userid UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [topic UTF8String], -1, SQLITE_TRANSIENT);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  Job instert - Start",__func__, __LINE__);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "INSERT INTO job(type, topic, content) VALUES(?, ?, ?)";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
    NSLog(@"%s:%d ======  getJobList - Start ",__func__, __LINE__);
    
	sqlite3_stmt *statement = nil;
	sqlite3 *pDataBase;
    NSMutableArray *jobList = [NSMutableArray array];
    
    
    @try {
        [self dataBaseConnection:&pDataBase];    // 데이터베이스 연결
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return NULL;
        }
        
        // 검색 SQL
        const char *sql = "SELECT id,type, topic, content FROM job";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
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
            NSLog(@"%s:%d Message : %d, %d, %@, %@",__func__, __LINE__, job.id,job.type,job.topic,job.content);
        }
        
        return (NSArray *) jobList;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
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
        NSLog(@"%s:%d ======  deleteJob ID:%d - Start ",__func__, __LINE__,id);
        
        
        [self dataBaseConnection:&pDataBase];     // 데이터베이스 연결합니다.
        if (pDataBase == nil) {
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            return;
        }
        
        const char *sql = "DELETE FROM job WHERE id=?";
        
        // SQL Text를 prepared statement로 변환합니다.
        if(sqlite3_prepare_v2(pDataBase, sql, -1, &statement, NULL) != SQLITE_OK)
        {
            
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
            //            sqlite3_close(pDataBase);   //데이터베이스를 닫는다
            //            pDataBase = nil;
            return;
            
            
        }
        
        // 조건을 바인딩합니다.
        sqlite3_bind_int(statement, 1, id);
        
        
        //쿼리를 실행한다.
        if(sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%s:%d Erro Message : '%s'",__func__, __LINE__, sqlite3_errmsg(pDataBase));
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s:%d exceptionName %@, reason %@",__func__, __LINE__, [exception name], [exception reason]);
    }
    @finally {
        
        sqlite3_reset(statement);   //객체 초기화
        sqlite3_finalize(statement);  //객체를 닫는다
        sqlite3_close(pDataBase);   //데이터베이스를 닫는다
        pDataBase = nil;
        
    }
    
}




@end
