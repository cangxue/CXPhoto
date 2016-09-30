//
//  CropImageViewController.m
//  ImageTailor
//
//  Created by yinyu on 15/10/10.
//  Copyright © 2015年 yinyu. All rights reserved.
//


#import "CropImageViewController.h"
#import "UIImage+Handler.h"
#import <QuartzCore/QuartzCore.h>//导入框架

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define CROPPROPORTIONIMAGEWIDTH 30.0f
#define CROPPROPORTIONIMAGESPACE 48.0f
#define CROPPROPORTIONIMAGEPADDING 20.0f
//箭头的宽度
#define ARROWWIDTH 25
//箭头的高度
#define ARROWHEIGHT 22
//两个相邻箭头之间的最短距离
#define ARROWMINIMUMSPACE 20
//箭头单边的宽度
#define ARROWBORDERWIDTH 2
//imageview的左右缩进
#define PADDING 8

@interface CropImageViewController () <UIGestureRecognizerDelegate>
{
    
    //记录左上角箭头移动的起始位置
    CGPoint _startPoint1;
    //记录右上角箭头移动的起始位置
    CGPoint _startPoint2;
    //记录左下角箭头移动的起始位置
    CGPoint _startPoint3;
    //记录右下角箭头移动的起始位置
    CGPoint _startPoint4;
    //记录透明区域移动的起始位置
    CGPoint _startPointCropView;
    
    CGFloat _imageScale;
    
    //存储不同缩放比例示意图的图片名
    NSArray *_proportionImageNameArr;
    //存储不同缩放比例示意图的高亮图片名
    NSArray *_proportionImageNameHLArr;
    //存储不同缩放比例
    NSArray *_proportionArr;
    //存储不同缩放比例的按钮
    NSMutableArray *_proportionBtnArr;
    //当前选择的缩放比例
    CGFloat _currentProportion;
    //当前待裁剪图片的高宽比
    CGFloat _imageHWFactor;
    
    
    //当前屏幕高宽比例
    CGFloat _viewHWFactor;
    
    //有效图片宽高
    CGFloat _holderWidth;
    CGFloat _holderHeight;
    
    //当前cropView宽高
    CGFloat _cropViewWidth;
    CGFloat _cropViewHeight;
    
}
//待裁剪图片的ImageView
@property (weak, nonatomic) IBOutlet UIImageView *imageHolderView;
//黑色蒙板
@property (strong, nonatomic) UIView *cropMaskView;
//左上角箭头
@property (strong, nonatomic) UIImageView *arrow1;
//右上角箭头
@property (strong, nonatomic) UIImageView *arrow2;
//左下角箭头
@property (strong, nonatomic) UIImageView *arrow3;
//右下角箭头
@property (strong, nonatomic) UIImageView *arrow4;
//透明区域的视图
@property (strong, nonatomic) UIImageView *cropView;

//手势

@property (strong, nonatomic) UIPanGestureRecognizer *cropViewGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *arrow1Gesture;
@property (strong, nonatomic) UIPanGestureRecognizer *arrow2Gesture;
@property (strong, nonatomic) UIPanGestureRecognizer *arrow3Gesture;
@property (strong, nonatomic) UIPanGestureRecognizer *arrow4Gesture;


@end


static UIImage *_myImage;

@implementation CropImageViewController
+ (instancetype)getCropImageWithImage:(UIImage *)image{

    CropImageViewController *cropImageViewController = [[CropImageViewController alloc] initWithNibName:@"CropImageViewController" bundle:nil];
    
    _myImage = image;
    
    return cropImageViewController;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _currentProportion = 0;
    
    _viewHWFactor = SCREENHEIGHT/SCREENWIDTH;
    
    _imageHWFactor = _myImage.size.height/_myImage.size.width;
    
    self.imageHolderView.image = _myImage;
    
    [self setSubviews];
    
    [self loadImage];
    
}

