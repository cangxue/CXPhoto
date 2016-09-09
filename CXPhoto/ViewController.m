//
//  ViewController.m
//  CXPhoto
//
//  Created by xiaoma on 16/9/6.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CropImageViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)choosePhotoAction:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction * photographAction = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            NSString *errorStr = @"应用相机权限受限,请在设置中启用";
            NSLog(@"%@",errorStr);
            return;
        }else{
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            picker.allowsEditing = YES;  //是否可编辑
            //摄像头
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            
        }
        
        
    }];
    
    UIAlertAction *albumsAction = [UIAlertAction actionWithTitle:@"手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
            picker.delegate = self;
            picker.allowsEditing = NO;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }else{
            //如果没有提示用户
            NSLog(@"调用相册出错");
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:photographAction];
    [alertController addAction:albumsAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orignImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    CropImageViewController  *imageEditVc = [CropImageViewController getCropImageWithImage:orignImage];
    
    
    imageEditVc.imageEditBlock = ^(UIImage *image1){
        
        self.mainImageView.image=image1;
        
    };
    [picker pushViewController:imageEditVc animated:YES];
}

@end
