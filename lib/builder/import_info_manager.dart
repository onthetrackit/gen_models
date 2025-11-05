import 'package:gen_models/string_utils.dart';

import '../models/inport_info.dart';
import 'package:collection/collection.dart';

import 'builder_funcs.dart';
import 'gen_models_builder.dart';

class ImportInfoManager {
  static ImportInfoManager _instance = ImportInfoManager._private();

  static ImportInfoManager get instance => _instance;

  ImportInfoManager._private();

  List<ImportInfo> importInfos = [];
  late BuilderFunc builderFunc;

  sort() {
    importInfos.sort(
      (a, b) => a.import!.compareTo(b.import!),
    );
  }

  addImportInfo(ImportInfo importInfo) {
    if (!hasImport(importInfo)) {
      importInfos.add(importInfo);
    }
  }

  addAllImportInfo(List<ImportInfo> importInfos) {
    importInfos.forEach(
      (element) {
        addImportInfo(element);
      },
    );
  }

  ImportInfo? getImportInfo(String? import, {bool isForDuplicate = true}) {
    if (import?.isNotEmpty != true) {
      return null;
    }
    return importInfos.firstWhereOrNull((element) => element.import == import);
  }

  hasImport(ImportInfo importInfo) {
    return importInfos.firstWhereOrNull((element) =>
            element.import == importInfo.import &&
            (element.prefix == importInfo.prefix ||
                (element.prefix?.isNotEmpty == true &&
                    importInfo.prefix?.isNotEmpty == true))) !=
        null;
  }

  GeneratedBuilderObject getGeneratedBuilderObjectFromImport(
      {required String importText, required String name, String? mapperName}) {
    mapperName ??= StringUtils.getMapperClassName(name);
    final import = StringUtils.getImportInfo(import: importText);
    GeneratedBuilderObject result = GeneratedBuilderObject();
    result.name = name;
    result.mapperClassName = mapperName;
    result.importInfo = getInfoFor(
      defaultImportInfo: import,
      name: name,
    );
    result.mapperImportInfo = getInfoFor(
      defaultImportInfo: import.cloneToMapper(),
      name: mapperName,
    );
    return result;
  }

  ImportInfo getInfoFor(
      {BuilderFunc? builderFunc,
      required String name,
      required ImportInfo defaultImportInfo}) {
    builderFunc ??= this.builderFunc;
    final duplicate = builderFunc.checkAndAddDuplicateClassName(name);
    if (duplicate) {
      ImportInfo result = defaultImportInfo;
      final addedImport = getImportInfo(defaultImportInfo.import);
      if (addedImport != null) {
        result = addedImport;
      } else {
        addImportInfo(result);
      }
      result.prefix ??= builderFunc.getPrefix();
      return result;
    }
    defaultImportInfo.prefix ??= builderFunc.getPrefix();
    addImportInfo(defaultImportInfo);
    return defaultImportInfo;
  }
}
