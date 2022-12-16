## 1.1.131
* Experimental support for Old Danube ergometers by allowing the use of CSC sensors
  for kayaking by a configuration switch in the Equipment preferences
* Refactoring internals of device and equipment handling related to recent developments

## 1.1.130
* Fix pixel overflow cosmetic bug on the Device Leaderboard's device selector screen

## 1.1.129
* Adding wheel circumference settings for CSC (Cycling Speed and Cadence) sensor speed and distance
  calculations
* Some modifications to cadence calculations (trying to chase a bug)
* Adding detailed cadence calculations logging (trying to chase a bug)
* Add divisions for almost all of slider type settings
* Upgrading Flutter version
* Upgrading many Flutter plugins

## 1.1.128
* Explicit switch if the app should prioritize the HRM directly paired to the app or the heart rate
  coming from the fitness machine console
* CSV export empty string instead of null values
* Upgrading Flutter version
* Upgrading many Flutter plugins

## 1.1.127
* Fix distance and calorie bump when workout is paused (and both metrics
  "bump back" when workout continues)

## 1.1.126
* Fix data flow with heart rate monitors when they send multiple RR-Interval readings in one
  data packet. Happened with a Polar H7 but it can happen with other monitors as well. The symptom
  was that the heart rate may only updated haphazardly.
* Flutter version upgrade
* Several package version upgrades

## 1.1.125
* Fix remaining power spike when HRM based calorie counting is on and the workout pauses

## 1.1.124
* Prevent distance jump when moving after a pause in case of some fitness equipment
* Prevent zeroing out of distance and time during full pause
* Verifying Wahoo KICKR FTMS support (preferred over the Power Meter Profile)

## 1.1.123
* Further changes to avoid heart rate glitching (when the heart rate monitor is paired with the app)
* Avoiding speed sensor intermittent drops to 0
* Avoiding cadence sensor glitches
* Pause state related changes / fixes

## 1.1.121
* Treat remaining power zone spike when HRM based calorie counting is on
* Fix for the new pause logic blanked out too many metrics
* Try to treat cadence, so it'd also zero out when the workout is paused
* Fix case when larger than 255 cadence value prevented FIT file uploads (Strava, Training Peaks)
* Flutter version upgrade and package version upgrades

## 1.1.120
* Treat Wahoo KICKR as an FTMS indoor bike instead of a power meter
* Try to treat power flickering
* Try to treat heart rate flickering
* Try to treat power zone 7 jump when HRM based calories are applied and pedaling stops

## 1.1.119
* Foundations for Concept2 rower support (experimental only, includes refactoring)
* Data processing bugfix
* Attempting to fix heart rate reading flicker
* Drag Force Tune option: Influence the speed when it's computed from power.
  When the power reading is proper but the computed speed is off compared to the console's reading.
  The power-to-speed equation is nonlinear. Example: 300W yields 24 mph while the console displays
  25.5 mph. 85% tune boosts the speed to align with the reading. Air temperature, drivetrain loss,
  athlete weight, and bike weight also influences the speed but way less than the drag force tune:
  it has the biggest - nonlinear - influence.
* Package version upgrades

## 1.1.118
* Stages SC3 support (SIC2 console relays power meter (and also HRM if paired));
  speed and distance are estimated
* Cycling Power Meter support (speed and distance is estimated)
* Cycling Speed and Cadence Sensor (CSC) support: wheel cadence + speed and pedal cadence
* DIY indoor bike possibility via power meter and CSC support
* More robust CSV import in case the type is picked wrong
* Flutter version upgrades
* Many package version upgrades

## 1.1.117
* Fixing the lock screen feature (no pointer absorption after the overlay tutorials were removed
  in favor of help modals) 

## 1.1.116
* Modify/correct full-screen bottom-sheet widget architecture
* Adding a close button to bottom sheets: Upload Picker, Leaderboard Type Picker
* Adding a cancel button to bottom sheets: Calorie Tune, Calorie Override, Export Format Picker,
  Import Format Picker, Power Tune, Sport Picker

## 1.1.115
* Schwinn 170/270/570 heart rate support
* Giant refactoring of core functionality related to extra sensors
* Galaxy App Store: CSV Import survives when migration CSV is mistakenly selected as MPower import
* Galaxy App Store: reorganize palette selector bottom sheet in landscape mode
* Galaxy App Store: all bottom sheets occupy full screen to deal with landscape mode

