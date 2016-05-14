//
//  MinRichTextParser.m
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "MinRichTextParser.h"

NSString * const kMinAttributeType = @"MinAttributeType";
NSString * const KMinAttributeRange = @"MinAttributeRange";
NSString * const kEmojiAttributeName = @"emojiAttributeName";
NSString * const kAtAttributeName = @"atAttributeName";
NSString * const kLinkAttributeName = @"linkAttributeName";
NSString * const kBlankPlaceholder = @"\uFFFC";

@interface MinRichTextParser ()

@end

@implementation MinRichTextParser

#pragma mark - Public Method

+ (instancetype)shareInstance {
    
    static MinRichTextParser *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[super allocWithZone:NULL] init];
        }
    });
    return instance;
}

- (NSMutableAttributedString *)parseContent:(NSString *)content {
    
    // 返回字符串
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    // 文本属性字典
    NSDictionary *textAttributeDict = [self textAttributeDictionary];
    // 匹配表情
    NSRegularExpression *emojiRegex =
        [NSRegularExpression regularExpressionWithPattern:_emojiRegular
                                                  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                    error:nil];
    NSArray *emojiMatches = [emojiRegex matchesInString:content
                                                options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                  range:NSMakeRange(0, content.length)];
    // 记录位置
    NSUInteger location = 0;
    for (NSTextCheckingResult *match in emojiMatches) {
        // 处理非表情字符
        NSRange range = match.range;
        if (range.location != location) {
            NSString *substring = [content substringWithRange:NSMakeRange(location, range.location - location)];
            NSMutableAttributedString *subAttributedString =
            [[NSMutableAttributedString alloc] initWithString:substring
                                                   attributes:textAttributeDict];
            [result appendAttributedString:subAttributedString];
        }
        
        // 定位下一段
        location = range.location + range.length;
        
        // 获取表情图片名字
        NSString *emojiKey = [content substringWithRange:range];
        NSString *emojiName = _emojiDict[emojiKey];
        if (!emojiName) {
            // 匹配内容非表情显示原文本
            NSString *nomalString = [content substringWithRange:range];
            NSMutableAttributedString *originalAttributedString =
            [[NSMutableAttributedString alloc] initWithString:nomalString
                                                   attributes:textAttributeDict];
            [result appendAttributedString:originalAttributedString];
        } else {
            // 替换空白占位符
            NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:kBlankPlaceholder
                                                                                      attributes:textAttributeDict];
            // 保存当前Range
            NSRange spaceRange = NSMakeRange([result length], 1);
            [result appendAttributedString:space];
            
            // 定义回调函数
            CTRunDelegateCallbacks callbacks;
            memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
            callbacks.version = kCTRunDelegateCurrentVersion;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            callbacks.dealloc = deallocCallback;
            
            // 设置需要绘制的大小
            MinGlyphMetricsRef metrics = malloc(sizeof(MinGlyphMetrics));
            metrics->ascent = self.config.font.ascender;
            metrics->descent = -self.config.font.descender;
            metrics->width = self.config.emojiSize.width;
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, metrics);

            // 添加属性字典
            [result addAttribute:(NSString *)kCTRunDelegateAttributeName
                           value:(__bridge id)delegate
                           range:spaceRange];
            
            // 释放内存
            CFRelease(delegate);
            
            // 设置自定义属性
            [result addAttribute:kMinAttributeType
                           value:[NSNumber numberWithInteger:MinAttributeEmoji]
                           range:spaceRange];
            
            [result addAttribute:kEmojiAttributeName
                           value:emojiName
                           range:spaceRange];
            
            
            
        }
        
    }
    // 处理后续非表情字符
    if (location < content.length) {
        NSRange range = NSMakeRange(location, content.length - location);
        NSString *substring = [content substringWithRange:range];
        NSMutableAttributedString *subAttributeString = [[NSMutableAttributedString alloc] initWithString:substring
                                                                                               attributes:textAttributeDict];
        [result appendAttributedString:subAttributeString];
    }
    
    // 匹配链接
    NSString *string = [result mutableString];
    NSRegularExpression *linkRegex =
    [NSRegularExpression regularExpressionWithPattern:_linkRegular
                                              options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
    NSArray *linkMatches = [linkRegex matchesInString:string
                                                options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                  range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in linkMatches) {
        NSRange range = match.range;
        
        // 添加属性
        [result addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)self.config.linkColor.CGColor
                       range:range];
        // 设置自定义属性
        [result addAttribute:kMinAttributeType
                       value:[NSNumber numberWithInteger:MinAttributeLink]
                       range:range];
        [result addAttribute:KMinAttributeRange
                       value:[NSValue valueWithRange:range]
                       range:range];
    }
    
    // 匹配@
    NSRegularExpression *atRegex =
    [NSRegularExpression regularExpressionWithPattern:_atRegular
                                              options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                error:nil];
    NSArray *atMatches = [atRegex matchesInString:string
                                              options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in atMatches) {
        NSRange range = match.range;
        
        // 添加属性
        [result addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)self.config.atColor.CGColor
                       range:range];
        // 设置自定义属性
        [result addAttribute:kMinAttributeType
                       value:[NSNumber numberWithInteger:MinAttributeAt]
                       range:range];
        [result addAttribute:KMinAttributeRange
                       value:[NSValue valueWithRange:range]
                       range:range];
    }
    
    
    return result;
}

#pragma mark - Private Method

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

static void deallocCallback(void *refCon) {
    free(refCon), refCon = NULL;
}

static CGFloat ascentCallback(void *refCon) {
    MinGlyphMetricsRef metrics = (MinGlyphMetricsRef)refCon;
    return metrics->ascent;
}

static CGFloat descentCallback(void *refCon) {
    MinGlyphMetricsRef metrics = (MinGlyphMetricsRef)refCon;
    return metrics->descent;
}

static CGFloat widthCallback(void *refCon) {
    MinGlyphMetricsRef metrics = (MinGlyphMetricsRef)refCon;
    return metrics->width;
}

/// 文本属性字典
- (NSDictionary *)textAttributeDictionary {
    
    // 字体
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.config.font.fontName, self.config.font.pointSize, NULL);
    // 段落
    CGFloat lineSpacing = self.config.lineSpace;
    const CFIndex kNumberOfSettings = 4;
    
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;
    
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreak}
    };
    CTParagraphStyleRef theParagraphStyleRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    // 颜色
    UIColor *textColor = self.config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(NSString *)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(NSString *)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(NSString *)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphStyleRef;

    // 释放内存
    CFRelease(fontRef);
    CFRelease(theParagraphStyleRef);
    
    return dict;
}


#pragma mark - Lazy Loading

- (MinRichTextConfig *)config {
    
    if (!_config) {
        _config = [[MinRichTextConfig alloc] init];
    }
    
    return _config;
}


@end
