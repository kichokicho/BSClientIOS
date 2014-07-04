//
//  MyAppDelegate.m
//  PushClient
//
//

#import "PushClient.h"
#import "PushDataBase.h"
#import "Subscription.h"


static float MQTTINTERVAL = 31.0f;
static float JOBINTERVAL = 17.0f;

@implementation MyAppDelegate

- (id) init
{	
    /*
     * If you need to do any extra app-specific initialization, you can do it here.
     **/
    return [super init];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    
    
//    //번들에 있는 데이터베이스를 복사 - start
//    [self CopyOfDataBaseIfNeeded];
//    //번들에 있는 데이터베이스를 복사 - end
    
    //앱이 완전 종료 후 푸쉬 받을때 - start
    if (launchOptions) {
        //       NSLog(@"Count : %d",   launchOptions.count);
        
        NSArray *allKeys = [launchOptions allKeys];
        NSArray *allValues = [launchOptions allValues];
        
        for (int i=0; i < [allKeys count]; i++) {
            NSLog(@"allKeys : %@",[allKeys objectAtIndex:i]);
            NSLog(@"allValues : %@",[allValues objectAtIndex:i]);
        }
        
//        NSDictionary *remoteNotificationKeyDictionary = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
//        NSDictionary *apsDictionary = [remoteNotificationKeyDictionary valueForKey:@"aps"];
//        
//        NSString *message = [apsDictionary objectForKey:@"alert"];
//        NSString *messageForm = [remoteNotificationKeyDictionary valueForKey:@"messageFrom"];
        
        
        //worklight 관련 강제 앱중지 방지를 위해 launchOptions 초기화
        launchOptions = [[NSDictionary alloc]init];

        
    }
    //앱이 완전 종료 후 푸쉬 받을때 - end
    

    //MQQ Connect try - start
    [self backgroundMQTTConection];
//    [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(backgroundMQTTConection) userInfo:nil repeats:NO];
    //MQQ Connect try - end
    
    //MQTT ConnectBackground loop run - start
    [NSTimer scheduledTimerWithTimeInterval:MQTTINTERVAL target:self selector:@selector(backgroundMQTTConection) userInfo:nil repeats:YES];
    //MQTT ConnectBackground loop run - end
    
    //Job Background loop run - start
    [NSTimer scheduledTimerWithTimeInterval:JOBINTERVAL target:self selector:@selector(backgroundJob) userInfo:nil repeats:YES];
    //Job Background loop run - start
    
    
    
    
//    [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(testP2) userInfo:nil repeats:NO];
    
    
    BOOL ret = [super application:application didFinishLaunchingWithOptions:launchOptions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWLNativeInit:) name:@"didFinishWLNativeInit" object:nil];
    
    //APNS 처리 - start
    UIRemoteNotificationType notiType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notiType];
    //APNS 처리 - end
    
    return ret;
}


