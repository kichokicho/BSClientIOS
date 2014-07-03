//
//  MappingJson.h
//  CertTest2
//
//  Created by gwangil on 2014. 6. 26..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBean.h"

@interface MappingJson : NSObject

-(MessageBean *) messageToObjectMapping:(NSString *)pPushMessage userID:(NSString *)userid;

@end
