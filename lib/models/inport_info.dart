import 'package:gen_models/string_utils.dart';

class ImportInfo {
  String? package;
  String? dirPath;
  String? import;
  String? fileName;
  String? mapperFileName;
  String? prefix;
  String? mapperPrefix;

  String getMapperImport({String? prefix, bool isFullImport = true}) {
    return '222'+
        StringUtils.getImportForElement(
            path: StringUtils.getMapperPath(import ?? ''),
            isAddSemicolon: false) +
        StringUtils.addPrefixAndSuffix(
            text: prefix ?? this.mapperPrefix, prefix: ' as ')+';';
  }

  String getImportPrefix({String? prefix}) {
    return '${StringUtils.getImportForElement(path:import??'',isAddSemicolon: false)} ${StringUtils.addPrefixAndSuffix(text: prefix ?? this.prefix, prefix: ' as ')}';
  }

  ImportInfo(
      {this.package,
      this.dirPath,
      this.import,
      this.fileName,
      this.mapperFileName});
}