- (void)layoutSubViews:(BOOL)animated {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

/**
 *加载image并根据image的尺寸重新设置imageview的尺寸，取到image的缩放比
 */
- (void)loadImage {
    
    CGRect frame = self.cropView.frame;
    if(_imageHWFactor <= _viewHWFactor) {//宽大于高
        if (_myImage.size.width < SCREENWIDTH) {
            _imageScale = 1;
            frame.size.height = _myImage.size.height;
            frame.size.width = frame.size.height * 3 / 4;
            _holderWidth = _myImage.size.width;
            _holderHeight = _myImage.size.height;
        } else {
            _imageScale = _myImage.size.width / SCREENWIDTH;
            frame.size.height = SCREENWIDTH *_imageHWFactor;
            frame.size.width = frame.size.height * 3 / 4;
            _holderWidth = SCREENWIDTH;
            _holderHeight = frame.size.height;
        }
        
    } else {
        if (_myImage.size.height < SCREENHEIGHT) {
            _imageScale = 1;
            frame.size.width = _myImage.size.width;
            frame.size.height = frame.size.width * 4 / 3;
            _holderWidth = _myImage.size.width;
            _holderHeight = _myImage.size.height;
        } else {
            _imageScale = _myImage.size.height / SCREENHEIGHT;
            frame.size.width = SCREENHEIGHT /_imageHWFactor;
            frame.size.height = frame.size.width * 4 / 3;
            
            _holderWidth = frame.size.width;
            _holderHeight = SCREENHEIGHT;
        }
    }
    
    frame.origin.x = (_holderWidth - frame.size.width)/2;
    frame.origin.y = (_holderHeight - frame.size.height)/2;
    
    self.cropView.frame = frame;
    
    CGRect maskframe = self.cropMaskView.frame;
    maskframe.size.width = _holderWidth;
    maskframe.size.height = _holderHeight;
    maskframe.origin.x = (SCREENWIDTH - _holderWidth)/2;
    maskframe.origin.y = (SCREENHEIGHT - _holderHeight)/2;
    self.cropMaskView.frame = maskframe;
    
    [self resetCropMask];
    [self resetAllArrows];
    
//    _cropViewWidth = self.cropView.frame.size.width;
//    _cropViewHeight = self.cropView.frame.size.height;

}

/**
 *根据当前裁剪区域的位置和尺寸将黑色蒙板的相应区域抠成透明
 */

- (void)resetCropMask {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: self.cropMaskView.bounds];
    CGFloat x = CGRectGetMinX(self.cropView.frame);
    CGFloat y =  CGRectGetMinY(self.cropView.frame);
    CGFloat width = CGRectGetWidth(self.cropView.frame);
    CGFloat height = CGRectGetHeight(self.cropView.frame);
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: CGRectMake(x, y, width, height)] bezierPathByReversingPath];
    [path appendPath: clearPath];
    
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [self.cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;
    
//     NSLog(@"cropView witdth=%f  cropView height=%f",self.cropView.frame.size.width, self.cropView.frame.size.height);
}

/**
 *移动裁剪区域的手势处理
 */
- (void)moveCropView:(UIPanGestureRecognizer *)panGesture {
    [self resetCropView];
    
    CGFloat minX = 0;
    CGFloat maxX = _holderWidth - CGRectGetWidth(self.cropView.frame);
    CGFloat minY = 0;
    CGFloat maxY = _holderHeight - CGRectGetHeight(self.cropView.frame);

    if(panGesture.state == UIGestureRecognizerStateBegan) {
        _startPointCropView = [panGesture locationInView:self.cropMaskView];
        self.arrow1.userInteractionEnabled = NO;
        self.arrow2.userInteractionEnabled = NO;
        self.arrow3.userInteractionEnabled = NO;
        self.arrow4.userInteractionEnabled = NO;
    }
    else if(panGesture.state == UIGestureRecognizerStateEnded) {
        self.arrow1.userInteractionEnabled = YES;
        self.arrow2.userInteractionEnabled = YES;
        self.arrow3.userInteractionEnabled = YES;
        self.arrow4.userInteractionEnabled = YES;
    }
    else if(panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint endPoint = [panGesture locationInView:self.cropMaskView];
        CGRect frame = panGesture.view.frame;
        frame.origin.x += endPoint.x - _startPointCropView.x;
        frame.origin.y += endPoint.y - _startPointCropView.y;
        frame.origin.x = MIN(maxX, MAX(frame.origin.x, minX));
        frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
        panGesture.view.frame = frame;
        _startPointCropView = endPoint;
    }
    
    [self resetCropMask];
    [self resetAllArrows];
}

/**
 *移动四个箭头的手势处理
 */
