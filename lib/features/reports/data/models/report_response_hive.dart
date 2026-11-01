import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';

part 'report_response_hive.g.dart';

/// Cached [ReportResponseModel], in the same field order.
@HiveType(typeId: 17)
class ReportResponseHive {
  ReportResponseHive({
    required this.section,
    required this.question,
    required this.answer,
    required this.order,
  });

  factory ReportResponseHive.fromModel(ReportResponseModel model) {
    return ReportResponseHive(
      section: model.section,
      question: model.question,
      answer: model.answer,
      order: model.order,
    );
  }

  ReportResponseModel toModel() {
    return ReportResponseModel(
      section: section,
      question: question,
      answer: answer,
      order: order,
    );
  }

  @HiveField(0)
  final String section;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final int order;
}
