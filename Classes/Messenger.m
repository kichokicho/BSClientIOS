//
//  Messenger.m
//  MQTTTest
//
//  Created by Bryan Boyd on 12/6/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import "Messenger.h"
#import "MqttOCClient.h"
#import "LogMessage.h"
#import "Subscription.h"
#import "MappingJson.h"
#import "MessageBean.h"
#import "JsonUtil.h"



// Connect Callbacks
@interface ConnectCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation ConnectCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"- invocationContext=%@", invocationContext);
//    [[Messenger sharedMessenger] addLogMessage:@"Connected to server!" type:@"Action"];
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate updateConnectButton];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"- invocationContext=%@  errorCode=%d  errorMessage=%@", invocationContext, errorCode, errorMessage);
//    [[Messenger sharedMessenger] addLogMessage:@"Failed to connect!" type:@"Action"];
}
@end

// disConnect Callbacks
@interface DisConnectCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation DisConnectCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"- invocationContext=%@", invocationContext);
//    [[Messenger sharedMessenger] addLogMessage:@"DisConnected to server!" type:@"Action"];
    
    //    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //    [appDelegate updateConnectButton];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"- invocationContext=%@  errorCode=%d  errorMessage=%@", invocationContext, errorCode, errorMessage);
//    [[Messenger sharedMessenger] addLogMessage:@"Failed to disconnect!" type:@"Action"];
}
@end

// Publish Callbacks
@interface PublishCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage;
@end
@implementation PublishCallbacks
- (void) onSuccess:(NSObject *) invocationContext
{
    NSLog(@"PublishCallbacks - onSuccess");
}
- (void) onFailure:(NSObject *) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage
{
    NSLog(@"PublishCallbacks - onFailure");
}
@end

// Subscribe Callbacks
@interface SubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation SubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"- invocationContext=%@", invocationContext);
//    NSLog(@"SubscribeCallbacks - onSuccess");
//    NSString *topic = (NSString *)invocationContext;
//    [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Subscribed to %@", topic] type:@"Action"];

//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate reloadSubscriptionList];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"SubscribeCallbacks - onFailure");
}
@end

// Unsubscribe Callbacks
@interface UnsubscribeCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end
@implementation UnsubscribeCallbacks
- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"- invocationContext=%@", invocationContext);
//    NSString *topic = (NSString *)invocationContext;
//    [[Messenger sharedMessenger] addLogMessage:[NSString stringWithFormat:@"Unsubscribed to %@", topic] type:@"Action"];
}
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"- invocationContext=%@  errorCode=%d  errorMessage=%@", invocationContext, errorCode, errorMessage);
}
@end

