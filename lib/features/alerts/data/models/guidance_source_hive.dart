import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';

part 'guidance_source_hive.g.dart';

/// Cached [GuidanceSourceModel], in the same field order.
@HiveType(typeId: 49)
class GuidanceSourceHive {
  GuidanceSourceHive({
    required this.sourceId,
    required this.title,
    required this.publisher,
    required this.url,
    required this.publishedOn,
    required this.accessedOn,
  });

  factory GuidanceSourceHive.fromModel(GuidanceSourceModel model) {
    return GuidanceSourceHive(
      sourceId: model.sourceId,
      title: model.title,
      publisher: model.publisher,
      url: model.url,
      publishedOn: model.publishedOn,
      accessedOn: model.accessedOn,
    );
  }

  GuidanceSourceModel toModel() {
    return GuidanceSourceModel(
      sourceId: sourceId,
      title: title,
      publisher: publisher,
      url: url,
      publishedOn: publishedOn,
      accessedOn: accessedOn,
    );
  }

  @HiveField(0)
  final String sourceId;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String publisher;
  @HiveField(3)
  final String url;
  @HiveField(4)
  final String publishedOn;
  @HiveField(5)
  final String accessedOn;
}
