//
//  PlotItem.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#else
#import <CorePlot/CorePlot.h>
#endif

@class CPGraph;
@class CPTheme;

@interface PlotItem : NSObject
{
    CPLayerHostingView  *defaultLayerHostingView;
    NSMutableArray      *graphs;
    NSString            *title;

#if TARGET_OS_IPHONE
    UIImage             *cachedImage;
#else
    NSImage             *cachedImage;
#endif
}

@property (nonatomic, retain) CPLayerHostingView *defaultLayerHostingView;
@property (nonatomic, retain) NSMutableArray *graphs;
@property (nonatomic, retain) NSString *title;

+ (void)registerPlotItem:(id)item;

#if TARGET_OS_IPHONE
- (void)renderInView:(UIView *)hostingView withTheme:(CPTheme *)theme;
- (UIImage *)image;
#else
- (void)renderInView:(NSView *)hostingView withTheme:(CPTheme *)theme;
- (NSImage *)image;
- (void)setFrameSize:(NSSize)size;
#endif

- (void)renderInLayer:(CPLayerHostingView *)layerHostingView withTheme:(CPTheme *)theme;

- (void)reloadData;
- (void)applyTheme:(CPTheme *)theme toGraph:(CPGraph *)graph withDefault:(CPTheme *)defaultTheme;

- (void)killGraph;

@end
