//
//  JobBean.h
//  CertTest2
//
//  Created by gwangil on 2014. 6. 26..
//  Copyright (c) 2014년 kamy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobBean : NSObject

@property int id;
@property int type;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic, retain) NSString *content;

@end
