import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:gen_models/app_values.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';

import 'builder.dart';

typedef GetClassPaths = void Function({required GeneratedBuilderFactory data});

class GenModelsGenerator extends GeneratorForAnnotation<GenModels> {
  GetClassPaths? onDetectedClassPaths;
  String? builderHashCode;
  GeneratedBuilderFactory? generateBuilderFactory;
  List objs = [];
  String? path = "";
  final modelPath = '/models';

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final buffer = StringBuffer();
    // path = _getPath(element);
    final importPath = 'lib/data/models/';
    List<String> imports = _getImports(element.library!);
    imports.add(_getImportForElement(element));
    generateBuilderFactory = GeneratedBuilderFactory(objects: [], path: '');
    final classes = _getBody(element.library!, annotation);
    List<String> bodies = [];
    classes.forEach(
      (element) {
        imports.addAll(element.imports);
        bodies.add(element.body);
      },
    );
    imports = imports.toSet().toList();
    imports.sort();
    buffer.writeln(imports.join('\n'));
    buffer.writeln(bodies.join('\n\n'));
    generateBuilderFactory?.objects = objs;
    generateBuilderFactory?.path = path ?? '';
    onDetectedClassPaths?.call(data: generateBuilderFactory!);
    return buffer.toString();
  }

  List<ClassResult> _getBody(
      LibraryElement library, ConstantReader annotation) {
    final reader = LibraryReader(library);
    final resultStrings = StringBuffer();
    List<ClassResult> results = [];
    reader.classes.forEach((cls) {
      objs.add(cls);
      results.add(_getClassText(cls));
    });
    return results;
  }

  ClassResult _getClassText(ClassElement cls) {
    StringBuffer sb = StringBuffer();
    final dtoClass = StringUtils.getDTOClass(cls.name);
    final mapperClass = StringUtils.getMapperClass(cls.name);
    final dtoObject = 'obj';
    final fromDTO = StringUtils.methodConvertName;
    final newObj = 'newObj';
    final domainClass = '${cls.name}';
    sb.writeln('class ${mapperClass}{');
    sb.writeln('  static ${domainClass} $fromDTO($dtoClass? ${dtoObject}){');
    sb.writeln('  ${domainClass} ${newObj} = $domainClass();');
    List<String> imports = [];
    cls.fields.forEach(
      (field) {
        if (!field.isSynthetic) {
          final type = field.type.toString().replaceAll(r'?', '');
          if (AppValues.nativeTypes.contains(type) ||
              (field.type.element != null &&
                  !isGenModelsClass(field.type.element!))) {
            sb.writeln(
                '   ${newObj}.${field.name} = ${dtoObject}.${field.name};');
          } else {
            sb.writeln(
                '    ${newObj}.${field.name} = ${_getClassNameFromType(field.type.toString())}Mapper.$fromDTO(${field.name});');
            imports.add(_getImportForElement(field.type.element!).replaceAll('.dart', '.mapper.dart'));
          }
        }
      },
    );
    sb.writeln('  )\n}');
    return ClassResult(body: sb.toString(), imports: imports);
  }

  String _getImportForElement(Element element) {
    return "import '${_getPath(element)}';";
  }

  String _getClassNameFromType(String? type) {
    if (type?.isNotEmpty == true) {
      type!.replaceAll('\?', '');
    }
    return type ?? '';
  }

  bool isGenModelsClass(Element element) {
    return element.metadata.firstWhereOrNull(
            (element) => element.toString().contains('@GenModels')) !=
        null;
  }

// Hàm hỗ trợ clone imports
  List<String> _getImports(LibraryElement library) {
    final reader = LibraryReader(library);
    final List<String> sb = [];
    for (final import in reader.allElements.where(
      (element) => element is LibraryImportElement,
    )) {
      if (!import.isSynthetic) {
        sb.add(_convertImport(import.getDisplayString(withNullability: true)));
      }
    }
    return sb;
  }

  String _getPath(Element? element) {
    return element?.location?.components
            .where(
              (element) => element.isNotEmpty == true,
            )
            .firstOrNull ??
        '';
  }

  String _convertImport(String text) {
    final splits = text.split(" ");
    final packages = splits[2].substring(1).split("/");
    //import source /gen_del3/lib/abc/test.dart
    String result =
        "${splits[0]} 'package:${packages.first}/${packages.sublist(2).join('/')}';";
    return result;
  }
}

class ClassResult {
  List<String> imports;
  String body;

  ClassResult({this.imports = const [], this.body = ''});
}
