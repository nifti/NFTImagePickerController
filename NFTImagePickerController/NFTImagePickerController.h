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
- (void)imagePickerController:(NFTImagePickerController *)imagePickerController didLongTouch:(ALAsset *)asset inView:(UIView *)view;
- (UIView *)imagePickerController:(NFTImagePickerController *)imagePickerController viewForCameraRollAccesDeniedReusingView:(UIView *)view;

- (void)imagePickerController:(NFTImagePickerController *)imagePickerController scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)imagePickerController:(NFTImagePickerController *)imagePickerController scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)imagePickerController:(NFTImagePickerController *)imagePickerController scrollViewDidEndDragging:(UIScrollView *)scrollView  willDecelerate:(BOOL)decelerate;

@end

@interface NFTImagePickerController : UIViewController

@property(nonatomic, strong, readonly) NSSet *selectedAssetURLs;
@property(nonatomic, strong) NSString *photoPermissionMessage;
@property(nonatomic, assign) NFTImagePickerControllerFilterType filterType;
@property(nonatomic, weak) id <NFTImagePickerControllerDelegate> delegate;
@property(nonatomic, strong) NFTAssetsGroupViewController *assetsGroupViewController;

+ (BOOL)isAuthorized;

- (void)selectAsset:(ALAsset *)asset;
- (void)deselectAsset:(ALAsset *)asset;

@end
