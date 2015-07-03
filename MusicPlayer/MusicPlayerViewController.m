//
//  MusicPlayerViewController.m
//  MusicPlayer
//
//  Created by administrator on 15/7/1.
//  Copyright (c) 2015年 gem. All rights reserved.
//

#import "MusicPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "Music.h"

#import "Lyric.h"

@interface MusicPlayerViewController ()<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AVAudioPlayer *avAudioPlayer;    //播放器player
    

}

@property (strong, nonatomic) NSTimer *timer;

//  声音开关控件
@property (strong, nonatomic) IBOutlet UISwitch *volumeSwitch;

//  音量控件
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;

//  歌曲进度条
@property (strong, nonatomic) IBOutlet UIProgressView *songsProgressView;

//  歌曲进度条slider
@property (strong, nonatomic) IBOutlet UISlider *songsProgressSlider;

//  歌曲现在的时间
@property (strong, nonatomic) IBOutlet UILabel *songsCurrentTime;

//  歌曲的持续时间（总时间）
@property (strong, nonatomic) IBOutlet UILabel *songsDurationTime;

//  播放按钮
@property (strong, nonatomic) IBOutlet UIButton *playBt;

//  歌曲名称数组
@property (strong, nonatomic) NSMutableArray *songsNameMutArray;

//  歌曲列表
@property (strong, nonatomic) IBOutlet UILabel *songsList;

//  当前的歌曲是第几首
@property (assign, nonatomic) int currentMusicNumber;

//  歌词的tableView
@property (strong, nonatomic) IBOutlet UITableView *musicLyricTableView;

//  歌词类
@property (strong, nonatomic) Lyric *musicLyric;

//  时间计时器用于判断歌词的变化
//@property (assign, nonatomic) NSInteger *timeCount;

@property (assign, nonatomic) NSInteger lrcLineNumber;

@end



@implementation MusicPlayerViewController

/**
 *  初始化定时器（控制歌曲进度条），声音进度条，声音开关,歌曲现在时间和歌曲持续时间
 */
- (void)initSongsProgressSliderAndVolumeSliderAndVolumeSwitchAndTimer{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(songsProgressSliderChanged) userInfo:nil repeats:YES];
    
    self.volumeSlider.minimumValue = 0.0f;
    self.volumeSlider.maximumValue = 10.0f;
    self.volumeSlider.value = avAudioPlayer.volume;
    [self.volumeSlider addTarget:self action:@selector(volumeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"soundSlider"] forState:UIControlStateNormal];
    
    //  初始化歌曲进度条
    [self.songsProgressSlider addTarget:self action:@selector(songsProgressSliderChangedTime) forControlEvents:UIControlEventValueChanged];
    [self.songsProgressSlider setThumbImage:[UIImage imageNamed:@"songsProgressSlider"] forState:UIControlStateNormal];
    
    self.volumeSwitch.on = YES;
    [self.volumeSwitch addTarget:self action:@selector(onOrOff:) forControlEvents:UIControlEventValueChanged];
    
    //self.songsDurationTime.text = [[NSString alloc]initWithString:@"12:00"];
    
    //  当前是第几首歌曲初始化
    self.currentMusicNumber = 0;
    
    //
    self.playBt.selected = YES;
    
    // 歌曲持续时间
    NSTimeInterval durationTime = avAudioPlayer.duration;
    
    self.songsDurationTime.text = [[NSString alloc]initWithFormat:@"%02li:%02li",lround(floor(durationTime / 60.)) % 60,lround(floor(durationTime)) % 60];
    
    //  初始化音乐歌词类
    self.musicLyric = [[Lyric alloc]initWithLyricStr:self.songsNameMutArray[self.currentMusicNumber]];

    NSLog(@"%@,===%ld",self.musicLyric.musicTimeMutArray,[self.musicLyric.musicTimeMutArray count]);
//    self.timeCount = 0;
    
    self.lrcLineNumber = 0;
    
}

//  歌曲进度条改变
- (void)songsProgressSliderChanged{
    
    //  歌曲当前时间
    NSTimeInterval currentTime = avAudioPlayer.currentTime;
    
    NSLog(@"====%f",currentTime);
    
    self.songsCurrentTime.text = [[NSString alloc]initWithFormat:@"%02li:%02li",lround(floor(currentTime / 60.)) % 60,lround(floor(currentTime))%60];
    //  设置进度条的改变
    self.songsProgressSlider.value = avAudioPlayer.currentTime/avAudioPlayer.duration;
    
    //  时间计时器变化
//    self.timeCount ++;
    
    //
    [self displaySondWord:currentTime];

    [self.musicLyricTableView reloadData];
    
    //  自动播放下一曲
    if (self.songsProgressSlider.value > 0.999){
        if (self.currentMusicNumber < self.songsNameMutArray.count-1)
        {
            self.currentMusicNumber ++;
            [self whenMusicChanged];
        }

    }
    
}
/**
 *
 *
 *  @return <#return value description#>
 */

