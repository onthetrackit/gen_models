
import '../models/inport_info.dart';
import 'package:collection/collection.dart';

import 'builder_funcs.dart';

class ImportInfoManager {
  static ImportInfoManager _instance = ImportInfoManager._private();

  static ImportInfoManager get instance => _instance;

  ImportInfoManager._private();

  List<ImportInfo> importInfos = [];

  sort() {
    importInfos.sort(
          (a, b) => a.import!.compareTo(b.import!),
    );
  }

  addImportInfo(ImportInfo importInfo) {
    if (!hasImport(importInfo)) {
      importInfos.add(importInfo);
    }
    // if (hasImport(importInfo)) {
    //   //todo remove
    //   importInfos.removeWhere(
    //         (element) => element.import == importInfo.import,
    //   );
    // }
    // importInfos.add(importInfo);
  }

  addAllImportInfo(List<ImportInfo> importInfos) {
    importInfos.forEach(
          (element) {
        addImportInfo(element);
      },
    );
  }

  ImportInfo? getImportInfo(String? import) {
    if (import?.isNotEmpty != true) {
      return null;
    }
    return importInfos.firstWhereOrNull(
          (element) => element.import == import,
    );
  }

  hasImport(ImportInfo importInfo) {
    return importInfos.firstWhereOrNull(
          (element) => element.import == importInfo.import,
    ) !=
        null;
  }

  ImportInfo getInfoFor(
      {required BuilderFunc builderFunc,
        required String name,
        required ImportInfo defaultImportInfo}) {
    final duplicate = builderFunc.checkAndAddDuplicateClassName(name);
    if (duplicate) {
      ImportInfo result = defaultImportInfo;
      final addedImport = getImportInfo(defaultImportInfo.import);
      if (addedImport != null) {
        result = addedImport;
        if (result.prefix?.isNotEmpty != true) {
          final prefix = builderFunc.getPrefix();
          result.prefix = prefix;
        }
      } else {
        addImportInfo(result);
      }
      print('check info:${result.prefix}');
      return result;
    }
    return defaultImportInfo;
  }
}