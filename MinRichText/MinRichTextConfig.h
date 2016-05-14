//
//  MinRichTextConfig.h
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinRichText.h"

@interface MinRichTextConfig : NSObject

@property (nonatomic, strong) UIFont *font;/*!< 默认字体 */
@property (nonatomic, strong) UIColor *textColor;/*!< 默认颜色 */
@property (nonatomic, strong) UIColor *atColor;/*!< @颜色 */
@property (nonatomic, strong) UIColor *clickBackgroundColor;/*!< 点击背景颜色 */
@property (nonatomic, strong) UIColor *linkColor;/*!< 链接颜色 */
@property (nonatomic, assign) CGFloat lineSpace;/*!< 行间距 */
@property (nonatomic, assign) CGSize emojiSize;/*!< 表情大小 */
@property (nonatomic, assign) CGFloat width;/*!< 默认宽度 */


@end
