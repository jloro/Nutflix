import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:Nutarr/PlayerPrefs.dart';
import 'dart:developer' as developer;

enum Status {
  Unavailable,
  Queued,
  Missing,
  Downloaded
}

class Movie {
  final Map<String, dynamic> obj;
  Status status;
  Movie({this.obj});

  String GetTitle() { return obj['title']; }

  String GetOverview() {
    if (obj['overview'] != null) return obj['overview'];
    else return 'no overview';
  }

  String GetPoster() {
    List<dynamic> images = obj['images'];
    if (images.length != 0) return images[0]['remoteUrl'].toString().replaceFirst('original', 'w185');
    else return 'https://papystreaming.black/uploads/posts/2018-03/1520187249_1469865155_no_poster.png';
  }

  String GetFanart() {
    List<dynamic> images = obj['images'];
    if (images.length > 1) return images[1]['remoteUrl'];
    else return 'https://papystreaming.black/uploads/posts/2018-03/1520187249_1469865155_no_poster.png';
  }

  String GetRelease() {
    if (obj['inCinemas'] != null) return obj['inCinemas'];
    else if (obj['physicalRelease'] != null) return obj['physicalRelease'];
    else if (obj['digitalRelease'] != null) return obj['digitalRelease'];
    else return 'N/A';
  }

  String GetYear() {
    return obj['year'].toString();
  }

  String GetAdded() {
    return obj['added'].toString();
  }

  String GetRating() { return obj['ratings']['value'].toString(); }

  String GetIMDBId() { return obj['imdbId']; }

  bool GetHasFile() { return obj['hasFile']; }

  bool GetIsAvailable() { return obj['isAvailable']; }

  Status GetStatus(Map<String, dynamic> body) {
      if (body['totalRecords'] != 0)
      {
        List<dynamic> queue = body['records'];
        for (int i = 0; i < queue.length; i++) {
          if (queue[i]['movieId'] == GetId())
            return Status.Queued;
        }
      }

      if (GetHasFile())
        return Status.Downloaded;
      else if (!GetHasFile() && GetIsAvailable())
        return Status.Missing;
      return Status.Unavailable;
  }

  int GetId() { return obj['id']; }

  List<String> GetGenres() { return new List<String>.from(obj['genres']);}

  int GetRuntime() { return obj['runtime']; }

  String ToJson(bool ultrahd)
  {
    Map<String, dynamic> toSend = obj;
    toSend['qualityProfileId'] = ultrahd ? PlayerPrefs.uhdProfile : PlayerPrefs.defaultProfile;
    String path = PlayerPrefs.folderNamingFormat;
    path = path.replaceFirst('{Movie Title}', GetTitle());
    path = path.replaceFirst('{Release Year}', GetYear());
    path = path.replaceFirst('{Quality Title}', ultrahd ? "UHD" : "Default");
    toSend['path'] = '/home/jules/Videos/$path';
    toSend['monitored'] = true;
    return json.encode(toSend);
  }

  String GetMovieFileName() { return obj['movieFile']['relativePath']; }

  int GetMovieSize() { return obj['movieFile']['size']; }

  String GetQualityName() { return obj['movieFile']['quality']['quality']['name']; }

  String GetQualitySource() { return obj['movieFile']['quality']['quality']['source']; }

  String GetQualityResolution() { return obj['movieFile']['mediaInfo']['resolution']; }

  int GetAudioBitrate() { return obj['movieFile']['mediaInfo']['audioBitrate']; }

  double GetAudioChannels() { return obj['movieFile']['mediaInfo']['audioChannels']; }

  String GetAudioCodec() { return obj['movieFile']['mediaInfo']['audioCodec']; }

  String GetAudioLanguages() { return obj['movieFile']['mediaInfo']['audioLanguages']; }

  int GetVideoBitDepth() { return obj['movieFile']['mediaInfo']['videoBitDepth']; }

  int GetVideoBitrate() { return obj['movieFile']['mediaInfo']['videoBitrate']; }

  String GetVideoCodec() { return obj['movieFile']['mediaInfo']['videoCodec']; }

  double GetVideoFps() { return obj['movieFile']['mediaInfo']['videoFps']; }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      obj: json
    );
  }
}