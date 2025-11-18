import 'dart:math';

import 'package:gen_models/string_utils.dart';

class MapperTypeInfo {
  String mapTypes;
  String mapTypesDTO;
  List<String> singleTypes;

  addSingleType(String type) {
    if (!StringUtils.checkCoreType(type)) {
      singleTypes.add(type);
    }
  }

  addAllSingleType(List<String> types) {
    types.forEach(
      (element) {
        addSingleType(element);
      },
    );
  }

  MapperTypeInfo({String? mapType, String? mapTypesDTO, List<String>? singleTypes})
      : singleTypes = singleTypes ?? [],
        mapTypes = mapType ?? '',
        mapTypesDTO = mapType ?? '';
}
