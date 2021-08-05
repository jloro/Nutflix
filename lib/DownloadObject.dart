class DownloadObject {
  final dynamic obj;
  final bool inQueue;

  DownloadObject({this.obj, this.inQueue});

  String GetMoviename() { return inQueue ? obj['filename'] : obj['name']; }
  String GetMovienameClean() {
    String name;
    if (inQueue)
      name = obj['filename'];
    else
      name = obj['name'];

    RegExp exp = RegExp(r"^((?:(?: ?.* )+)(?:\ ?\d+ ))(?: ?.* )*\d*p");
    Iterable<RegExpMatch> matches = exp.allMatches(name.replaceAll('.', ' ').replaceAll(RegExp(' +'), ' '));
    return matches.length > 0 && matches.first.groupCount > 0 ? matches.first.group(1) : name;
  }

  String GetPercentage() { return obj['percentage']; }

  String GetActionLine() { if (obj['action_line'] != '') return obj['action_line']; else return 'Waiting'; }

  String GetMb() { return obj['mb']; }

  String GetMbLeft() { return obj['mbleft']; }

  String GetSize() { return obj['size']; }

  String GetTimeLeft() { return obj['timeleft']; }

  int get hashCode => obj.hashCode;

  @override
  bool operator ==(o) => o is DownloadObject && GetMoviename() == o.GetMoviename() && GetActionLine() == o.GetActionLine() && GetMbLeft() == o.GetMbLeft();

  static bool Compare(List<DownloadObject> a, List<DownloadObject> b) {
    if (a.length != b.length)
      return false;
    for (int i in Iterable.generate(a.length)) {
      if (a[i] != b[i])
        return false;
    }
    return true;
  }

}

