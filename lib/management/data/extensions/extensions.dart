/// A centralized registry of file‑type extensions recognized by *cache_kit*.
///
/// These lists let the library infer a file’s media type (video, image,
/// music, or generic file) from its extension. The class is `sealed` and
/// contains only static members; it must not be instantiated or subclassed.
sealed class Extensions {
  /// Common video file extensions.
  static const List<String> video = ["mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "mpeg", "mpg"];
  /// Common image file extensions.
  static const List<String> image = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "svg"];
  /// Common audio/music file extensions.
  static const List<String> music = ["mp3", "wav", "flac", "aac", "ogg", "wma", "m4a"];
  /// Common generic document/archive file extensions.
  static const List<String> file = ["txt", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "zip", "rar", "7z"];
  /// Combined list of *all* supported extensions across categories.
  static const List<String> all = [...video, ...image, ...music, ...file];
}
