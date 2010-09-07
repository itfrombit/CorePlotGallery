//
//  PlotItem.m
//  Plot Gallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGallery.h"
#import "PlotItem.h"

#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
// For IKImageBrowser
#import <Quartz/Quartz.h>
#endif

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize title;


+ (void)registerPlotItem:(id)item
{
	Class itemClass = [item class];
	
	if (itemClass)
	{
		// There's no autorelease pool here yet...
		PlotItem* plotItem = [[itemClass alloc] init];
		if (plotItem)
		{
			[[PlotGallery sharedPlotGallery] addPlotItem:plotItem];
			[plotItem release];
		}
	}
}

- (id)init
{
	self = [super init];
	
	if (self == nil)
		return nil;
	
	graphs = [[NSMutableArray alloc] init];
	return self;
}


- (void)killGraph
{
	// Remove the CPLayerHostingView
	if (defaultLayerHostingView)
	{
		[defaultLayerHostingView removeFromSuperview];
		defaultLayerHostingView.hostedLayer = nil;
		[defaultLayerHostingView release];
		defaultLayerHostingView = nil;
	}
	
	[graphs removeAllObjects];
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

- (UIImage*)image
{
	CGRect imageFrame = CGRectMake(0, 0, 800, 600);
	
	UIView* imageView = [[UIView alloc] initWithFrame:imageFrame];
	
	[self renderInView:imageView withTheme:nil];
	[self reloadData];

	UIGraphicsBeginImageContext(imageView.bounds.size);
		CGContextRef c = UIGraphicsGetCurrentContext();
		CGContextGetCTM(c);
		CGContextScaleCTM(c, 1, -1);
		CGContextTranslateCTM(c, 0, -imageView.bounds.size.height);
		[imageView.layer renderInContext:c];
		UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[imageView release];
	
	return image;
}

#else

- (NSImage*)image
{
	CGRect imageFrame = CGRectMake(0, 0, 800, 600);
	
	NSView* imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
	[imageView setWantsLayer:YES];
	
	[self renderInView:imageView withTheme:nil];
	[self reloadData];
	
	CGSize boundsSize = imageFrame.size;
	
	NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
																		   pixelsWide:boundsSize.width 
																		   pixelsHigh:boundsSize.height 
																		bitsPerSample:8 
																	  samplesPerPixel:4 
																			 hasAlpha:YES 
																			 isPlanar:NO 
																	   colorSpaceName:NSCalibratedRGBColorSpace 
																		  bytesPerRow:(NSInteger)boundsSize.width * 4 
																		 bitsPerPixel:32];
	NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
	CGContextRef context = (CGContextRef)[bitmapContext graphicsPort];

	CGContextClearRect(context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height));
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetShouldSmoothFonts(context, false);
	[imageView.layer renderInContext:context];
	CGContextFlush(context);
	
    NSImage *image = [[[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)] autorelease];
    [image addRepresentation:layerImage];
	[layerImage release];

	[imageView release];
	
	return image;	
}
	
#endif
	

- (void)applyTheme:(CPTheme*)theme toGraph:(CPGraph*)graph withDefault:(CPTheme*)defaultTheme
{
	if (theme == nil)
	{
		[graph applyTheme:defaultTheme];
	}
	else if (![theme isKindOfClass:[NSNull class]])
	{
		[graph applyTheme:theme];
	}	
}

#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)setFrameSize:(NSSize)size
{
}
#endif


#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)renderInView:(UIView*)hostingView withTheme:(CPTheme*)theme
#else
- (void)renderInView:(NSView*)hostingView withTheme:(CPTheme*)theme
#endif
{
	[self killGraph];

	// Create a default CPLayerHostingView
	defaultLayerHostingView = [[CPLayerHostingView alloc] initWithFrame:[hostingView bounds]];
	
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
	[defaultLayerHostingView setAutoresizesSubviews:YES];
	[defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif

	[hostingView addSubview:defaultLayerHostingView];
	[self renderInLayer:defaultLayerHostingView withTheme:theme];
}

- (void)renderInLayer:(CPLayerHostingView*)layerHostingView withTheme:(CPTheme*)theme
{
	NSLog(@"PlotItem:renderInLayer: Override me");
}

- (void)reloadData
{
	for (CPGraph* g in graphs)
		[g reloadData];
}


- (void)dealloc
{
	[super dealloc];
}


#pragma mark -
#pragma mark IKImageBrowserItem methods

#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED

- (NSString*)imageUID
{
	return title;
}

- (NSString*)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
	return [self image];
}

- (NSString*)imageTitle
{
	return title;
}

#if 0
- (NSString*)imageSubtitle
{
	return graph.title;
}
#endif

#endif

@end
