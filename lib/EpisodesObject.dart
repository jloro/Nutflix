class Episodes {
  final dynamic obj;
  final dynamic queue;

  Episodes({this.obj, this.queue});

  int get hashCode => obj.hashCode;

  dynamic GetEpisode(int season, int nb)
  {
    for (int i = 0; i < obj.length; i++) {
      if (obj[i]['seasonNumber'] == season && obj[i]['episodeNumber'] == nb)
        return obj[i];
    }
  }

  @override
  bool operator ==(o) => o is Episodes && obj.toString() == o.obj.toString() && queue.toString() == o.queue.toString();
}