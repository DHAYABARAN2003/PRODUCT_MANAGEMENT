

part of 'meta_model.dart';


MetaModel _$MetaModelFromJson(Map<String, dynamic> json) => MetaModel(
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  barcode: json['barcode'] as String,
  qrCode: json['qrCode'] as String,
);

Map<String, dynamic> _$MetaModelToJson(MetaModel instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'barcode': instance.barcode,
  'qrCode': instance.qrCode,
};
