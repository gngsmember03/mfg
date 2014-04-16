//
//  MGCardData.h
//  MyFirstGame
//
//  Created by Jaesung Moon on 2014. 4. 6..
//  Copyright (c) 2014년 Jaesung Moon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGCardData : NSObject

@property (strong, nonatomic) NSMutableData *cardData;
/** カード識別用の数字*/
@property (strong, nonatomic) NSNumber     *cardTag;

@end
