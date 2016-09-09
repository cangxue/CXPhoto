//
//  CropImageViewController.h
//  ImageTailor
//
//  Created by yinyu on 15/10/10.
//  Copyright © 2015年 yinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BBimageEditBlock) (UIImage *editedImage);
@interface CropImageViewController : UIViewController

+ (instancetype)getCropImageWithImage:(UIImage *)image;
@property (nonatomic,copy) BBimageEditBlock imageEditBlock;
//@property (nonatomic, copy) void (^CropImageBlock)(UIImage *cropedImage);
//
@end
