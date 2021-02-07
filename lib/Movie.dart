import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

enum Status {
  Unavailable,
  Queued,
  Missing,
  Downloaded
}

class Movie {
  final Map<String, dynamic> obj;

  Movie({this.obj});

  String GetTitle() { return obj['title']; }

  String GetOverview() {
    if (obj['overview'] != null) return obj['overview'];
    else return 'no overview';
  }

  String GetPoster() {
    List<dynamic> images = obj['images'];
    if (images.length != 0) return images[0]['remoteUrl'];
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

  String GetRating() { return obj['ratings']['value'].toString(); }

  String GetIMDBId() { return obj['imdbId']; }

  bool GetHasFile() { return obj['hasFile']; }

  bool GetIsAvailable() { return obj['isAvailable']; }

  Future<Status> GetStatus() async {
    if (GetHasFile())
      return Status.Downloaded;
    else if (!GetHasFile() && GetIsAvailable())
      return Status.Missing;

    final response =
    await http.get('https://nutflix.fr/radarr/api/v3/queue', headers : {HttpHeaders.authorizationHeader: 'aaaedca659fa4206bc50153292ba6da2'});

    if (response.statusCode == 200) {

      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> body = json.decode(response.body);
      if (body['totalRecords'] != 0)
      {
        List<dynamic> queue = body['records'];
        for (int i = 0; i < queue.length; i++) {
          if (queue[i]['movieId'] == GetId())
            return Status.Queued;
        }
      }
      return Status.Unavailable;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Movie');
    }
  }

  String GetId() { return obj['id']; }

  String ToJson()
  {
    Map<String, dynamic> toSend = obj;
    toSend['qualityProfileId'] = 1;
    toSend['path'] = '/home/jules/Videos/${GetTitle()} ${GetYear()}';
    toSend['monitored'] = true;
    return json.encode(toSend);
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      obj: json
    );
  }
}