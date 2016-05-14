//
//  MinRichTextParser.h
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinRichText.h"

extern NSString * const kMinAttributeType;
extern NSString * const KMinAttributeRange;
extern NSString * const kEmojiAttributeName;/*!< 表情属性字典key */
extern NSString * const kAtAttributeName;/*!< @属性字典key */
extern NSString * const kLinkAttributeName;/*!< 链接属性字典key */

typedef NS_ENUM(NSUInteger, MinAttributeType) {
    MinAttributeLink,
    MinAttributeAt,
    MinAttributeEmoji,
    MinAttributeInfoImage,
};

typedef struct MinGlyphMetrics {
    CGFloat ascent;
    CGFloat descent;
    CGFloat width;
} MinGlyphMetrics, *MinGlyphMetricsRef;

@class MinRichTextConfig;

@interface MinRichTextParser : NSObject

@property (nonatomic, strong) NSString *emojiRegular;/*!< 表情正则 */
@property (nonatomic, strong) NSString *atRegular;/*!< @正则 */
@property (nonatomic, strong) NSString *linkRegular;/*!< 链接正则 */
@property (nonatomic, strong) MinRichTextConfig *config;/*!< 属性配置 */
@property (nonatomic, strong) NSDictionary *emojiDict;/*!< 表情字典 */

/// 单例
+ (instancetype)shareInstance;

/**
 *  解析字符串
 *
 *  @param content 传入需要解析的字符串
 *
 *  @return 解析完成的属性字符串
 */
- (NSMutableAttributedString *)parseContent:(NSString *)content;

@end
