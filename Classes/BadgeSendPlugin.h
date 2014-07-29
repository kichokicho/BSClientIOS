//
//  BadgeSendPlugin.h
//  BSPushClientIphone
//
//  Created by gwangil on 2014. 7. 29..
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface BadgeSendPlugin : CDVPlugin{
    CDVInvokedUrlCommand *tcomm;
    //	    NSString *callId ;
    //    CDVPlugin * pCDP;
}

@property (nonatomic, retain) NSString * callId;
@property id * pCDP;

- (void)badgeSend:(CDVInvokedUrlCommand*)command;
- (void) testTime;

@end