## 1.1.114
* Galaxy App Store find: orientation change disturbs opened circular menu
* Instant save feature (right after a workout, FIT format)
* Technogym Skillrow / Aquafeel strokes per minute fix
* Generic FTMS rower defaults to rowing instead of kayaking
* Android 13 (SDK level 33)

## 1.1.113

* Fixing Stages SB20 calorie counting (other machines might be affected too)
* Fixing cut-off action icons (at certain resolutions) on the Activities screen

## 1.1.112

* Fixing Stages SB 20 speed acquisition/display
* Galaxy App Store find: Screen rotation artifact workarounds on many screens
* Replacing overlay tutorial/help with legend modal dialogs
* Android 12L SDK level targeting and package version bumps

## 1.1.111

* Fixing broken OAuth integration flows (Strava, SUUNTO, UA, TP)
* Make Huawei Privacy Policy popup unavoidable

## 1.1.110

* Version bump for Huawei AppGallery submission.

## 1.1.109

* Circuit workout mode: being able to switch between multiple fitness machines while 
  leaving the workout open simultaneously on all of them (by simply navigating back
  from the measurement screen) and continue arbitrarily any of them until all the
  workouts are finalized with the stop button.
* HIIT display mode: while the athlete is alternating between active and rest periods
  the timer counts each period starting from 0, active is red-colored, and rest is blue.
* Buttons on the Expert configuration page pop up modal dialogs instead of snack bars.
* Several screens (About screen for example) are scrollable now in landscape mode

## 1.1.108

* Fix Palette color configuration picker contrast problem in light mode
* Providing explicit modal dialog feedback to the Expert preferences page's button presses
  (instead of just snack bars)

## 1.1.107

