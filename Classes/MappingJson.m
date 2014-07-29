//
//  MappingJson.m
//  CertTest2
//
//  Created by gwangil on 2014. 6. 26..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import "MappingJson.h"
#import "JsonUtil.h"


@implementation MappingJson

-(MessageBean *) messageToObjectMapping:(NSString *)pPushMessage userID:(NSString *)userid{
    
//    pPushMessage = @"{\"id\":6,\"ack\":true,\"type\":0,\"content\":{\"notification\":{\"notificationStyle\":1,\"contentTitle\":\"교육장소공지\",\"contentText\":\"교육장소공지입니다.\",\"ticker\":\"부산은행교육장소알림장소: 수림연수원 시간: 3월 22일 오전: 12시\",\"summaryText\":\"장소: 수림연수원 시간: 3월 22일 오전:1시\",\"image\":\"\"} } }";
    
    MessageBean *pMessage = [[MessageBean alloc]init];
    JsonUtil *jUil = [[JsonUtil alloc]init];
    
    NSDictionary *dMessage = [jUil jSonToObject:pPushMessage];
    
    NSString *content = [jUil objectToJSon:dMessage[@"content"]];
    NSString *category = dMessage[@"category"];
    NSString *sendDate = dMessage[@"sendDate"];
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date]; //현재 날짜로 객체 생성

    @try {
        [pMessage setId:[dMessage[@"id"] intValue]];
        [pMessage setUserid:userid];
        [pMessage setAck:[dMessage[@"ack"] intValue]];
        [pMessage setType:[dMessage[@"type"] intValue]];
        [pMessage setContent:content];
        [pMessage setReceivedate:[dateFormat stringFromDate:now]];
        [pMessage setRead:1];
        [pMessage setCategory:category];
        [pMessage setSendDate:sendDate];
     }
    @catch (NSException *exception) {
        NSLog(@"Mapping exceptionName %@, reason %@", [exception name], [exception reason]);
        return NULL;
    }

    return pMessage;
    
}

@end
