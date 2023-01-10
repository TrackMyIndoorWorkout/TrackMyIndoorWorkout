import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

import '../../preferences/metric_spec.dart';
import '../../preferences/palette_spec.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import '../models/tile_configuration.dart';

class ActivityDetailGraphs extends StatelessWidget {
  final String item;
  final int index;
  final Size size;
  final ExpandableThemeData expandableThemeData;
  final TextStyle textStyle;
  final TextStyle measurementStyle;
  final TextStyle unitStyle;
  final TextStyle chartLabelStyle;
  final Color chartTextColor;
  final TileConfiguration tileConfiguration;
  final MetricSpec preferencesSpec;
  final bool si;
  final String sport;
  final bool isLight;
  final double sizeDefault;
  final PaletteSpec paletteSpec;
  final ThemeManager themeManager;

  const ActivityDetailGraphs({
    super.key,
    required this.item,
    required this.index,
    required this.size,
    required this.expandableThemeData,
    required this.textStyle,
    required this.measurementStyle,
    required this.unitStyle,
    required this.chartLabelStyle,
    required this.chartTextColor,
    required this.tileConfiguration,
    required this.preferencesSpec,
    required this.si,
    required this.sport,
    required this.isLight,
    required this.sizeDefault,
    required this.paletteSpec,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle pieChartLabelStyle = TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    final charts.TooltipBehavior tooltipBehavior = charts.TooltipBehavior(enable: true);
    final charts.ZoomPanBehavior zoomPanBehavior = charts.ZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePinching: true,
      enableSelectionZooming: true,
      zoomMode: charts.ZoomMode.x,
      enablePanning: true,
    );
    final charts.TrackballBehavior trackballBehavior = charts.TrackballBehavior(
      enable: true,
      activationMode: charts.ActivationMode.singleTap,
      tooltipDisplayMode: charts.TrackballDisplayMode.groupAllPoints,
    );

    return Card(
      elevation: 6,
      child: ExpandablePanel(
        theme: expandableThemeData,
        header: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextOneLine(
                  tileConfiguration.title,
                  style: textStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                themeManager.getBlueIcon(preferencesSpec.icon, sizeDefault),
                Text("MAX", style: unitStyle),
                const Spacer(),
                FitHorizontally(
                  child: Text(
                    tileConfiguration.maxString,
                    style: measurementStyle,
                  ),
                ),
                const Spacer(),
                Text(
                  preferencesSpec.multiLineUnit,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: unitStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                themeManager.getBlueIcon(preferencesSpec.icon, sizeDefault),
                Text("AVG", style: unitStyle),
                const Spacer(),
                FitHorizontally(
                  child: Text(
                    tileConfiguration.avgString,
                    style: measurementStyle,
                  ),
                ),
                const Spacer(),
                Text(
                  preferencesSpec.multiLineUnit,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: unitStyle,
                ),
              ],
            ),
          ],
        ),
        collapsed: Container(),
        expanded: Column(children: [
          item == "speed" && sport != ActivityType.ride
              ? TextOneLine(
                  "Speed ${si ? 'km' : 'mi'}/h",
                  style: textStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                )
              : Container(),
          SizedBox(
            width: size.width,
            height: size.height / 2,
            child: charts.SfCartesianChart(
              primaryXAxis: charts.DateTimeAxis(
                labelStyle: chartLabelStyle,
                axisLine: charts.AxisLine(color: chartTextColor),
                majorTickLines: charts.MajorTickLines(color: chartTextColor),
                minorTickLines: charts.MinorTickLines(color: chartTextColor),
                majorGridLines: charts.MajorGridLines(color: chartTextColor),
                minorGridLines: charts.MinorGridLines(color: chartTextColor),
              ),
              primaryYAxis: charts.NumericAxis(
                plotBands: preferencesSpec.plotBands,
                labelStyle: chartLabelStyle,
                axisLine: charts.AxisLine(color: chartTextColor),
                majorTickLines: charts.MajorTickLines(color: chartTextColor),
                minorTickLines: charts.MinorTickLines(color: chartTextColor),
                majorGridLines: charts.MajorGridLines(color: chartTextColor),
                minorGridLines: charts.MinorGridLines(color: chartTextColor),
              ),
              margin: const EdgeInsets.all(0),
              series: tileConfiguration.dataFn(),
              zoomPanBehavior: zoomPanBehavior,
              trackballBehavior: trackballBehavior,
            ),
          ),
          const Divider(height: 20, thickness: 2),
          TextOneLine(
            tileConfiguration.histogramTitle,
            style: textStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: size.width,
            height: size.height / 3,
            child: charts.SfCircularChart(
              margin: const EdgeInsets.all(0),
              legend: charts.Legend(isVisible: true, textStyle: pieChartLabelStyle),
              series: tileConfiguration.histogramFn!(),
              palette: paletteSpec.getPiePalette(isLight, preferencesSpec),
              tooltipBehavior: tooltipBehavior,
            ),
          ),
        ]),
      ),
    );
  }
}
