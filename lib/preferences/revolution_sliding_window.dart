const revolutionSlidingWindow = "Revolution Sliding Window (seconds)";
const revolutionSlidingWindowTag = "revolutionSlidingWindow";
const revolutionSlidingWindowMin = 2;
const revolutionSlidingWindowDefault = 4;
const revolutionSlidingWindowMax = 20;
const revolutionSlidingWindowDivisions = revolutionSlidingWindowMax - revolutionSlidingWindowMin;
const revolutionSlidingWindowDescription =
    "Used for cadence smoothing. "
    "Wider window results in more smoothing and less jitter, but means more "
    "delay to ramp up to the current cadence in case it suddenly changes. "
    "Narrower window means more responsive cadence reading but it can "
    "can be more jittery.";
