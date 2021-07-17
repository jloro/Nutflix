import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:Nutarr/PlayerPrefs.dart';
import 'dart:developer' as developer;

import 'Movie.dart';

class Show {
  final Map<String, dynamic> obj;
  Status status;
  Show({this.obj});

  String GetTitle() { return obj['title']; }

  String GetOverview() {
    if (obj['overview'] != null) return obj['overview'];
    else return 'no overview';
  }

  String GetPoster() {
    List<dynamic> images = obj['images'];
    String ret;
    for (int i in Iterable.generate(images.length))
    {
      if (images[i]['coverType'] == 'poster')
        ret = images[i]['remoteUrl'];
    }
    if (ret == null) return 'https://papystreaming.black/uploads/posts/2018-03/1520187249_1469865155_no_poster.png';
    else return ret;
  }

  int GetNbSeasons() { return obj['statistics']['seasonCount']; }

  dynamic GetStatPerSeason(int nb) {
    for (int i  = 0; i < obj['seasons'].length; i++) {
      if (obj['seasons'][i]['seasonNumber'] == nb)
        return obj['seasons'][i]['statistics'];
    }}

  String GetFanart() {
    List<dynamic> images = obj['images'];
    String ret;
    for (int i in Iterable.generate(images.length))
    {
        if (images[i]['coverType'] == 'fanart')
          ret = images[i]['remoteUrl'];
    }
    if (ret == null) return 'https://papystreaming.black/uploads/posts/2018-03/1520187249_1469865155_no_poster.png';
    else return ret;
  }

  bool GetEnded() { return obj['ended']; }

  String GetYear() {
    return obj['year'].toString();
  }

  String GetAdded() {
    return obj['added'].toString();
  }

  String GetRating() { return obj['ratings']['value'].toString(); }

  String GetIMDBId() { return obj['imdbId']; }

  bool GetHasFile() { return obj['statistics']['episodeFileCount'] == obj['statistics']['episodeCount']; }

  bool GetIsAvailable() { return obj['statistics']['episodeCount'] != 0; }

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

  // String ToJson(bool ultrahd)
  // {
  //   Map<String, dynamic> toSend = obj;
  //   toSend['id'] = 0;
  //   toSend['qualityProfileId'] = ultrahd ? PlayerPrefs.uhdProfile : PlayerPrefs.defaultProfile;
  //   String path = PlayerPrefs.folderNamingFormat;
  //   path = path.replaceFirst('{Movie Title}', GetOriginalTitle());
  //   path = path.replaceFirst('{Release Year}', GetYear());
  //   path = path.replaceFirst('{Quality Title}', ultrahd ? "UHD" : "Default");
  //   toSend['path'] = '${PlayerPrefs.dlPath}/$path';
  //   toSend['monitored'] = true;
  //   return json.encode(toSend);
  // }
}