//
//  CLMarkerCreationViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLMarkerManager.h"
#import "CLMarkerCreationViewController.h"
#import "PECropViewController.h"
#import "SWSnapshotStackView.h"
#import "UIColor+MLPFlatColors.h"

@interface CLMarkerCreationViewController () <PECropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) IBOutlet SWSnapshotStackView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;

@end

@implementation CLMarkerCreationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.contentMode = UIViewContentModeRedraw;
    self.imageView.displayAsStack = NO;
    self.imageView.hidden = YES;
    self.editButton.hidden = YES;
    self.nextStepButton.hidden = YES;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.frame];
    background.image = [UIImage imageNamed:@"bg_3.jpg"];
    [self.view insertSubview:background atIndex:0];
    
    [self.addImageButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.addImageButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
    
}

- (IBAction)addMarkerButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
#if TARGET_IPHONE_SIMULATOR
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)editButtonPressed:(id)sender {
    
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.imageView.image;
    
    UIImage *image = self.imageView.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)retakeButtonPressed:(id)sender {
    [self addMarkerButtonPressed:sender];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)executeAnimation
{
    CGRect initRect = self.imageView.frame;
    self.imageView.frame = CGRectMake(initRect.origin.x - 25, initRect.origin.y - 25, initRect.size.width + 50, initRect.size.height + 50);
    [UIView animateWithDuration:1.2f animations:^{
        self.imageView.alpha = 1.0f;
        self.imageView.frame = initRect;
        } completion:^(BOOL finished){
    }];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = chosenImage;
    self.imageView.alpha = 0.0f;
    self.imageView.hidden = NO;
    self.editButton.hidden = NO;
    self.nextStepButton.hidden = NO;
    self.addImageButton.hidden = YES;
    
    [self executeAnimation];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [CLMarkerManager sharedManager].tempMarkerImage = self.imageView.image;
}


@end
