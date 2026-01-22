class ProfilePhoto {
  final String? id;
  final String? url;
  final bool? isPrimary;
  final DateTime uploadDate;

  ProfilePhoto({
    this.id,
    this.url,
    this.isPrimary,
    required this.uploadDate
  });

  factory ProfilePhoto.fromMap(Map<String, dynamic> map) => ProfilePhoto(
    id: map["id"],
    url: map["url"],
    isPrimary: map["is_primary"],
    uploadDate: map["upload_date"].toDate(),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "url": url,
    "is_primary": isPrimary,
    "upload_date": uploadDate,
  };

  ProfilePhoto copyWith({
    String? id,
    String? url,
    bool? isPrimary,
    DateTime? uploadDate,
  }) => ProfilePhoto(
    id: id ?? this.id,
    url: url ?? this.url,
    isPrimary: isPrimary ?? this.isPrimary,
    uploadDate: uploadDate ?? this.uploadDate,
  );  
}