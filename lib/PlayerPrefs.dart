import 'package:shared_preferences/shared_preferences.dart';

class PlayerPrefs
{
  static const String statsForNerdsKey = "statsForNerds";
  static bool statsForNerds = false;

  static const String radarrApiKeyKey = "radarrApiKey";
  static String radarrApiKey;

  static const String radarrURLKey = "radarrURL";
  static String radarrURL;

  static const String defaultProfileKey = "defaultProfile";
  static int defaultProfile = 1;

  static const String uhdProfileKey = "uhdProfile";
  static int uhdProfile = 5;

  static const String folderNamingFormatKey = "folderNamingFormat";
  static String folderNamingFormat;

  static const String sabApiKeyKey = "sabApiKey";
  static String sabApiKey;

  static const String sabURLKey = "sabURL";
  static String sabURL;

  static const String dlPathKey = "dlPath";
  static String dlPath;

  static const String showAdvancedSettingsKey = "showAdvancedSettings";
  static bool showAdvancedSettings = false;

  static bool demo = false;
  static String demoKey = "demo";

  static const String firstLaunchKey = "firstLaunch";
  static bool firstLaunch = true;

  static void Reset(SharedPreferences prefs)
  {
    PlayerPrefs.statsForNerds = false;
    PlayerPrefs.radarrURL = null;
    PlayerPrefs.radarrApiKey = null;
    PlayerPrefs.defaultProfile = 1;
    PlayerPrefs.uhdProfile = 5;
    PlayerPrefs.sabURL = null;
    PlayerPrefs.sabApiKey = null;
    PlayerPrefs.showAdvancedSettings = false;

    prefs.setString(PlayerPrefs.radarrURLKey, PlayerPrefs.radarrURL);
    prefs.setString(PlayerPrefs.radarrApiKeyKey, PlayerPrefs.radarrApiKey);
    prefs.setBool(PlayerPrefs.statsForNerdsKey, PlayerPrefs.statsForNerds);
    prefs.setInt(PlayerPrefs.defaultProfileKey, PlayerPrefs.defaultProfile);
    prefs.setInt(PlayerPrefs.uhdProfileKey, PlayerPrefs.uhdProfile);
    prefs.setString(PlayerPrefs.sabURLKey, PlayerPrefs.sabURL);
    prefs.setString(PlayerPrefs.sabApiKeyKey, PlayerPrefs.sabApiKey);
    prefs.setBool(PlayerPrefs.showAdvancedSettingsKey, PlayerPrefs.showAdvancedSettings);

    if (PlayerPrefs.radarrURL == PlayerPrefs.demoKey && PlayerPrefs.radarrApiKey == PlayerPrefs.demoKey && PlayerPrefs.sabURL == PlayerPrefs.demoKey && PlayerPrefs.sabApiKey == PlayerPrefs.demoKey)
      PlayerPrefs.demo = true;
    else
      PlayerPrefs.demo = false;
  }
}