- (void) application:(UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)apnsToken {
    NSLog(@"%s:%d Success - DeviceToken : %@", __func__, __LINE__, apnsToken);

    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
//    PushDataBase *pDataBase = [[PushDataBase alloc] init];
    NSString *tapnsToken = [pDB getAPNSToken];
    
//    NSLog(@"%s:%d ==== tapnsToken : %@", __func__, __LINE__, tapnsToken);
    
    if (tapnsToken == NULL) {
        
        // Prepare the Device Token for Registration (remove spaces and < >)
        NSString *aToken = [[[[apnsToken description]
                              stringByReplacingOccurrencesOfString:@"<"withString:@""]
                             stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        NSLog(@"%s:%d ==== tapnsToken insert : %@", __func__, __LINE__, aToken);
        
        [pDB insertAPNSToken:aToken];
        
    }else {
        NSLog(@"%s:%d ====  기존 apnsToken 있음", __func__, __LINE__);
    }
    
    
    
    
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%s:%d Fail - Error : %@", __func__, __LINE__, error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%s:%d ------didReceiveRemoteNotification", __func__, __LINE__);
    
    NSDictionary *apsDictionary = [userInfo valueForKey:@"aps"];
    
    NSString *badge = [apsDictionary objectForKey:@"badge"];
    NSLog(@"%s:%d Badge : %@", __func__, __LINE__, badge);
    if (badge != nil) {
        application.applicationIconBadgeNumber = [badge integerValue];
        
    }
    
    NSString *message = [apsDictionary objectForKey:@"alert"];
    NSString *messageForm = [apsDictionary valueForKey:@"messageFrom"];
    //    NSLog(@"Message : %@, form : %@", message, messageForm);
    //    if (message != nil) {
    //        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:messageForm message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //        [alertView show];
    //    }
    //
    //        NSDate *now = [NSDate date]; //현재 날짜로 객체 생성
    //        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    //        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss:SS"];
    //        NSString *dateString = [dateFormat stringFromDate:now];
    //        NSLog(@"======  NOW : %@", dateString);
    //
    //        PushDataBase *pDataBase = [[PushDataBase alloc] init];
    //        [pDataBase insertPushData:dateString PushMessage:message];
    
    [self PushProcess:message andMessageForm:messageForm];
    
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //    NSDictionary *userInfo = notification.userInfo;
    NSString *alertBody = notification.alertBody;
    NSDictionary *pushInfo = notification.userInfo;
    NSLog(@"%s:%d ==== local noti TEst : %@", __func__, __LINE__,alertBody);
    NSString *contentTitle = [pushInfo objectForKey:@"contentTitle"];
    NSString *contentText = [pushInfo objectForKey:@"contentText"];
    
    [self PushProcess:contentText andMessageForm:contentTitle];
    //    NSString *action = [userInfo objectForKey:@"action1"];
    
}

// APNS Alert 처리
- (void)PushProcess:(NSString *)message andMessageForm:(NSString *)messageForm {
    
    NSLog(@"%s:%d Message : %@, form : %@", __func__, __LINE__, message, messageForm);
    if (message != nil) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:messageForm message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    
    NSDate *now = [NSDate date]; //현재 날짜로 객체 생성
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss:SS"];
    NSString *dateString = [dateFormat stringFromDate:now];
    NSLog(@"%s:%d ======  NOW : %@", __func__, __LINE__, dateString);
}


- (void) testP {
    
    NSString  *userID = [[Messenger sharedMessenger] userID];
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
//    PushDataBase *pDB = [[PushDataBase alloc]init];
    NSArray  *topicList = [pDB getTopicList:userID];
    
    NSArray *test = [[Messenger sharedMessenger] subscriptionData];
    
    
    
    if (topicList.count > 0) {
        NSLog(@"%s:%d ===== tesPr2 : %lu", __func__, __LINE__,(unsigned long)test.count);
        
        for (int i=0 ; i < topicList.count; i++) {
            Subscription *obj = [test objectAtIndex:i];
            NSLog(@"%s:%d ===== Topic %d : %@", __func__, __LINE__,i, obj.topicFilter);
        }
        
    }

    
}


/**
 * This is main kick off after the app inits, the views and Settings are setup here. 
 */
-(void) didFinishWLNativeInit:(NSNotification *)notification {
    /*
     * If you need to do any extra app-specific initialization, you can do it here.
     * Note: At this point webview is available.
     **/
     
}

/**
* These functions handle moving to background and foreground and invoke the appropriate JavaScript functions in the UIWebView.
*/
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSString *result = [super.viewController.webView stringByEvaluatingJavaScriptFromString:@"WL.App.BackgroundHandler.onAppEnteringBackground();"]; 
	if([result isEqualToString:@"hideView"]){
		[[self.viewController view] setHidden:YES];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSString *result = [super.viewController.webView stringByEvaluatingJavaScriptFromString:@"WL.App.BackgroundHandler.onAppEnteringForeground();"];
	if([result isEqualToString:@"hideViewToForeground"]){
		[[self.viewController view] setHidden:NO];
	}
    
    [self backgroundMQTTConection];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    application.applicationIconBadgeNumber = 0;
	[super applicationDidBecomeActive:application];
    /*
     * If you need to do any extra app-specific stuff, you can do it here.
     **/
}

- (void)dealloc
{
	[ super dealloc ];
}


////번들에 있는 데이터베이스를 복사하는 메소드
//- (void) CopyOfDataBaseIfNeeded
//{
//	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	
//	NSString *documentDirectory = [paths objectAtIndex:0];
////    NSArray *directoryContent = [[NSFileManager defaultManager] directoryContentsAtPath: documentDirectory];
//    
//    NSLog(@"Documet Path: %@", documentDirectory);
//	
//	NSString *myPath = [documentDirectory stringByAppendingPathComponent:@"PushDB"];
//	NSLog(@"My Path: %@", myPath);
//    
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	
//	BOOL exist = [fileManager fileExistsAtPath:myPath];
//	
//	if (exist) {
//		NSLog(@"DB가 존재합니다.");
//		return;
//	}
//	
//    //파일이 없으면 리소스 에서 파일을 복사한다
//	
//	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PushDB.sqlite"];
//    NSLog(@"DB를 Documet에 복사를 합니다.");
////	return [fileManager copyItemAtPath:defaultDBPath toPath:myPath error:nil];
//	
//}


- (void) backgroundMQTTConection{
    NSLog(@"%s:%d === mqttConnectBackground - start", __func__, __LINE__);
    
    
    
    [self userRead];
    NSString  *clientID = [[Messenger sharedMessenger] clientID];
    
    if (clientID != NULL) {
        
        MqttClient *mClient = [[Messenger sharedMessenger] client];
        
        
        
        if ([mClient isConnected]) {
            
            NSLog(@"%s:%d ===== MQTT Connected", __func__, __LINE__);
            
        } else {
            NSLog(@"%s:%d ===== not Client => Connect try", __func__, __LINE__);
            [self mqttConn];
        }

    }
    
    NSLog(@"%s:%d ==== mqttConnectBackground - end", __func__, __LINE__);
    
    //    [[Messenger sharedMessenger] disconnectWithTimeout:10];
}


//MQTT connection
- (void) mqttConn {
    
    NSLog(@"%s:%d ===== mqttConn - start ", __func__, __LINE__);
    
    NSArray *servers = [[NSArray alloc] initWithObjects:@"adflow.net", nil];
    NSArray *ports = [[NSArray alloc] initWithObjects:@"1883", nil];
    NSString  *clientID = [[Messenger sharedMessenger] clientID];
    //    clientID = @"test12345";
    
    [[Messenger sharedMessenger] connectWithHosts:servers ports:ports clientId:clientID cleanSession:FALSE];
    
//    [self mqttSubscribe];
    [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(mqttSubscribe) userInfo:nil repeats:NO];
    
}

- (void) mqttSubscribe {


    
    NSString  *userID = [[Messenger sharedMessenger] userID];
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
//    PushDataBase *pDB = [[PushDataBase alloc]init];
    NSArray  *topicList = [pDB getTopicList:userID];
    TopicBean *topic = [[TopicBean alloc]init];
    
    if (topicList.count > 0) {
        
        //기존 subscribe 에 없으면  DB를 읽어 추가 -start
        NSMutableArray *subscribeList = [[Messenger sharedMessenger] subscriptionData];
        if (subscribeList.count <= 0) {
            for (int i=0; i < topicList.count; i++) {
                Subscription *tSub = [[Subscription alloc]init];
                topic = [topicList objectAtIndex:i];
                [tSub setTopicFilter:topic.topic];
                [tSub setQos:2];
                [subscribeList addObject:tSub];
                
                [[Messenger sharedMessenger] subscribe:topic.topic qos:(int)2];
                
            }
            //개인 Notification용 -- start
            NSMutableString *tmpTopic = [[NSMutableString alloc]init];
            [tmpTopic appendFormat:@"/users/%@",userID];
            NSString *baseTopic = tmpTopic;
            
            [[Messenger sharedMessenger] subscribe:baseTopic qos:(int)2];
            //개인 Notification용 -- end
            
            // 전체 Notification용 - start
            [[Messenger sharedMessenger] subscribe:@"/users" qos:(int)2];
            // 전체 Notification용 - end
            
        }
        //기존 subscribe 에 없으면  DB를 읽어 추가 -end
        
    } else {
        
        MqttClient *mClient = [[Messenger sharedMessenger] client];
        
        
        
        if ([mClient isConnected]) {
            
            NSLog(@"%s:%d ===== mqttSubscribe MQTT Connected", __func__, __LINE__);
            //개인 Notification용 -- start
            NSMutableString *tmpTopic = [[NSMutableString alloc]init];
            [tmpTopic appendFormat:@"/users/%@",userID];
            NSString *baseTopic = tmpTopic;
            
            [[Messenger sharedMessenger] subscribe:baseTopic qos:(int)2];
            //개인 Notification용 -- end
            
            // 전체 Notification용 - start
            [[Messenger sharedMessenger] subscribe:@"/users" qos:(int)2];
            // 전체 Notification용 - end
            
            // 그룹정보동기화요청 - start
            NSMutableString *tmpMSG = [[NSMutableString alloc]init];
            [tmpMSG appendFormat:@"{\"userID\":\"%@\"}",userID];
            [[Messenger sharedMessenger] publish:@"/push/group" payload:tmpMSG qos:2 retained:NO];
            // 그룹정보동기화요청 - end
            
        } else {
            NSLog(@"%s:%d ===== mqttSubscribe not Client", __func__, __LINE__);
            //Base(개인,전체) Notification용  Job 추가-- start
            NSMutableString *tmpTopic = [[NSMutableString alloc]init];
            [tmpTopic appendFormat:@"/users/%@",userID];
            NSString *baseTopic = tmpTopic;
            
 //           [[Messenger sharedMessenger] subscribe:baseTopic qos:(int)2];
            JobBean *job = [[JobBean alloc]init];
            [job setType:1000]; //Base SUBSCRIBE
            [job setTopic:baseTopic];
            [job setContent:@""];
            
            [pDB insertJob:job];
            
            //Base(개인,전체) Notification용  Job 추가 -- end
            

        }
        
        
    }
}

- (void) userRead {
    
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
//    PushDataBase *pDB = [[PushDataBase alloc]init];
    
    UserBean *user = [pDB getUser];
    
    if (user != NULL && user.userid != nil) {
        
        NSString  *clientID = [[Messenger sharedMessenger] clientID];
        
        if (clientID != nil) {
            if (!([clientID isEqual:user.tokenid])) {
                NSLog(@"%s:%d 토큰이변경되었습니다.", __func__, __LINE__);
                
                MqttClient *mClient = [[Messenger sharedMessenger] client];
                
                if ([mClient isConnected]) {
                    
                    NSLog(@"%s:%d 클라이언트를종료합니다.", __func__, __LINE__);
                    [[Messenger sharedMessenger] disconnectWithTimeout:5];
                    
                    //다시 연결 시도.
                    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(backgroundMQTTConection) userInfo:nil repeats:NO];
                    

                }
                
                NSLog(@"%s:%d ===== mqttSubscribe not Client", __func__, __LINE__);
                //Base(개인,전체) Notification용  Job 추가-- start
                NSMutableString *tmpTopic = [[NSMutableString alloc]init];
                [tmpTopic appendFormat:@"/users/%@",user.userid];
                NSString *baseTopic = tmpTopic;
                
                //           [[Messenger sharedMessenger] subscribe:baseTopic qos:(int)2];
                JobBean *job = [[JobBean alloc]init];
                [job setType:1000]; //Base SUBSCRIBE
                [job setTopic:baseTopic];
                [job setContent:@""];
                
                [pDB insertJob:job];
                
                //Base(개인,전체) Notification용  Job 추가 -- end
            }
        }
        
        [[Messenger sharedMessenger] setUserID:user.userid];
        [[Messenger sharedMessenger] setClientID:user.tokenid];
        
        
    }else{
        NSLog(@"%s:%d 토큰 or 유저아이디가없습니다.", __func__, __LINE__);
        
        UserBean *userB = [[UserBean alloc]init];
        [userB setUserid:@"1731124"];
        [userB setTokenid:@"e9272e69ff554b5d997a4c2"];
        [userB setPassword:@"aaaaa"];
        [userB setCurrentuser:1];
        
        [pDB insertUser:userB];
    }
    
}

