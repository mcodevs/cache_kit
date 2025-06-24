/// Media categories recognized by *cache_kit*.
///
/// Each enum value wraps a user‑visible [directory] name that becomes the
/// sub‑folder where files of that type are stored. Helper getters
/// (e.g. [isVideo]) make type checks more readable.
enum MediaType {
  /// Video files (mp4, mkv, webm, …).
  video("Videos"),
  /// Image files (jpg, png, webp, …).
  image("Images"),
  /// Audio/music files (mp3, aac, flac, …).
  music("Musics"),
  /// Generic documents or archives (pdf, zip, txt, …).
  file("Files");

  /// Folder name used on disk for this media type.
  final String directory;

  const MediaType(this.directory);

  /// `true` if this media type is [MediaType.video].
  bool get isVideo => this == video;
  /// `true` if this media type is [MediaType.image].
  bool get isImage => this == image;
  /// `true` if this media type is [MediaType.music].
  bool get isMusic => this == music;
  /// `true` if this media type is [MediaType.file].
  bool get isFile => this == file;
}
