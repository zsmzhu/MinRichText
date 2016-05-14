# MinRichText
CoreText Handle Link、@xxxx and Emoji image String
### Installation
#### CocoaPods
pod 'MinRichText'

### How to use
1.create a MinRichTextParser instance.
support the regular express
```
MinRichTextParser *parser = [MinRichTextParser shareInstance];
parser.linkRegular = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
parser.atRegular = @"@[-_a-zA-Z0-9\u4E00-\u9FA5]+";
parser.emojiRegular = @"\\[[^ \\[\\]]+?\\]";
```
support the dictionary for emoji image name and key
```
parser.emojiDict = emojiDcit;
```
2.parser the content string
```
NSMutableAttributedString *as = [parser parseContent:text];
```
3.create a MinRichTextView instance to show the attributedString
```
_richTextView.attributedString = as;
```
4.resize the frame
```
CGRect frame = _richTextView.frame;

frame.size = [MinRichTextView adjustSizeWithAttributedString:as maxWidth:_richTextView.frame.size.width];

_richTextView.frame = frame;
```

### Note
MinRichTextDelegate is a protocol of click motion  callback 
```
- (void)clickedLinkString:(NSString *)linkString;
- (void)clickedAtSring:(NSString *)atString;
```
MinRichTextConfig
you can set the font、text color、link color、click background color and so on in MinRichTextConfig.

#### Here you go