//  歌曲音量改变
- (void)volumeSliderChanged{
    avAudioPlayer.volume = self.volumeSlider.value;
}

//  歌曲进度条拖动
- (void)songsProgressSliderChangedTime{
    avAudioPlayer.currentTime = self.songsProgressSlider.value*avAudioPlayer.duration;
    NSLog(@"*****%0.2f",avAudioPlayer.currentTime);
}

//  歌曲音量开关
- (IBAction)onOrOff:(UISwitch *)sender {
    avAudioPlayer.volume = sender.on;
}

//  歌曲播放结束，停止定时器
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    [self.timer invalidate];
}


/**
 *  初始化歌曲名称数组（采用懒加载）
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)songsNameMutArray{
    if (_songsNameMutArray == nil){
        NSString *songsNamePath = [[NSBundle mainBundle] pathForResource:@"songsName" ofType:@"plist"];
        NSArray *songsNameArr = [[NSArray alloc] initWithContentsOfFile:songsNamePath];
        _songsNameMutArray = [[NSMutableArray alloc]initWithArray:songsNameArr];
//        NSLog(@"%@",_songsNameMutArray[self.currentMusicNumber]);
    }
    return _songsNameMutArray;
}
/**
 *  初始化播放器，根据传入的歌曲名，将歌曲添加到播放器中
 *
 *  @param songsName <#songsName description#>
 *  - (void)initMusicPlayer:(Music *)music{}
 */
- (void)initMusicPlayer{
    //  从NSBundle路径读取音频文件。
    NSString *songsFilePath = [[NSBundle mainBundle] pathForResource:self.songsNameMutArray[self.currentMusicNumber] ofType:@"mp3"];
    
    //  将音频文件转化成url格式
    NSURL *songsFileUrl = [NSURL fileURLWithPath:songsFilePath];
    
    //  初始化音频类 并且添加播放文件
    avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:songsFileUrl error:nil];
    //  设置代理
    avAudioPlayer.delegate = self;
    
    //  设置音乐播放次数 -1为循环播放 0为只播放一次
    avAudioPlayer.numberOfLoops = 0;
    
    //  预播放
    [avAudioPlayer prepareToPlay];
    
}
/**
 *  播放音乐
 *
 *  @param sender <#sender description#>
 */
