class AppSettings {
  final double textScaleFactor;

  const AppSettings({
    required this.textScaleFactor,
  });

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      textScaleFactor: 1.0,
    );
  }

  AppSettings copyWith({
    double? textScaleFactor,
  }) {
    return AppSettings(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.textScaleFactor == textScaleFactor;
  }

  @override
  int get hashCode {
    return textScaleFactor.hashCode;
  }

  @override
  String toString() {
    return 'AppSettings('
        'textScaleFactor: $textScaleFactor'
        ')';
  }
}
