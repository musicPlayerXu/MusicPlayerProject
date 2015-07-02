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

@interface MusicPlayerViewController ()<AVAudioPlayerDelegate,UITableViewDataSource,UITabBarDelegate>
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

@property (strong, nonatomic) Lyric *musicLyric;

@end



@implementation MusicPlayerViewController

/**
 *  初始化定时器（控制歌曲进度条），声音进度条，声音开关,歌曲现在时间和歌曲持续时间
 */
- (void)initSongsProgressViewAndVolumeSliderAndVolumeSwitchAndTimer{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(songsProgressViewChanged) userInfo:nil repeats:YES];
    
    self.volumeSlider.minimumValue = 0.0f;
    self.volumeSlider.maximumValue = 10.0f;
    self.volumeSlider.value = avAudioPlayer.volume;
    [self.volumeSlider addTarget:self action:@selector(volumeSliderChanged) forControlEvents:UIControlEventValueChanged];
    
    self.volumeSwitch.on = YES;
    [self.volumeSwitch addTarget:self action:@selector(onOrOff:) forControlEvents:UIControlEventValueChanged];
    
    // 歌曲持续时间初始化
    NSTimeInterval durationTime = avAudioPlayer.duration;
    
    self.songsDurationTime.text = [[NSString alloc]initWithFormat:@"%02li:%02li",lround(floor(durationTime / 60.)) % 60,lround(floor(durationTime)) % 60];
    
    //  当前是第几首歌曲初始化
    self.currentMusicNumber = 0;
    
    //
    self.playBt.selected = YES;
    
    //  初始化音乐歌词类
    self.musicLyric = [[Lyric alloc]initWithLyricStr:self.songsNameMutArray[self.currentMusicNumber]];
    
}

//  歌曲进度条改变
- (void)songsProgressViewChanged{
    
    NSTimeInterval currentTime = avAudioPlayer.currentTime;
    
    self.songsCurrentTime.text = [[NSString alloc]initWithFormat:@"%02li:%02li",lround(floor(currentTime / 60.)) % 60,lround(floor(currentTime))%60];
    
    self.songsProgressView.progress = avAudioPlayer.currentTime/avAudioPlayer.duration;
}

//  歌曲音量改变
- (void)volumeSliderChanged{
    avAudioPlayer.volume = self.volumeSlider.value;
}

//  歌曲音量开关
- (IBAction)onOrOff:(UISwitch *)sender {
    avAudioPlayer.volume = sender.on;
}

//  歌曲播放结束，停止定时器
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.timer invalidate];
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
        NSLog(@"%@",_songsNameMutArray[self.currentMusicNumber]);
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
    
    //  设置音乐播放次数 -1为循环播放
    avAudioPlayer.numberOfLoops = -1;
    
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
    }else{
        [avAudioPlayer stop];
        self.playBt.titleLabel.text = @"pause";
        self.playBt.selected = YES;
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
        [self initMusicPlayer];
        [avAudioPlayer play];
        self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
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
        [self initMusicPlayer];
        [avAudioPlayer play];
        self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

/**
 *  歌词只有一个部分
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
    
    cell.textLabel.text = self.musicLyric.musicLyricMutArray[indexPath.row];
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.songsList.text = self.songsNameMutArray[self.currentMusicNumber];
    [self initMusicPlayer];
    [self initSongsProgressViewAndVolumeSliderAndVolumeSwitchAndTimer];
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
