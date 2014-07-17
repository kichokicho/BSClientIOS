//
//  UserBean.h
//  CertTest2
//
//  Created by gwangil on 2014. 6. 26..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBean : NSObject

@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *tokenid;
@property int currentuser;

@end
