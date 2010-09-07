//
//  SimpleScatterPlot.m
//  CPTestGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "SimpleScatterPlot.h"

@implementation SimpleScatterPlot

+ (void)load
{
	[super registerPlotItem:self];
}

- (id)init
{
	self = [super init];
	
	title = @"Simple Scatter Plot";

	return self;
}

- (void)killGraph
{
	if ([graphs count])
	{		
		CPGraph* graph = [graphs objectAtIndex:0];
		
		if (symbolTextAnnotation)
		{
			[graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
			[symbolTextAnnotation release];
			symbolTextAnnotation = nil;
		}
	}
	
	[super killGraph];
}


- (void)generateData
{
    // Add some initial data
	if (plotData == nil)
	{
		NSMutableArray *contentArray = [NSMutableArray array];
		for ( NSUInteger i = 0; i < 10; i++ ) {
			id x = [NSDecimalNumber numberWithDouble:1.0 + i * 0.05];
			id y = [NSDecimalNumber numberWithDouble:1.2 * rand()/(double)RAND_MAX + 0.5];
			[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
		}
		
		plotData = [contentArray retain];
	}
}


- (void)renderInLayer:(CPLayerHostingView *)layerHostingView withTheme:(CPTheme*)theme
{
	// Core-Plot view
	CPGraph* graph = [[[CPXYGraph alloc] initWithFrame:layerHostingView.bounds] autorelease];
	[graphs addObject:graph];

	[self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPDarkGradientTheme]];
	
	layerHostingView.hostedLayer = graph;
	graph.title = title;
    CPTextStyle *textStyle = [CPTextStyle textStyle];
    textStyle.color = [CPColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 18.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
    graph.titlePlotAreaFrameAnchor = CPRectAnchorTop;
	
    // Graph padding
    graph.paddingLeft = 60.0;
    graph.paddingTop = 60.0;
    graph.paddingRight = 60.0;
    graph.paddingBottom = 60.0;
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    // Grid line styles
    CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.1];    
    
    CPLineStyle *redLineStyle = [CPLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPColor redColor] colorWithAlphaComponent:0.5];
	
    // Axes
    // Label x axis with a fixed interval policy
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"1");
    x.minorTicksPerInterval = 2;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
	
	x.title = @"X Axis";
	x.titleOffset = 30.0;
	x.titleLocation = CPDecimalFromString(@"3.0");
	
	// Label y with an automatic label policy. 
    CPXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPAxisLabelingPolicyAutomatic;
    y.orthogonalCoordinateDecimal = CPDecimalFromString(@"1");
    y.minorTicksPerInterval = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelOffset = 10.0;
    
	y.title = @"Y Axis";
	y.titleOffset = 30.0;
	y.titleLocation = CPDecimalFromString(@"2.7");
	
    // Rotate the labels by 45 degrees, just to show it can be done.
	labelRotation = M_PI * 0.25;
	
    // Set axes
    //graph.axisSet.axes = [NSArray arrayWithObjects:x, y, y2, nil];
	graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.0;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Put an area gradient under the plot above
    CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
    areaGradient.angle = -90.0;
    CPFill* areaGradientFill = [CPFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"0.0");
	
	[self generateData];

    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:dataSourceLinePlot, nil]];
    CPPlotRange *xRange = plotSpace.xRange;
    CPPlotRange *yRange = plotSpace.yRange;
    [xRange expandRangeByFactor:CPDecimalFromDouble(1.3)];
    [yRange expandRangeByFactor:CPDecimalFromDouble(1.1)];
    plotSpace.yRange = yRange;
    
    // Restrict y range to a global range
    CPPlotRange *globalYRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) 
															length:CPDecimalFromFloat(6.0f)];
    plotSpace.globalYRange = globalYRange;
    
    // set the x and y shift to match the new ranges
	CGFloat length = xRange.lengthDouble;
	xShift = length - 3.0;
	length = yRange.lengthDouble;
	yShift = length - 2.0;
    
	// Add plot symbols
	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPColor blackColor];
	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
	// We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self; 
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0f;
}

- (void)dealloc
{
	[symbolTextAnnotation release];
	[plotData release];
	
	[super dealloc];
}


#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    if ( [plot isKindOfClass:[CPBarPlot class]] ) 
        return 8;
    else
        return [plotData count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber* num = [[plotData objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if (fieldEnum == CPScatterPlotFieldY)
	{
		num = [NSNumber numberWithDouble:[num doubleValue]];
	}

    return num;
}


#pragma mark Plot Space Delegate Methods

-(CPPlotRange *)plotSpace:(CPPlotSpace *)space 
	willChangePlotRangeTo:(CPPlotRange *)newRange 
			forCoordinate:(CPCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if ( coordinate == CPCoordinateX )
	{
        CPPlotRange *maxRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0f) length:CPDecimalFromFloat(6.0f)];
        CPPlotRange *changedRange = [[newRange copy] autorelease];
        [changedRange shiftEndToFitInRange:maxRange];
        [changedRange shiftLocationToFitInRange:maxRange];
        newRange = changedRange;
    }
    
    return newRange;
}

#pragma mark -
#pragma mark CPScatterPlot delegate method

-(void)scatterPlot:(CPScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
	CPXYGraph* graph = [graphs objectAtIndex:0];
	
	if (symbolTextAnnotation)
	{
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
		[symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTextStyle *hitAnnotationTextStyle = [CPTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [[plotData objectAtIndex:index] valueForKey:@"x"];
    NSNumber *y = [[plotData objectAtIndex:index] valueForKey:@"y"];
	NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTextLayer *textLayer = [[[CPTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
	symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}


@end
