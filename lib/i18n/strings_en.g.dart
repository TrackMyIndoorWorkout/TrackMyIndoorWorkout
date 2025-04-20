///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsPreferencesEn preferences = TranslationsPreferencesEn.internal(_root);
	late final TranslationsWorkoutEn workout = TranslationsWorkoutEn.internal(_root);
	late final TranslationsHistoryEn history = TranslationsHistoryEn.internal(_root);
	late final TranslationsSharingEn sharing = TranslationsSharingEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get appName => 'Track My Indoor Exercise';
	String get ok => 'OK';
	String get cancel => 'Cancel';
	String get save => 'Save';
	String get delete => 'Delete';
	String get error => 'An unexpected error occurred.';
	String get confirm => 'Confirm';
	String get yes => 'Yes';
	String get no => 'No';
	String get loading => 'Loading...';
	String get success => 'Success';
	String get failed => 'Failed';
}

// Path: preferences
class TranslationsPreferencesEn {
	TranslationsPreferencesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Preferences';
	late final TranslationsPreferencesThemeEn theme = TranslationsPreferencesThemeEn.internal(_root);
	late final TranslationsPreferencesNotificationsEn notifications = TranslationsPreferencesNotificationsEn.internal(_root);
	late final TranslationsPreferencesDataEn data = TranslationsPreferencesDataEn.internal(_root);
	late final TranslationsPreferencesAboutEn about = TranslationsPreferencesAboutEn.internal(_root);
	late final TranslationsPreferencesUnitsEn units = TranslationsPreferencesUnitsEn.internal(_root);
}

// Path: workout
class TranslationsWorkoutEn {
	TranslationsWorkoutEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get start => 'Start Workout';
	String get stop => 'Stop Workout';
	String get pause => 'Pause';
	String get resume => 'Resume';
	String get lap => 'Lap {count}';
	String get duration => 'Duration';
	String get distance => 'Distance';
	String get speed => 'Speed';
	String get calories => 'Calories';
	String get noDevice => 'No device connected.';
	String get searchingDevice => 'Searching for device...';
}

// Path: history
class TranslationsHistoryEn {
	TranslationsHistoryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Workout History';
	String get empty => 'No workouts recorded yet.';
	late final TranslationsHistoryDeleteConfirmationEn deleteConfirmation = TranslationsHistoryDeleteConfirmationEn.internal(_root);
}

// Path: sharing
class TranslationsSharingEn {
	TranslationsSharingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get shareWorkout => 'Share Workout';
	String get shareSuccess => 'Workout shared successfully.';
	String get shareError => 'Failed to share workout.';
}

// Path: preferences.theme
class TranslationsPreferencesThemeEn {
	TranslationsPreferencesThemeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Appearance';
	String get description => 'Choose the application theme.';
	late final TranslationsPreferencesThemeOptionsEn options = TranslationsPreferencesThemeOptionsEn.internal(_root);
}

// Path: preferences.notifications
class TranslationsPreferencesNotificationsEn {
	TranslationsPreferencesNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notifications';
	String get enable => 'Enable Notifications';
	String get description => 'Allow the app to send you notifications.';
	late final TranslationsPreferencesNotificationsSoundEn sound = TranslationsPreferencesNotificationsSoundEn.internal(_root);
}

// Path: preferences.data
class TranslationsPreferencesDataEn {
	TranslationsPreferencesDataEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Data Management';
	late final TranslationsPreferencesDataExportEn export = TranslationsPreferencesDataExportEn.internal(_root);
	late final TranslationsPreferencesDataImportDataEn importData = TranslationsPreferencesDataImportDataEn.internal(_root);
	late final TranslationsPreferencesDataClearCacheEn clearCache = TranslationsPreferencesDataClearCacheEn.internal(_root);
}

// Path: preferences.about
class TranslationsPreferencesAboutEn {
	TranslationsPreferencesAboutEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'About';
	String get version => 'Version {version}';
	late final TranslationsPreferencesAboutUpdatesEn updates = TranslationsPreferencesAboutUpdatesEn.internal(_root);
	String get rate => 'Rate App';
	String get privacy => 'Privacy Policy';
	String get terms => 'Terms of Service';
	String get licenses => 'Open Source Licenses';
}

// Path: preferences.units
class TranslationsPreferencesUnitsEn {
	TranslationsPreferencesUnitsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Units';
	String get description => 'Choose measurement units.';
	late final TranslationsPreferencesUnitsDistanceEn distance = TranslationsPreferencesUnitsDistanceEn.internal(_root);
	late final TranslationsPreferencesUnitsSpeedEn speed = TranslationsPreferencesUnitsSpeedEn.internal(_root);
}

