//
//  Music.m
//  MusicPlayer
//
//  Created by administrator on 15/7/1.
//  Copyright (c) 2015年 gem. All rights reserved.
//

#import "Music.h"

@implementation Music

- (instancetype)initWithName:(NSString *)name AndType:(NSString *)type{
    self = [super init];
    if (self != nil){
        self.name = name;
        self.type = type;
    }
    return self;
}
@end
