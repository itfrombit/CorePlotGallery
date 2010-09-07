//
//  Plot_GalleryAppDelegate.m
//  Plot Gallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "Plot_GalleryAppDelegate.h"

#import "RootViewController.h"
#import "DetailViewController.h"

#import "PlotGallery.h"
#import "PlotItem.h"


#if 0
// Add new PlotItems to this list
static NSString* plotClasses[] =
{
	@"SimpleScatterPlot",
	@"GradientScatterPlot",
	@"SimplePieChart",
	@"VerticalBarChart",
	@"CompositePlot"
};
#endif


@implementation Plot_GalleryAppDelegate

@synthesize window;
@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
#if 0
	PlotGallery* gallery = [PlotGallery sharedPlotGallery];
	
	int plotCount = sizeof(plotClasses)/sizeof(NSString*);
	
	for (int i = 0; i < plotCount; i++)
	{
		Class plotClass = NSClassFromString(plotClasses[i]);
		id plotItem = [[[plotClass alloc] init] autorelease];
		if (plotItem)
		{
			[gallery addPlotItem:plotItem];
		}
	}
#endif

    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];

    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"AppDelegate:applicationDidReceiveMemoryWarning");
}


- (void)dealloc
{
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

