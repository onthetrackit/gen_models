import 'dart:io';

import 'package:build/build.dart';
import 'package:gen_models/builder/builder_funcs.dart';
import 'package:gen_models/constants/build_option_keys.dart';
import 'package:gen_models/mapper_factory.dart';
import 'package:gen_models/models/inport_info.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';

import '../generator.dart';

final String markHeader = '//__markHeader__';
final String markBody = '//__markBody__';
final String fileSeparator = '//__start file__';

class GenModelsBuilder extends LibraryBuilder implements BuilderFunc {
  int _importCount = 0;
  late GenModelsGenerator generator;

  // List<String> _imports = [];
  // List<String> _funcs = [];
  Set<String> allClassName = Set();
  late Map<String, GeneratedBuilderFactory> mapGenerateBuilderFactory={};
  final filePath = 'build/fake.mapper.dart';
  final split = '//=============';
  BuilderOptions? options;
  String? dataDir;
  String? domainDir;
  Set<String> classNames = Set();

  GenModelsBuilder(
    Generator generator, {
    String Function(String code)? formatOutput,
    String generatedExtension = '.g.dart',
    List<String> additionalOutputExtensions = const [],
    String? header,
    bool allowSyntaxErrors = false,
    BuilderOptions? options,
  }) : super(
          generator,
          formatOutput: formatOutput,
          generatedExtension: generatedExtension,
          additionalOutputExtensions: additionalOutputExtensions,
          header: header,
          allowSyntaxErrors: allowSyntaxErrors,
          options: options,
        ) {
    this.options = options;
    dataDir ??= options?.config[BuildOptionKeys.dataDir];
    domainDir ??= options?.config[BuildOptionKeys.domainDir];
    this.generator = generator as GenModelsGenerator;
    this.generator.builderFunc = this;
  }

  @override
  final buildExtensions = const {
    // r'$lib/**.dart': ['gen_models_generated.mapper.dart'],
    '.dart': ['.mapper.dart'],
  };

  @override
  void onDetectedClassPaths({required GeneratedBuilderFactory data}) {}

  @override
  bool checkDuplicateClassName(String className) {
    final isContain = classNames.contains(className);
    classNames.add(className);
    return isContain;
  }

  @override
  String getPrefix() {
    return 'prefix${++_importCount}';
  }

  int count = 0;

  String getBuildStepPath(BuildStep buildStep) {
    String path = buildStep.inputId.path;
    return path;
  }

  GeneratedBuilderFactory? getBuildStepGenerated(BuildStep buildStep) {
    String path = getBuildStepPath(buildStep);
    return mapGenerateBuilderFactory[path];
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    count++;
    String path = getBuildStepPath(buildStep);
    final generateBuilderFactory = GeneratedBuilderFactory();
    mapGenerateBuilderFactory[path] = generateBuilderFactory;
    generator.mapGenerateBuilderFactory = mapGenerateBuilderFactory;
    final result = await super.build(buildStep);
    if (generateBuilderFactory.bodies.isNotEmpty) {
      _writeFile(buildStep: buildStep, content: '''
  ${generateBuilderFactory.objectImportInfos.map(
                (e) => e.getImportPrefix(),
              ).join('\n')}
  ${generateBuilderFactory.bodies.join('\n\n')}
    ''');
    }
    generateBuilderFactory.path = buildStep.inputId.path;
    if (generateBuilderFactory.objects.isNotEmpty &&
        StringUtils.checkFileName(generateBuilderFactory.path)) {
      _genMapperFile(buildStep);
    }
    return result;
  }



  _genMapperFile(BuildStep buildStep) async {
    File indexFile = File('lib/mapper_generated.mapper.dart');
    MapperData a;
    String content = _fileContent;
    if (indexFile.existsSync()) {
      content = indexFile.readAsStringSync();
      indexFile.deleteSync();
    }
    final generateBuilderFactory=getBuildStepGenerated(buildStep);
    if(generateBuilderFactory==null) return;
    final imports = generateBuilderFactory.objectImportInfos
        .map(
          (e) => e.getImportPrefix(),
        )
        .join('\n');

    final funcs = generateBuilderFactory.objects.map((element) {
      if (element.name?.isNotEmpty == true) {
        String className = element.name ?? '';
        return 'MapperData(name:"${element.name}",prefixName: "${StringUtils.addPrefixAndSuffix(text: element.prefix, suffix: '.')}${className}", func: ${StringUtils.addPrefixAndSuffix(text: element.mapperPrefix, suffix: '.')}${element.mapperClassName}.fromDTO)';
      }
    }).join(',\n')+',';

    content = content
        .replaceAll(markHeader, '${imports}\n${markHeader}')
        .replaceAll(markBody,
            '${funcs}\n//${generateBuilderFactory.path}\n${markBody}');
    indexFile.writeAsStringSync(content, mode: FileMode.write);
  }

  _writeFile({String content = '', required BuildStep buildStep}) async {
    final outputId = AssetId(buildStep.inputId.package,
        StringUtils.getMapperPath(buildStep.inputId.path));
    await buildStep.writeAsString(outputId, content);
  }

// Future<String> _readFile({String? path, required BuildStep buildStep}) async {
//   final inputId = AssetId(buildStep.inputId.package, path ?? filePath);
//   if (await buildStep.canRead(inputId))
//     return await buildStep.readAsString(inputId);
//   return '';
// }
}

class GeneratedBuilderFactory {
  List<GeneratedBuilderObject> _objects;

  List<GeneratedBuilderObject> get objects => _objects;
  List<ImportInfo> objectImportInfos;
  List<String> bodies;
  String? prefix;
  String path;

  addObject(GeneratedBuilderObject obj) {
    _objects.add(obj);
  }

  addImportInfo(ImportInfo importInfo) {
    if (!hasImport(importInfo)) {
      objectImportInfos.add(importInfo);
    }
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
    return objectImportInfos.firstWhereOrNull(
      (element) => element.import == import,
    );
  }

  hasImport(ImportInfo importInfo) {
    return objectImportInfos.firstWhereOrNull(
          (element) => element.import == importInfo.import,
        ) !=
        null;
  }

  GeneratedBuilderFactory(
      {List<GeneratedBuilderObject>? objects,
      List<ImportInfo>? importInfos,
      List<String>? bodies,
      String? prefix,
      String? path,
      String? mapperClassName,
      String? mapperPrefix})
      : objectImportInfos = importInfos ?? [],
        path = path ?? '',
        _objects = objects ?? [],
        bodies = bodies ?? [];
}

class GeneratedBuilderObject {
  String? name;
  String? prefix;
  String mapperClassName;
  String mapperPrefix;

  GeneratedBuilderObject(
      {this.name,
      String? prefix,
      String? mapperClassName,
      String? mapperPrefix})
      : prefix = prefix ?? '',
        mapperClassName = mapperClassName ?? '',
        mapperPrefix = mapperPrefix ?? '';
}

String _fileContent = '''
import 'package:gen_models/mapper_factory.dart';
${markHeader}
List<MapperData> get getMapperData => [
${markBody}
      
];
''';
