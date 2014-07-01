//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import "NFTAssetsGroupViewController.h"
#import "NFTPhotoAssetCell.h"

#define kNFTPhotoAssetsViewCellId @"_nft.id.photoAssetViewCellId"

static const int itemSpacing = 2;

@interface NFTAssetsGroupViewController ()

@property(nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property(nonatomic, strong) NSMutableArray *assets;

- (void)reloadAssets;
@end

@implementation NFTAssetsGroupViewController

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        self.assetsGroup = assetsGroup;
    }

    return self;
}

+ (instancetype)controllerWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    return [[self alloc] initWithAssetsGroup:assetsGroup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.collectionView];

    self.view.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:137 / 255.0 green:153 / 255.0 blue:167 / 255.0 alpha:1];
//
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//            NSForegroundColorAttributeName : [UIColor colorWithRed:137 / 255.0 green:153 / 255.0 blue:167 / 255.0 alpha:1],
//            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]
//    }];

    self.collectionView.frame = self.view.bounds;
}

#pragma mark - Lazy init

- (UICollectionView *)collectionView {

    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                             collectionViewLayout:self.collectionViewFlowLayout];

        _collectionView.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.clipsToBounds = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;

        [_collectionView registerClass:[NFTPhotoAssetCell class] forCellWithReuseIdentifier:kNFTPhotoAssetsViewCellId];
    }

    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if (_collectionViewFlowLayout == nil) {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionViewFlowLayout.minimumLineSpacing = itemSpacing;
        _collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing;
        _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    }

    return _collectionViewFlowLayout;
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
    _assetsGroup = assetsGroup;

    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];

    [self reloadAssets];
}

- (void)reloadAssets {
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

    self.assets = [NSMutableArray array];

    __weak typeof(self) weakSelf = self;
    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [weakSelf.assets addObject:result];
        }
    }];

    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NFTPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNFTPhotoAssetsViewCellId forIndexPath:indexPath];

    ALAsset *asset = [self.assets objectAtIndex:(NSUInteger) indexPath.row];

    [cell updateWithAsset:asset];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(78.5, 80);
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

@end