//
//  JsonUtil.m
//  CertTest2
//
//  Created by gwangil on 2014. 6. 19..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import "JsonUtil.h"
#import "SBJson.h"

@implementation JsonUtil

//#define EncodePercentString(string) ( (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)(string), NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8)) )
//
//#define DecodePercentString(string) ( (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)(string), (CFStringRef)@"", kCFStringEncodingUTF8)) )

- (NSDictionary *)jSonToObject:(NSString *)jSonData
{
    // JSON DATA ( utf-8 encoding ) --> OBJ
    
//    NSError* error;
//    NSDictionary* json = [NSJSONSerialization
//                          JSONObjectWithData:[jSonData dataUsingEncoding:NSUTF8StringEncoding]
//                          options:kNilOptions
//                          error:&error];
//    NSMutableDictionary* json = [NSJSONSerialization
//                          JSONObjectWithData:[jSonData dataUsingEncoding:NSUTF8StringEncoding]
//                          options:NSJSONReadingMutableContainers
//                          error:&error];
//    
//    // check ERROR
//    if (error) {
//        NSLog(@"error : %@", error.localizedDescription);
//        return NULL;
//    }
    
    SBJsonParser *parser = [[SBJsonParser alloc]init];
    NSDictionary *json = [parser objectWithString:jSonData];
    
    
    return json;
}
- (NSString *)objectToJSon:(NSDictionary *)jObjectData
{
    // OBJ --> JSON DATA ( utf-8 encoding )
//    NSError* error;
//    
//    
//    NSData* jsonData = [NSJSONSerialization
//                        dataWithJSONObject:jObjectData
//                        options:kNilOptions
//                        error:&error];
//    
//    if (error) {
//        NSLog(@"error : %@", error.localizedDescription);
//        return NULL;
//    }
//    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc]init];
    NSString *jsonData = [writer stringWithObject:jObjectData];
    
    return jsonData;
}

@end
