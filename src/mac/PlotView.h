//
//  PlotView.h
//  Plot Gallery-Mac
//
//  Created by Jeff Buck on 9/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PlotView : NSView
{
	id delegate;
}

@property (nonatomic, retain) id delegate;

@end
