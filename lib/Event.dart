
class Event {
  final int? id;
  final int userid;
  final String title;
  final String description;
  final String date;
  final String? imagePath;
  final String? audioPath;

  Event({
    this.id = null,
    required this.userid,
    required this.title,
    required this.description,
    required this.date,
    this.imagePath,
    this.audioPath,
  });

  Event copyWith({
    int? id,
    int? userid,
    String? title,
    String? description,
    String? date,
    String? imagePath,
    String? audioPath,
  }) {
    return Event(
      id: id ?? this.id,
      userid: userid ?? this.userid,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      userid: map['userid'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      imagePath: map['imagePath'],
      audioPath: map['audioPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userid,
      'title': title,
      'description': description,
      'date': date,
      'imagePath': imagePath,
      'audioPath': audioPath,
    };
  }
}