//
//  CompositePlot.h
//  Plot Gallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"
#import "PlotGallery.h"


@interface CompositePlot : PlotItem <CPPlotSpaceDelegate,
									 CPPlotDataSource,
									 CPScatterPlotDelegate,
									 CPBarPlotDelegate>
{
	CPLayerHostingView*			scatterPlotView;
	CPLayerHostingView*			barChartView;
	CPLayerHostingView*			pieChartView;
	
	CPXYGraph*					scatterPlot;
	CPXYGraph*					barChart;
	CPXYGraph*					pieChart;
	
	NSMutableArray*				dataForChart;
	NSMutableArray*				dataForPlot;	
}

@property(readwrite, retain, nonatomic) NSMutableArray* dataForChart;
@property(readwrite, retain, nonatomic) NSMutableArray* dataForPlot;

// Plot construction methods
- (void)renderScatterPlotInLayer:(CPLayerHostingView*)layerHostingView withTheme:(CPTheme*)theme;
- (void)renderBarPlotInLayer:(CPLayerHostingView*)layerHostingView withTheme:(CPTheme*)theme;
- (void)renderPieChartInLayer:(CPLayerHostingView*)layerHostingView withTheme:(CPTheme*)theme;

@end
