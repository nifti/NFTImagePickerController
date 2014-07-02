//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@class NFTAssetsGroupViewController;

@protocol NFTAssetsGroupViewControllerDelegate <NSObject>

@optional
- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didSelectAsset:(ALAsset *)asset;
- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didDeselectAsset:(ALAsset *)asset;

@end

@interface NFTAssetsGroupViewController : UIViewController<
        UIAlertViewDelegate,
        UICollectionViewDelegate,
        UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout>

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup;

+ (instancetype)controllerWithAssetsGroup:(ALAssetsGroup *)assetsGroup;

- (void)deselectAsset:(ALAsset *)asset;

@property (nonatomic, weak) id<NFTAssetsGroupViewControllerDelegate> delegate;

@end