@interface GeneralCallbacks : NSObject <MqttCallbacks>
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage;
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg;
- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId;
@end
@implementation GeneralCallbacks
- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage
{
    [[[Messenger sharedMessenger] subscriptionData] removeAllObjects];
    NSLog(@"errorMessage :%@", errorMessage);
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate updateConnectButton];
//    [appDelegate reloadSubscriptionList];
}
- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg
{
    int qos = msg.qos;
    BOOL retained = msg.retained;
//    NSString *payload = [[NSString alloc] initWithBytes:msg.payload length:msg.payloadLength encoding:NSASCIIStringEncoding];
    NSString *payload = [[NSString alloc] initWithBytes:msg.payload length:msg.payloadLength encoding:NSUTF8StringEncoding];
//    NSString* aString = [[[NSString alloc] initWithString:payload encoding:0×80000840] autorelease];
    
    NSString *topic = msg.destinationName;
    NSString *retainedStr = retained ? @" [retained]" : @"";
    NSString *logStr = [NSString stringWithFormat:@"[%@ QoS:%d] %@%@", topic, qos, payload, retainedStr];
    NSLog(@"- %@", logStr);
    NSLog(@"GeneralCallbacks - onMessageArrived!");
//    [[Messenger sharedMessenger] addLogMessage:logStr type:@"Subscribe"];
    
    JsonUtil *jUtil = [[JsonUtil alloc]init];
    NSDictionary *dContent;
    MappingJson *mJson = [[MappingJson alloc]init];
    NSString *userid = [[Messenger sharedMessenger] userID];
    MessageBean *messageBean = [mJson messageToObjectMapping:payload userID:userid];
    
    if (messageBean == NULL) {
        return;
    }
    
    NSMutableString *tmpMS = [[NSMutableString alloc]init];
//    PushDataBase *pDB = [[PushDataBase alloc]init];
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
    JobBean *job = [[JobBean alloc]init];
    NSDictionary *pushInfo;
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    NSArray *groups;
    NSMutableArray *subscribeList;
    Subscription *sub;
//    TopicBean *topicBean = [[TopicBean alloc]init];
//    UIWebView *pWebView = [[Messenger sharedMessenger] pWebView];
    NSMutableString *javascriptFuntion = [[NSMutableString alloc]init];
    NSDate *today;
    NSDate *dateNoti;
    
    NSMutableString *sendDate;
    NSDateFormatter *formatter;
    NSDate *pSendDate;
    NSDate *pSendDateAddOneDay;
    
    
    @try {
        // Message Insert
//        [pDB insertMessage:messageBean];
        
        
        switch (messageBean.type) {
            case 0: // 개인메시지
			case 1: // 전체메시지
			case 2: // 그룹메시지(계열사)
			case 3: // 그룹메시지(부서)
			case 4: // 그룹메시지(직급)
            
                today = [NSDate date];
                sendDate = [[NSMutableString alloc]init];
                [sendDate appendFormat:@"%@ +0900",messageBean.sendDate];
                NSLog(@"======== sendDate:  %@", sendDate);
            
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss Z"];
            
                pSendDate = [[NSDate alloc] init];
                pSendDate = [formatter dateFromString:sendDate];
                NSLog(@"======== pSendDate:  %@", [pSendDate description]);
            
                // sendDate + 1 Day (24 * 3600 = 86400
                pSendDateAddOneDay = [NSDate dateWithTimeInterval:86400 sinceDate:pSendDate];
                NSLog(@"======== pSendDateAddOneDay:  %@", [pSendDateAddOneDay description]);
            
                // 두 날짜 비교 Compare - 하루가 지난 메세지 skip
                NSComparisonResult compareResult = [today compare:pSendDateAddOneDay];
                if(compareResult == -1) {
                    
                    NSLog(@"=======   today < pSendDateAddOneDay");

                    messageBean.read = 1;
                    [pDB insertMessage:messageBean];
                    if (messageBean.ack) {
                        [tmpMS appendFormat:@"{\"userID\":\"%@\",\"id\":%d}",userid, messageBean.id];
                        [job setType:0]; //PUBLISH
                        [job setTopic:@"/push/ack"];
                        [job setContent:tmpMS];
                    
                        [pDB insertJob:job];
                    }
                
                    // WebView Load Finish Check
                    if (!([[Messenger sharedMessenger] webViewLoadFinish])) {
                        NSLog(@"WebView가 아직 로드 되지 않았습니다.");
                        break;
                    }
                    // Local Notification - start
                    
                    if ([[Messenger sharedMessenger]localNoti]) {
                        dContent = [jUtil jSonToObject:messageBean.content];
                        pushInfo = [NSDictionary dictionaryWithObjectsAndKeys:messageBean.category,@"category", nil];
                        localNotif.timeZone = [NSTimeZone defaultTimeZone];
                        
                        
                        //javacript call name
                        [javascriptFuntion appendFormat:@"refreshFunction('%@')",messageBean.category];
                        localNotif.alertBody = javascriptFuntion;
                        //                localNotif.alertBody = dContent[@"notification"][@"contentTitle"];
                        
                        localNotif.alertAction = @"AlertAction";
                        localNotif.soundName = UILocalNotificationDefaultSoundName;
                        localNotif.applicationIconBadgeNumber = 0;
                        localNotif.userInfo = pushInfo;
                        // 5초 후 시간 계산 - start
                        today = [NSDate date];
                        dateNoti = [NSDate dateWithTimeInterval:5 sinceDate:today];
                        // 5초 후 시간 계산 - end
                        
                        localNotif.fireDate = dateNoti;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                        [[Messenger sharedMessenger] setLocalNoti:FALSE];
                    };
            
                    
                    
                    
//                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                    // Local Notification - end
                    
                    //                [pWebView stringByEvaluatingJavaScriptFromString:@"test()"];
                    //                NSLog(@"=============  javascript Call ");

                }
                
                
                break;
            case 100:
                // command msg
                // (토픽=/users/nadir93,메시지={"id":5,"ack":false,"type":1,"content":{"userID":"nadir93","groups":["dev","adflow"]}},qos=2)
                
                
                //기존 topic 가져와 unsubscribe 처리 - start
                messageBean.read = 0;
                [pDB insertMessage:messageBean];
                
                subscribeList = [[Messenger sharedMessenger] subscriptionData];
                for (int i=0; i < subscribeList.count; i++) {
                    
                    sub = [subscribeList objectAtIndex:i];
                    [job setType:101]; //UNSUBSCRIBE
                    [job setTopic:sub.topicFilter];
                    [job setContent:@""];
                    
                    [pDB insertJob:job];
                }
                //기존 topic 가져와 unsubscribe 처리 - end
                
                dContent = [jUtil jSonToObject:messageBean.content];
                groups = dContent[@"groups"];
                
                for (int i=0; i < groups.count; i++) {
                    tmpMS = [[NSMutableString alloc]init];
                    [tmpMS appendFormat:@"/groups/%@", [groups objectAtIndex:i]];
                    [job setType:100]; //SUBSCRIBE
                    [job setTopic:tmpMS];
                    [job setContent:@""];
                    
                    [pDB insertJob:job];
                }
                
                
                break;
                
            case 101:
                // command msg
                // (토픽=/users/nadir93,메시지={"id":5,"ack":false,"type":1,"content":{"userID":"nadir93","groups":["dev","adflow"]}},qos=2)
                messageBean.read = 0;
                [pDB insertMessage:messageBean];
                
                
                dContent = [jUtil jSonToObject:messageBean.content];
                
                groups = dContent[@"groups"];
                
                for (int i=0; i < groups.count; i++) {
                    [tmpMS appendFormat:@"/groups/%@", [groups objectAtIndex:i]];
                    [job setType:101]; //UNSUBSCRIBE
                    [job setTopic:tmpMS];
                    [job setContent:nil];
                    
                    [pDB insertJob:job];
                }
                
                
                break;
                
            default:
                break;
        }


    }
    @catch (NSException *exception) {
        NSLog(@"onMessageArrived exceptionName %@, reason %@", [exception name], [exception reason]);
    }
}

- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId
{
    NSLog(@"GeneralCallbacks - onMessageDelivered!");
}
@end


@implementation Messenger

@synthesize client;

#pragma mark Singleton Methods

+ (id)sharedMessenger {
    static Messenger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.client = [MqttClient alloc];
        self.clientId = nil;
        self.userID = nil;
        self.pDB = [[PushDataBase alloc]init];
        self.client.callbacks = [[GeneralCallbacks alloc] init];
//        self.logMessages = [[NSMutableArray alloc] init];
        self.SubscriptionData = [[NSMutableArray alloc] init];
        self.pWebView = [UIWebView alloc];
        self.webViewLoadFinish = FALSE;
        self.apnsToken = nil;
        self.mqttConnReset = FALSE;
        self.localNoti = TRUE;
    }
    return self;
}

- (void)connectWithHosts:(NSArray *)hosts ports:(NSArray *)ports clientId:(NSString *)clientId cleanSession:(BOOL)cleanSession
{
    /*NSUInteger currentIndex = 0;
    for (id obj in self.subscriptionData) {
        NSString *topicFilter = ((Subscription *)obj).topicFilter;
        [client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
        currentIndex++;
    }
    [[self subscriptionData] removeAllObjects];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate reloadSubscriptionList];*/
    
    client = [client initWithHosts:hosts ports:ports clientId:clientId];
    ConnectOptions *opts = [[ConnectOptions alloc] init];
    opts.timeout = 3600;
    opts.cleanSession = cleanSession;

    SSLOptions *ssloti = [[SSLOptions alloc] init];
    ssloti.enableServerCertAuth = FALSE;
    opts.sslProperties = ssloti;

    
    NSLog(@"host=%@, port=%@, clientId=%@", hosts, ports, clientId);
    [client connectWithOptions:opts invocationContext:self onCompletion:[[ConnectCallbacks alloc] init]];
}