- (void)moveCorner:(UIPanGestureRecognizer *)panGesture {
    CGPoint *startPoint = NULL;
    CGFloat minX = - ARROWBORDERWIDTH;
    CGFloat maxX = _holderWidth - ARROWWIDTH + ARROWBORDERWIDTH;
    CGFloat minY = - ARROWBORDERWIDTH;
    CGFloat maxY = _holderHeight - ARROWHEIGHT + ARROWBORDERWIDTH;
    
    NSLog(@"minX=%f  maxX=%f  minY=%f  maxY%f",minX,maxY,minY,maxY);
    
    if(panGesture.view == self.arrow1) {
        startPoint = &_startPoint1;
        maxY = CGRectGetMinY(self.arrow3.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
        maxX = CGRectGetMinX(self.arrow2.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
    }
    else if(panGesture.view == self.arrow2) {
        startPoint = &_startPoint2;
        maxY = CGRectGetMinY(self.arrow4.frame) - ARROWHEIGHT - ARROWMINIMUMSPACE;
        minX = CGRectGetMaxX(self.arrow1.frame) + ARROWMINIMUMSPACE;
    }
    else if(panGesture.view == self.arrow3) {
        startPoint = &_startPoint3;
        minY = CGRectGetMaxY(self.arrow1.frame) + ARROWMINIMUMSPACE;
        maxX = CGRectGetMinX(self.arrow4.frame) - ARROWWIDTH - ARROWMINIMUMSPACE;
    }
    else if(panGesture.view == self.arrow4) {
        startPoint = &_startPoint4;
        minY = CGRectGetMaxY(self.arrow2.frame) + ARROWMINIMUMSPACE;
        minX = CGRectGetMaxX(self.arrow3.frame) + ARROWMINIMUMSPACE;
    }
    
    if(panGesture.state == UIGestureRecognizerStateBegan) {
        *startPoint = [panGesture locationInView:self.cropMaskView];
        self.cropView.userInteractionEnabled = NO;
    }
    else if(panGesture.state == UIGestureRecognizerStateEnded) {
        self.cropView.userInteractionEnabled = YES;
    }
    else if(panGesture.state == UIGestureRecognizerStateChanged) {
        
        
        
        CGPoint endPoint = [panGesture locationInView:self.cropMaskView];
        CGRect frame = panGesture.view.frame;
        frame.origin.x += endPoint.x - startPoint->x;
        frame.origin.y += endPoint.y - startPoint->y;
        frame.origin.x = MIN(maxX, MAX(frame.origin.x, minX));
        frame.origin.y = MIN(maxY, MAX(frame.origin.y, minY));
        panGesture.view.frame = frame;
        *startPoint = endPoint;
    }
    [self resetArrowsFollow: panGesture.view];
    [self resetCropView];
    [self resetCropMask];
}

/**
 *根据当前移动的箭头的位置重新设置与之一起变化位置的箭头的位置
 */

- (void)resetArrowsFollow: (UIView *)arrow {
//    NSLog(@"_holderWidth=%f  _holderHeight=%f",_holderWidth,_holderHeight);
//    
//    NSLog(@"cropView witdth=%f  cropView height=%f",self.cropView.frame.size.width, self.cropView.frame.size.height);

    CGFloat borderMinX = CGRectGetMinX(self.cropMaskView.frame);
    CGFloat borderMaxX = CGRectGetMaxX(self.cropMaskView.frame);
    CGFloat borderMinY = CGRectGetMinY(self.cropMaskView.frame);
    CGFloat borderMaxY = CGRectGetMaxY(self.cropMaskView.frame);
    if(arrow == self.arrow1) {
        
        if(_currentProportion == 0) {
            self.arrow2.center = CGPointMake(self.arrow2.center.x, self.arrow1.center.y);
            self.arrow3.center = CGPointMake(self.arrow1.center.x, self.arrow3.center.y);
            return;
        }
        
        CGPoint leftTopPoint = CGPointMake(CGRectGetMinX(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMinY(self.arrow1.frame) + ARROWBORDERWIDTH);
        CGRect frame = self.cropView.frame;
        CGFloat maxX = CGRectGetMaxX(frame);
        CGFloat maxY = CGRectGetMaxY(frame);
        
        if(_currentProportion >= 1) {
            frame.size.height = MIN(MAX(maxX - leftTopPoint.x, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) * _currentProportion, maxY - borderMinY);
            frame.size.width = frame.size.height / _currentProportion;
        }
        else {
            frame.size.width = MIN(MAX(maxY - leftTopPoint.y, 2 * ARROWHEIGHT + ARROWMINIMUMSPACE) / _currentProportion, maxX - borderMinX);
            frame.size.height = frame.size.width * _currentProportion;
        }
        frame.origin.x = maxX - frame.size.width;
        frame.origin.y = maxY - frame.size.height;
        self.cropView.frame = frame;
        
        [self resetAllArrows];
    }
    else if(arrow == self.arrow2) {
        
        if(_currentProportion == 0) {
            self.arrow1.center = CGPointMake(self.arrow1.center.x, self.arrow2.center.y);
            self.arrow4.center = CGPointMake(self.arrow2.center.x, self.arrow4.center.y);
            return;
        }
        
        CGPoint rightTopPoint = CGPointMake(CGRectGetMaxX(self.arrow2.frame) - ARROWBORDERWIDTH, CGRectGetMinY(self.arrow2.frame) + ARROWBORDERWIDTH);
        CGRect frame = self.cropView.frame;
        CGFloat minX = CGRectGetMinX(frame);
        CGFloat maxY = CGRectGetMaxY(frame);
        
        if(_currentProportion >= 1) {
            frame.size.height = MIN(MAX(rightTopPoint.x - minX, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) * _currentProportion, maxY - borderMinY);
            frame.size.width = frame.size.height / _currentProportion;
        }
        else {
            frame.size.width = MIN(MAX(maxY - rightTopPoint.y, 2 * ARROWHEIGHT + ARROWMINIMUMSPACE) / _currentProportion,  borderMaxX - minX);
            frame.size.height = frame.size.width * _currentProportion;
        }

        frame.origin.y = maxY - frame.size.height;
        self.cropView.frame = frame;
        
        [self resetAllArrows];
    }
    else if(arrow == self.arrow3) {
        
        if(_currentProportion == 0) {
            self.arrow1.center = CGPointMake(self.arrow3.center.x, self.arrow1.center.y);
            self.arrow4.center = CGPointMake(self.arrow4.center.x, self.arrow3.center.y);
            return;
        }
        
        CGPoint leftBottomPoint = CGPointMake(CGRectGetMinX(self.arrow3.frame) + ARROWBORDERWIDTH, CGRectGetMaxY(self.arrow3.frame) - ARROWBORDERWIDTH);
        CGRect frame = self.cropView.frame;
        CGFloat maxX = CGRectGetMaxX(frame);
        CGFloat minY = CGRectGetMinY(frame);
        
        if(_currentProportion >= 1) {
            frame.size.height = MIN(MAX(maxX - leftBottomPoint.x, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) * _currentProportion, borderMaxY - minY);
            frame.size.width = frame.size.height / _currentProportion;
        }
        else {
            frame.size.width = MIN(MAX(leftBottomPoint.y - minY, 2 * ARROWHEIGHT + ARROWMINIMUMSPACE) / _currentProportion, maxX - borderMinX);
            frame.size.height = frame.size.width * _currentProportion;
        }
        
        frame.origin.x = maxX - frame.size.width;
        self.cropView.frame = frame;
        
        [self resetAllArrows];
    }
    else if(arrow == self.arrow4) {
        
        if(_currentProportion == 0) {
            self.arrow2.center = CGPointMake(self.arrow4.center.x, self.arrow2.center.y);
            self.arrow3.center = CGPointMake(self.arrow3.center.x, self.arrow4.center.y);
            return;
        }
        
        CGPoint rightBottomPoint = CGPointMake(CGRectGetMaxX(self.arrow4.frame) - ARROWBORDERWIDTH, CGRectGetMaxY(self.arrow4.frame) - ARROWBORDERWIDTH);
        CGRect frame = self.cropView.frame;
        CGFloat minX = CGRectGetMinX(frame);
        CGFloat minY = CGRectGetMinY(frame);
        
        if(_currentProportion >= 1) {
            frame.size.height = MIN(MAX(rightBottomPoint.x - minX, 2 * ARROWWIDTH + ARROWMINIMUMSPACE) * _currentProportion, borderMaxY - minY);
            frame.size.width = frame.size.height / _currentProportion;

        }
        else {
            frame.size.width = MIN(MAX(rightBottomPoint.y - minY, 2 * ARROWHEIGHT + ARROWMINIMUMSPACE) / _currentProportion, borderMaxX - minX);
            frame.size.height = frame.size.width * _currentProportion;
        }
        self.cropView.frame = frame;
        
        [self resetAllArrows];
    }
}

/**
 *根据当前裁剪区域的位置重新设置所有角的位置
 */
- (void)resetAllArrows {
    
    self.arrow1.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
    self.arrow2.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMinY(self.cropView.frame) - ARROWBORDERWIDTH + ARROWHEIGHT/2.0);
    self.arrow3.center = CGPointMake(CGRectGetMinX(self.cropView.frame) - ARROWBORDERWIDTH + ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
    self.arrow4.center = CGPointMake(CGRectGetMaxX(self.cropView.frame) + ARROWBORDERWIDTH - ARROWWIDTH/2.0, CGRectGetMaxY(self.cropView.frame) + ARROWBORDERWIDTH - ARROWHEIGHT/2.0);
    [self.arrow1 layoutIfNeeded];
    [self.arrow2 layoutIfNeeded];
    [self.arrow3 layoutIfNeeded];
    [self.arrow4 layoutIfNeeded];
}
/**
 *根据当前所有角的位置重新设置裁剪区域的位置
 */
- (void)resetCropView {
    self.cropView.frame = CGRectMake(CGRectGetMinX(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMinY(self.arrow1.frame) + ARROWBORDERWIDTH, CGRectGetMaxX(self.arrow2.frame) - CGRectGetMinX(self.arrow1.frame) - ARROWBORDERWIDTH * 2, CGRectGetMaxY(self.arrow3.frame) - CGRectGetMinY(self.arrow1.frame) - ARROWBORDERWIDTH * 2);
}
/**
 *由于image在imageview中是缩放过的，这里要根据裁剪区域在imageview的尺寸换算
 *出对应的裁剪区域在实际image的尺寸
 */
- (CGRect)cropAreaInImage {
    CGRect cropAreaInImageView = [self.cropMaskView convertRect:self.cropView.frame toView:self.cropMaskView];
    CGRect cropAreaInImage;
    cropAreaInImage.origin.x = cropAreaInImageView.origin.x * _imageScale;
    cropAreaInImage.origin.y = cropAreaInImageView.origin.y * _imageScale;
    cropAreaInImage.size.width = cropAreaInImageView.size.width * _imageScale;
    cropAreaInImage.size.height = cropAreaInImageView.size.height * _imageScale;
    return cropAreaInImage;
}

#pragma mark - IBActions
- (IBAction)clickCancelBtn:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clickOkBtn:(id)sender {
    
    UIImage *cropImage = [_myImage imageAtRect:[self cropAreaInImage]];
    
    
    if (self.imageEditBlock) {
        self.imageEditBlock(cropImage);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - privte
/*
 * 设置view子控件
 */
- (void)setSubviews {
    self.cropViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCropView:)];
    self.arrow1Gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCorner:)];
    self.arrow2Gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCorner:)];
    self.arrow3Gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCorner:)];
    self.arrow4Gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCorner:)];
    
    
    self.cropMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.cropMaskView.backgroundColor = [UIColor colorWithWhite:0x000000 alpha:0.7];
    [self.view insertSubview:self.cropMaskView atIndex:1];
    
    self.cropView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.cropView setUserInteractionEnabled:YES];
    [self.cropView addGestureRecognizer:self.cropViewGesture];
    
    self.arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ARROWWIDTH, ARROWHEIGHT)];
    self.arrow1.image = [UIImage imageNamed:@"arrow1.png"];
    [self.cropView setUserInteractionEnabled:YES];
    [self.arrow1 addGestureRecognizer:_arrow1Gesture];
    
    self.arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ARROWWIDTH, ARROWHEIGHT)];
    self.arrow2.image = [UIImage imageNamed:@"arrow2.png"];
    [self.arrow2 setUserInteractionEnabled:YES];
    [self.arrow2 addGestureRecognizer:_arrow2Gesture];
    
    self.arrow3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ARROWWIDTH, ARROWHEIGHT)];
    self.arrow3.image = [UIImage imageNamed:@"arrow3.png"];
    [self.arrow3 setUserInteractionEnabled:YES];
    [self.arrow3 addGestureRecognizer:_arrow3Gesture];
    
    self.arrow4 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ARROWWIDTH, ARROWHEIGHT)];
    self.arrow4.image = [UIImage imageNamed:@"arrow4.png"];
    [self.arrow4 setUserInteractionEnabled:YES];
    [self.arrow4 addGestureRecognizer:_arrow4Gesture];
    
    [self.cropMaskView addSubview:self.cropView];
    [self.cropMaskView addSubview:self.arrow1];
    [self.cropMaskView addSubview:self.arrow2];
    [self.cropMaskView addSubview:self.arrow3];
    [self.cropMaskView addSubview:self.arrow4];
}

@end
