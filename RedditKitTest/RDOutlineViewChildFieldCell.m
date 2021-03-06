//
//  RDOutlineViewChildFieldCell.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/8/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDOutlineViewChildFieldCell.h"

@implementation RDOutlineViewChildFieldCell

- (void)awakeFromNib
{
    isDark = NO;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
//    NSRect imageRect = [self imageRectForBounds:cellFrame];
//    if (image) {
//        [image drawInRect:imageRect
//                 fromRect:NSZeroRect
//                operation:NSCompositeSourceOver
//                 fraction:1.0
//           respectFlipped:YES
//                    hints:nil];
//    } else {
//        NSBezierPath *path = [NSBezierPath bezierPathWithRect:imageRect];
//        [[NSColor grayColor] set];
//        [path fill];
//    }
//    
//    NSRect titleRect = [self titleRectForBounds:cellFrame];
    NSAttributedString *title = [self attributedStringValue];
    if ([title length] > 0) {
        [title drawInRect:cellFrame];
    }
    
//
//    NSRect subtitleRect = [self subtitleRectForBounds:cellFrame forTitleBounds:titleRect];
//    NSAttributedString *aSubtitle = [self attributedSubtitleValue];
//    if ([aSubtitle length] > 0) {
//        [aSubtitle drawInRect:subtitleRect];
//    }
}

- (NSAttributedString *)attributedStringValue
{
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.6]];
    [shadow setShadowOffset:NSMakeSize(0, 1.0)];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.8f alpha:1.0f];
    if (isDark) {
        color = [NSColor whiteColor];
        [shadow setShadowOffset:NSMakeSize(0, -1.0)];
        [shadow setShadowBlurRadius:1.0f];
    }

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName,
                                       color, NSForegroundColorAttributeName,
                                      shadow, NSShadowAttributeName,
                                      nil];
    
    
    
    return [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
    
}

- (void)setBackgroundStyle:(NSBackgroundStyle)style
{
    [super setBackgroundStyle:style];
    
    switch (style) {
        case NSBackgroundStyleLight:
            isDark = NO;
            break;
            
        case NSBackgroundStyleDark:
        default:
            isDark = YES;
            break;
    }
}

@end
