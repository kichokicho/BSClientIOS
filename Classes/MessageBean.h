//
//  MessageBean.h
//  CertTest2
//
//  Created by gwangil on 2014. 6. 26..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageBean : NSObject

@property int id;
@property NSString *userid;
@property int ack;
@property int type;
@property NSString *content;
@property NSString *receivedate;

@end
