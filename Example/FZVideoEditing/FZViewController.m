//
//  FZViewController.m
//  FZVideoEditing
//
//  Created by wufuzeng on 08/06/2019.
//  Copyright (c) 2019 wufuzeng. All rights reserved.
//

#import "FZViewController.h"
#import "FZVideoEditing.h"


#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
 
@interface FZViewController ()
<
FZVideoPlayerViewDelegate,
FZVideoClipViewDelegate,
FZVideoDisplayViewDelegate
>

@property (nonatomic,strong) FZVideoPlayerView* player;
@property (nonatomic,strong) FZVideoEditor* videoEditor;
@property (nonatomic,strong) FZVideoDisplayView *displayView;
@property (nonatomic,strong) FZVideoClipView *videoClipView;

@property (nonatomic,strong) NSMutableArray* images;
@property (nonatomic,strong) NSMutableArray* videoQueue;

@property (nonatomic,assign) CGFloat beginProgress;
@property (nonatomic,assign) CGFloat endProgress;

@property (nonatomic,strong) UIButton *btn_back;
@property (nonatomic,strong) UIButton *btn_more;

@property (nonatomic,assign) BOOL isDragging;

@end

@implementation FZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
 
    [self player];
    [self videoClipView];
    [self displayView];
    [self btn_back];
    [self btn_more];
    [self.player play];
}

