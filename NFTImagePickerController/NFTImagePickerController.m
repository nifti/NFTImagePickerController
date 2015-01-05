//
//  NFTImagePickerController.m
//
//  Created by Ryan Fitzgerald on 6/18/14.
//
//

#import "NFTImagePickerController.h"
#import "NFTImagePickerGroupCell.h"
#import "NFTPhotoAccessDeniedView.h"
#import "NFTNoPhotosFoundCell.h"


static const int itemSpacing = 2;

ALAssetsFilter *ALAssetsFilterFromNFTImagePickerControllerFilterType(NFTImagePickerControllerFilterType type) {
    switch (type) {
        case NFTImagePickerControllerFilterTypeNone:
            return [ALAssetsFilter allAssets];

        case NFTImagePickerControllerFilterTypePhotos:
            return [ALAssetsFilter allPhotos];

        case NFTImagePickerControllerFilterTypeVideos:
            return [ALAssetsFilter allVideos];

        default:
            return [ALAssetsFilter allAssets];
    }
}

@interface NFTImagePickerController () <
        UIAlertViewDelegate,
        UICollectionViewDelegate,
        UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout,
        NFTAssetsGroupViewControllerDelegate>

@property(nonatomic, copy) NSArray *groupTypes;
@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property(nonatomic, copy, readwrite) NSArray *assetsGroups;

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property(nonatomic, strong) NFTPhotoAccessDeniedView *genericPhotoAccessDeniedView;
@property(nonatomic, strong) UIView *currentPhotoAccessDeniedView;

@property(nonatomic, assign) BOOL firstLoad;
@property(nonatomic, assign) BOOL viewDidAppear;
@property(nonatomic, strong, readwrite) NSSet *selectedAssetURLs;

@property(nonatomic) NSInteger assetsGroupIndex;

- (void)showDeniedView;

- (void)hideDeniedView;

- (void)selectedAssetURLsAddAsset:(ALAsset *)asset;

- (void)selectedAssetURLsRemoveAsset:(ALAsset *)asset;

@end

@implementation NFTImagePickerController

+ (BOOL)isAuthorized __unused {
    return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized;
}

- (id)init {
    self = [super init];
    if (self) {
        self.photoPermissionMessage = @"Enable Photo Access?";
        self.filterType = NFTImagePickerControllerFilterTypePhotos;
        self.firstLoad = YES;
        self.viewDidAppear = NO;

        self.selectedAssetURLs = [NSSet set];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Albums";
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groupTypes = @[
            @(ALAssetsGroupSavedPhotos),
            @(ALAssetsGroupPhotoStream),
            @(ALAssetsGroupAlbum)
    ];

    [self.view addSubview:self.collectionView];

    self.view.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.collectionView.frame = self.view.bounds;

    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        [self showAskForPermissionDialog];
    } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [self showDeniedView];
    } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        [self loadAssetsGroups];
    } else {
        NSLog(@"unknown");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.viewDidAppear = YES;
    ALAssetsGroup *assetsGroup = [self.assetsGroups firstObject];
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized && self.firstLoad && assetsGroup) {
        self.firstLoad = NO;
        [self displayAssetGroupViewController:assetsGroup animated:NO push:YES];
    }
}

#pragma mark - Lazy init

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                             collectionViewLayout:self.collectionViewFlowLayout];

        _collectionView.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1];
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.clipsToBounds = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;

        [_collectionView registerClass:[NFTImagePickerGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTImagePickerGroupCell class])];
        [_collectionView registerClass:[NFTNoPhotosFoundCell class] forCellWithReuseIdentifier:NSStringFromClass([NFTNoPhotosFoundCell class])];
    }

    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if (!_collectionViewFlowLayout) {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionViewFlowLayout.minimumLineSpacing = 1;
        _collectionViewFlowLayout.minimumInteritemSpacing = 0;
        _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    return _collectionViewFlowLayout;
}

