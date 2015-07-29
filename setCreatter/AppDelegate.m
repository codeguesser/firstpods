//
//  AppDelegate.m
//  setCreatter
//
//  Created by wsg on 15/7/3.
//  Copyright (c) 2015年 wsg. All rights reserved.
//

#import "AppDelegate.h"

@implementation NSString(category)
- (NSString *) capitalizedFirstCharacterString
{
    if ([self length] > 0)
    {
        NSString *firstChar = [[self substringToIndex:1] capitalizedString];
        return [firstChar stringByAppendingString:[self substringFromIndex:1]];
    }
    return self;
}
@end
@interface AppDelegate (){
    
    __unsafe_unretained IBOutlet NSTextView *_textView;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [[NSApplication sharedApplication]
//    [[NSPasteboard generalPasteboard] clearContents];
}
- (IBAction)transform:(NSButton *)sender {
    
    NSArray *arr = [_textView.string componentsSeparatedByString:@"\n"];
    NSMutableArray *arrNew = [NSMutableArray new];
    for (NSString *s in arr) {
        if ([s hasPrefix:@"@property"]&&[s hasSuffix:@";"]) {
            NSRegularExpression * rex = [NSRegularExpression regularExpressionWithPattern:@"^@property(.*)\\*{1}(.*);" options:NSRegularExpressionCaseInsensitive error:nil];
            [rex enumerateMatchesInString:s options:0 range:NSMakeRange(0, s.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange range = [result rangeAtIndex:2];
                if (range.location != NSNotFound) {
                    NSString *s1 = [s substringWithRange:range];
                    [arrNew addObject:s1];
                }
            }];
        }
    }
    NSMutableArray *arrOfValues = [NSMutableArray new];
    NSMutableArray *arrOfMethods = [NSMutableArray new];
    [arrNew enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        [arrOfValues addObject:[NSString stringWithFormat:@"@\"%@\"",obj]];
        [arrOfMethods addObject:[NSString stringWithFormat:@"-(void)set%@:(NSString *)%@{\n\
                                 _%@ = [self dataFromValue:%@];\n\
                                 }\n",[obj capitalizedFirstCharacterString],obj,obj,obj]];
    }];
    
    
    NSString * valueString = [arrOfValues componentsJoinedByString:@","];
    NSString * methodString = [arrOfMethods componentsJoinedByString:@"\n"];
    NSString *targetString = [NSString stringWithFormat:@"+ (NSArray *)propertyKeys{\n\
                              return @[%@];\n\
                              }\n%@",valueString,methodString];
    
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pasteboard setString:targetString forType:NSStringPboardType];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(void)applicationWillBecomeActive:(NSNotification *)notification{
    NSLog(@"激活");
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    //判断是否包含RTF
    if ([pasteboard canReadItemWithDataConformingToTypes:@[NSPasteboardTypeRTF,NSPasteboardTypeString]])
    {
//        //获取RTF代表的文本
        NSString *plainText = [[pasteboard readObjectsForClasses:@[[NSString class]] options:nil] firstObject];
        //获取AttributedText
//        NSAttributedString *attributedStr = [[pasteboard readObjectsForClasses:@[[NSAttributedString class]] options:nil] firstObject];
//        //获取RTF源文本
//        NSString *rawRTFText = [NSString stringWithUTF8String:[pasteboard dataForType:NSPasteboardTypeRTF].bytes];
        
        NSLog(@"纯文本: %@", plainText);
        _textView.string = plainText;
        [pasteboard clearContents];
//        NSLog(@"AttributedText: %@", attributedStr);
        
//        NSLog(@"RTF: %@", rawRTFText);
    }
}

@end
