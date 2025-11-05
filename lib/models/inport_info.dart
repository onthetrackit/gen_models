import 'package:gen_models/string_utils.dart';

class ImportInfo {
  String? package;
  String? dirPath;
  String? import;
  String? fileName;
  String? prefix;

  String getImportPrefix({String? prefix}) {
    prefix=StringUtils.addPrefixAndSuffix(text: prefix ?? this.prefix, prefix: ' as ');
    return '${StringUtils.getImportForElement(path: import ?? '', isAddSemicolon: prefix.isEmpty)} ${prefix.isEmpty?'':'${prefix};'}';
  }

  ImportInfo cloneToMapper() {
    return ImportInfo(
        package: package,
        dirPath: StringUtils.getMapperPath(dirPath ?? ''),
        import: StringUtils.getMapperPath(import ?? ''),
        fileName: StringUtils.getMapperPath(fileName ?? ''),
        prefix: prefix);
  }

  ImportInfo(
      {this.package, this.dirPath, this.import, this.fileName, this.prefix});
}
