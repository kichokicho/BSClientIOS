//
//  BadgeSendPlugin.m
//  BSPushClientIphone
//
//  Created by gwangil on 2014. 7. 29..
//
//

#import "BadgeSendPlugin.h"
#import "PushDataBase.h"
#import "Messenger.h"


@implementation BadgeSendPlugin
@synthesize callId;
@synthesize pCDP;

- (void)badgeSend:(CDVInvokedUrlCommand*)command{
    
    tcomm = command;
    [self setCallId:command.callbackId]  ;
    NSLog(@" ======  callbackId : %@", self.callId);
//    NSString *responseString = [NSString stringWithFormat:@"Hello World, %@", [command.arguments objectAtIndex:0]];
    
    NSString *responseString = @"";
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseString];
    
    
    // 읽지 않는 메세지 개수를 서버에 보냄 - start
    PushDataBase *pDB = [[Messenger sharedMessenger] pDB];
    MqttClient *mClient = [[Messenger sharedMessenger] client];
    NSString *userID = [[Messenger sharedMessenger] userID];
    NSString *deviceId = [[Messenger sharedMessenger] apnsToken];
    
    int count = [pDB getMessageUnReadCount];
    
    NSMutableString *payload = [[NSMutableString alloc]init];
    [payload appendFormat:@"{\"userID\":\"%@\",\"deviceID\":\"%@\",\"unRead\":%d}",userID, deviceId, count];
    
    
    mClient = [[Messenger sharedMessenger] client];
    if ([mClient isConnected]) {
        //PUBLISH
        [[Messenger sharedMessenger] publish:@"/push/badge" payload:payload qos:2 retained:FALSE];
        NSLog(@"메시지를전송하였습니다. 메시지=%@",payload);
    }
    // 읽지 않는 메세지 개수를 서버에 보냄 - end
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    
}


- (void) testTime {
    
    NSLog(@" ======  callbackId2 : %@", self.callId);
    
    CDVPluginResult *pluginResult =
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"test"];
    
    NSLog(@" ======  testTime start");
    
    //    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callId];
    
    
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"test()"];
    
    
    
    
}

@end