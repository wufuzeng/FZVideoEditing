//
//  FZVideoClipView.m
//  FZVideoEditing
//
//  Created by 吴福增 on 2019/8/6.
//

#import "FZVideoClipView.h"

#import "FZVideoEditingBundle.h"

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
/**
 *  随机色 0~255
 */
#define kColorRandom [UIColor colorWithRed:arc4random_uniform(255)/255.0 \
green:arc4random_uniform(255)/255.0 \
blue:arc4random_uniform(255)/255.0 \
alpha:1.0]


@interface FZVideoClipDisplayCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView* imageView;

- (void)setContentImage:(UIImage*)image;
@end

@implementation FZVideoClipDisplayCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self imageView];
    }
    return self;
}

-(void)setContentImage:(UIImage *)image{
    self.imageView.image = image;
}

-(UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:00];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.contentView addConstraints:@[top,left,bottom,right]];
    }
    return _imageView;
}

@end


@interface FZSelectedAreaView : UIView

@property (nonatomic,copy) void(^leftPanBlock)(CGFloat value,UIGestureRecognizerState state);
@property (nonatomic,copy) void(^rightPanBlock)(CGFloat value,UIGestureRecognizerState state);
@property (nonatomic,strong) UIPanGestureRecognizer *leftPan;
@property (nonatomic,strong) UIPanGestureRecognizer *rightPan;

@property (nonatomic,strong) UIImageView *leftSilder;

@property (nonatomic,strong) UIImageView *rightSilder;

@end

@implementation FZSelectedAreaView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self leftSilder];
        [self rightSilder];
        [self leftPan];
        [self rightPan];
        
        self.layer.cornerRadius = 10;
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 3;
        self.layer.masksToBounds = YES;
        
        self.leftSilder.layer.borderColor = [UIColor orangeColor].CGColor;
        self.leftSilder.layer.borderWidth = 2;
        
        self.rightSilder.layer.borderColor = [UIColor orangeColor].CGColor;
        self.rightSilder.layer.borderWidth = 2;
        
    }
    return self;
}

-(void)leftPanAction:(UIPanGestureRecognizer *)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:break;
        case UIGestureRecognizerStateChanged:{
        }break;
        case UIGestureRecognizerStateEnded:break;
        default:break;
    }
    CGPoint translation = [sender translationInView:self.superview];
    if (self.leftPanBlock) {
        self.leftPanBlock(translation.x,sender.state);
    }
    [sender setTranslation:CGPointZero inView:self.superview];
}
-(void)rightPanAction:(UIPanGestureRecognizer *)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:break;
        case UIGestureRecognizerStateChanged:{
        }break;
        case UIGestureRecognizerStateEnded:break;
        default:break;
    }
    CGPoint translation = [sender translationInView:self.superview];
    if (self.rightPanBlock) {
        self.rightPanBlock(translation.x,sender.state);
    }
    [sender setTranslation:CGPointZero inView:self.superview];
}

-(UIImageView *)leftSilder{
    if (_leftSilder == nil) {
        _leftSilder = [[UIImageView alloc]init];
        _leftSilder.userInteractionEnabled = YES;
        _leftSilder.contentMode = UIViewContentModeScaleAspectFill;
        _leftSilder.image = [FZVideoEditingBundle fz_imageNamed:@"drag"];
        [self addSubview:_leftSilder];
        _leftSilder.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_leftSilder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_leftSilder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_leftSilder attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_leftSilder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        [self addConstraints:@[top,left,bottom,width]];
    }
    return _leftSilder;
}

-(UIImageView *)rightSilder{
    if (_rightSilder == nil) {
        _rightSilder = [[UIImageView alloc]init];
        _rightSilder.userInteractionEnabled = YES;
        _rightSilder.contentMode = UIViewContentModeScaleAspectFill;
        _rightSilder.image = [FZVideoEditingBundle fz_imageNamed:@"drag"];
        [self addSubview:_rightSilder];
        _rightSilder.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_rightSilder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
       NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_rightSilder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_rightSilder attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_rightSilder attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self addConstraints:@[top,width,bottom,right]];
    }
    return _rightSilder;
}

-(UIPanGestureRecognizer *)leftPan{
    if (_leftPan == nil) {
        _leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanAction:)];
        [_leftPan setMinimumNumberOfTouches:1];
        [_leftPan setEnabled:YES];
        [_leftPan delaysTouchesEnded];
        [_leftPan cancelsTouchesInView];
        [self.leftSilder addGestureRecognizer:_leftPan];
    }
    return _leftPan;
}
-(UIPanGestureRecognizer *)rightPan{
    if (_rightPan == nil) {
        _rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanAction:)];
        [_rightPan setMinimumNumberOfTouches:1];
        [_rightPan setEnabled:YES];
        [_rightPan delaysTouchesEnded];
        [_rightPan cancelsTouchesInView];
        [self.rightSilder addGestureRecognizer:_rightPan];
    }
    return _rightPan;
}
@end

@interface FZVideoClipView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>


@property (nonatomic,strong) UIView *leftMaskView;
@property (nonatomic,strong) FZSelectedAreaView *selectedAreaView;
@property (nonatomic,strong) UIView *rightMaskView;
@property (nonatomic,strong) NSLayoutConstraint *selectedAreaLayoutLeft;
@property (nonatomic,strong) NSLayoutConstraint *selectedAreaLayoutRight;
@end

