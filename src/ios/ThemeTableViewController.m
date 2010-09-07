//
//  ThemeTableViewController.m
//  Plot Gallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "ThemeTableViewController.h"
#import "CorePlot-CocoaTouch.h"


@implementation ThemeTableViewController

@synthesize themePopoverController;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)setupThemes
{
	themes = [[NSMutableArray alloc] init];
	
	[themes addObject:kThemeTableViewControllerDefaultTheme];
	[themes addObject:kThemeTableViewControllerNoTheme];
	
	for (Class c in [CPTheme themeClasses])
	{
		[themes addObject:[c defaultName]];
	}
}

- (void)awakeFromNib
{
	[self setupThemes];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [themes count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [themes objectAtIndex:indexPath.row];
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[delegate themeSelectedAtIndex:[themes objectAtIndex:indexPath.row]];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc
{
	[self.tableView setDataSource:nil];
	[self.tableView setDelegate:nil];

	[themes release];
    [super dealloc];
}


@end

