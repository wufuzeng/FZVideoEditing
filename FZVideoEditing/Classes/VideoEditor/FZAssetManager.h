//
//  FZAssetManager.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^AuthBlock)(AVAuthorizationStatus cerma,PHAuthorizationStatus photos ,AVAuthorizationStatus alumb,NSInteger isShowAuthView);

@class AVAsset;

@interface FZAssetManager : NSObject

#pragma mark -- 验证是否具有媒体权限
+ (BOOL)cameraAuthorized;
+ (BOOL)microPhoneAuthorized;
+ (BOOL)albumAuthorized;

#pragma mark -- 请求媒体权限
+ (void)requestCameraAuth:(void(^)(BOOL granted))authorized;
+ (void)requestMicroPhoneAuth:(void(^)(BOOL granted))authorized;
+ (void)requestAlbumAuth:(void(^)(BOOL granted))authorized;

#pragma mark -- 保存视频到指定相册
+ (void)saveVideo:(NSString *)videoUrl toAlbum:(NSString *)albumName completion:(void (^)(NSURL* url, NSError* error))block;

#pragma mark -- 打印媒体信息
/*you can check the class 'FZMediaInfo' for the log information*/
+ (void)printMediaInfoWithAsset:(AVAsset*)asset;

#pragma mark -- 打印图片头EXIF信息


@end

NS_ASSUME_NONNULL_END
