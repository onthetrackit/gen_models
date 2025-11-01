import 'dart:collection';


typedef GetMapperFunction = Function(dynamic obj);
class MapperFactory {
  static final MapperFactory _instance = MapperFactory._private();

  static MapperFactory get instance => _instance;
  final HashMap<String, MapperData> _mapFuncs = HashMap();

  MapperFactory._private();

  init() {
    // addMapper("First", FirstToSecondMapper.fromDTO);
  }

  addMapper(String type, dynamic func) {
    if (_mapFuncs[type] == null) {
      _mapFuncs[type] = MapperData(type: type, func: func);
    } else {

    }
  }

  T? getMapper<T, R>(obj) {
    if (obj == null) return null;
    final func = _mapFuncs[obj.runtimeType.toString()];
    return func?.func?.call(obj) as T?;
  }
}

class MapperData {
  String? type;
  dynamic func;

  MapperData({this.type, this.func});
}
