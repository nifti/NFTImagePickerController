//
//  NFTImagePickerController.h
//
//  Created by Ryan Fitzgerald on 6/18/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

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

@end

@interface NFTImagePickerController : UIViewController

@property(nonatomic, strong) NSString *photoPermissionMessage;
@property(nonatomic, assign) NFTImagePickerControllerFilterType filterType;
@property(nonatomic, weak) id <NFTImagePickerControllerDelegate> delegate;

@end