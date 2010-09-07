//
//  DetailViewController.m
//  Plot Gallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "ThemeTableViewController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController* popoverController;

- (CPTheme*)currentTheme;

@end


@implementation DetailViewController

@synthesize toolbar;
@synthesize popoverController;
@dynamic detailItem;
@synthesize hostingView;
@synthesize themeBarButton;
@synthesize themeTableViewController;
@synthesize currentThemeName;

#pragma mark -
#pragma mark Theme support

- (void)awakeFromNib
{
	self.currentThemeName = [NSString stringWithFormat:@"Theme: %@",
							 kThemeTableViewControllerDefaultTheme];
}


#pragma mark -
#pragma mark Managing the detail item

- (PlotItem*)detailItem
{
	return detailItem;
}


- (void)setDetailItem:(id)newDetailItem 
{
    if (detailItem != newDetailItem)
	{
		[detailItem killGraph];
        [detailItem release];
		
        detailItem = [newDetailItem retain];

		[detailItem renderInView:hostingView withTheme:[self currentTheme]];
	}

    if (popoverController != nil)
	{
        [popoverController dismissPopoverAnimated:YES];
    }
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem
	   forPopoverController: (UIPopoverController*)pc
{    
    barButtonItem.title = @"Plot Gallery";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController*)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem*)barButtonItem
{
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[detailItem renderInView:hostingView withTheme:[self currentTheme]];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	themeBarButton.title = currentThemeName;
}

- (void)viewDidUnload
{
    self.popoverController = nil;
	self.themeBarButton = nil;
}

#pragma mark -
#pragma mark Theme Selection

- (CPTheme*)currentTheme
{
	CPTheme* theme;
	
	if (currentThemeName == kThemeTableViewControllerNoTheme)
	{
		theme = (id)[NSNull null];
	}
	else if (currentThemeName == kThemeTableViewControllerDefaultTheme)
	{
		theme = nil;
	}
	else
	{
		theme = [CPTheme themeNamed:currentThemeName];
	}
	
	return theme;
}

- (void)closeThemePopover
{
	// Cancel the popover
	[themePopoverController dismissPopoverAnimated:YES];
	[themePopoverController release];
	themePopoverController = nil;	
}

- (IBAction)showThemes:(id)sender
{
	if (themePopoverController == nil)
	{
		themePopoverController = [[UIPopoverController alloc]
								  initWithContentViewController:themeTableViewController];
	
		[themeTableViewController setThemePopoverController:themePopoverController];
		[themePopoverController setPopoverContentSize:CGSizeMake(320, 320)];

		[themePopoverController presentPopoverFromBarButtonItem:themeBarButton
									   permittedArrowDirections:UIPopoverArrowDirectionAny
													   animated:YES];
	}
	else
	{
		[self closeThemePopover];
	}
}

- (void)themeSelectedAtIndex:(NSString*)themeName
{
	themeBarButton.title = [NSString stringWithFormat:@"Theme: %@", themeName];
	self.currentThemeName = themeName;
	
	[self closeThemePopover];

	[detailItem renderInView:hostingView withTheme:[self currentTheme]];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
    [hostingView release];
	[themeBarButton release];
	
    [super dealloc];
}

@end
