//
//  PushDataBase.h
//  ADFlowOfficeADFlowOfficeIphone
//
//  Created by gwangil on 2014. 6. 15..
//
//

//#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "MessageBean.h"
#import "UserBean.h"
#import "TopicBean.h"
#import "JobBean.h"




@interface PushDataBase : NSObject

- (id)initWithDataBaseFilename:(NSString *) databaseFilename;
- (void) dataBaseConnection:(sqlite3 **)tempDataBase;
- (void) insertMessage:(MessageBean *)pPushMessage;
- (void) getMessageList;
- (void) insertAPNSToken:(NSString *)apnsToken; //APNS Token reg.
- (NSString *) getAPNSToken; //APNS Token get.
- (void) allDeleteMessage; //Push message All delete.


- (NSArray *) getJobList;
- (void) insertJob:(JobBean *)job;
- (NSArray *) getTopicList:(NSString *)userid;
- (int) insertTopic:(TopicBean *)topic;
- (UserBean *) getUser;
- (void) insertUser:(UserBean *)user;

- (void) deleteJob:(int)id;
- (void) deleteTopic:(NSString *)userid whitAndTopic:(NSString *)topic;
- (int) getMessageUnReadCount;

@end
