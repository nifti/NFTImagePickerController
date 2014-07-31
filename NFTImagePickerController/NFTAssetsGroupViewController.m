//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import "NFTAssetsGroupViewController.h"
#import "NFTPhotoAssetCell.h"
#import "NFTNoPhotosFoundCell.h"

@interface NFTAssetsGroupViewController ()

@property(nonatomic, strong) NSArray *assets;
@property(nonatomic, strong) NSArray *assetURLs;

- (void)reloadAssets;

@end

@implementation NFTAssetsGroupViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.collectionView.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1];
        self.collectionView.allowsMultipleSelection = YES;
        self.collectionView.clipsToBounds = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;

        [self.collectionView registerClass:[NFTPhotoAssetCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTPhotoAssetCell class])];
        [self.collectionView registerClass:[NFTNoPhotosFoundCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTNoPhotosFoundCell class])];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsChanged:)
                                                     name:ALAssetsLibraryChangedNotification object:nil];

        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGestureRecognizer.minimumPressDuration = .3; //seconds
        longPressGestureRecognizer.delaysTouchesBegan = YES;
        [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1];
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
    [self reloadAssetsAnimated:NO];
}

- (void)reloadAssetsAnimated:(BOOL)animated {
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSMutableArray *assets = [NSMutableArray new];
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets addObject:result];
        }
    }];

    [self setItems:assets animated:animated];
}

- (void)assetsChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;

    NSSet *groupURLs = userInfo[ALAssetLibraryUpdatedAssetGroupsKey];

    // if changes didn't happen to current asset group ignore it
    if (![groupURLs containsObject:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL]]) {
        return;
    }

    [self reloadAssetsAnimated:YES];
}

- (NSArray *)assetURLsForAssets:(NSArray *)assets {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:assets.count];

    for (ALAsset *asset in assets) {
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        if (url) {
            [result addObject:url];
        }
    }

    return result;
};

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    if (_assets == items || [_assets isEqualToArray:items])
        return;

    if (!animated) {
        _assets = [items copy];
        _assetURLs = [self assetURLsForAssets:_assets];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self notifyAssetsReloaded];
        });

        return;
    }

    NSOrderedSet *oldItemSet = [NSOrderedSet orderedSetWithArray:self.assetURLs];
    NSOrderedSet *newItemSet = [NSOrderedSet orderedSetWithArray:[self assetURLsForAssets:items]];

    NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
    [deletedItems minusOrderedSet:newItemSet];

    NSMutableOrderedSet *newItems = [newItemSet mutableCopy];
    [newItems minusOrderedSet:oldItemSet];

    NSMutableOrderedSet *movedItems = [newItemSet mutableCopy];
    [movedItems intersectOrderedSet:oldItemSet];

    NSMutableArray *deletedIndexPaths = [NSMutableArray arrayWithCapacity:[deletedItems count]];
    for (id deletedItem in deletedItems) {
        [deletedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:deletedItem] inSection:0]];
    }

    NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[newItems count]];
    for (id newItem in newItems) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:newItem] inSection:0]];
    }

    NSMutableArray *fromMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    NSMutableArray *toMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
    for (id movedItem in movedItems) {
        [fromMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:movedItem] inSection:0]];
        [toMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:movedItem] inSection:0]];
    }

    _assets = [items copy];
    _assetURLs = [self assetURLsForAssets:_assets];

    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(&*self) weakself = self;
        [self.collectionView performBatchUpdates:^() {

            if ([deletedIndexPaths count]) {
                [weakself.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];
            }

            if ([insertedIndexPaths count]) {
                [weakself.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
            }

            NSUInteger count = [fromMovedIndexPaths count];
            for (NSUInteger i = 0; i < count; ++i) {
                NSIndexPath *fromIndexPath = fromMovedIndexPaths[i];
                NSIndexPath *toIndexPath = toMovedIndexPaths[i];
                if (fromIndexPath != nil && toIndexPath != nil) {
                    [weakself.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                }
            }

        }                             completion:^(BOOL finished) {
            [weakself notifyAssetsReloaded];
        }];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self showNoPhotosFound]) {
        return 1;
    } else {
        return self.assets.count;
    }
}

- (BOOL)showNoPhotosFound {
    return self.assets.count == 0;
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

- (void)selectAsset:(ALAsset *)asset {
    for (NSUInteger i = 0; i < self.assets.count; i++) {
        NSURL *aURL = [[self.assets objectAtIndex:i] valueForProperty:ALAssetPropertyAssetURL];

        if ([aURL isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

- (void)deselectAsset:(ALAsset *)asset {
    for (NSUInteger i = 0; i < self.assets.count; i++) {
        NSURL *aURL = [[self.assets objectAtIndex:i] valueForProperty:ALAssetPropertyAssetURL];

        if ([aURL isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)notifyAssetsReloaded {
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupViewControllerDidReloadAssets:)]) {
        [self.delegate assetsGroupViewControllerDidReloadAssets:self];
    }
}

#pragma mark - Asset Selection

- (void)selectAssetsHavingURLs:(NSSet *)assetURLs {
    for (NSUInteger i = 0; i < self.assets.count; i++) {
        ALAsset *asset = [self.assets objectAtIndex:i];
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];

        if ([assetURLs containsObject:assetURL]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    }
}

#pragma mark - Long press gesture action

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
        if (indexPath) {
            ALAsset *asset = [self.assets objectAtIndex:(NSUInteger) indexPath.row];
            NFTPhotoAssetCell *cell = (NFTPhotoAssetCell *) [self.collectionView cellForItemAtIndexPath:indexPath];

            if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupViewController:didLongTouch:inView:)]) {
                [self.delegate assetsGroupViewController:self didLongTouch:asset inView:cell];
            }
        }
    }
}

@end