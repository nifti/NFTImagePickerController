//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import "NFTAssetsGroupViewController.h"
#import "NFTPhotoAssetCell.h"
#import "NFTNoPhotosFoundCell.h"

@interface NFTAssetsGroupViewController ()

@property(nonatomic, strong) NSMutableArray *assets;
@property(nonatomic, strong) NSMutableSet *assetURLs;

- (void)reloadAssets;
@end

@implementation NFTAssetsGroupViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.collectionView.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
        self.collectionView.allowsMultipleSelection = YES;
        self.collectionView.clipsToBounds = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;

        [self.collectionView registerClass:[NFTPhotoAssetCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTPhotoAssetCell class])];
        [self.collectionView registerClass:[NFTNoPhotosFoundCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTNoPhotosFoundCell class])];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsChanged:)
                                                     name:ALAssetsLibraryChangedNotification object:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification object:nil];
}

#pragma mark - Lazy init

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
    _assetsGroup = assetsGroup;

    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];

    [self reloadAssets];
}

- (void)reloadAssets {
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

    self.assets = [NSMutableArray array];
    self.assetURLs = [NSMutableSet new];

    __weak typeof(self) weakSelf = self;
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [weakSelf.assets addObject:result];
            [weakSelf.assetURLs addObject:[result valueForProperty:ALAssetPropertyAssetURL]];
        }
    }];

    [self.collectionView reloadData];
}

- (void)assetsChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;

    NSSet *groupURLs = userInfo[ALAssetLibraryUpdatedAssetGroupsKey];

    // if changes didn't happen to current asset group ignore it
    if (![groupURLs containsObject:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL]]) {
        return;
    }

    if (userInfo == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadAssets];
        });
    }

    NSMutableOrderedSet *newItemSet = [NSMutableOrderedSet orderedSetWithSet:userInfo[ALAssetLibraryUpdatedAssetsKey]];
    [newItemSet minusSet:self.assetURLs];

    if (newItemSet.count > 0) {
        __weak typeof(self) weakSelf = self;

        NSMutableArray *indexPaths = [NSMutableArray new];

        // TODO refactor to be easier to read & understand
        [newItemSet enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
            [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:weakSelf.assets.count inSection:0];
                [indexPaths addObject:path];
                [weakSelf.assets addObject:asset];
                [weakSelf.assetURLs addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];

                if (idx == newItemSet.count - 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.collectionView performBatchUpdates:^{
                            [weakSelf.collectionView insertItemsAtIndexPaths:indexPaths];
                        }
                                                          completion:^(BOOL finished) {
                        }];
                    });
                }
            }                  failureBlock:^(NSError *error) {
                NSLog(@"error %@", error.description);
            }];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadAssets];
        });
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self showNoPhotosFound]) {
        return 1;
    } else {
        return self.assetsGroup.numberOfAssets;
    }
}

- (BOOL)showNoPhotosFound {
    return self.assetsGroup.numberOfAssets == 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        NFTNoPhotosFoundCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NFTNoPhotosFoundCell class]) forIndexPath:indexPath];
        return cell;
    } else {
        NFTPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NFTPhotoAssetCell class]) forIndexPath:indexPath];

        ALAsset *asset = [self.assets objectAtIndex:(NSUInteger) indexPath.row];

        [cell updateWithAsset:asset];

        return cell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(104, 104);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.assets objectAtIndex:(NSUInteger) indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupViewController:didSelectAsset:)]) {
        [self.delegate assetsGroupViewController:self didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.assets objectAtIndex:(NSUInteger) indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupViewController:didDeselectAsset:)]) {
        [self.delegate assetsGroupViewController:self didDeselectAsset:asset];
    }
}

- (void)deselectAsset:(ALAsset *)asset {
    for (NSInteger i = 0; i < self.assets.count; i++) {
        NSURL *aURL = [[self.assets objectAtIndex:i] valueForProperty:ALAssetPropertyAssetURL];

        if ([aURL isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}


#pragma mark - Asset Selection

- (void)selectAssetHavingURL:(NSURL *)URL {
    for (NSInteger i = 0; i < self.assets.count; i++) {
        ALAsset *asset = [self.assets objectAtIndex:i];
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];

        if ([assetURL isEqual:URL]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

            return;
        }
    }
}

@end