// Path: history.deleteConfirmation
class TranslationsHistoryDeleteConfirmationEn {
	TranslationsHistoryDeleteConfirmationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Delete Workout?';
	String get message => 'Are you sure you want to delete this workout? This action cannot be undone.';
}

// Path: preferences.theme.options
class TranslationsPreferencesThemeOptionsEn {
	TranslationsPreferencesThemeOptionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get light => 'Light';
	String get dark => 'Dark';
	String get system => 'System Default';
}

// Path: preferences.notifications.sound
class TranslationsPreferencesNotificationsSoundEn {
	TranslationsPreferencesNotificationsSoundEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notification Sound';
	String get select => 'Select Notification Sound';
	String get current => 'Current sound: {soundName}';
	late final TranslationsPreferencesNotificationsSoundOptionsEn options = TranslationsPreferencesNotificationsSoundOptionsEn.internal(_root);
}

// Path: preferences.data.export
class TranslationsPreferencesDataExportEn {
	TranslationsPreferencesDataExportEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Export Data';
	String get description => 'Export your workout data to a file.';
	String get button => 'Export Data';
	String get inProgress => 'Exporting data...';
	String get success => 'Data exported successfully to {path}';
	String get error => 'Failed to export data.';
}

// Path: preferences.data.importData
class TranslationsPreferencesDataImportDataEn {
	TranslationsPreferencesDataImportDataEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Import Data';
	String get description => 'Import workout data from a file.';
	String get button => 'Import Data';
	String get selectFile => 'Select file to import';
	String get inProgress => 'Importing data...';
	String get success => 'Data imported successfully.';
	String get error => 'Failed to import data.';
}

// Path: preferences.data.clearCache
class TranslationsPreferencesDataClearCacheEn {
	TranslationsPreferencesDataClearCacheEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Clear Cache';
	String get description => 'Clear temporary application data.';
	String get button => 'Clear Cache';
	String get inProgress => 'Clearing cache...';
	String get success => 'Cache cleared successfully.';
	String get error => 'Failed to clear cache.';
	late final TranslationsPreferencesDataClearCacheConfirmDialogEn confirmDialog = TranslationsPreferencesDataClearCacheConfirmDialogEn.internal(_root);
}

// Path: preferences.about.updates
class TranslationsPreferencesAboutUpdatesEn {
	TranslationsPreferencesAboutUpdatesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get button => 'Check for Updates';
	String get checking => 'Checking for updates...';
	String get upToDate => 'App is up to date.';
	String get available => 'New version available: {newVersion}';
}

// Path: preferences.units.distance
class TranslationsPreferencesUnitsDistanceEn {
	TranslationsPreferencesUnitsDistanceEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Distance Unit';
	late final TranslationsPreferencesUnitsDistanceOptionsEn options = TranslationsPreferencesUnitsDistanceOptionsEn.internal(_root);
}

// Path: preferences.units.speed
class TranslationsPreferencesUnitsSpeedEn {
	TranslationsPreferencesUnitsSpeedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Speed Unit';
	late final TranslationsPreferencesUnitsSpeedOptionsEn options = TranslationsPreferencesUnitsSpeedOptionsEn.internal(_root);
}

// Path: preferences.notifications.sound.options
class TranslationsPreferencesNotificationsSoundOptionsEn {
	TranslationsPreferencesNotificationsSoundOptionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get defaultSound => 'Default Sound';
	String get silent => 'Silent';
}

// Path: preferences.data.clearCache.confirmDialog
class TranslationsPreferencesDataClearCacheConfirmDialogEn {
	TranslationsPreferencesDataClearCacheConfirmDialogEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Confirm Clear Cache';
	String get message => 'Are you sure you want to clear the application cache? This cannot be undone.';
}

// Path: preferences.units.distance.options
class TranslationsPreferencesUnitsDistanceOptionsEn {
	TranslationsPreferencesUnitsDistanceOptionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get kilometers => 'Kilometers (km)';
	String get miles => 'Miles (mi)';
}