- (NFTPhotoAccessDeniedView *)genericPhotoAccessDeniedView {
    if (!_genericPhotoAccessDeniedView) {
        _genericPhotoAccessDeniedView = [NFTPhotoAccessDeniedView new];
    }

    return _genericPhotoAccessDeniedView;
}

- (void)showDeniedView {
    [self.collectionView removeFromSuperview];

    self.title = @"Permissions";

    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:viewForCameraRollAccesDeniedReusingView:)]) {
        self.currentPhotoAccessDeniedView = [self.delegate imagePickerController:self viewForCameraRollAccesDeniedReusingView:self.currentPhotoAccessDeniedView];
    } else {
        self.currentPhotoAccessDeniedView = self.genericPhotoAccessDeniedView;
    }

    self.currentPhotoAccessDeniedView.frame = self.view.bounds;
    [self.view addSubview:self.currentPhotoAccessDeniedView];
}

- (void)hideDeniedView __unused {
    [self.currentPhotoAccessDeniedView removeFromSuperview];
    self.title = @"Albums";
}

- (void)showAskForPermissionDialog __unused {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Let %@ Access Photos?", appName]
                                                    message:self.photoPermissionMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Not Now"
                                          otherButtonTitles:@"Give Access", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showDeniedView];
    } else if (buttonIndex == 1) {
        [self loadAssetsGroups];
    }
}

- (void)loadAssetsGroups {
    [self loadAssetsGroupsWithTypes:self.groupTypes
                         completion:^(NSArray *assetsGroups) {
        self.assetsGroups = assetsGroups;

        if (self.viewDidAppear && self.firstLoad) {
            ALAssetsGroup *assetsGroup = [assetsGroups firstObject];
            self.firstLoad = NO;
            if (assetsGroup) {
                [self displayAssetGroupViewController:assetsGroup animated:NO push:YES];
            } else {
                [self.collectionView reloadData];
            }
        } else if (!self.firstLoad) {
            [self.collectionView reloadData];
        } else if (self.assetsGroups.count == 0) {
            self.firstLoad = NO;
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark - Managing Assets

- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion {
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;

    for (NSNumber *type in types) {
        __weak typeof(self) weakSelf = self;

        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                          usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
            if (assetsGroup) {
                // Filter the assets group
                [assetsGroup setAssetsFilter:ALAssetsFilterFromNFTImagePickerControllerFilterType(weakSelf.filterType)];

                if (assetsGroup.numberOfAssets > 0) {
                    // Add assets group
                    [assetsGroups addObject:assetsGroup];
                }
            } else {
                numberOfFinishedTypes++;
            }

            // Check if the loading finished
            if (numberOfFinishedTypes == types.count) {
                // Sort assets groups
                NSArray *sortedAssetsGroups = [self sortAssetsGroups:assetsGroups typesOrder:types];

                // Call completion block
                if (completion) {
                    completion(sortedAssetsGroups);
                }
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [weakSelf showDeniedView];
        }];
    }
}

- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder {
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];

    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }

        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];

        for (NSUInteger i = 0; i <= sortedAssetsGroups.count; i++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }

            ALAssetsGroup *sortedAssetsGroup = sortedAssetsGroups[i];
            ALAssetsGroupType sortedAssetsGroupType = [[sortedAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(sortedAssetsGroupType)];

            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }

    return [sortedAssetsGroups copy];
}

- (void)selectAsset:(ALAsset *)asset __unused {
    [self selectedAssetURLsAddAsset:asset];

    if (self.assetsGroupViewController) {
        [self.assetsGroupViewController selectAsset:asset];
    }
}

- (void)deselectAsset:(ALAsset *)asset __unused {
    [self selectedAssetURLsRemoveAsset:asset];

    if (self.assetsGroupViewController) {
        [self.assetsGroupViewController deselectAsset:asset];
    }
}

#pragma mark - Collection View delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    } else {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), 50);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self showNoPhotosFound]) {
        return 1;
    } else {
        return self.assetsGroups.count;
    }
}

