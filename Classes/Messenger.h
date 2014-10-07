//
//  Messenger.h
//  MQTTTest
//
//  Created by Bryan Boyd on 12/6/13.
//  Copyright (c) 2013 Bryan Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttOCClient.h"
#import "PushDataBase.h"
#import <AVFoundation/AVFoundation.h>

@interface Messenger : NSObject {
    MqttClient *client;
}

@property (nonatomic, retain) MqttClient *client;
@property (nonatomic, retain) NSString *clientId;
@property (nonatomic, retain) NSString *userID;
@property PushDataBase *pDB;
//@property NSMutableArray *logMessages;
@property (nonatomic, retain) NSMutableArray *subscriptionData;
@property (nonatomic, retain) UIWebView *pWebView;
@property BOOL webViewLoadFinish;
@property (nonatomic, retain) NSString *apnsToken;
@property BOOL mqttConnReset;
@property BOOL localNoti;

+ (id)sharedMessenger;
- (void)connectWithHosts:(NSArray *)hosts ports:(NSArray *)ports clientId:(NSString *)clientId cleanSession:(BOOL)cleanSession;
- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained;
- (void)subscribe:(NSString *)topicFilter qos:(int)qos;
- (void)unsubscribe:(NSString *)topicFilter;
- (void)disconnectWithTimeout:(int)timeout;

//- (void)clearLog;
//- (void)addLogMessage:(NSString *)data type:(NSString *)type;

@end
