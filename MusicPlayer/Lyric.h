//
//  Lyric.h
//  MusicPlayer
//
//  Created by administrator on 15/7/1.
//  Copyright (c) 2015年 gem. All rights reserved.
//  歌词类

#import <Foundation/Foundation.h>

@interface Lyric : NSObject

//  歌词数组
@property (nonatomic, strong) NSMutableArray *musicLyricMutArray;

//  歌曲时间数组
//@property (nonatomic, strong) NSMutableArray *musicTimeMutArray;

//  歌曲时间分钟数组
@property (nonatomic, strong) NSMutableArray *musicTimeMinute;

//  歌曲时间秒钟数组
@property (nonatomic, strong) NSMutableArray *musicTimeSecond;

//  歌曲时间毫秒数组
@property (nonatomic, strong) NSMutableArray *musicTimeMm;

//  每一行歌词的总时间
@property (nonatomic, strong) NSMutableArray *perLyricTime;

- (instancetype)initWithLyricStr:(NSString *)lyricStr;
@end