* Support fitness machines that require explicit workout 
  Start/Stop signaling via FTMS control point (needed when workout doesn't start)
* Workaround for Mr Captain rower's botched/malformed FTMS Rower protocol

## 1.1.106

* Further refactoring for Mr Captain rower's support

## 1.1.105

* Recognizing Mr Captain rowers
* Released to Samsung Galaxy App Store
* Released to Huawei AppGallery

## 1.1.104

* Dummy version bump to appease Huawei AppGallery submission.
  (The app is also in the Galaxy store now BTW).

## 1.1.103

* Schwinn 170 / 270 / 570u experimental support 
* Upgrade to Flutter 3.x
* Training Peaks API changes part 1 (deprecation approaching)

## 1.1.102

* Decrease the Leaderboard flicker (jump back-and-forth) effect especially the first few minutes
* Introduce a lock screen feature

## 1.1.101

* Ability to turn off GPS data from uploads and exports
* Ability to specify pacer with a fixed speed (per sport, speed in km/h)
* Ability to display average speed on the leaderboard info section (center of the track)

## 1.1.100

* Fixing manufacturer name check which fixes Yesoul S3 support as well (by Sebastian Kutschbach)
* Revising some zone threshold and boundary defaults
* Revising a few default zone colors to differ more by contrast/color
* Making zone colors configurable (5 / 6 / 7 zones, light / dark theme, foreground / background)
* Making sport and device-based leaderboards mutually exclusive. More info is coming and we won't
  have space for both at the same time.

## 1.1.99

* Adding attributions link to About page.

## 1.1.98

* Unit system will default to imperial only for the US, UK, Myanmar, and Liberia.
  Every other country will default to metric upon the first start.
* Further tuning of the data processing throttling logic. Please file an issue if you
  come across any suspicious anomaly (such as stuck cumulative values, or flickering).

## 1.1.97

* Bugfix: cure accidental double application of calorie/power tunes

## 1.1.96

* Foundations for optional debug logging to help remote debugging issues or
  support new fitness machines
* The app grew large enough with this feature that it became multi-dex

## 1.1.95

* Attempting to fix distance stuck at 0.3mi (Schwinn IC4)
* Attempting to fix calories stuck at 1 (Genesis Port)

## 1.1.94

* Changes towards proper Stages SB20 and Yesoul S3 support which can also
  help with many other machines
* Fix for 4x calorie reading inflation of Schwinn AC Perf+ CSV imported workouts

## 1.1.93

* Adding support: Stages SB 20, FlexStride Pro, Matrix TF50, Matrix R50, Sole E25
* Moving time into FIT uploads (Strava, SUUNTO, Training Peaks)
* Training Peaks upload default visibility switch
* Leaderboard distance display is automatic high res / low res (m / km, yd / mi)
* Handling machines that report themselves as multiple types
* Fix calorie tunes for non-heartrate-based calorie counting
* Fix leaderboard display

## 1.1.92

* Workout will only start when the first movement is sensed
* Moving time is accounted for besides elapsed time and persisted. UI switch tells which one is
  primarily preferred on the measurement screen and the activities list. The workout details
  display both moving and elapsed time if they differ.
* Cross Trainer support fixes
* Two-column layout size adjustment
* Workout migration import fix

## 1.1.91

* Enabling FTMS Cross Trainer, assigning it to Elliptical sport

## 1.1.90

* Measurement row configuration UI for graph height (1/4, 1/3, 1/2) and expanded/collapsed state
* More natural 1-based zone index display instead of 0-based

## 1.1.89

* Adding lap counter display option (center of the track or in the leaderboard as well)
* Adding preferences slider to shrink fonts on the Recording, Activity, and Workout Details screens
* Adding simple fixed two-column layout for landscape mode with explicit preferences switch

## 1.1.88

* Hotfix: Calorie factor adjuster data migration could lock up

## 1.1.87

* Fix: power-based calorie counting factor won't interfere (skyrocket) the HR based calories
* Fix: Default 4.0 power-based calorie factor will be implicit and hidden
  to make factors more uniform
* Large code churn to get Continuous Integration going and preparation for contributions
* GPLv3 license once the app will go open source
* Recognize Bowflex C7 not as generic

## 1.1.86

* Update the check mark and open icons immediately when Strava upload finishes
  (right now it requires the upload bottom shelf to be closed and reopened).
* Fix the activity timestamp problem of SUUNTO workout uploads.

## 1.1.85

* Fix Training Peaks sport type (showed up as other, now it's proper)
* When data connection timeout happens the auto-closed workout won't be all zeroes
* Specially designated button in the Data Preferences to retroactively fix workouts with all zeroes
* Increase default data connection timeout limit from 5 seconds to 30 seconds
* Fix anomaly when someone starts a workout on a fitness machine right after exercising on another

## 1.1.84

* Training Peaks integration (workout upload)
* Workout upload in-progress UI feedback

## 1.1.83

* BREAKING CHANGE: Re-authentication with Strava will be needed due to preference library changes
* Under Armour integration (workout upload)
* SUUNTO integration (workout upload)
* Integration of UX changes in concert with the new supported portals
* Flutter API v2 upgrade for the file download module (share_files_and_screenshot_widgets)
* Flutter API v2 upgrade for the Bluetooth enable module (bluetooth_enable)
* Fix: 10-second lag while uploading workout files, data connection checker module
  (internet_connection_checker) main upgrade
* Fix: custom data connection checking rules now apply
* Fix: enforce GetX permanent flag to avoid eviction of services by SmartManagement
* Fix: release version exception prevention by catches in flutter_blue fork

## 1.1.82

* Adding compensation logic for (distance, calories, and elapsed time) consecutive workouts
* Starting to introduce code for machine control features
* Properly stopping workout automatically when Data Connection Watchdog is triggered
* Trying to improve data connection for older Android devices. As a side effect, the Bluetooth status
  button is gone from the top right of the AppBar on the workout screen

## 1.1.81

* Adding help overlay to scanning, workout recording, and activity list screens
* Adding a changelog button to the About screen

## 1.1.80

* Correcting Strava sync delay
* Changing data connection check endpoints from Strava's Amazon AWS EC2 server IPs to default, which
  means Google, CloudFlare, and OpenDNS DNS servers
* Fixing Schwinn 510u support, making manufacturer check more lenient (less stringent)

## 1.1.79

* Transforming some colors (on the graph and on the track visualization) opaque for possible
  speedup
* Foundations for Cross Trainer / Elliptical support
* Option to display distance in kilometers or yards by introducing "distance resolution" orthogonal
  switch besides the unit system metric / imperial

## 1.1.78

* Adding back logic to infer sport by connecting to the device and deducting it from the
  FTMS characteristics. Some consoles don't implement Advertisement Data's Service Data which
  typically signals in a bitfield what type of machine it is
* Plugin step version updates
* Increase Schwinn IC4/IC8, BowFlex C6 default calorie factor from 1.4 to 3.6. This will result
  in a closer measurement of the console. Any user who has a calorie tune established should delete
  the tune or adjust it!
* Preparations for upcoming SUUNTO and Training Peaks integration

## 1.1.77

* Adding fix for auto connect error (application not responding)
* Adding fix for auto connect bug when it's impossible to navigate away from the recording screen

## 1.1.76

* Better graph axis and text colors for light theme graphs
* Recording screen Help button would open the About screen just as on other screens
* About screen contains a separate button for Quick Start, FAQ, Known Issues entries

## 1.1.72

* Adding recording Start / Stop button into the menu (besides it being in the top right corner)
* Small step version plugin updates

## 1.1.71

* Display the sports icon for the fitness machines on the scan screen instead of the transmission
  signal strength dB level
* Making scan result more compact (font size decrease)

## 1.1.70

* Data connection check preferences bug fix (was not reading the right value)
* Recognizing Schwinn 230 / 510u specifically by name instead of a generic FTMS bike
* Swap the order of the Leaderboard and Zone Preferences button in the preferences hub
* Preferences wording change: persist -> record
* Reverting to the official pref plugin after my PR was merged

## 1.1.69

* There was a bug that caused elapsed time to be 0 seconds
* Minor corrections to CSV import
* TCX export will contain 7 precision digits only (no need for more) for space saving
* Adding source code linting, correcting some linter findings
* Adding CSV export (a proprietary format which is an enriched MPower Echelon2 format)
* Adding support to import the proprietary CSV format
* Adding CSV import type picker since now it can be either MPower Echelon2 or application migration

## 1.1.68

* Fixing GPS track generation algorithm. It left gaps at the end of the straights.
* Adjusting some GPS track factors.
* Sports change is possible for superusers (debug mode)
* Adding track for Elliptical and Star Stepper
* Adjusting the Marymoor field measurements

## 1.1.67

* Better UX when connecting (transitioning from the scanning screen to the recording):
  displaying beating hourglass
* Use FTMS Advertisement Data's Service Data to determine FTMS Machine type, so no pre-connection
  is needed anymore for generic devices
* Recognizing KayakPro devices also by "KP" Bluetooth name prefix, not just "KayakPro"
* Fixing the jumping dot color on the HRM management bottom sheet
* Decrease artificial intermittent delay during Bluetooth initialization hoping for a shorter splash
* Rate limiting small code refactor

## 1.1.66

* Fix bug with Simpler UI turned on while being on light theme. Also happened with old Android
  devices by default.

## 1.1.65

* Running Cadence Sensor support progress
* Preventing the display of extreme high pace (very low speed) on the recording screen (essentially
  utilizing slow speed settings there as well)
* Scan logic change: no more periodic polling of connected devices. We keep track of them
* Increase minimum scanning duration to 6 seconds
* Adding support to NPE Runn treadmill smart device
* Cycling Cadence Sensor logic fix
* Avoid displaying "null" on the recording screen, the default is "--"

## 1.1.64

* Moving About from the Preferences hub to a stand-alone screen and be invoked by the help button
* Slight font size decrease to accommodate smaller devices
* Lot of code refactoring

## 1.1.63

* White screen ANR (Application Not Responding) error when the theme is light. (palette color crashed)

## 1.1.62.

* Supporting heartrate-based calorie counting: needs configuration of weight, age, and gender
* Even more precise heartrate-based calorie counting if VO2max is supplied (in configuration)

## 1.1.61

* Changes to permission and Bluetooth enablement check and help logic during startup
* Remove the Exit button (cannot kill the app due to technical limitations and the app staying
  in the background may keep holding paired devices and preventing them from discovery)
* Step version bump of plugins

## 1.1.60

* Running Cadence Sensor support foundations
* Preventing kicking off simultaneous scanning
* Changing the scan discovery logic

## 1.1.59

* Cycling Cadence Sensor feature flag interpretation fix
* Support 16-bit value Heart Rate Monitors (like Wahoo TICKR)
* Bluetooth connection code-related changes and refactorings
* Bluetooth scanning changes (remove stream peeks not to drain the stream)

## 1.1.58

* Bluetooth scan: display text when there's no available device
* Heart Rate Monitor scanning UX enhancements for re-scanning

## 1.1.56

* Upgrading all plugins and the codebase to Sound Null Safety, huge code churn
* Required new preferences library
* Required new charting library

## 1.1.54

* Disconnecting from HRM if already connected
* Move filter devices settings from UX to the Expert settings
* Shrink font a little in some places to support smaller devices better
* Scanning logic changes

## 1.1.53

* Styling the ranking info/pace light feature on the track visualization
* Fix bug for a leaderboard switch combination

## 1.1.50

* Adding pace light/rank visualization to the track
* Using my own version of the circular menu plugin code

## 1.1.49

* Adding an Exit button to the Find Devices and Activites screen (unfortunately it does not
  kill the app all the way)

## 1.1.46

* Weight remembrance option for preserving weight default at Spin Down start
* Workout will be forcefully finished upon connection loss

## 1.1.45

* Android 5 splash screen error fix (blind fix based on Play Store crash report)

## 1.1.44

* Add option to the color the measurements by the zone index

## 1.1.43

* First open beta version after many closed beta

## 1.1.42

* Last closed beta before the open beta track
* Generic FTMS machine support enhancements
* There's no more heart rate flicker when connecting HRM directly to the app
* Automatically restart workout when data connection watchdog is triggered
* More contrast in the pie charts
* White text annotation on the graphs in dark theme mode

## 1.1.41

* Fix URL opening problems (like help page) with Android API 30+ devices (Android 11 and up)
* Sport picker, export format picker, and battery status bottom sheet should be dismissible
* Bringing back splash screen
* Remove the debug ribbon even in debug mode
* Generic FTMS support foundations
* Dark / light theme support

## 1.1.40

* Zone index display feature and its settings
* 1-based leaderboards instead of 0-based
* Track marker annotation centering and other fixes
* Rank display corrections
* Build number will match the step number starting from that version

## 1.1.30

* Build number 39
* Styling leaderboards
* Pace light visual feedback
* Audio alerting feature adjustments
* Correct speed display on the recording details screen
* Leaderboard and pace light preferences
* HR alerting feature (color / visual, and audio)
* Target heart rate settings
* Dividing preferences into subpages

## 1.1.29

* Build number 38
* Supporting split screen mode (for landscape split screen, no distinct landscape mode yet)
* Some foundations for Treadmill support
* Extended tune would affect Rower / Kayak / Swim ergometers
* Calorie Tune and Power Tune feature development
* Fixing bug in FIT export

## 1.1.28

* Build number 37
* Remove splash screen
* Remove portrait restriction to prepare for split-screen support
* Bluetooth state and location permission handling changes
* Full-screen mode during workout measurement to avoid accidental navigation
* Remove the compression switch for export. Gzip confused users, it only allows uncompressed downloads,
  uploads will still use gzip for Strava

## 1.1.27

* Build number 36
* Introducing permission_handler to help with location permission handling and enablement
* Bluetooth enablement handling changes

## 1.1.26

* Build number 35
* Calorie scale correction for FIT export

## 1.1.25

* Build number 34
* Introduce bluetooth_enable plugin specifically to handle Bluetooth enablement condition
* FIT file export is introduced
* TCX sport export bug fix
* Heart rate limiting feature (capping the display and recording), various choices
* Heart rate data gap bridging changes
* Making data connection check endpoints configurable
* Slow-speed configuration
* Sport-based last-used fitness machine remembrance logic
* Per-sport-based Zone configurations
* Accordion icons are not present when in Simpler UI mode
* Own fork of flutter_blue with one production crash avoidance code (blind fix)

## 1.1.24

* Build number 33, second closed beta release
* Multi-sport device support (for example Genesis Port), sport picker UI
* Flipped zone coloring for pace-based sports, flipped Y axis

## 1.1.23

* Build number 32
* FTMS Rower Machine support
* Support KayakPro Genesis Port enabled devices like Compact, SpeedStroke Pro, SwimFast
* Paced based sport support
* Supporting HRM pairing directly to the app (instead of the console)
* Specific tests for supported devices
* FTMS Spin Down (machine calibration) support
* Data connection check test is using Strava's 6 AWS IP addresses

## 1.1.21

* Build number 30
* Plugin version upgrades
* Aerodynamic drag will limit the speed-by-power calculation
* Speed selection values respect unit preferences

## 1.1.18

* Build number 27
* Don't generate the cycling into the velodrome to avoid Strava KOM takeovers. Placing rides onto
  a running track (no cycling segments there) and similarly the run into the velodrome (no run
  segments)
* Allow resizing of the graphs by long press. Saved into the settings
* Adding zone boundary lines
* Remove Y-axis labels

## 1.1.17

* Build number 26
* Trying to tackle the Plugin Not Found error

## 1.1.16

* Build number 25
* Using the File Picker plugin for file imports
* Place the running GPS track onto the Hoover track (no run segments)

## 1.1.12

* Build number 21
* Initial version of Schwinn AC Performance Plus support via MPower Echelon2 CSV saves

## 1.1.11

* Build number 20
* Introducing Roboto Mono font as an alternative for 7SEG and 14SEG
* More concise service data and UUID displays: just the 4 hex part which matters

## 1.1.10

* Build number 19
* Automatic activity uploading optional feature, UI configurable switch
* More consistent Strava icons, actions
* Introducing auto scanning and instant workout features

## 1.1.9

* Build number 18
* Device scan result styling
* Don't even bother with devices like a Garmin watch
* Trying to fix crash on ancient Samsung S4 tablet seen in the play store reports

## 1.1.6

* Build number 15
* Bugfixes and emergency release due to flutter_blue white screen ANR (Plugin Not Found exception)
* Rolling back flutter_blue from 0.7.3 to 0.7.2, nuking Android port, etc.
* Package upgrades

## 1.1.5

* Build number 14
* Strava upload bug hotfix (feature code interfered with production code)
* Trying to blind fix some errors seen in Play Store reports

## 1.1.3

* Build number 12
* Coloring the Circular FAB icons
* Jumping dots feedback about scanning
* Strava sync bugfix attempt (by using broadcast streams)

## 1.1.2

* Build number 11
* Changing Strava token logic
* Strava sync REST HTTP handling code changes
* Some preferences options for UI enhancement
* Coloring of Pie Charts fixed
* Rounding cosmetic ugliness fixed
* Disable chart animations
* Simplified UI feature fixes
* Bug fixes

## 1.1.0

* Build number 9
* Schwinn IC4, Schwinn IC8, and Bowflex C6 support
* Precor distance measurement handling modification
* Still tackling HTTP errors seen in the Play Store reports
* Change action button colors of the circular FAB
* Bug fixes

## 1.0.7

* Build number 8
* Introducing Circular FAB menus
* Being able to switch between imperial and SI units
* Replace histogram charts with pie charts
* Activity list refresh logic (for example after deletion)
* Average and maximum display of the workout details
* Interactive time series graph: selection value is displayed
* Visual feedback about the Strava upload result
* Package upgrades

## 1.0.6

* Build number 7
* Fix false error snack bar while the upload is successful

## 1.0.5

* Build number 6
* Correct distance calculation of the GPS points
* Preparing to support multiple devices (Schwinn IC4 besides Precor Spinner Chrono Power)
* Toggleable device filtering

## 1.0.4

* Build number 5
* Transient error fix during the workout start
* Using unit systems on the Records and the measurement screen
* Enhancing threshold & zone preferences UX
* Correcting histogram percent scaling

## 1.0.3

* Build number 4
* Real-time colored graphs during workout measurement!

## 1.0.2

* Build number 3
* Zone bands display on the graphs
* Zone-based binning of the histogram
* Fixing issue with Flutter ListUtils
* Adding Workout details screen with graphs

## 1.0.1

* Build number 2
* Add Help button, pops up the browser with the Quick Start page of the app
* Rebranding (Track My Indoor Exercise -> Track My Indoor Workout)
* UX debugging feature
* Display track visualization at the bottom
* DSEG7 and DSEG14 display fonts for a retro look
* Also using VT323 font for an even more retro look where DSEG7 is not usable
* Activity deletion feature (list doesn't refresh yet)
* GPS calculation corrections
* GPS is only calculated during the upload
* TCX export support
* Wake lock on the measurement screen (must avoid the device going to sleep)
* Adding wake lock package

## 1.0.0

* Build number 1
* Starting off of Flutter Blue example app
* Precor Spinner Chrono Power support
* GPS calculation logic
* Strava integration
* TCX format export and upload support