-(void)backgroundJob {
    
//    [self testP];
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
//    PushDataBase *pDB = [[PushDataBase alloc]init];
    
    NSString  *userID = [[Messenger sharedMessenger] userID];
    NSArray *jobList = [pDB getJobList];
    JobBean *job = [[JobBean alloc]init];
//    NSMutableString *tmpMS = [[NSMutableString alloc]init];
    TopicBean *topic = [[TopicBean alloc]init];
    NSMutableArray *subscribeList = [[Messenger sharedMessenger] subscriptionData];
    Subscription *tSub;
    MqttClient *mClient = [[Messenger sharedMessenger] client];
    
    
    for (int i=0; i < jobList.count; i++) {
        job = [jobList objectAtIndex:i];
        
        NSLog(@"%s:%d Message List : %d, %d, %@, %@", __func__, __LINE__, job.id,job.type,job.topic,job.content);
        
        switch (job.type) {
            case 0:
                mClient = [[Messenger sharedMessenger] client];
                if ([mClient isConnected]) {
                    //PUBLISH
                    [[Messenger sharedMessenger] publish:job.topic payload:job.content qos:2 retained:FALSE];
                    NSLog(@"%s:%d 메시지를전송하였습니다. 메시지=%@", __func__, __LINE__,job.content);
                    
                    // DB Job delete
                    [pDB deleteJob:job.id];
                    NSLog(@"%s:%d 해당 Job을 삭제하였습니다. id=%d", __func__, __LINE__,job.id);
                
                }
            
            
                
                break;
            case 100:
                mClient = [[Messenger sharedMessenger] client];
                if ([mClient isConnected]) {
                    // SUBSCRIBE
                    [[Messenger sharedMessenger] subscribe:job.topic qos:(int)2];
                    
                    //Topic DB Insert
                    [topic setTopic:job.topic];
                    [topic setUserid:userID];
                    [pDB insertTopic:topic];
                    
                    //Subscribe Add
                    tSub=[[Subscription alloc]init];
                    [tSub setTopicFilter:job.topic];
                    [tSub setQos:2];
                    [subscribeList addObject:tSub];
                    
                    // DB Job delete
                    [pDB deleteJob:job.id];
                    NSLog(@"%s:%d 해당 Job을 삭제하였습니다. id=%d", __func__, __LINE__,job.id);
                
                }
            
                
                
                break;
                
            case 101:
                mClient = [[Messenger sharedMessenger] client];
                if ([mClient isConnected]) {
                    // UNSUBSCRIBE
                    [[Messenger sharedMessenger] unsubscribe:job.topic];
                    
                    //Topic DB Delete
                    [pDB deleteTopic:userID whitAndTopic:job.topic];
                    
                    // DB Job delete
                    [pDB deleteJob:job.id];
                    NSLog(@"%s:%d 해당 Job을 삭제하였습니다. id=%d", __func__, __LINE__,job.id);
                
                }
            
                
                
                break;
            
            case 1000: //Base(개인,전체) Notification용
                mClient = [[Messenger sharedMessenger] client];
                if ([mClient isConnected]) {
                    // SUBSCRIBE
                    //개인 Notification용 -- start
                    NSMutableString *tmpUser = [[NSMutableString alloc]init];
                    [tmpUser appendFormat:@"/users/%@",userID];
                    [[Messenger sharedMessenger] subscribe:tmpUser qos:(int)2];
                    //개인 Notification용 -- end
                    
                    // 전체 Notification용 - start
                    [[Messenger sharedMessenger] subscribe:@"/users" qos:(int)2];
                    // 전체 Notification용 - end
                    
                    // 그룹정보동기화요청 - start
                    NSMutableString *tmpMSG = [[NSMutableString alloc]init];
                    [tmpMSG appendFormat:@"{\"userID\":\"%@\"}",userID];
                    [[Messenger sharedMessenger] publish:@"/push/group" payload:tmpMSG qos:2 retained:NO];
                    // 그룹정보동기화요청 - end
                
                    // DB Job delete
                    [pDB deleteJob:job.id];
                    NSLog(@"%s:%d 해당 Job을 삭제하였습니다. id=%d", __func__, __LINE__,job.id);
                
                }
            
            break;
            
            default:
                break;
        }
    }
    
    
}





@end