#pragma mark -- Button Action --
-(void)backAction:(UIButton *)sender{
    [self.player destroy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)moreAction:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"more" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"添加背景音乐" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [self.videoEditor addMusicToAsset:self.asset completion:^(FZAVCommand *avCommand) {
            [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"添加水印" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [self.videoEditor addWatermark:FZWatermarkTypeImage inAsset:self.asset completion:^(FZAVCommand *avCommand) {
            //we have to create a layer manually added to the playerview, otherwise it will not show
            [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"导出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[self.videoEditor exportAsset:self.asset];
        CGFloat assetTimeLong = CMTimeGetSeconds(self.asset.duration);
        CGFloat beginTime = assetTimeLong * self.beginProgress;
        CGFloat endTime = assetTimeLong * self.endProgress;
        [self.videoEditor exportClipAsset:self.asset startTime:beginTime endTime:endTime completedHandler:^(NSString * _Nonnull path) {
            
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}



#pragma mark -- FZVideoPlayerDelegate

/** 播放进度 */
- (void)player:(FZVideoPlayerView *)player didPlayedToTime:(CMTime)time{
    if (self.player.playerState == FZPlayerStatePlaying) {
        CGFloat currentTime = time.value*1.0/time.timescale;
        CGFloat timeLong = self.asset.duration.value*1.0/self.asset.duration.timescale;
        
        if (timeLong == 0 || isnan(timeLong)) {
            timeLong = 1;
        }
        
        CGFloat beginTime = timeLong * self.beginProgress;
        CGFloat endTime = timeLong * self.endProgress;
        
        if (currentTime >= endTime ||
            currentTime >= timeLong) {
            [self.player seekToTime:CMTimeMakeWithSeconds(beginTime, NSEC_PER_SEC)];
            CGFloat offsetX = self.displayView.collectionView.contentSize.width * beginTime/timeLong - CGRectGetWidth(self.displayView.collectionView.frame) /2.0;
            [self.displayView.collectionView setContentOffset:CGPointMake(offsetX, 0)];
        }else{
            CGFloat offsetX = self.displayView.collectionView.contentSize.width * currentTime/timeLong - CGRectGetWidth(self.displayView.collectionView.frame) /2.0;
            [self.displayView.collectionView setContentOffset:CGPointMake(offsetX, 0)];
        }
        
        
    }
}

/** 准备播放 */
- (void)player:(FZVideoPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index{
    // we need to get all images of the video to played
    AVAsset* asset = [self.videoQueue objectAtIndex:index];
    self.asset = asset;
    [self.images removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    [self.videoEditor frameImagesWithAsset:asset count:10 completion:^(NSArray<UIImage *> * _Nonnull images) {
        weakSelf.videoClipView.images = images;
        [weakSelf.videoClipView.collectionView reloadData];
    }];
    
    [self.videoEditor frameImagesWithAsset:self.asset count:0 completion:^(NSArray<UIImage *> * _Nonnull images) {
        weakSelf.displayView.images = images;
        [weakSelf.displayView.collectionView reloadData];
    }];
    
//    [self.videoEditor centerFrameImageWithAsset:asset completion:^(UIImage *image) {
//
//        [self.images addObject:image];
//        self.displayView.images = self.images;
//        [self.displayView.collectionView reloadData];
//    }];
}

#pragma mark –- FZVideoClipViewDelegate --
-(void)clipView:(FZVideoClipView *)clipView begin:(CGFloat)begain isOver:(BOOL)isOver{
    self.beginProgress = begain;
    self.isDragging = !isOver;
    CGFloat assetTimeLong = CMTimeGetSeconds(self.asset.duration);
    CGFloat beginTime = assetTimeLong * self.beginProgress;
    [self.player seekToSeconds:beginTime isPlay:isOver];
}
-(void)clipView:(FZVideoClipView *)clipView end:(CGFloat)end isOver:(BOOL)isOver{
    self.endProgress = end;
    self.isDragging = !isOver;
    CGFloat assetTimeLong = CMTimeGetSeconds(self.asset.duration);
    CGFloat beginTime = assetTimeLong * self.beginProgress;
    CGFloat endTime = assetTimeLong * self.endProgress;
    [self.player seekToSeconds:isOver?beginTime:endTime isPlay:isOver];
}
#pragma mark –- FZVideoDisplayViewDelegate --

- (void)displayView:(FZVideoDisplayView *)displayView scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.player.playerState == FZPlayerStateStop) {
        
        CGPoint offset = scrollView.contentOffset;
        CGFloat timeLong = CMTimeGetSeconds(self.asset.duration);
        NSTimeInterval seconds =  offset.x * timeLong / displayView.collectionView.contentSize.width;
        
        CGFloat beginTime = timeLong * self.beginProgress;
        CGFloat endTime = timeLong * self.endProgress;
        
        if (seconds <= beginTime ||
            seconds >= endTime) { 
            [self.player seekToTime:CMTimeMakeWithSeconds(beginTime, NSEC_PER_SEC)];
        }
    }
}

- (void)displayView:(FZVideoDisplayView *)displayView scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.player pause];
}

- (void)displayView:(FZVideoDisplayView *)displayView scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.player play];
}


#pragma mark -- Lazy Func --

-(FZVideoPlayerView *)player{
    if (_player == nil) {
        _player = [[FZVideoPlayerView alloc] init];
        _player.isUsingRemoteCommand = YES;
        _player.singleCirclePlay = NO;
        _player.delegate = self;
        _player.videoQueue = self.videoQueue;
        [self.view addSubview:_player];
        _player.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_player attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:64];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_player attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_player attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_player attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
       
        [self.view addConstraints:@[top,left,bottom,right]];
    }
    return _player;
}

-(FZVideoDisplayView *)displayView{
    if (_displayView == nil) {
        _displayView = [[FZVideoDisplayView alloc]init];
        _displayView.delegate = self;
        _displayView.layer.borderColor = [UIColor whiteColor].CGColor;
        _displayView.layer.borderWidth = 1;
        _displayView.layer.masksToBounds = YES;
        [self.view addSubview:_displayView];
        _displayView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_displayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_displayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.videoClipView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_displayView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_displayView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:85];
        [self.view addConstraints:@[left,bottom,right,height]];
    }
    return _displayView;
}

-(FZVideoClipView *)videoClipView{
    if (_videoClipView == nil) {
        _videoClipView = [[FZVideoClipView alloc]init];
        _videoClipView.delegate = self;
        [self.view addSubview:_videoClipView];
        _videoClipView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_videoClipView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_videoClipView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-30];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_videoClipView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_videoClipView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
        [self.view addConstraints:@[left,bottom,right,height]];
    }
    return _videoClipView;
}

-(UIButton *)btn_back{
    if (_btn_back == nil) {
        _btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_back.frame = CGRectMake(15, 10, 45, 20);
        [_btn_back setTitle:@"back" forState:UIControlStateNormal];
        [_btn_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn_back addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btn_back];
    }
    return _btn_back;
}

-(UIButton *)btn_more{
    if (_btn_more == nil) {
        _btn_more = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_more.frame = CGRectMake(KScreenWidth - 45 - 15, 10, 45, 20);
        [_btn_more setTitle:@"more" forState:UIControlStateNormal];
        [_btn_more setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn_more addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btn_more];
    }
    return _btn_more;
}

-(NSMutableArray *)videoQueue{
    if (_videoQueue == nil) {
        _videoQueue = [NSMutableArray array];
        
//        NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
//        AVAsset* asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:firstVideoPath]] ;
        
//        NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
//        AVAsset* asset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideoPath] options:nil];
//
//        NSString *thirdVideoPath = [[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp4"];
//        AVAsset* asset3 = [AVAsset assetWithURL:[NSURL fileURLWithPath:thirdVideoPath]] ;

        NSString *fourVideoPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"mov"];
        AVAsset* asset4 = [AVAsset assetWithURL:[NSURL fileURLWithPath:fourVideoPath]] ;
        
//        [_videoQueue addObject:asset1];
//        [_videoQueue addObject:asset2];
//        [_videoQueue addObject:asset3];
        [_videoQueue addObject:asset4];
    }
    return _videoQueue;
}

-(NSMutableArray *)images{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}

-(FZVideoEditor *)videoEditor{
    if (_videoEditor == nil) {
        _videoEditor = [[FZVideoEditor alloc] init];
    }
    return _videoEditor;
}



-(CGFloat)endProgress{
    if (_endProgress <= 0) {
        _endProgress = 1;
    }
    return _endProgress;
}

- (void)dealloc{
    NSLog(@"-- video editor view controller dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
