//
//  UIImage+Handler.m
//  ImageTailor
//
//  Created by yinyu on 15/10/10.
//  Copyright © 2015年 yinyu. All rights reserved.
//

#import "UIImage+Handler.h"

@implementation UIImage(Handler)
- (UIImage *)imageAtRect:(CGRect)rect
{
    // 截图 : 根据rect和image的size 截图图片
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
}

@end
