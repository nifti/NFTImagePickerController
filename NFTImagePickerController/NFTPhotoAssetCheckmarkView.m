//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import "NFTPhotoAssetCheckmarkView.h"


@implementation NFTPhotoAssetCheckmarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(24.0, 24.0);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Border
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//    CGContextFillEllipseInRect(context, self.bounds);

    // Body
    CGContextSetRGBFillColor(context, 57 / 255.0f, 187 / 255.0f, 181 / 255.0f, 1.0);
    CGContextFillEllipseInRect(context, CGRectInset(self.bounds, 1.0, 1.0));

    // Checkmark
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 1.2);

    CGContextMoveToPoint(context, 6.0, 12.0);
    CGContextAddLineToPoint(context, 10.0, 16.0);
    CGContextAddLineToPoint(context, 18.0, 8.0);

    CGContextStrokePath(context);
}

@end