//
//  JsonUtil.h
//  CertTest2
//
//  Created by gwangil on 2014. 6. 19..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonUtil : NSObject
- (NSDictionary *)jSonToObject:(NSString *)jSon;
- (NSString *)objectToJSon:(NSDictionary *)jObject;
@end
