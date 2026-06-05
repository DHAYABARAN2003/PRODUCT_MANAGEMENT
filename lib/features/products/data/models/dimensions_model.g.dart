part of 'dimensions_model.dart';


DimensionsModel _$DimensionsModelFromJson(Map<String, dynamic> json) =>
    DimensionsModel(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
    );

Map<String, dynamic> _$DimensionsModelToJson(DimensionsModel instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'depth': instance.depth,
    };
