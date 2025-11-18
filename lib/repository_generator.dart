import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:gen_models/builder/builder_funcs.dart';
import 'package:gen_models/constants/app_values.dart';
import 'package:gen_models/generator.dart';
import 'package:gen_models/models/inport_info.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';
import 'builder/gen_models_builder.dart';
import 'builder/import_info_manager.dart';
import 'constants/build_option_keys.dart';
import 'models/mapper_type_info.dart';

class GenModelsRepositoryGenerator extends GenModelsGenerator<GenModels> {
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
  late Map<String, GeneratedBuilderFactory> mapGenerateBuilderFactory;
  Set<String> pathBuilded = Set();

  GenModelsRepositoryGenerator({this.options}) {
    dataDir ??= options?.config[BuildOptionKeys.dataDir];
    domainDir ??= options?.config[BuildOptionKeys.domainDir];
  }

  GeneratedBuilderFactory? getGeneratedBuilderFactory(String? path) =>
      mapGenerateBuilderFactory['lib/${path}'];

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await super.generate(library, buildStep);
  }

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    StringBuffer sb = StringBuffer();
    ImportInfo currentImportInfo = StringUtils.getImportInfo(element: element);
    if (!StringUtils.checkFileName(currentImportInfo.dirPath ?? '')) return '';
    currentImportInfo.prefix ??= builderFunc.getPrefix();
    final currentGeneratedBuilderFactory =
        getGeneratedBuilderFactory(currentImportInfo.dirPath);
    if (currentGeneratedBuilderFactory == null) return '';
    // if (ImportInfoManager.instance.getImportInfo(currentInportInfo.import) !=
    //     null) {
    //   currentInportInfo =
    //       ImportInfoManager.instance.getImportInfo(currentInportInfo.import)!;
    // }
    // if (currentGeneratedBuilderFactory.prefix?.isNotEmpty != true) {
    //   currentGeneratedBuilderFactory.prefix = currentInportInfo.prefix;
    // }
    path = StringUtils.getPath(element, isRemovePackage: true);
    List<String> imports = _getImports(element.library!);
    // imports.add(StringUtils.getImportForElement(element: element));
    // imports.add(StringUtils.getImportForElement(element: element));
    // imports.add(currentInportInfo.getMapperImport(
    //     prefix: currentGeneratedBuilderFactory.prefix));
    // imports.add(
    //     currentInportInfo.getMapperImport(prefix: builderFunc.getPrefix()));
    final dtoPath = StringUtils.getDTOPath(
        element: element,
        annotation: annotation,
        buildStep: buildStep,
        domainDir: domainDir,
        dataDir: dataDir);
    if (dtoPath.isNotEmpty == true) {
      imports.add(dtoPath);
    }
    final classes = _getBody(element as ClassElement, element.library,
        annotation, currentGeneratedBuilderFactory);
    List<String> bodies = [];
    List<String> mappers = [];
    imports.addAll(classes.imports);
    bodies.add(classes.body);
    imports = imports.toSet().toList();
    imports.sort();
    sb.writeln(currentGeneratedBuilderFactory.mappers.join('\n'));
    mappers.addAll(currentGeneratedBuilderFactory.mappers);
    currentGeneratedBuilderFactory.bodies.addAll(bodies);
    ImportInfoManager.instance.addAllImportInfo(imports
        .map(
          (e) => ImportInfo(import: e),
        )
        .toList());
    sb.write(currentGeneratedBuilderFactory.mappers.join('\n'));
    // builderFunc.onDetectedClassPaths(data: currentGeneratedBuilderFactory);
    return sb.toString();
  }

  ClassResult _getBody(
    ClassElement cls,
    LibraryElement targetLibrary,
    ConstantReader annotation,
    GeneratedBuilderFactory generatedBuilderFactory,
  ) {
    return _getClassResult(cls, null, generatedBuilderFactory);
  }

  ClassResult _getClassResult(ClassElement cls, ClassElement? targetClass,
      GeneratedBuilderFactory generatedBuilderFactory) {
    StringBuffer sb = StringBuffer();
    List<String> imports = [];
    List<String> mappers = [];
    cls.methods.forEach((method) {
      print('method name ${method.name}-type ${method.returnType.toString()}');
      if (true ||method.returnType is! InvalidType) {
        if (!StringUtils.checkNativeType(
            method.returnType.element?.name ?? '')) {
          final resultType = _getReturnType(method.returnType);
          if (method.returnType.isDartCoreList ||
              method.returnType is InterfaceType) {
            generatedBuilderFactory.mappers.add(
                '${method.name}-MapType<${resultType.mapTypes}>(ignoreFieldNull: true)');
          } else if (method.returnType.isDartCoreMap) {
            final result = _getClassTextForList(
                type: method.returnType as InterfaceType,
                varName: '',
                generatedBuilderFactory: generatedBuilderFactory);
            //MapType<Parent<Child>, ParentDTO<ChildDTO>>(ignoreFieldNull: true),
            generatedBuilderFactory.mappers
                .add(StringUtils.getMapTypeText(result?.mappers));
          } else {
            generatedBuilderFactory.mappers.add(
                '//${method.name}-${method.runtimeType.toString()}-${method.returnType.runtimeType.toString()}:' +
                    StringUtils.getMapTypeText(
                        [method.returnType.element?.name ?? '']));
          }
          // generatedBuilderFactory.mappers.add(method.returnType.getDisplayString(withNullability: true));
        }
      }
    });
    return ClassResult(body: sb.toString(), imports: imports, mappers: mappers);
  }

  MapperTypeInfo _getReturnType(DartType type) {
    MapperTypeInfo mapperTypeInfo = MapperTypeInfo();
    final name = type.element?.name ?? '';
    mapperTypeInfo.addSingleType(name);
    StringBuffer sb = StringBuffer();
    sb.write(name);
    if (!StringUtils.checkNativeType(name)) {
      if (type is InterfaceType) {
        List<String> childTypes = [];
        List<String> childTypesDTO = [];
        // print("type.typeArguments"+type.typeArguments.length.toString());
        type.typeArguments.forEach((e) {
          final name = e.element!.name ?? '';
          mapperTypeInfo.addSingleType(name);
          if (!StringUtils.checkNativeType(name)) {
            final resultMapper = _getReturnType(e);
            childTypes.add('${resultMapper.mapTypes}');
            mapperTypeInfo.addAllSingleType(resultMapper.singleTypes);
          }else {
            childTypes.add(name);
          }
        });
        // print("childTypes"+childTypes.length.toString()+"kq:  ${childTypes.join('---')}");
        if(type.typeArguments.length>0) {
          sb.write('<${childTypes.join(', ')}>');
        }else{
          sb.write('${childTypes.join(', ')}');
        }
      }
    }

    mapperTypeInfo.mapTypes = sb.toString();
    appLog([
      'mapperTypeInfo.mapTypes',
      mapperTypeInfo.mapTypes,
      mapperTypeInfo.singleTypes.join('\n')
    ]);
    final isAllNative = mapperTypeInfo.singleTypes.isEmpty;
    if (isAllNative) {
      mapperTypeInfo.mapTypes = '';
    }
    return mapperTypeInfo;
  }

  ClassResult? _getFieldDeclare(
      FieldElement field, GeneratedBuilderFactory generatedBuilderFactory) {
    ClassResult? result;
    if (field.type.isDartCoreList) {
      result = _getClassTextForList(
          type: field.type as InterfaceType,
          varName: field.name,
          generatedBuilderFactory: generatedBuilderFactory);
      //MapType<Parent<Child>, ParentDTO<ChildDTO>>(ignoreFieldNull: true),
      generatedBuilderFactory.mappers
          .add(StringUtils.getMapTypeText(result?.mappers));
    } else if (field.type.element != null) {
      result = _getClassResultForNotIterator(
          field: field.type.element!,
          varName: field.name,
          generatedBuilderFactory: generatedBuilderFactory);
      generatedBuilderFactory.mappers
          .add(StringUtils.getMapTypeText(result.mappers));
    }
    return result;
  }

  ClassResult _getClassResultForNotIterator(
      {required Element field,
      required String varName,
      String? obj,
      required GeneratedBuilderFactory generatedBuilderFactory}) {
    final dtoObject = obj ?? StringUtils.dtoObject;
    ClassResult result = ClassResult();
    final name = field.name ?? '';
    final isGenModels = (isGenModelsClass(field));
    if (!AppValues.nativeTypes.contains(name)) {
      result.body =
          '    ${newObj}.${varName} = ${_getClassNameFromType(field.name)}Mapper.$fromDTO(${dtoObject}.${varName});';
    }
    return result;
  }

  ClassResult _getClassResultForIterator(
      {required Element field,
      required String varName,
      required GeneratedBuilderFactory generatedBuilderFactory}) {
    ClassResult result = ClassResult();
    final name = field.name ?? '';
    final isGenModels = isGenModelsClass(field);
    if (AppValues.nativeTypes.contains(name) || !isGenModels) {
      result.body = varName;
    } else {
      if ((isGenModelsClass(field))) {
        result.body =
            '${_getClassNameFromType(field.name)}Mapper.$fromDTO(${varName})!';
        // result.imports.add(StringUtils.getImportForElement(element: field)
        //     .replaceAll('.dart', '.mapper.dart'));
      }
    }
    result.mappers.add(field.name ?? '');
    return result;
  }

  ClassResult? _getClassTextForList(
      {required InterfaceType type,
      required String varName,
      String? obj,
      required GeneratedBuilderFactory generatedBuilderFactory}) {
    StringBuffer sb = StringBuffer();
    StringBuffer mapperStringBuffer = StringBuffer();
    final first = type.typeArguments.firstOrNull;
    ClassResult? result = ClassResult();
    List<String> mappers = [];
    if (first == null) {
      return _getClassResultForIterator(
          field: type.element,
          varName: 'element',
          generatedBuilderFactory: generatedBuilderFactory);
    } else if (first is InterfaceType) {
      result = _getClassTextForList(
          type: first,
          varName: varName,
          obj: 'element',
          generatedBuilderFactory: generatedBuilderFactory);
    } else {
      result = _getClassResultForIterator(
          field: type.element,
          varName: 'element',
          generatedBuilderFactory: generatedBuilderFactory);
    }
    if (result != null) {
      mappers.add(first.element!.name!);
      return ClassResult(
          body: sb.toString(), imports: result.imports, mappers: mappers);
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
        "package:${packages.first}/${packages.sublist(2).join('/')}";
    return result;
  }

  String _getClassNameFromType(String? type) {
    if (type?.isNotEmpty == true) {
      type!.replaceAll('?', '');
    }
    return type ?? '';
  }

  bool isGenModelsRepositoryClass(Element element) {
    return element.metadata.firstWhereOrNull(
            (element) => element.toString().contains('@GenModels')) !=
        null;
  }
}

class ClassResult {
  List<String> imports;
  String body;
  List<String> mappers;
  GeneratedBuilderObject? generatedBuilderObject;

  ClassResult(
      {List<String>? imports,
      this.body = '',
      this.generatedBuilderObject,
      List<String>? mappers})
      : imports = imports ?? [],
        mappers = mappers ?? [];
}
