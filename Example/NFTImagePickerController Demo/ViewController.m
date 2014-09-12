//
// Created by Ryan Fitzgerald on 6/20/14.
// Copyright (c) 2014 Nifti. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic, strong) UIButton *imagePickerButton;

- (void)didTapImagePickerButton:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Demo";
    self.view.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];

    self.edgesForExtendedLayout=UIRectEdgeNone;

    [self.view addSubview:self.imagePickerButton];

    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([NFTImagePickerController isAuthorized]) {
        NSLog(@"Photo access accessible");
    } else {
        NSLog(@"Photo access currently not accessible");
    }

    self.imagePickerButton.frame = CGRectMake(0, 40, CGRectGetWidth(self.view.bounds), 44.0f);
}

#pragma mark - Lazy init

- (UIButton *)imagePickerButton {
    if (!_imagePickerButton) {
        _imagePickerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_imagePickerButton setTitle:@"Launch Image Picker"
                            forState:UIControlStateNormal];

        _imagePickerButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [_imagePickerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _imagePickerButton.backgroundColor = [UIColor whiteColor];
        [_imagePickerButton addTarget:self action:@selector(didTapImagePickerButton:) forControlEvents:UIControlEventTouchUpInside];
        _imagePickerButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
        _imagePickerButton.layer.borderWidth = 1.0f;
    }

    return _imagePickerButton;
}

- (void)didTapImagePickerButton:(id)sender {
    NFTImagePickerController *ctrl = [[NFTImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.allowAccessPhoto = [UIImage imageNamed:@"allow-access-photo"];

    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - NFTImagePickerControllerDelegate

- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset {
    NSLog(@"Did Select");
}

- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset {
    NSLog(@"Did Deselect");
}

@end