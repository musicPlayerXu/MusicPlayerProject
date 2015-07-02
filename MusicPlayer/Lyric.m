//
//  Lyric.m
//  MusicPlayer
//
//  Created by administrator on 15/7/1.
//  Copyright (c) 2015年 gem. All rights reserved.
//

#import "Lyric.h"

@implementation Lyric

- (instancetype)initWithLyricStr:(NSString *)songName{
    self = [super init];
    if (self != nil)
    {
        NSString *lyricStrPath = [[NSBundle mainBundle]pathForResource:songName ofType:@"lrc"];
        if ([lyricStrPath length])
        {
            
            NSString *lyricStr = [NSString stringWithContentsOfFile:lyricStrPath encoding:NSUTF8StringEncoding error:nil];
            
            self.musicLyricMutArray = [NSMutableArray array];
//            self.musicTimeMutArray = [NSMutableArray array];
            self.musicTimeMinute = [NSMutableArray array];
            self.musicTimeSecond = [NSMutableArray array];
            self.musicTimeMm = [NSMutableArray array];
            
            NSArray *allLyricArr = [lyricStr componentsSeparatedByString:@"\n"];
            
           // NSLog(@"%@,l=%ld",allLyricArr,[allLyricArr count]);
            
            for (NSString *perLyric in allLyricArr) {
                if ([perLyric length]){
                    NSRange startRange = [perLyric rangeOfString:@"["];
                    NSRange stopRange = [perLyric rangeOfString:@"]"];
                    
                    NSString *musicTimeStr = [perLyric substringWithRange:NSMakeRange(startRange.location, stopRange.location-startRange.location)];
                    
                    NSLog(@"%@,%d,%d",musicTimeStr,startRange.location,stopRange.location);
                    
                    if ([perLyric length] == 8){
                        NSString *minute = [perLyric substringWithRange:NSMakeRange(0, 2)];
                        NSString *second = [perLyric substringWithRange:NSMakeRange(3, 4)];
                        NSString *mm = [perLyric substringWithRange:NSMakeRange(5, 6)];
                        
                        NSNumber *perLyricTime = [NSNumber numberWithInteger:[minute integerValue]*60 +[second integerValue]];
                        
                        NSString *lyric = [perLyric substringFromIndex:10];
                        [self.musicLyricMutArray addObject:lyric];
                        NSLog(@"min=%@,sec=%@,mm=%@,perTime=%@,lyric=%@",minute,second,mm,perLyricTime,lyric);
                        
                    }
                }
            }
        }
    }
    return self;
}

@end
