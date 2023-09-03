const wheelCircumference = "Wheel Circumference (mm)";
const wheelCircumferenceTag = "wheel_circumference";
// Common circumferences:
// https://www.bikelockwiki.com/how-to-measure-bike-tire-circumference/
// Minimum: 935 mm / 12" x 1.75" / 47-203
const wheelCircumferenceMin = 900;
// Default: 2096 mm / 700 x 23C 23-622
const wheelCircumferenceDefault = 2096;
// Maximum: 2326 mm 29" x 2.3" / 60-622
const wheelCircumferenceMax = 2400;
const wheelCircumferenceDivisions = wheelCircumferenceMax - wheelCircumferenceMin;
const wheelCircumferenceDescription = "Used to calculate speed from wheel revolutions";
