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
            self.musicTimeMutArray = [NSMutableArray array];
            self.musicTimeMinute = [NSMutableArray array];
            self.musicTimeSecond = [NSMutableArray array];
            self.musicTimeMm = [NSMutableArray array];
            self.perLyricTime = [NSMutableArray array];
            NSArray *allLyricArr = [lyricStr componentsSeparatedByString:@"\n"];
            
           // NSLog(@"%@,l=%ld",allLyricArr,[allLyricArr count]);
            
            for (NSString *perLyric in allLyricArr) {
                if ([perLyric length]){
                    NSRange startRange = [perLyric rangeOfString:@"["];
                    NSRange stopRange = [perLyric rangeOfString:@"]"];
                    
                    NSString *musicTimeStr = [perLyric substringWithRange:NSMakeRange(startRange.location, stopRange.location-startRange.location+1)];
                    
//                    NSLog(@"music=%@,start=%ld,stop=%ld,length=%ld",musicTimeStr,startRange.location,stopRange.location,[musicTimeStr length]);
                    NSString *pertime = [perLyric substringWithRange:NSMakeRange(1, 5)];
                    
                    if ([musicTimeStr length] == 10){
                        NSString *minute = [perLyric substringWithRange:NSMakeRange(1, 2)];
                        NSString *second = [perLyric substringWithRange:NSMakeRange(4, 2)];
//                        NSString *mm = [perLyric substringWithRange:NSMakeRange(7, 2)];
                       
                        NSNumber *perLyricTime = [NSNumber numberWithInteger:[minute integerValue]*60 +[second integerValue]];
                        
                        [self.perLyricTime addObject:perLyricTime];
//                        NSLog(@"min=%@,sec=%@,mm=%@,perTime=%@",minute,second,mm,perLyricTime);
                    }
                    if ([perLyric length] > 10){
//                        [self.musicTimeMutArray addObject:[perLyric substringWithRange:NSMakeRange(1, 5)]];
                        [self.musicTimeMutArray addObject:pertime];
                        NSString *lyric = [perLyric substringFromIndex:10];
                        [self.musicLyricMutArray addObject:lyric];
                    }else{
                        [self.musicLyricMutArray addObject:@""];
                        [self.musicTimeMutArray addObject:pertime];
                    }
                }
            }
        }
    }
    return self;
}

@end
