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

@interface FZDisplayCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView* imageView;

- (void)setContentImage:(UIImage*)image;
@end

@implementation FZDisplayCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)setContentImage:(UIImage *)image{
    self.imageView.image = image;
}

@end

@interface FZViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
FZVideoPlayerViewDelegate
>
@property (nonatomic, strong) FZVideoPlayerView* player;
@property (nonatomic, strong) FZVideoEditor* videoEditor;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* images;

@property (nonatomic, strong) NSMutableArray* videoQueue;

@property (nonatomic,strong) FZVideoClipView *videoClipView;

@end

@implementation FZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.images = [NSMutableArray array];
    self.videoEditor = [[FZVideoEditor alloc] init];
    
    //    self.player = [[FZVideoPlayerView alloc] initWithAsset:self.asset frame:CGRectMake(0, 40, KScreenWidth, KScreenWidth)];
    
    NSMutableArray* videoQueue = [NSMutableArray array];
    self.videoQueue = videoQueue;
    NSString *firstVideoPath = [[NSBundle mainBundle] pathForResource:@"nnn" ofType:@"mp4"];
    AVAsset* asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:firstVideoPath]] ;
    
    NSString *secondVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    AVAsset* asset2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:secondVideoPath] options:nil];
    
    NSString *thirdVideoPath = [[NSBundle mainBundle] pathForResource:@"dance" ofType:@"mp4"];
    AVAsset* asset3 = [AVAsset assetWithURL:[NSURL fileURLWithPath:thirdVideoPath]] ;
    
    [videoQueue addObject:asset1];
    [videoQueue addObject:asset2];
    [videoQueue addObject:asset3];
    
    self.player = [[FZVideoPlayerView alloc] initWithVideoQueue:videoQueue frame:CGRectMake(0, 40, KScreenWidth, KScreenWidth)];
    
    self.player.isUsingRemoteCommand = YES;
    self.player.singleCirclePlay = NO;
    self.player.delegate = self;
    [self.view addSubview:self.player];
    [self.player play];
    
    
    self.videoClipView = [[FZVideoClipView alloc]initWithFrame:CGRectMake(0, 300, KScreenWidth, 60)];
    [self.view addSubview:self.videoClipView];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(85, 85);
    flowLayout.headerReferenceSize = CGSizeMake(KScreenWidth/2+1, 85);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-1, KScreenWidth+60+10, KScreenWidth+2, 85) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.layer.masksToBounds = YES;
    
    [self.collectionView registerClass:[FZDisplayCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeaderView"];
    [self.collectionView registerClass:[UICollectionElementKindSectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"collectionFooterView"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth/2-1, self.collectionView.frame.origin.y, 2, self.collectionView.frame.size.height)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    UIButton* addMusicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMusicBtn.frame = CGRectMake(35, KScreenHeight - 90, 100, 45);
    [addMusicBtn setTitle:@"add music" forState:UIControlStateNormal];
    [addMusicBtn addTarget:self action:@selector(addMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addMusicBtn];
    
    UIButton* addWatermarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addWatermarkBtn.frame = CGRectMake(170, KScreenHeight - 90, 45, 45);
    [addWatermarkBtn setTitle:@"水印" forState:UIControlStateNormal];
    [addWatermarkBtn addTarget:self action:@selector(addWatermark) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addWatermarkBtn];
    
    UIButton* exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exportBtn.frame = CGRectMake(KScreenWidth - 135, KScreenHeight - 90, 100, 45);
    [exportBtn setTitle:@"export" forState:UIControlStateNormal];
    [exportBtn addTarget:self action:@selector(export) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportBtn];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 10, 45, 20);
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
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
        [self.collectionView setContentOffset:CGPointMake(85*self.images.count*currentTime/timeLong, 0)];
    }
}

/** 准备播放 */
- (void)player:(FZVideoPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index{
    // we need to get all images of the video to played
    AVAsset* asset = [self.videoQueue objectAtIndex:index];
    self.asset = asset;
    [self.images removeAllObjects];
    [self.videoEditor centerFrameImageWithAsset:asset completion:^(UIImage *image) {
        [self.images addObject:image];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (FZDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FZDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImage* image = self.images[indexPath.row];
    [cell setContentImage:image];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeaderView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"collectionFooterView" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.player.playerState == FZPlayerStateStop) {
        CGPoint offset = scrollView.contentOffset;
        NSTimeInterval seconds =  offset.x*CMTimeGetSeconds(self.asset.duration)/(85*self.images.count);
        CMTime seekTime = CMTimeMakeWithSeconds(seconds, self.player.currentPlayItem.duration.timescale);
        [self.player seekToTime:seekTime];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.player pause];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.player play];
}

- (void)addMusic{
    __weak typeof(self) weakSelf = self;
    [self.videoEditor addMusicToAsset:self.asset completion:^(FZAVCommand *avCommand) {
        [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)addWatermark{
    __weak typeof(self) weakSelf = self;
    [self.videoEditor addWatermark:FZWatermarkTypeImage inAsset:self.asset completion:^(FZAVCommand *avCommand) {
        //we have to create a layer manually added to the playerview, otherwise it will not show
        [weakSelf.player replaceItemWithAsset:avCommand.mutableComposition];
    }];
}

- (void)export{
    [self.videoEditor exportAsset:self.asset];
}

- (void)back{
    [self.player destroy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc{
    NSLog(@"-- video editor view controller dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
