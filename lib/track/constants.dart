import 'dart:math';

import 'package:flutter/material.dart';

const RADIUS_BOOST = 1.25;
const LANE_SHRINK = 2.0 - RADIUS_BOOST;
const THICK = 20.0;
const TRACK_LENGTH = 400.0;
const TRACK_QUARTER = TRACK_LENGTH / 4.0;
const HALF_CIRCLE = TRACK_QUARTER * RADIUS_BOOST;
const LANE_LENGTH = TRACK_QUARTER * LANE_SHRINK;

// GPS constants
final trackCenter = Offset(47.665821, -122.112045);
const LON_METER = 0.000013351;
const LAT_METER = 0.000008993;
const RADIUS = HALF_CIRCLE / pi;
const LON_RADIUS = RADIUS * LON_METER;
const LANE_HALF = LANE_LENGTH / 2.0 * LAT_METER;