- (IBAction)playBtClick:(id)sender {
    
    if (self.playBt.selected){
        [avAudioPlayer play];
        self.playBt.titleLabel.text = @"play";
        self.playBt.selected = NO;
//        [self.playBt setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        NSLog(@"playing");
//        [self.timer setFireDate:[NSDate date]];
    }else{
        [avAudioPlayer stop];
        self.playBt.titleLabel.text = @"pause";
        self.playBt.selected = YES;
//        [self.playBt setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        NSLog(@"no play");
//        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

/**
 *  下一首
 *
 *  @param sender <#sender description#>
 */
- (IBAction)nextSongBtClick:(id)sender {
    if (self.currentMusicNumber < self.songsNameMutArray.count-1)
    {
        self.currentMusicNumber ++;
//        [self initMusicPlayer];
//        [avAudioPlayer play];
//        self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
        [self whenMusicChanged];
    }
}

/**
 *  上一首
 *
 *  @param sender <#sender description#>
 */
- (IBAction)previousSongBtClick:(id)sender {
    if (self.currentMusicNumber > 0){
        self.currentMusicNumber --;
//        [self initMusicPlayer];
//        [avAudioPlayer play];
//        self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
        [self whenMusicChanged];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//
- (void)whenMusicChanged{
    [self initMusicPlayer];
    self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
    // 歌曲持续改变
    NSTimeInterval durationTime = avAudioPlayer.duration;
    
    self.songsDurationTime.text = [[NSString alloc]initWithFormat:@"%02li:%02li",lround(floor(durationTime / 60.)) % 60,lround(floor(durationTime)) % 60];
    
    //  音乐歌词类改变
    self.musicLyric = [[Lyric alloc]initWithLyricStr:self.songsNameMutArray[self.currentMusicNumber]];
    [self.musicLyricTableView reloadData];
    [avAudioPlayer play];
}

//#pragma mark 动态显示歌词
//- (void)displaySondWord:(NSUInteger)time {
////        NSLog(@"time = %u",time);
//    for (int i = 0; i < [self.musicLyric.musicTimeMutArray count]; i++) {
////        NSLog(@"%@,===%ld",self.musicLyric.musicTimeMutArray[i],[self.musicLyric.musicTimeMutArray count]);
//        NSUInteger numi = i;
//        NSArray *array = [self.musicLyric.musicTimeMutArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
//        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
//        NSLog(@"currentTime === %ld",currentTime);
//        if (i == [self.musicLyric.musicTimeMutArray count]-1) {
//            //求最后一句歌词的时间点
//            NSArray *array1 = [self.musicLyric.musicTimeMutArray[self.musicLyric.musicTimeMutArray.count-1] componentsSeparatedByString:@":"];
//            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
//            if (time > currentTime1) {
//                [self updateLrcTableView:numi];
//                 NSLog(@"====%ld",numi);
//                break;
//            }
//        } else {
//            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
//            NSArray *array2 = [self.musicLyric.musicTimeMutArray[0] componentsSeparatedByString:@":"];
//            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
//            if (time < currentTime2) {
//                [self updateLrcTableView:0];
//                 NSLog(@"====%ld",numi);
//                //                NSLog(@"马上到第一句");
//                break;
//            }
//            //求出下一步的歌词时间点，然后计算区间
//            NSArray *array3 = [self.musicLyric.perLyricTime[i+1] componentsSeparatedByString:@":"];
//            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
//            if (time >= currentTime && time <= currentTime3) {
//                [self updateLrcTableView:numi];
//                NSLog(@"====%ld",numi);
//                break;
//            }
//            
//        }
//    }
//    
//}
#pragma mark 动态显示歌词
- (void)displaySondWord:(NSUInteger)time {
//        NSLog(@"time = %u",time);
    NSInteger countnum = [self.musicLyric.musicTimeMutArray count];
    for (int i = 0; i < [self.musicLyric.musicTimeMutArray count]; i++) {
//        NSLog(@"%@,===%ld",self.musicLyric.musicTimeMutArray[i],[self.musicLyric.musicTimeMutArray count]);
        NSUInteger currentTime = [self.musicLyric.perLyricTime[i] integerValue];
        if (i == [self.musicLyric.musicTimeMutArray count]-1) {
            //求最后一句歌词的时间点
            
            NSUInteger currentTime1 = [self.musicLyric.perLyricTime[countnum-1] integerValue];
            if (time > currentTime1) {
                [self updateLrcTableView:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSUInteger currentTime2 = [self.musicLyric.perLyricTime[0] integerValue];
            if (time < currentTime2) {
                [self updateLrcTableView:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSUInteger currentTime3 = [self.musicLyric.perLyricTime[i+1] integerValue];
            if (time >= currentTime && time <= currentTime3) {
                [self updateLrcTableView:i];
                break;
            }
        }
    }

}


#pragma mark 动态更新歌词表歌词
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    //    NSLog(@"lrc = %@", [LRCDictionary objectForKey:[timeArray objectAtIndex:lineNumber]]);
    //重新载入 歌词列表lrcTabView
    self.lrcLineNumber = lineNumber;
    NSLog(@"======%ld",self.lrcLineNumber);
    [self.musicLyricTableView reloadData];
    //使被选中的行移到中间
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lineNumber inSection:0];
    [self.musicLyricTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
//        NSLog(@"%lu",(unsigned long)lineNumber);
}
/**
 *  歌词只有一个section
 *
 *  @param tableView 歌词的tableView
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.musicLyric.musicLyricMutArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
  //  cell.textLabel.text = self.musicLyric.musicLyricMutArray[indexPath.row];
//    NSLog(@"%d====%d",self.timeCount,[self.musicLyric.perLyricTime[indexPath.row] integerValue]);
//    if (self.timeCount < [self.musicLyric.perLyricTime[indexPath.row] integerValue])
//    {
//
//        cell.textLabel.backgroundColor = [UIColor redColor];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == self.lrcLineNumber ) {
        cell.textLabel.text = self.musicLyric.musicLyricMutArray[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
//        cell.textLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.textLabel.text = self.musicLyric.musicLyricMutArray[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    //        cell.textLabel.textColor = [UIColor blackColor];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    //        [cell.contentView addSubview:lable];//往列表视图里加 label视图，然后自行布局

    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
    [self initMusicPlayer];
    [self initSongsProgressSliderAndVolumeSliderAndVolumeSwitchAndTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
