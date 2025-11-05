import 'dart:collection';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:gen_models/builder/builder_funcs.dart';
import 'package:gen_models/constants/app_values.dart';
import 'package:gen_models/models/inport_info.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';
import 'builder/gen_models_builder.dart';
import 'constants/build_option_keys.dart';

class GenModelsGenerator extends GeneratorForAnnotation<GenModels> {
  late BuilderFunc builderFunc;
  String? builderHashCode;

  // List<GeneratedBuilderObject> objs = [];
  String? path = "";
  final modelPath = '/models';
  final newObj = StringUtils.newObj;
  final fromDTO = StringUtils.methodConvertName;
  final dtoObject = StringUtils.dtoObject;
  BuilderOptions? options;

  String? dataDir;
  String? domainDir;
  late GeneratedBuilderFactory currentGenerateBuilderFactory;
  late ImportInfo currentInportInfo;
  Set<String> pathBuilded = Set();

  GenModelsGenerator({this.options}) {
    dataDir ??= options?.config[BuildOptionKeys.dataDir];
    domainDir ??= options?.config[BuildOptionKeys.domainDir];
  }

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    currentInportInfo = StringUtils.getInportInfo(element: element);
    if(currentGenerateBuilderFactory.prefix?.isNotEmpty!=true) {
      currentGenerateBuilderFactory.prefix = builderFunc.getPrefix();
    }
    currentInportInfo.prefix = currentGenerateBuilderFactory.prefix;
    path = StringUtils.getPath(element, isRemovePackage: true);
    List<String> imports = _getImports(element.library!);
    imports.add(StringUtils.getImportForElement(element: element));
    imports.add(StringUtils.getImportForElement(element: element));
    // imports.add(currentInportInfo.getMapperImport(
    //     prefix: currentGenerateBuilderFactory.prefix));
    // imports.add(
    //     currentInportInfo.getMapperImport(prefix: builderFunc.getPrefix()));
    final dtoPath = StringUtils.getDTOPath(
        element: element,
        annotation: annotation,
        buildStep: buildStep,
        domainDir: domainDir,
        dataDir: dataDir);
    if (dtoPath.isNotEmpty == true) {
      imports.add("import '${dtoPath}';");
    }
    final classes =
        _getBody(element as ClassElement, element.library!, annotation);
    List<String> bodies = [];
    imports.addAll(classes.imports);
    bodies.add(classes.body);
    imports = imports.toSet().toList();
    imports.sort();
    currentGenerateBuilderFactory.bodies.addAll(bodies);
    currentGenerateBuilderFactory.addAllImportInfo(imports
        .map(
          (e) => ImportInfo(import: e),
        )
        .toList());
    builderFunc.onDetectedClassPaths(data: currentGenerateBuilderFactory);
    return '';
  }

  ClassResult _getBody(ClassElement cls, LibraryElement targetLibrary,
      ConstantReader annotation) {
    // final currentReader = LibraryReader(currentLibrary);
    // final targetReader = LibraryReader(targetLibrary);
    // HashMap<String, ClassElement> currentClasses =
    //     _getMapElements(currentReader.classes);
    // HashMap<String, ClassElement> targetClasses =
    //     _getMapElements(targetReader.classes);
    // List<ClassResult> results = [];
    // currentReader.classes.forEach((cls) {
    final generatedBuilderObject = GeneratedBuilderObject(
        name: cls.name,
        prefix: currentGenerateBuilderFactory.prefix,
        mapperClassName: StringUtils.getMapperClass(cls.name));
    currentGenerateBuilderFactory.objects.add(generatedBuilderObject);
    final duplicate = builderFunc.checkDuplicateClassName(cls.name);
    if (duplicate) {
      appLog(['duplicate', duplicate]);
      var importInfo = StringUtils.getInportInfo(element: cls);
      final addedImport =
          currentGenerateBuilderFactory.getImportInfo(importInfo.import);
      if (currentInportInfo.package != importInfo.package) {
        if (addedImport != null) {
          importInfo = addedImport;
          if (importInfo.prefix?.isNotEmpty != true) {
            final prefix = builderFunc.getPrefix();
            importInfo.prefix = prefix;
          }
          if (importInfo.mapperPrefix?.isNotEmpty != true) {
            final prefix = builderFunc.getPrefix();
            importInfo.mapperPrefix = prefix;
          }
        } else {
          final mapperPrefix = builderFunc.getPrefix();
          generatedBuilderObject.prefix = currentGenerateBuilderFactory.prefix;
          generatedBuilderObject.mapperPrefix = mapperPrefix;
          importInfo.prefix = currentGenerateBuilderFactory.prefix;
        }
        currentGenerateBuilderFactory.addImportInfo(importInfo);
        currentGenerateBuilderFactory.objects.add(generatedBuilderObject);
      }
    }
    //todo check null targetClasses[cls.name]
    return _getClassResult(cls, null);
    // });
  }

  ClassResult _getClassResult(ClassElement cls, ClassElement? targetClass) {
    StringBuffer sb = StringBuffer();
    final dtoClass = StringUtils.getDTOClass(cls.name);
    final mapperClass = StringUtils.getMapperClass(cls.name);
    final domainClass = '${cls.name}';
    sb.writeln('class ${mapperClass}{');
    sb.writeln('  static ${domainClass}? $fromDTO($dtoClass? ${dtoObject}){');
    sb.writeln('  if(${dtoObject}==null) return null;');
    sb.writeln('  ${domainClass} ${newObj} = $domainClass();');
    List<String> imports = [];
    HashMap<String, FieldElement> currentFields = _getMapElements(cls.fields);
    // HashMap<String, FieldElement> targetFields =
    //     _getMapElements(targetClass.fields);
    // Set<String> targetKeys = Set.from(targetFields.keys);
    // currentFields.removeWhere((key, value) => !targetKeys.contains(key));
    currentFields.forEach((key, field) {
      final result = _getFieldDeclare(field);
      if (result != null) {
        imports.addAll(result.imports);
        sb.writeln(result.body);
      }
    });
    sb.writeln('  return ${newObj};');
    sb.writeln('  }\n\t}');
    return ClassResult(body: sb.toString(), imports: imports);
  }

  HashMap<String, T> _getMapElements<T extends Element>(Iterable<T> elements) {
    HashMap<String, T> result = HashMap();
    (elements)
        .where(
      (element) => !element.isSynthetic,
    )
        .forEach(
      (element) {
        result[element.name ?? ''] = element;
      },
    );
    return result;
  }

  ClassResult? _getFieldDeclare(FieldElement field) {
    ClassResult? result;
    if (field.type.isDartCoreList) {
      result = _getClassTextForList(
          type: field.type as InterfaceType, varName: field.name);
      if (result?.body.isNotEmpty == true) {
        result?.body += ';';
      }
    } else if (field.type.element != null) {
      result = _getClassResultForNotIterator(
          field: field.type.element!, varName: field.name);
    }
    return result;
  }

  ClassResult _getClassResultForNotIterator(
      {required Element field, required String varName, String? obj}) {
    final dtoObject = obj ?? StringUtils.dtoObject;
    ClassResult result = ClassResult();
    final name = field.name ?? '';
    final isGenModels = (isGenModelsClass(field));
    if (AppValues.nativeTypes.contains(name) || !isGenModels) {
      result.body = '   ${newObj}.${varName} = ${dtoObject}.${varName};';
    } else {
      result.body =
          '    ${newObj}.${varName} = ${_getClassNameFromType(field.name)}Mapper.$fromDTO(${dtoObject}.${varName});';
      result.imports.add(StringUtils.getImportForElement(element: field)
          .replaceAll('.dart', '.mapper.dart'));
    }
    return result;
  }

  ClassResult _getClassResultForIterator(
      {required Element field, required String varName}) {
    ClassResult result = ClassResult();
    final name = field.name ?? '';
    final isGenModels = (isGenModelsClass(field));
    if (AppValues.nativeTypes.contains(name) || !isGenModels) {
      result.body = varName;
    } else {
      if ((isGenModelsClass(field))) {
        result.body =
            '${_getClassNameFromType(field.name)}Mapper.$fromDTO(${varName})!';
        result.imports.add(StringUtils.getImportForElement(element: field)
            .replaceAll('.dart', '.mapper.dart'));
      }
    }
    return result;
  }

  ClassResult? _getClassTextForList(
      {required InterfaceType type, required String varName, String? obj}) {
    StringBuffer sb = StringBuffer();
    final first = type.typeArguments.firstOrNull;
    ClassResult? result = ClassResult();
    if (first == null) {
      return _getClassResultForIterator(
          field: type.element, varName: 'element');
    } else if (first is InterfaceType) {
      result =
          _getClassTextForList(type: first, varName: varName, obj: 'element');
    } else {
      result = _getClassResultForIterator(
        field: type.element,
        varName: 'element',
      );
    }
    if (result != null) {
      sb.writeln(
          '''${obj?.isNotEmpty == true ? '' : '${newObj}.${varName}='}${obj != null ? obj : '${dtoObject}.${obj ?? varName}'}?.map((element)=>${result.body}).toList()??[]''');
      return ClassResult(body: sb.toString(), imports: result.imports);
    }
    return null;
  }

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

  String _convertImport(String text) {
    final splits = text.split(" ");
    final packages = splits[2].substring(1).split("/");
    String result =
        "${splits[0]} 'package:${packages.first}/${packages.sublist(2).join('/')}';";
    return result;
  }

  String _getClassNameFromType(String? type) {
    if (type?.isNotEmpty == true) {
      type!.replaceAll('?', '');
    }
    return type ?? '';
  }

  bool isGenModelsClass(Element element) {
    return element.metadata.firstWhereOrNull(
            (element) => element.toString().contains('@GenModels')) !=
        null;
  }
}

class ClassResult {
  List<String> imports;
  String body;

  ClassResult({List<String>? imports, this.body = ''})
      : imports = imports ?? [];
}
