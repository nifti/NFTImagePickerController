//
//  NFTImagePickerController.h
//
//  Created by Ryan Fitzgerald on 6/18/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NFTPhotoAssetCell.h"
#import "NFTAssetsGroupViewController.h"

@class NFTImagePickerController;

typedef NS_ENUM(NSUInteger, NFTImagePickerControllerFilterType) {
    NFTImagePickerControllerFilterTypeNone,
    NFTImagePickerControllerFilterTypePhotos,
    NFTImagePickerControllerFilterTypeVideos
};

@protocol NFTImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset;

- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didDeselectAsset:(ALAsset *)asset;

- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didLongTouch:(NFTPhotoAssetCell *)cell image:(UIImage *)image;

- (UIView *)imagePickerController:(NFTImagePickerController *)imagePickerController viewForCameraRollAccesDeniedReusingView:(UIView *)view;

@end

@interface NFTImagePickerController : UIViewController

@property (nonatomic, strong, readonly) NSSet *selectedAssetURLs;
@property(nonatomic, strong) NSString *photoPermissionMessage;
@property(nonatomic, assign) NFTImagePickerControllerFilterType filterType;
@property(nonatomic, weak) id <NFTImagePickerControllerDelegate> delegate;
@property(nonatomic, strong) NFTAssetsGroupViewController *assetsGroupViewController;

+ (BOOL)isAuthorized;

- (void)selectAsset:(ALAsset *)asset;
- (void)deselectAsset:(ALAsset *)asset;
@end
