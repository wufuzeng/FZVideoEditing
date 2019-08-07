//
//  FZVideoDisplayView.h
//  FZVideoEditing
//
//  Created by 吴福增 on 2019/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FZVideoDisplayView;
@protocol FZVideoDisplayViewDelegate <NSObject>
- (void)displayView:(FZVideoDisplayView *)displayView scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)displayView:(FZVideoDisplayView *)displayView scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)displayView:(FZVideoDisplayView *)displayView scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
@interface FZVideoDisplayView : UIView
@property (nonatomic,weak) id<FZVideoDisplayViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* images;
@end

NS_ASSUME_NONNULL_END
