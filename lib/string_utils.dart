import 'package:analyzer/dart/element/element.dart';
import 'package:gen_models/models/inport_info.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:gen_models/constants/app_values.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';

import 'builder/builder.dart';
import 'builder/gen_models_builder.dart';
import 'constants/build_option_keys.dart';

class StringUtils {
  static const methodConvertName = 'fromDTO';
  static const dtoObject = 'obj';
  static const newObj = 'newObj';

  static String toCamelCase(String? text) {
    if (text?.isNotEmpty == true) {
      return text!.substring(0, 1).toLowerCase() + text.substring(1);
    }
    return '';
  }

  static String getMapperClass(String className) {
    return '${className}Mapper';
  }

  static String addPrefixAndSuffix(
      {String? text, String? prefix, String? suffix}) {
    if (text?.isNotEmpty == true) {
      return '${prefix ?? ''}${text}${suffix ?? ''}';
    }
    return '';
  }

  static String getDTOMapperClassName(String className) {
    return '${className}DTO';
  }

  static String getDTOClass(String className) {
    return '${className}DTO';
  }

  static String addDtoToFilePath(String? path) {
    if (path?.isNotEmpty == true) {
      if (!path!.toLowerCase().endsWith('_dto.dart'))
        return path.replaceAll(RegExp('.dart\$'), '_dto.dart');
    }
    return path ?? '';
  }

  static String getPath(Element? element, {bool isRemovePackage = false}) {
    String path = element?.location?.components
            .where(
              (element) => element.isNotEmpty == true,
            )
            .firstOrNull ??
        '';
    int index;
    if (isRemovePackage &&
        path.isNotEmpty == true &&
        (index = path.indexOf('/')) != -1) return path.substring(index + 1);
    return path;
  }

  static String getPackage({Element? element}) {
    String path = element?.location?.components
            .where(
              (element) => element.isNotEmpty == true,
            )
            .firstOrNull ??
        '';
    if (path.isNotEmpty == true) {
      return path.substring(path.indexOf(':') + 1, path.indexOf('/'));
    }
    return '';
  }

  static bool checkFileName(String path) {
    List<String> notAllowed = ['.g.dart', '.mapper.dart', 'dto.dart'];
    return notAllowed.firstWhereOrNull(
          (element) => path.toLowerCase().endsWith(element),
        ) ==
        null;
  }

  static ImportInfo getInportInfo({Element? element}) {
    if (element == null) appLog([' if(element==null)']);
    ImportInfo importInfo = ImportInfo();
    String path = element?.location?.components
            .where(
              (element) => element.isNotEmpty == true,
            )
            .firstOrNull ??
        '';
    if (path.isNotEmpty == true) {
      int index = path.indexOf('/');
      importInfo.package =
          path.substring(path.indexOf(':') + 1, path.indexOf('/'));
      importInfo.dirPath = path.substring(index + 1);
      importInfo.fileName = path.substring(path.lastIndexOf('/') + 1);
      importInfo.import = path;
    }
    return importInfo;
  }

  static String getMapperPath(String path) {
    print(
        'getMapperPath:${path}====${path.replaceAll(RegExp('.dart\$'), '.mapper.dart')}');
    return path.replaceAll(RegExp(r'.dart$'), '.mapper.dart');
  }

  static String getImportForElement(
      {Element? element, String? path, bool isAddSemicolon = true}) {
    return "import '${path ?? StringUtils.getPath(element)}'${isAddSemicolon ? ';' : ''}";
  }

  static String getDTOPath(
      {required Element element,
      required ConstantReader annotation,
      required BuildStep buildStep,
      String? domainDir,
      String? dataDir,
      bool isRemovePackage = false}) {
    final target = annotation.read('target');
    final rev = annotation.revive();
    String path = '';
    if (rev.namedArguments.containsKey('target') &&
        target.typeValue.element != null) {
      path =
          getPath(target.typeValue.element!, isRemovePackage: isRemovePackage);
    } else if (domainDir?.isNotEmpty == true && dataDir?.isNotEmpty == true) {
      path = getPath(element);
      if (path.isNotEmpty == true) {
        int index = -1;
        String package = '';
        if ((index = path.indexOf('/')) != -1) {
          index++;
          package = path.substring(0, index);
          path = path.substring(index);
        }
        print('path ${path}===${package}');
        path = path.replaceAll(RegExp('^${domainDir}'), dataDir!);
        if (index != -1) {
          path = '$package$path';
        }
      }
    }
    return StringUtils.addDtoToFilePath(path);
  }
}

appLog(List params, {String? prefix, String? suffix}) {
  if (prefix?.isNotEmpty == true) {
    print(prefix);
  }
  print(params
      .map(
        (e) => e.toString(),
      )
      .join('\n'));
  if (suffix?.isNotEmpty == true) {
    print(suffix);
  }
}
