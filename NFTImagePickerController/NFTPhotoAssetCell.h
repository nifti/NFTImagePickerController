//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NFTPhotoAssetCell : UICollectionViewCell
- (void)updateWithAsset:(ALAsset *)asset;
@end