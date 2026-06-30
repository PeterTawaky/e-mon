class ReadingModel {
  const ReadingModel({
    required this.id,
    required this.tenantId,
    required this.componentName,
    required this.accumulativeValue,
    required this.pastAccumulativeValue,
    required this.relativeValue,
    required this.createdAt,
  });

  final int id;
  final int tenantId;
  final String componentName;
  final double accumulativeValue;
  final double pastAccumulativeValue;
  final double relativeValue;
  final DateTime createdAt;

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int,
      componentName: json['component_name'] as String,
      accumulativeValue: (json['accumulative_value'] as num).toDouble(),
      pastAccumulativeValue: (json['past_accumulative_value'] as num)
          .toDouble(),
      relativeValue: (json['relative_value'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