// Path: preferences.units.speed.options
class TranslationsPreferencesUnitsSpeedOptionsEn {
	TranslationsPreferencesUnitsSpeedOptionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get kmh => 'Kilometers per hour (km/h)';
	String get mph => 'Miles per hour (mph)';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Track My Indoor Exercise';
			case 'common.ok': return 'OK';
			case 'common.cancel': return 'Cancel';
			case 'common.save': return 'Save';
			case 'common.delete': return 'Delete';
			case 'common.error': return 'An unexpected error occurred.';
			case 'common.confirm': return 'Confirm';
			case 'common.yes': return 'Yes';
			case 'common.no': return 'No';
			case 'common.loading': return 'Loading...';
			case 'common.success': return 'Success';
			case 'common.failed': return 'Failed';
			case 'preferences.title': return 'Preferences';
			case 'preferences.theme.title': return 'Appearance';
			case 'preferences.theme.description': return 'Choose the application theme.';
			case 'preferences.theme.options.light': return 'Light';
			case 'preferences.theme.options.dark': return 'Dark';
			case 'preferences.theme.options.system': return 'System Default';
			case 'preferences.notifications.title': return 'Notifications';
			case 'preferences.notifications.enable': return 'Enable Notifications';
			case 'preferences.notifications.description': return 'Allow the app to send you notifications.';
			case 'preferences.notifications.sound.title': return 'Notification Sound';
			case 'preferences.notifications.sound.select': return 'Select Notification Sound';
			case 'preferences.notifications.sound.current': return 'Current sound: {soundName}';
			case 'preferences.notifications.sound.options.defaultSound': return 'Default Sound';
			case 'preferences.notifications.sound.options.silent': return 'Silent';
			case 'preferences.data.title': return 'Data Management';
			case 'preferences.data.export.title': return 'Export Data';
			case 'preferences.data.export.description': return 'Export your workout data to a file.';
			case 'preferences.data.export.button': return 'Export Data';
			case 'preferences.data.export.inProgress': return 'Exporting data...';
			case 'preferences.data.export.success': return 'Data exported successfully to {path}';
			case 'preferences.data.export.error': return 'Failed to export data.';
			case 'preferences.data.importData.title': return 'Import Data';
			case 'preferences.data.importData.description': return 'Import workout data from a file.';
			case 'preferences.data.importData.button': return 'Import Data';
			case 'preferences.data.importData.selectFile': return 'Select file to import';
			case 'preferences.data.importData.inProgress': return 'Importing data...';
			case 'preferences.data.importData.success': return 'Data imported successfully.';
			case 'preferences.data.importData.error': return 'Failed to import data.';
			case 'preferences.data.clearCache.title': return 'Clear Cache';
			case 'preferences.data.clearCache.description': return 'Clear temporary application data.';
			case 'preferences.data.clearCache.button': return 'Clear Cache';
			case 'preferences.data.clearCache.inProgress': return 'Clearing cache...';
			case 'preferences.data.clearCache.success': return 'Cache cleared successfully.';
			case 'preferences.data.clearCache.error': return 'Failed to clear cache.';
			case 'preferences.data.clearCache.confirmDialog.title': return 'Confirm Clear Cache';
			case 'preferences.data.clearCache.confirmDialog.message': return 'Are you sure you want to clear the application cache? This cannot be undone.';
			case 'preferences.about.title': return 'About';
			case 'preferences.about.version': return 'Version {version}';
			case 'preferences.about.updates.button': return 'Check for Updates';
			case 'preferences.about.updates.checking': return 'Checking for updates...';
			case 'preferences.about.updates.upToDate': return 'App is up to date.';
			case 'preferences.about.updates.available': return 'New version available: {newVersion}';
			case 'preferences.about.rate': return 'Rate App';
			case 'preferences.about.privacy': return 'Privacy Policy';
			case 'preferences.about.terms': return 'Terms of Service';
			case 'preferences.about.licenses': return 'Open Source Licenses';
			case 'preferences.units.title': return 'Units';
			case 'preferences.units.description': return 'Choose measurement units.';
			case 'preferences.units.distance.title': return 'Distance Unit';
			case 'preferences.units.distance.options.kilometers': return 'Kilometers (km)';
			case 'preferences.units.distance.options.miles': return 'Miles (mi)';
			case 'preferences.units.speed.title': return 'Speed Unit';
			case 'preferences.units.speed.options.kmh': return 'Kilometers per hour (km/h)';
			case 'preferences.units.speed.options.mph': return 'Miles per hour (mph)';
			case 'workout.start': return 'Start Workout';
			case 'workout.stop': return 'Stop Workout';
			case 'workout.pause': return 'Pause';
			case 'workout.resume': return 'Resume';
			case 'workout.lap': return 'Lap {count}';
			case 'workout.duration': return 'Duration';
			case 'workout.distance': return 'Distance';
			case 'workout.speed': return 'Speed';
			case 'workout.calories': return 'Calories';
			case 'workout.noDevice': return 'No device connected.';
			case 'workout.searchingDevice': return 'Searching for device...';
			case 'history.title': return 'Workout History';
			case 'history.empty': return 'No workouts recorded yet.';
			case 'history.deleteConfirmation.title': return 'Delete Workout?';
			case 'history.deleteConfirmation.message': return 'Are you sure you want to delete this workout? This action cannot be undone.';
			case 'sharing.shareWorkout': return 'Share Workout';
			case 'sharing.shareSuccess': return 'Workout shared successfully.';
			case 'sharing.shareError': return 'Failed to share workout.';
			default: return null;
		}
	}
}

