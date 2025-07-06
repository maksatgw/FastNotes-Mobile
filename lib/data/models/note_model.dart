class NoteModel {
  final int? id;
  final String? title;
  final String? content;
  final String? createdAt;
  final String? updatedAt;
  final String? userId;

  NoteModel({
    this.id,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
