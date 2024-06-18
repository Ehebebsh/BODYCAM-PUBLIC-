class DiaryEntry {
  final String formattedDate;
  final String selectedOption;
  final double weight;
  final String diaryText;
  final String videoFileName;

  DiaryEntry({
    required this.formattedDate,
    required this.selectedOption,
    required this.weight,
    required this.diaryText,
    required this.videoFileName,
  });

  Map<String, dynamic> toJson() => {
    'formattedDate': formattedDate,
    'selectedOption': selectedOption,
    'weight': weight,
    'diaryText': diaryText,
    'videoFileName': videoFileName,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      formattedDate: json['formattedDate'],
      selectedOption: json['selectedOption'],
      weight: json['weight'],
      diaryText: json['diaryText'],
      videoFileName: json['videoFileName'],
    );
  }
}