@implementation FZVideoClipView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self collectionView];
        [self leftMaskView];
        [self rightMaskView];
        [self selectedAreaView];
    }
    return self;
}

#pragma mark -- UICollectionViewDataSource --

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (FZVideoClipDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FZVideoClipDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImage* image = self.images[indexPath.row];
    [cell setContentImage:image];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    return nil;
}

#pragma mark -- UICollectionViewDelegate --

#pragma mark -- UICollectionViewDelegateFlowLayout --

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.frame.size.width/(self.images.count?:1), self.frame.size.height);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}




#pragma mark -- Lazy Func --

-(UICollectionView *)collectionView{
    
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal; 
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.layer.borderColor = [UIColor whiteColor].CGColor;
        _collectionView.layer.borderWidth = 1;
        _collectionView.layer.masksToBounds = YES;
        
        [_collectionView registerClass:[FZVideoClipDisplayCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        [_collectionView registerClass:[UICollectionElementKindSectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        
        [self addSubview:_collectionView];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
        [self addConstraints:@[top,left,bottom,right]];
        
    }
    return _collectionView;
}

-(NSMutableArray *)images{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}
-(UIView *)leftMaskView{
    if (_leftMaskView == nil) {
        _leftMaskView = [UIView new];
        _leftMaskView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        [self addSubview:_leftMaskView];
        _leftMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_leftMaskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_leftMaskView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_leftMaskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_leftMaskView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.selectedAreaView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
        [self addConstraints:@[top,left,bottom,right]];
    }
    return _leftMaskView;
}
-(FZSelectedAreaView *)selectedAreaView{
    if (_selectedAreaView == nil) {
        _selectedAreaView = [[FZSelectedAreaView alloc]init];
        _selectedAreaView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_selectedAreaView];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_selectedAreaView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_selectedAreaView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        self.selectedAreaLayoutLeft = left;
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_selectedAreaView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_selectedAreaView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        self.selectedAreaLayoutRight = right;
        [self addConstraints:@[top,left,bottom,right]];
        
        __weak __typeof(self) weakSelf = self;
        _selectedAreaView.leftPanBlock = ^(CGFloat value,UIGestureRecognizerState state) {
            CGRect frame = weakSelf.selectedAreaView.frame;
            CGFloat minX = CGRectGetMinX(frame);
            CGFloat sliderWidth = 20;
            weakSelf.selectedAreaLayoutLeft.constant += value;
            if (frame.size.width < 60 && value > 0){
                weakSelf.selectedAreaLayoutLeft.constant = minX;
            }
            if (weakSelf.selectedAreaLayoutLeft.constant < 0) {
                weakSelf.selectedAreaLayoutLeft.constant = 0;
            }
            CGFloat begin = ((CGRectGetMinX(frame) + sliderWidth) - CGRectGetMinX(weakSelf.collectionView.frame))/CGRectGetWidth(weakSelf.collectionView.frame)*1.0;
            
            if ([weakSelf.delegate respondsToSelector:@selector(clipView:begin:isOver:)]) {
                [weakSelf.delegate clipView:weakSelf begin:begin isOver:state == UIGestureRecognizerStateEnded];
            }
        };
        _selectedAreaView.rightPanBlock = ^(CGFloat value,UIGestureRecognizerState state) {
            CGRect frame = weakSelf.selectedAreaView.frame;
            CGFloat maX = CGRectGetMaxX(frame);
            CGFloat sliderWidth = 20;
            weakSelf.selectedAreaLayoutRight.constant += value;
            if (frame.size.width < 60 && value < 0){
                weakSelf.selectedAreaLayoutRight.constant = -(weakSelf.frame.size.width-maX);
            }
            if (weakSelf.selectedAreaLayoutRight.constant > 0) {
                weakSelf.selectedAreaLayoutRight.constant = 0;
            }
            CGFloat begin = ((CGRectGetMinX(frame) + sliderWidth) - CGRectGetMinX(weakSelf.collectionView.frame))/CGRectGetWidth(weakSelf.collectionView.frame)*1.0;
            
            CGFloat end = ((CGRectGetMaxX(frame) - sliderWidth) - CGRectGetMinX(weakSelf.collectionView.frame))/CGRectGetWidth(weakSelf.collectionView.frame)*1.0;
            
            if ([weakSelf.delegate respondsToSelector:@selector(clipView:end:isOver:)]) {
                [weakSelf.delegate clipView:weakSelf end:end isOver:state == UIGestureRecognizerStateEnded];
            }
        };
    }
    return _selectedAreaView;
}
-(UIView *)rightMaskView{
    if (_rightMaskView == nil) {
        _rightMaskView = [UIView new];
        _rightMaskView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        //[self addSubview:_rightMaskView];
        [self insertSubview:_rightMaskView belowSubview:self.selectedAreaView];
        _rightMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_rightMaskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:_rightMaskView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.selectedAreaView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_rightMaskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:_rightMaskView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self addConstraints:@[top,left,bottom,right]];
    }
    return _leftMaskView;
}
@end
