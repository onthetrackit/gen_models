class StringUtils {
  static const methodConvertName = 'fromDTO';

  static String toCamelCase(String? text) {
    if (text?.isNotEmpty == true) {
      return text!.substring(0, 1).toLowerCase() + text.substring(1);
    }
    return '';
  }

  static String getMapperClass(String className) {
    return '${className}Mapper';
  }
  static String getDTOClass(String className) {
    return '${className}DTO';
  }
}
