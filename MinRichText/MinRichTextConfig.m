//
//  MinRichTextConfig.m
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "MinRichTextConfig.h"

@implementation MinRichTextConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _width = 200.f;
    _lineSpace = 5.f;
    _font = [UIFont systemFontOfSize:16.f];
    _textColor = [UIColor darkTextColor];
    _atColor = [UIColor grayColor];
    _clickBackgroundColor = [UIColor lightGrayColor];
    _linkColor = [UIColor blueColor];
    CGFloat emojiHeight = _font.ascender - _font.descender;
    CGFloat emojiWidth = emojiHeight;
    _emojiSize = CGSizeMake(emojiWidth, emojiHeight);
}

@end