- (void)disconnectWithTimeout:(int)timeout {
    DisconnectOptions *opts = [[DisconnectOptions alloc] init];
    [opts setTimeout:timeout];
    
    [[self subscriptionData] removeAllObjects];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate reloadSubscriptionList];
    
    [client disconnectWithOptions:opts invocationContext:self onCompletion:[[DisConnectCallbacks alloc] init]];
}

- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained
{
    NSLog(@"=========== playload1 :%@", payload);
    
    NSString *retainedStr = retained ? @" [retained]" : @"";
    NSString *logStr = [NSString stringWithFormat:@"[%@] %@%@", topic, payload, retainedStr];
    NSLog(@"- %@", logStr);
//    [[Messenger sharedMessenger] addLogMessage:logStr type:@"Publish"];
    
    NSLog(@"=========== playload2 :%@", payload);
    MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:(char*)[payload UTF8String] length:(int)payload.length qos:qos retained:retained duplicate:NO];
    NSLog(@"=========== msg :%@", msg);
    
    [client send:msg invocationContext:self onCompletion:[[PublishCallbacks alloc] init]];
}

- (void)subscribe:(NSString *)topicFilter qos:(int)qos
{
    NSLog(@"topicFilter=%@, qos=%d", topicFilter, qos);
    NSLog(@"=====  subscribe start");
    
    [client subscribe:topicFilter qos:qos invocationContext:topicFilter onCompletion:[[SubscribeCallbacks alloc] init]];

    NSLog(@"=====  subscribe end");
    
//    Subscription *sub = [[Subscription alloc] init];
//    sub.topicFilter = topicFilter;
//    sub.qos = qos;
//    [self.subscriptionData addObject:sub];
//    
//    NSLog(@"sue1 : %lu",(unsigned long)self.subscriptionData.count);
//    
//    NSMutableArray *temp = [[Messenger sharedMessenger] subscriptionData];
//    [temp addObject:sub];
//    NSLog(@"sue2 : %lu",(unsigned long)self.subscriptionData.count);
//    NSLog(@"sue3 : %lu",(unsigned long)temp.count);
//    [[Messenger sharedMessenger] setSubscriptionData:temp];
//    temp = [[Messenger sharedMessenger] subscriptionData];
//    NSLog(@"sue4 : %lu",(unsigned long)temp.count);
    
}

- (void)unsubscribe:(NSString *)topicFilter
{
    NSLog(@"topicFilter=%@", topicFilter);
    [client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
    
    NSUInteger currentIndex = 0;
    for (id obj in self.subscriptionData) {
        if ([((Subscription *)obj).topicFilter isEqualToString:topicFilter]) {
            [self.subscriptionData removeObjectAtIndex:currentIndex];
            break;
        }
        currentIndex++;
    }
}

//- (void)clearLog
//{
////    self.logMessages = [[NSMutableArray alloc] init];
//}

//- (void)addLogMessage:(NSString *)data type:(NSString *)type
//{
//    LogMessage *msg = [[LogMessage alloc] init];
//    msg.data = data;
//    msg.type = type;
//    
//    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
//    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//    msg.timestamp = [DateFormatter stringFromDate:[NSDate date]];
//    
//    NSLog(@"=== msg data : %@,  type:%@", data, type);
//    
//   
////    if ([data  isEqual: @"Connected to server!"]) {
////        NSLog(@"=== aaaaaaaaaa");
////        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(mqttSubscribe2) userInfo:nil repeats:NO];
////        NSLog(@"=== bbbbbbbbbbb");
////
////        //        NSString *topic = @"test/12345";
//////        NSString *msg = @"good";
//////        [[Messenger sharedMessenger] subscribe:topic qos:(int)1];
////    }
////    [self.logMessages addObject:msg];
////    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
////    [appDelegate reloadLog];
//}



@end