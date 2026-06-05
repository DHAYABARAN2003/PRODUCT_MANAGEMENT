import 'package:json_annotation/json_annotation.dart';

part 'dimensions_model.g.dart';

@JsonSerializable()
class DimensionsModel {
  final double width;
  final double height;
  final double depth;

  const DimensionsModel({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory DimensionsModel.fromJson(Map<String, dynamic> json) =>
      _$DimensionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DimensionsModelToJson(this);

  @override
  String toString() => '${width}W x ${height}H x ${depth}D';
}
