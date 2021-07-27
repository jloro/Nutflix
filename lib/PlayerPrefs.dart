import 'package:shared_preferences/shared_preferences.dart';

class PlayerPrefs
{
  static const String statsForNerdsKey = "statsForNerds";
  static bool statsForNerds = false;

  static const String radarrApiKeyKey = "radarrApiKey";
  static String radarrApiKey;

  static const String radarrURLKey = "radarrURL";
  static String radarrURL;

  static const String radarrDefaultProfileKey = "radarrdefaultProfile";
  static int radarrDefaultProfile = 1;

  static const String radarrUhdProfileKey = "radarruhdProfile";
  static int radarrUhdProfile = 5;

  static const String radarrFolderNamingFormatKey = "radarrfolderNamingFormat";
  static String radarrFolderNamingFormat;

  static const String sabApiKeyKey = "sabApiKey";
  static String sabApiKey;

  static const String sabURLKey = "sabURL";
  static String sabURL;

  static const String radarrDlPathKey = "radarrdlPath";
  static String radarrDlPath;

  static const String showAdvancedSettingsKey = "showAdvancedSettings";
  static bool showAdvancedSettings = false;

  static const String firstLaunchKey = "firstLaunch";
  static bool firstLaunch = true;

  static const String sonarrApiKeyKey = "sonarrApiKey";
  static String sonarrApiKey;

  static const String sonarrURLKey = "sonarrURL";
  static String sonarrURL;

  static const String sonarrDlPathKey = "sonarrdlPath";
  static String sonarrDlPath;

  static const String sonarrDefaultProfileKey = "sonarrdefaultProfile";
  static int sonarrDefaultProfile = 1;

  static const String sonarrUhdProfileKey = "sonarruhdProfile";
  static int sonarrUhdProfile = 5;

  static const String sonarrFolderNamingFormatKey = "sonarrfolderNamingFormat";
  static String sonarrFolderNamingFormat;

  static void Reset(SharedPreferences prefs)
  {
    PlayerPrefs.statsForNerds = false;
    PlayerPrefs.radarrURL = '';
    PlayerPrefs.radarrApiKey = '';
    PlayerPrefs.radarrDefaultProfile = 1;
    PlayerPrefs.radarrUhdProfile = 5;
    PlayerPrefs.sabURL = '';
    PlayerPrefs.sabApiKey = '';
    PlayerPrefs.showAdvancedSettings = false;
    PlayerPrefs.sonarrURL = '';
    PlayerPrefs.sonarrApiKey = '';
    PlayerPrefs.sonarrDefaultProfile = 1;
    PlayerPrefs.sonarrUhdProfile = 5;

    prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
    prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
    prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
    prefs.setInt(PlayerPrefs.radarrDefaultProfileKey, PlayerPrefs.radarrDefaultProfile);
    prefs.setInt(PlayerPrefs.radarrUhdProfileKey, PlayerPrefs.radarrUhdProfile);
    prefs.setString(PlayerPrefs.sabURLKey, PlayerPrefs.sabURL);
    prefs.setString(PlayerPrefs.sabApiKeyKey, PlayerPrefs.sabApiKey);
    prefs.setBool(PlayerPrefs.showAdvancedSettingsKey, PlayerPrefs.showAdvancedSettings);
    prefs.setString(PlayerPrefs.sonarrURLKey, PlayerPrefs.sonarrURL);
    prefs.setString(PlayerPrefs.sonarrApiKeyKey, PlayerPrefs.sonarrApiKey);
    prefs.setInt(PlayerPrefs.sonarrDefaultProfileKey, PlayerPrefs.radarrDefaultProfile);
    prefs.setInt(PlayerPrefs.sonarrUhdProfileKey, PlayerPrefs.sonarrUhdProfile);
  }
}