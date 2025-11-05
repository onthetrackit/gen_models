import 'package:build/build.dart';
import 'package:gen_models/builder/builder_funcs.dart';
import 'package:gen_models/constants/build_option_keys.dart';
import 'package:gen_models/models/inport_info.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:collection/collection.dart';

import '../generator.dart';

class GenModelsBuilder extends LibraryBuilder implements BuilderFunc {
  int _importCount = 0;
  late GenModelsGenerator generator;

  List<String> _imports = [];
  List<String> _funcs = [];
  Set<String> allClassName = Set();
  late GeneratedBuilderFactory generateBuilderFactory;
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
  void onDetectedClassPaths({required GeneratedBuilderFactory data}) {
    generateBuilderFactory = data;
  }

  @override
  bool checkDuplicateClassName(String className) {
    return classNames.contains(className);
  }

  @override
  String getPrefix() {
    return 'prefix${++_importCount}';
  }

  int count = 0;

  Future<GenModelsBuilderOutput> getBuildOutput(BuildStep buildStep) async {
    await build(buildStep);
    appLog(['params12', _imports.length, _funcs.length]);
    return GenModelsBuilderOutput(
        imports: _imports.join('\n'),
        funcs: _funcs.join(',\n'),
        path: buildStep.inputId.path);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    count++;
    _imports = [];
    _funcs = [];
    generateBuilderFactory = GeneratedBuilderFactory();
    generator.currentGenerateBuilderFactory = generateBuilderFactory;
    final result = await super.build(buildStep);
    _generateContent();
    if(generateBuilderFactory.bodies.isNotEmpty) {
      _writeFile(buildStep: buildStep, content: '''
  ${generateBuilderFactory.objectImportInfos.map(
                (e) => e.getImportPrefix(),
              ).join('\n')}
  ${generateBuilderFactory.bodies.join('\n\n')}
    ''');
    }
    return result;
  }

  // _createdMapperFile(BuildStep buildStep) async {
  //   // if(count==0){
  //   //   count++;
  //   //   return;
  //   // }
  //   _generateContent();
  //   String? content = await _readFile(buildStep: buildStep);
  //   content ??= '';
  //   String startFile = '''class MapperImports{
  //   final data=[''';
  //   String endFile = '''
  //   ];
  // }
  //   ''';
  //   if (content.isNotEmpty) {
  //     final arrays = content!.split(split);
  //     startFile = arrays[0];
  //     endFile = arrays[1];
  //   }
  //   // print('_imports.join:${_imports.join('\n')}');
  //   // print('_funcs.join:${_funcs.join('\n')}');
  //   startFile = '''${_imports.join('\n')}${startFile}''';
  //   endFile = '''${_funcs.join('\n')}${endFile}''';
  //   content = '''
  //     $startFile
  //     $split
  //     $endFile
  //   ''';
  //   // print('content 1:${content}');
  //   await _writeFile(content: content, buildStep: buildStep);
  // }

  _generateContent() async {
    _imports.addAll(generateBuilderFactory.objectImportInfos
        .where(
          (element) => element.import?.isNotEmpty == true,
        )
        .map(
          (e) => '${e.getImportPrefix()}',
        )
        .toList());
    generateBuilderFactory.objects.forEach(
      (element) {
        if (element.name?.isNotEmpty == true) {
          String className = element.name ?? '';
          _funcs.add(
            'MapperData(type: "${StringUtils.addPrefixAndSuffix(text: element.prefix, suffix: '.')}${className}", func: ${StringUtils.addPrefixAndSuffix(text: element.mapperPrefix, suffix: '.')}${element.mapperClassName}.fromDTO)',
          );
        }
      },
    );
  }

//
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
  List<GeneratedBuilderObject> objects;
  List<ImportInfo> objectImportInfos;
  List<String> bodies;
  String? prefix;
  String path;

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
        objects = objects ?? [],
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

class GenModelsBuilderOutput {
  String? imports;
  String? funcs;
  String? path;

  GenModelsBuilderOutput({this.imports, this.funcs, this.path});
}