- (BOOL)showNoPhotosFound {
    return !self.firstLoad && self.assetsGroups.count == 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self showNoPhotosFound]) {
        NFTNoPhotosFoundCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NFTNoPhotosFoundCell class]) forIndexPath:indexPath];
        return cell;
    } else {
        NFTImagePickerGroupCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NFTImagePickerGroupCell class]) forIndexPath:indexPath];

        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger) indexPath.row];

        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:137.0f / 255.0f green:153.0f / 255.0f blue:167.0f / 255.0f alpha:0.3];

        [cell updateAssetsGroup:assetsGroup];
        return cell;
    }

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger) indexPath.row];
    [self displayAssetGroupViewController:assetsGroup animated:YES push:YES];
}

- (void)displayAssetGroupViewController:(ALAssetsGroup *)assetsGroup animated:(BOOL)animated push:(BOOL)push {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = itemSpacing;
    layout.minimumInteritemSpacing = itemSpacing;
    layout.sectionInset = UIEdgeInsetsZero;

    self.assetsGroupViewController = [[NFTAssetsGroupViewController alloc] initWithCollectionViewLayout:layout];

    self.assetsGroupViewController.assetsLibrary = self.assetsLibrary;
    self.assetsGroupViewController.assetsGroup = assetsGroup;
    self.assetsGroupViewController.delegate = self;

    [self.assetsGroupViewController selectAssetsHavingURLs:self.selectedAssetURLs];

    if (push) {
        [self.navigationController pushViewController:self.assetsGroupViewController animated:animated];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

#pragma mark - NFTAssetsGroupViewControllerDelegate

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didSelectAsset:(ALAsset *)asset {
    [self selectedAssetURLsAddAsset:asset];

    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectAsset:)]) {
        [self.delegate imagePickerController:self didSelectAsset:asset];
    }
}

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didDeselectAsset:(ALAsset *)asset {
    [self selectedAssetURLsRemoveAsset:asset];

    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didDeselectAsset:)]) {
        [self.delegate imagePickerController:self didDeselectAsset:asset];
    }
}

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSInteger newIndex = self.assetsGroupIndex + 1;
    if (newIndex <= self.assetsGroups.count - 1) {
        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger) newIndex];
        [self displayAssetGroupViewController:assetsGroup animated:YES push:YES];
    }
}

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSInteger newIndex = self.assetsGroupIndex - 1;
    if (newIndex >= 0) {
        ALAssetsGroup *assetsGroup = self.assetsGroups[(NSUInteger) newIndex];
        [self displayAssetGroupViewController:assetsGroup animated:YES push:NO];
    }
}

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didAppear:(ALAssetsGroup *)assetsGroup {
    self.assetsGroupIndex = [self.assetsGroups indexOfObject:assetsGroup];
}

- (void)assetsGroupViewController:(NFTAssetsGroupViewController *)assetsGroupViewController didLongTouch:(ALAsset *)asset inView:(UIView *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didLongTouch:inView:)]) {
        [self.delegate imagePickerController:self didLongTouch:asset inView:cell];
    }
}

- (void)assetsGroupViewControllerDidReloadAssets:(NFTAssetsGroupViewController *)assetsGroupViewController {
    [self.assetsGroupViewController selectAssetsHavingURLs:self.selectedAssetURLs];
}

#pragma mark - Private Methods

- (void)selectedAssetURLsAddAsset:(ALAsset *)asset {
    NSMutableSet *mset = [self.selectedAssetURLs mutableCopy];
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [mset addObject:assetURL];

    self.selectedAssetURLs = mset;
}

- (void)selectedAssetURLsRemoveAsset:(ALAsset *)asset {
    NSMutableSet *mset = [self.selectedAssetURLs mutableCopy];
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    [mset removeObject:assetURL];

    self.selectedAssetURLs = mset;
}

@end
