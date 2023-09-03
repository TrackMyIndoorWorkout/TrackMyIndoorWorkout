const dragForceTune = "Drag Force Tune (%)";
const dragForceTuneTag = "drag_force_tune";
const dragForceTuneMin = 80;
const dragForceTuneDefault = 100;
const dragForceTuneMax = 120;
const dragForceTuneDivisions = dragForceTuneMax - dragForceTuneMin;
const dragForceTuneDescription = "Influence the speed when it's computed from "
    "power. When the power reading is proper but the computed speed is off "
    "compared to the console's reading. The power to speed equation is non "
    "linear. Example: 300W yields 24 mph while the console displays 25.5 mph. "
    "85% tune boosts the speed to align with the reading. Air temperature, "
    "drive train loss, athlete weight, and bike weight also influences the "
    "speed but way less than the drag force tune: it has the biggest - "
    "non linear - influence.";
