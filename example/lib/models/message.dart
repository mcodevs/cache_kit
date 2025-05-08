class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  int progress = 0;
  bool isDownloading = false;

   Message({required this.id, required this.content, required this.timestamp, this.type = MessageType.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.fromString(json['type'] as String),
    );
  }

  String? get fileName {
    if (type == MessageType.text) return null;
    return content.split('/').last;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'timestamp': timestamp.toIso8601String(), 'type': type.name};
  }

}

enum MessageType {
  text,
  image,
  video,
  audio,
  file;

  static const Map<String, MessageType> _map = {
    'text': MessageType.text,
    'image': MessageType.image,
    'video': MessageType.video,
    'audio': MessageType.audio,
    'file': MessageType.file,
  };
  static MessageType fromString(String type) {
    return _map[type] ?? MessageType.text;
  }
}

/// Demo chat messages used by the example application.
///
/// Imported by `main.dart` as `demoMessages`.
final List<Message> demoMessages = [
  Message(
    id: '1',
    content: 'Hello, this is a text message.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    type: MessageType.text,
  ),
  Message(
    id: '2',
    content:
        'https://sample-videos.com/img/Sample-jpg-image-2mb.jpg',
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    type: MessageType.image,
  ),
  Message(
    id: '3',
    content:
        'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_5mb.mp4',
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    type: MessageType.video,
  ),
  Message(
    id: '4',
    content:
        'https://sample-videos.com/audio/mp3/crowd-cheering.mp3',
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    type: MessageType.audio,
  ),
  Message(
    id: '5',
    content:
        'https://sample-videos.com/pdf/Sample-pdf-5mb.pdf',
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    type: MessageType.file,
  ),
];
