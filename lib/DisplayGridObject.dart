import 'package:flutter/cupertino.dart';

import 'Movie.dart';
import 'Show.dart';

enum Type {
  Movie,
  TVShow
}
class DisplayGridObject {
  Status status;
  final Map<String, dynamic> obj;
  final Type type;

  DisplayGridObject({@required this.type, this.obj});

  String GetPoster() {
    List<dynamic> images = obj['images'];
    if (type == Type.Movie && images.length != 0) return images[0]['remoteUrl'].toString().replaceFirst('original', 'w185');
    else if (type == Type.TVShow && images.length >= 2) return images[1]['remoteUrl'];
    else return 'https://papystreaming.black/uploads/posts/2018-03/1520187249_1469865155_no_poster.png';
  }

  Status GetStatus(Map<String, dynamic> body) {
    if (body['totalRecords'] != 0) {
      List<dynamic> queue = body['records'];
      for (int i = 0; i < queue.length; i++) {
        if (queue[i]['seriesId'] == GetId())
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

  bool GetHasFile() {
    if (type == Type.Movie) return obj['hasFile'];
    else return obj['statistics']['episodeFileCount'] == obj['statistics']['episodeCount'];
  }

  String GetAdded() {
    return obj['added'].toString();
  }

  bool GetIsAvailable() {
    if (type == Type.Movie) return obj['isAvailable'];
    else return obj['statistics']['episodeCount'] != 0;
  }

  Movie ToMovie() {
    Movie ret = Movie(obj: obj);
    ret.status = status;
    return ret;
  }

  Show ToShow() {
    Show ret = Show(obj: obj);
    ret.status = status;
    return ret;
  }

}