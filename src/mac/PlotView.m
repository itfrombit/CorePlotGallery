//
//  PlotView.m
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 9/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotView.h"


@implementation PlotView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
}

- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	
	if ([delegate respondsToSelector:@selector(setFrameSize:)])
		[delegate setFrameSize:newSize];
}

@end
