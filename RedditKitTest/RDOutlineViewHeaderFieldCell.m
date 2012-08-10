//
//  RDOutlineViewHeaderFieldCell.m
//  RedditKitTest
//
//  Created by Robert Dougan on 8/8/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import "RDOutlineViewHeaderFieldCell.h"

@implementation RDOutlineViewHeaderFieldCell

- (void)awakeFromNib
{
    isDark = NO;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSAttributedString *title = [self attributedStringValue];
    if ([title length] > 0) {
        [title drawInRect:cellFrame];
    }
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
