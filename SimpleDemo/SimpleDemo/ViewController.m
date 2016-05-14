//
//  ViewController.m
//  SimpleDemo
//
//  Created by songmin.zhu on 16/5/14.
//  Copyright © 2016年 zhusongmin. All rights reserved.
//

#import "ViewController.h"
#import "MinRichText.h"

@interface ViewController ()<MinRichTextDelegate>
@property (weak, nonatomic) IBOutlet MinRichTextView *richTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    NSString *text = @"@aldfjk www.baidu.com 为公高学素质供衡和指导。有条的科学精神了@知识 、www.baidu.com具备的能力[悲伤][拜拜][拜拜][悲伤]每条基准下列出了相应的点[拜拜][鄙视][鄙视][鄙视][鄙视][悲伤]@哈哈哈 [鄙视][鄙视][鄙视][鄙视][鄙视]。";
    
    _richTextView.delegate = self;
    MinRichTextParser *parser = [self richTextParser];
    NSMutableAttributedString *as = [parser parseContent:text];
    _richTextView.attributedString = as;
    
    CGRect frame = _richTextView.frame;
    frame.size = [MinRichTextView adjustSizeWithAttributedString:as maxWidth:_richTextView.frame.size.width];
    _richTextView.frame = frame;
}

- (NSDictionary *)emojiDict {
    NSString * emojiPath = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    NSDictionary *emojiDcit = [[NSDictionary alloc] initWithContentsOfFile:emojiPath];
    return emojiDcit;
}

- (MinRichTextParser *)richTextParser {
    MinRichTextParser *parser = [MinRichTextParser shareInstance];
    parser.linkRegular = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    parser.atRegular = @"@[-_a-zA-Z0-9\u4E00-\u9FA5]+";
    parser.emojiRegular = @"\\[[^ \\[\\]]+?\\]";
    parser.emojiDict = [self emojiDict];
    return parser;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedAtSring:(NSString *)atString {
    NSLog(@"%@", atString);
}

- (void)clickedLinkString:(NSString *)linkString {
    NSLog(@"%@", linkString);
}

@end
