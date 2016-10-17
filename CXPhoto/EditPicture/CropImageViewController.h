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

@property (nonatomic,copy) BBimageEditBlock imageEditBlock;

+ (instancetype)getCropImageWithImage:(UIImage *)image;

@property (strong, nonatomic) UIImage *image;

@end
