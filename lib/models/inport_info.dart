import 'package:gen_models/string_utils.dart';

class ImportInfo {
  String? package;
  String? dirPath;
  String? import;
  String? fileName;
  String? mapperFileName;
  String? prefix;

  String getMapperImport({String? prefix, bool isFullImport = true}) {
    return 'mapper' +
        StringUtils.getImportForElement(
            path: StringUtils.getMapperPath(import ?? '')) +
        StringUtils.addPrefixAndSuffix(
            text: prefix ?? this.prefix, prefix: ' as ');
  }

  String getImportPrefix({String? prefix}) {
    return '$import ${StringUtils.addPrefixAndSuffix(text: prefix ?? this.prefix, prefix: ' as ')}';
  }

  ImportInfo(
      {this.package,
      this.dirPath,
      this.import,
      this.fileName,
      this.mapperFileName});
}
