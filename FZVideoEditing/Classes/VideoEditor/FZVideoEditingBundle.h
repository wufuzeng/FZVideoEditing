//
//  FZVideoEditingBundle.h
//  FZVideoEditing
//
//  Created by 吴福增 on 2019/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZVideoEditingBundle : NSBundle

+ (UIImage *)fz_imageNamed:(NSString *)name;

+ (UIImage *)fz_imageNamed:(NSString *)name ofType:(nullable NSString *)type;

+ (NSString *)fz_localizedStringForKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
