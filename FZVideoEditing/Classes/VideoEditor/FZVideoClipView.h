//
//  FZVideoClipView.h
//  FZVideoEditing
//
//  Created by 吴福增 on 2019/8/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FZVideoClipView;

@protocol FZVideoClipViewDelegate <NSObject>

-(void)clipView:(FZVideoClipView *)clipView begin:(CGFloat)begain isOver:(BOOL)isOver;

-(void)clipView:(FZVideoClipView *)clipView end:(CGFloat)end isOver:(BOOL)isOver;

@end
@interface FZVideoClipView : UIView
@property (nonatomic,weak) id<FZVideoClipViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* images;

@end

NS_ASSUME_NONNULL_END
