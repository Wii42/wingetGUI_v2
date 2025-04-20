// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_screenshots.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageScreenshots _$PackageScreenshotsFromJson(Map<String, dynamic> json) =>
    PackageScreenshots(
      packageKey: json['packageKey'] as String,
      icon: json['icon'] == null ? null : Uri.parse(json['icon'] as String),
      screenshots: (json['images'] as List<dynamic>?)
          ?.map((e) => Uri.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$PackageScreenshotsToJson(PackageScreenshots instance) =>
    <String, dynamic>{
      'packageKey': instance.packageKey,
      'icon': instance.icon?.toString(),
      'images': instance.screenshots?.map((e) => e.toString()).toList(),
    };
