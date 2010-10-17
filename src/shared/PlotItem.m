//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGallery.h"
#import "PlotItem.h"

#if !TARGET_OS_IPHONE
// For IKImageBrowser
#import <Quartz/Quartz.h>
#endif

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize title;

+ (void)registerPlotItem:(id)item
{
    NSLog(@"registerPlotItem for class %@", [item class]);

    Class itemClass = [item class];
	
    if (itemClass) {
        // There's no autorelease pool here yet...
        PlotItem *plotItem = [[itemClass alloc] init];
        if (plotItem) {
            [[PlotGallery sharedPlotGallery] addPlotItem:plotItem];
            [plotItem release];
        }
    }
}

- (id)init
{
    if (self = [super init]) {
        graphs = [[NSMutableArray alloc] init];
    }

    return self;
}


- (void)killGraph
{
    // Remove the CPLayerHostingView
    if (defaultLayerHostingView) {
        [defaultLayerHostingView removeFromSuperview];
        defaultLayerHostingView.hostedLayer = nil;
        [defaultLayerHostingView release];
        defaultLayerHostingView = nil;
    }

    [cachedImage release];
    cachedImage = nil;

    [graphs removeAllObjects];
}

- (void)dealloc
{
    [self killGraph];
    [super dealloc];
}


#if TARGET_OS_IPHONE

// There's a UIImage function to scale and orient an existing image,
// but this will also work in pre-4.0 iOS
- (CGImageRef)scaleCGImage:(CGImageRef)image toSize:(CGSize)size
{
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    CGContextRef c = CGBitmapContextCreate(NULL,
                                           size.width,
                                           size.height,
                                           CGImageGetBitsPerComponent(image),
                                           CGImageGetBytesPerRow(image),
                                           colorspace,
                                           CGImageGetAlphaInfo(image));
    CGColorSpaceRelease(colorspace);

    if (c == NULL) {
        return nil;
    }

    CGContextDrawImage(c, CGRectMake(0, 0, size.width, size.height), image);
    CGImageRef newImage = CGBitmapContextCreateImage(c);
    CGContextRelease(c);
	
    return newImage;
}

- (UIImage *)image
{
    if (cachedImage == nil) {
        CGRect imageFrame = CGRectMake(0, 0, 800, 600);

        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];

        [self renderInView:imageView withTheme:nil];
        [self reloadData];

        UIGraphicsBeginImageContext(imageView.bounds.size);
            CGContextRef c = UIGraphicsGetCurrentContext();
            CGContextGetCTM(c);
            CGContextScaleCTM(c, 1, -1);
            CGContextTranslateCTM(c, 0, -imageView.bounds.size.height);
            [imageView.layer renderInContext:c];
            UIImage* bigImage = UIGraphicsGetImageFromCurrentImageContext();
            // iOS 4.0 only
            //	cachedImage = [UIImage imageWithCGImage:[bigImage CGImage] 
            //									  scale:0.125f
            //								orientation:0.0f];
            cachedImage = [[UIImage imageWithCGImage:[self scaleCGImage:[bigImage CGImage] toSize:CGSizeMake(100.0f, 75.0f)]] retain];
        UIGraphicsEndImageContext();

        [imageView release];
    }

    return cachedImage;
}

#else  // OSX

- (NSImage *)image
{
    if (cachedImage == nil) {
        CGRect imageFrame = CGRectMake(0, 0, 800, 600);

		NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
        [imageView setWantsLayer:YES];

        [self renderInView:imageView withTheme:nil];
        [self reloadData];

        CGSize boundsSize = imageFrame.size;

        NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc] 
                                        initWithBitmapDataPlanes:NULL 
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

        cachedImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
        [cachedImage addRepresentation:layerImage];
        [layerImage release];

        [imageView release];
    }

    return cachedImage;	
}

#endif

- (void)applyTheme:(CPTheme *)theme toGraph:(CPGraph *)graph withDefault:(CPTheme *)defaultTheme
{
    if (theme == nil) {
        [graph applyTheme:defaultTheme];
    }
    else if (![theme isKindOfClass:[NSNull class]])	{
        [graph applyTheme:theme];
    }
}

#if !TARGET_OS_IPHONE
- (void)setFrameSize:(NSSize)size
{
}
#endif


#if TARGET_OS_IPHONE
- (void)renderInView:(UIView*)hostingView withTheme:(CPTheme*)theme
#else
- (void)renderInView:(NSView*)hostingView withTheme:(CPTheme*)theme
#endif
{
    [self killGraph];

    defaultLayerHostingView = [[CPLayerHostingView alloc] initWithFrame:[hostingView bounds]];

#if !TARGET_OS_IPHONE
    [defaultLayerHostingView setAutoresizesSubviews:YES];
    [defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif

    [hostingView addSubview:defaultLayerHostingView];
    [self renderInLayer:defaultLayerHostingView withTheme:theme];
}

- (void)renderInLayer:(CPLayerHostingView *)layerHostingView withTheme:(CPTheme *)theme
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

- (void)reloadData
{
    for (CPGraph *g in graphs) {
        [g reloadData];
    }
}


#pragma mark -
#pragma mark IKImageBrowserItem methods

#if !TARGET_OS_IPHONE

- (NSString *)imageUID
{
    return title;
}

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return [self image];
}

- (NSString *)imageTitle
{
	return title;
}

/*
- (NSString*)imageSubtitle
{
	return graph.title;
}
*/

#endif

@end
