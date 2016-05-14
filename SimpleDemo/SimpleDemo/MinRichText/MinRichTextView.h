//
//  MinRichTextView.h
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MinRichText.h"

/// 两个CFRange是否相交
NS_INLINE Boolean CFRangesIntersect(CFRange range1, CFRange range2) {
    CFIndex max_location = MAX(range1.location, range2.location);
    CFIndex min_tail = MIN(range1.location + range1.length, range2.location + range2.length);
    return (min_tail - max_location > 0) ? TRUE : FALSE;
}
/// NSRange转CFRange
NS_INLINE CFRange CFRangeFromNSRange(NSRange source) {
    return CFRangeMake(source.location, source.length);
}
/// loc是否在range范围内
NS_INLINE Boolean CFLocationInRange(CFIndex loc, CFRange range) {
    return (!(loc < range.location) && (loc - range.location) < range.length) ? TRUE : FALSE;
}

@protocol MinRichTextDelegate <NSObject>

@optional
- (void)clickedLinkString:(NSString *)linkString;
- (void)clickedAtSring:(NSString *)atString;

@end

@interface MinRichTextView : UIView

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, weak) id<MinRichTextDelegate> delegate;


+ (CGSize)adjustSizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)width;

@end
