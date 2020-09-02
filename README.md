# Virtul Velodrome Rider

Based on the flutter_blue example

## Plans

* The app will support Precor Spinner Power Chrono.
* My goal is to pick up the watt meter and the pedal cadence unlike the Wahoo Precor Spinner Power Chrono integration.
* The app will emulate a virtual ride as if the user would circle in a Velodrome or on a running track.
* By default that Velodrome will be the [Millenáris Sporttelep multi-use velodrome in Budapest, Hungary](https://en.wikipedia.org/wiki/Millen%C3%A1ris_Sporttelep)
* Paid in-app purchase will unlock the ability to specify any desired location. The user would be able to configure the center of the velodrome/track and the angle how the track main axis is rotated compared to the equator.
* Possibly user would be able to configure outer track lines (imagine a running track: lines 1-8) so larger than 400m velodromes can be accommodated.
* The app will generate a FIT or TCX file as a result of the workout so the user can upload it to Strava or other workout tracking portals.
* Another paid in-app purchase could unlock support for other potential indoor exercise bikes with BLE pairing capability (for example Schwinn IC4). For this the data we need is the manufacturer strings the app can identify the cycle and also the GUIDs of the respective characteristics for estimated speed, power, cadence, heart rate and so on.
