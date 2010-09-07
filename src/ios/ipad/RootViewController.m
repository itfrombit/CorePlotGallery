//
//  RootViewController.m
//  Plot Gallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"

#import "PlotGallery.h"
#import "PlotItem.h"

@implementation RootViewController

@synthesize detailViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tv
{
	return 1;
}


- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
    return [[PlotGallery sharedPlotGallery] count];
}


- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{    
    static NSString* cellId = @"PlotCell";

    UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

	// Render the plot offscreen to create an image for the tableview
	PlotItem* plotItem = [[PlotGallery sharedPlotGallery] objectAtIndex:indexPath.row];

	cell.imageView.image = [plotItem image];
    cell.textLabel.text = plotItem.title;

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PlotItem* plotItem = [[PlotGallery sharedPlotGallery] objectAtIndex:indexPath.row];
	detailViewController.detailItem = plotItem;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	detailViewController = nil;
}

- (void)dealloc
{
    [detailViewController release];
    [super dealloc];
}


@end

