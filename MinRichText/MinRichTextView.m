//
//  MinRichTextView.m
//  MinRichTextDemo
//
//  Created by songmin.zhu on 16/5/4.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "MinRichTextView.h"

const CFIndex kNoTouchIndex = -1;
const CGPoint kErrorPoint = {.x = CGFLOAT_MAX, .y = CGFLOAT_MAX};

/// 翻转坐标点
NS_INLINE CGPoint CGPointFilpped(CGPoint point, CGRect bounds) {
    return CGPointMake(point.x, CGRectGetMaxY(bounds) - point.y);
}

/// 翻转Rect
NS_INLINE CGRect CGRectFlipped(CGRect rect, CGRect bounds) {
    return CGRectMake(CGRectGetMinX(rect),
                      CGRectGetMaxY(bounds) - CGRectGetMaxY(rect),
                      CGRectGetWidth(rect),
                      CGRectGetHeight(rect));
}

static Boolean isTouchRange(CFIndex index, CFRange touch_range, CFRange run_range) {
    if (touch_range.location < index && touch_range.location + touch_range.length >= index) {
        return CFRangesIntersect(touch_range, run_range);
    } else {
        return FALSE;
    }
}

const CFRange CFRangeZero = {0, 0};

@interface MinRichTextView ()
@property (nonatomic, assign) UITouchPhase touchPhase;/*!< 点击状态 */
@property (nonatomic, assign) CGPoint beginPoint;/*!< 开始点击的坐标点 */
@property (nonatomic, assign) CGPoint endPoint;/*!< 结束点击的坐标点 */
@property (nonatomic, assign) CFIndex beginIndex;/*!< 开始点击的Range位置 */
@property (nonatomic, assign) CFIndex endIndex;/*!< 结束点击的Range位置 */
@end

@implementation MinRichTextView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _touchPhase = UITouchPhaseCancelled;
}

