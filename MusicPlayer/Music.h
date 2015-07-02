//
//  Music.h
//  MusicPlayer
//
//  Created by administrator on 15/7/1.
//  Copyright (c) 2015年 gem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *type;

- (instancetype)initWithName:(NSString *)name AndType:(NSString *)type;

@end
