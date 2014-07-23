//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "NFTPhotoAssetCell.h"

@class NFTAssetsGroupViewController;

@protocol NFTAssetsGroupViewControllerDelegate <NSObject>

@optional
- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didSelectAsset:(ALAsset *)asset;
- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didDeselectAsset:(ALAsset *)asset;
- (void)assetsGroupViewControllerDidReloadAssets:(NFTAssetsGroupViewController *)assetsGroupViewController;
- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didLongTouch:(NFTPhotoAssetCell *)cell image:(UIImage *)image;

@end

@interface NFTAssetsGroupViewController : UICollectionViewController<
        UIAlertViewDelegate,
        UICollectionViewDelegateFlowLayout>

- (void)selectAsset:(ALAsset *)asset;

- (void)deselectAsset:(ALAsset *)asset;

- (void)selectAssetHavingURL:(NSURL *)URL;

@property(nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, weak) id<NFTAssetsGroupViewControllerDelegate> delegate;

@end