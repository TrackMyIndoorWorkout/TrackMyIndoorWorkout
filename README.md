# TrackMyIndoorExercise

## Plans

* The app supports [Precor Spinner® Chrono™ Power](https://www.precor.com/en-us/commercial/cardio/indoor-cycling/spinner-chrono-power).
* It picks up the watt meter and the pedal cadence readings unlike the [Wahoo](https://play.google.com/store/apps/details?id=com.wahoofitness.fitness) [Precor Spinner® Chrono™ Power](https://www.precor.com/en-us/commercial/cardio/indoor-cycling/spinner-chrono-power) integration.
* On top of that the app supplies GPS data as well: it emulates a virtual ride as if the user would circle in the [Jerry Baker Memorial Velodrome](https://velodrome.org/) in [Redmond, Washington](https://www.google.com/maps/place/Jerry+Baker+Memorial+Velodrome/@47.6659161,-122.1125076,96m/data=!3m1!1e3!4m5!3m4!1s0x0:0x7d3c1ebef878f4c!8m2!3d47.665894!4d-122.1126097).
* The app is capable of uploading the workout to Strava and would also offer TCX file download for in-app purchase.
* In-app purchase will unlock the ability to specify any desired location. The user would be able to configure the center of the velodrome/track and the angle how the track main axis is rotated compared to the equator.
* Possibly user would be able to configure outer track lines (imagine a running track: lines 1-8) so larger than 400m velodromes can be accommodated.
* In-app purchase could unlock support for other potential indoor exercise bikes with BLE pairing capability (for example Schwinn IC4). For this the data we need is the manufacturer strings the app can identify the cycle and also the GUIDs of the respective characteristics for estimated speed, power, cadence, heart rate and so on.