+ (CGSize)adjustSizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)width {
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)attributedString);
    
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, maxSize, NULL);
    
    CFRelease(framesetter);
    
    return CGSizeMake(floor(size.width) + 1, floor(size.height) + 1);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.attributedString) {
        return;
    }
    
    // 描绘区域
    CTFramesetterRef framesetterRef =
        CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)_attributedString);
    CGPathRef pathRef = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, NULL);
    
    // 翻转坐标系
    // 由CoreText坐标系(原点左下角)转为UIView坐标系(原点左上角)
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertial = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
    CGContextConcatCTM(context, flipVertial);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    // 获取CTFrame中的CTLine
    CFArrayRef lineArray = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lineArray);
    CGPoint originArray[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), originArray);
    
    // 寻找点击位置
    for (CFIndex i = 0; i < lineCount; ++i) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        // 获取CTLine中的CTRun
        CFArrayRef runArray = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runArray);
        for (CFIndex j = 0; j < runCount; ++j) {
            CTRunRef run = CFArrayGetValueAtIndex(runArray, j);

            CGFloat ascent, descent, leading, height, width;
            width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            CGFloat x = originArray[i].x + xOffset;
            CGFloat y = originArray[i].y - descent;
            CGRect runBounds = CGRectMake(x, y, width, height);
            
            if (_touchPhase == UITouchPhaseBegan) {
                CGPoint flippedPoint = CGPointFilpped(_beginPoint, rect);
                if (CGRectContainsPoint(runBounds, flippedPoint)) {
                    _beginIndex = CTLineGetStringIndexForPosition(line, flippedPoint);
                    break;
                }
            } else if (_touchPhase == UITouchPhaseEnded) {
                CGPoint flippedPoint = CGPointFilpped(_endPoint, rect);
                if (CGRectContainsPoint(runBounds, flippedPoint)) {
                    _endIndex = CTLineGetStringIndexForPosition(line, flippedPoint);
                    break;
                }
            }
            
        }
    }
    
    // draw
    for (CFIndex i = 0; i < lineCount; ++i) {
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        
        CGFloat lineAscent, lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        
        CFArrayRef runArray = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runArray);
        for (CFIndex j = 0; j < runCount; ++j) {
            CTRunRef run = CFArrayGetValueAtIndex(runArray, j);
            CFRange range = CTRunGetStringRange(run);
            CGContextSetTextPosition(context, originArray[i].x, originArray[i].y);
            
            // 获取CTRun属性
            NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
            NSNumber *typeValue = attDic[kMinAttributeType];
            if (typeValue) {
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
                CGFloat height = lineAscent + lineDescent;
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat x = originArray[i].x + xOffset;
                CGFloat y = originArray[i].y - lineDescent;
                CGRect runBounds = CGRectMake(x, y, width, height);
                
                NSInteger type = typeValue.integerValue;
                
                if (type <= MinAttributeAt) {
                    // 文字范围
                    NSValue *value = attDic[KMinAttributeRange];
                    CFRange linkRange = CFRangeFromNSRange([value rangeValue]);
                    
                    // 先绘制背景，不然文字会被背景覆盖
                    if (_touchPhase == UITouchPhaseBegan && isTouchRange(_beginIndex, linkRange, range)) {// 点击开始
                        CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
                        CGContextFillRect(context, runBounds);
                        
//                        CGPathRef path = [[UIBezierPath bezierPathWithRoundedRect:runBounds cornerRadius:5] CGPath];
//                        CGContextAddPath(context, path);
//                        CGContextFillPath(context);
                        
                    } else {// 点击结束
                        BOOL isSameRange = NO;
                        if (isTouchRange(_beginIndex, linkRange, range)) {// 如果点击区域落在链接区域内
                            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                            CGContextFillRect(context, runBounds);
                            // beginIndex & endIndex in the same range
                            isSameRange = isTouchRange(_endIndex, linkRange, range);
                        }
                        CGPoint mirrorPoint = CGPointFilpped(_endPoint, rect);
                        if (_touchPhase == UITouchPhaseEnded &&
                            CGRectContainsPoint(runBounds, mirrorPoint) &&
                            isSameRange) {
                            if (type == MinAttributeLink) {

                                if (self.delegate && [self.delegate respondsToSelector:@selector(clickedLinkString:)]) {
                                    [self.delegate clickedLinkString:[self.attributedString.string substringWithRange:[value rangeValue]]];
                                }
                            }
                            else if (type == MinAttributeAt) {
                                if (self.delegate && [self.delegate respondsToSelector:@selector(clickedAtSring:)]) {
                                    [self.delegate clickedLinkString:[self.attributedString.string substringWithRange:[value rangeValue]]];
                                }
                            }
                            else if (type == MinAttributeInfoImage) {
                                #warning 点击处理Todo！
                            }
                            else {
                                NSAssert(NO, @"error type");
                            }
                        }
                    }
                    // 绘制文字
                    CTRunDraw(run, context, CFRangeMake(0, 0));
                    if (type == MinAttributeLink) {
                        // 这里需要绘制下划线，记住CTRun是不会自动绘制下滑线的
                        // 即使你设置了这个属性也不行
                        // CTRun.h中已经做出了相应的说明
                        // 所以这里的下滑线我们需要自己手动绘制
                        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
                        CGContextSetLineWidth(context, 0.5);
                        CGContextMoveToPoint(context, runBounds.origin.x, runBounds.origin.y);
                        CGContextAddLineToPoint(context, runBounds.origin.x + runBounds.size.width, runBounds.origin.y);
                        CGContextStrokePath(context);
                    }
                }
                else if (type == MinAttributeEmoji) {
                    // 重新表情图片大小计算
                    CGFloat ascent, descent, leading, emojiHeight, emojiWidth;
                    emojiWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                    emojiHeight = ascent + descent;
                    runBounds = CGRectMake(x, y, emojiWidth, emojiHeight);
                    NSString *emojiName = attDic[kEmojiAttributeName];
                    UIImage *emoji = [UIImage imageNamed:emojiName];
                    CGContextDrawImage(context, runBounds, emoji.CGImage);
                }
            } else { // 没有特殊处理的时候我们只进行文字的绘制
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }

    // 释放内存
    CFRelease(framesetterRef);
    CFRelease(pathRef);
    CFRelease(frameRef);
    
}

- (void)setAttributedString:(NSMutableAttributedString *)attributedString {
    if (_attributedString != attributedString) {
        _attributedString = attributedString;
    }
    [self setNeedsDisplay];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _beginPoint = point;
    _touchPhase = touch.phase;
    _beginIndex = kNoTouchIndex;
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchPhase = touch.phase;
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        [self touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _endPoint = [touch locationInView:self];
    _touchPhase = touch.phase;
    _endIndex = kNoTouchIndex;
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchPhase = touch.phase;
    _endPoint = kErrorPoint;
    _endIndex = kNoTouchIndex;
    
    [self setNeedsDisplay];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!newWindow) {// disappear
        _touchPhase = UITouchPhaseCancelled;
        _endPoint = kErrorPoint;
        _endIndex = kNoTouchIndex;
        
        [self setNeedsDisplay];
    }
}


@end








