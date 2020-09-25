import 'dart:math';

import 'package:flutter/material.dart';

const RADIUS_BOOST = 1.2;
const LANE_SHRINK = 2.0 - RADIUS_BOOST;
const THICK = 10.0;
const TRACK_LENGTH = 400.0;
const TRACK_QUARTER = TRACK_LENGTH / 4.0;
const HALF_CIRCLE = TRACK_QUARTER * RADIUS_BOOST;
const LANE_LENGTH = TRACK_QUARTER * LANE_SHRINK;

// GPS constants
final trackCenter = Offset(-122.112045, 47.665821); // lon, lat
const EW_METER = 0.000013356;
const NS_METER = 0.000008993;
const RADIUS = HALF_CIRCLE / pi;
const EW_RADIUS = RADIUS * EW_METER; // lon
const NS_LANE_HALF = LANE_LENGTH / 2.0 * NS_METER;
const TRACK_ALTITUDE = 6.0; // in meters, the base level
