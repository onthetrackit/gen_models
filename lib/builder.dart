import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

Builder genBuilder(BuilderOptions options) {
  final libBuilder = GenModelsBuilder(GenModelsGenerator(),
      generatedExtension: '.mapper.dart');

  // Trả builder "bọc"
  return _IndexingBuilder(libBuilder);
}

class _IndexingBuilder implements Builder {
  final GenModelsBuilder _inner;
  bool isDeleted = false;
  Set<String> allFiles = Set();
  final String fileSeparator = '__start file__';
  Map<String, String> allFileContents = {};

  _IndexingBuilder(this._inner);

  @override
  Map<String, List<String>> get buildExtensions => _inner.buildExtensions;

  @override
  Future<void> build(BuildStep buildStep) async {
    File indexFile = File('lib/mapper_generated.mapper.dart');

    if (indexFile.existsSync() && !isDeleted) {
      final content = indexFile.readAsStringSync().split(fileSeparator);

      indexFile.deleteSync();
    }
    final resutl = await _inner.getBuildOutput(buildStep);
    if (resutl.imports?.isEmpty == true) return;
    if (indexFile.existsSync() && !isDeleted) {
      indexFile.deleteSync();
    }
    indexFile.createSync(recursive: true);
    String content = '''
    //__start file__
    //${resutl.path}
    ${resutl.imports ?? ''}\n${resutl.funcs ?? ''}\n
    ''';
    if (resutl.imports?.isNotEmpty == true) {
      indexFile.writeAsStringSync(content, mode: FileMode.append);
    }
    isDeleted = true;
  }
}

class GenModelsBuilder extends LibraryBuilder {
  int _importCount = 0;
  late GenModelsGenerator generator;

  String get _getImportPrefix => 'prefix${++_importCount}';
  List<String> _imports = [];
  List<String> _funcs = [];
  Set<String> allClassName = Set();
  late GeneratedBuilderFactory generateBuilderFactory;
  final filePath = 'build/fake.mapper.dart';
  final split = '//=============';

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
    this.generator = generator as GenModelsGenerator;
  }

  @override
  final buildExtensions = const {
    // r'$lib/**.dart': ['gen_models_generated.mapper.dart'],
    '.dart': ['.mapper.dart'],
  };

  void _onDetectedClassPaths({required GeneratedBuilderFactory data}) {
    data.prefix = _getImportPrefix;
    generateBuilderFactory = data;
  }

  int count = 0;

  Future<GenModelsBuilderOutput> getBuildOutput(BuildStep buildStep) async {
    await build(buildStep);
    return GenModelsBuilderOutput(
        imports: _imports.join('\n'), funcs: _funcs.join('\n'),path: generateBuilderFactory.path);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    count++;
    _imports.clear();
    _funcs.clear();
    generateBuilderFactory = GeneratedBuilderFactory();
    generator.onDetectedClassPaths = _onDetectedClassPaths;
    generator.builderHashCode = hashCode.toString();
    final result = await super.build(buildStep);
    _generateContent();
    // await _createdMapperFile(buildStep);
    return result;
  }

  _createdMapperFile(BuildStep buildStep) async {
    // if(count==0){
    //   count++;
    //   return;
    // }
    _generateContent();
    String? content = await _readFile(buildStep: buildStep);
    content ??= '';
    String startFile = '''class MapperImports{
    final data=[''';
    String endFile = '''
    ];
  }
    ''';
    if (content.isNotEmpty) {
      final arrays = content!.split(split);
      startFile = arrays[0];
      endFile = arrays[1];
    }
    // print('_imports.join:${_imports.join('\n')}');
    // print('_funcs.join:${_funcs.join('\n')}');
    startFile = '''${_imports.join('\n')}${startFile}''';
    endFile = '''${_funcs.join('\n')}${endFile}''';
    content = '''
      $startFile
      $split
      $endFile
    ''';
    // print('content 1:${content}');
    await _writeFile(content: content, buildStep: buildStep);
  }

  _generateContent() async {
    generateBuilderFactory?.objects?.forEach(
      (element) {
        _getText(
            file: generateBuilderFactory!,
            obj: element,
            prefix: generateBuilderFactory!.prefix);
      },
    );
  }

  _getText(
      {required GeneratedBuilderFactory file,
      required dynamic obj,
      String? prefix}) {
    String className = obj.runtimeType.toString();
    // print('file.path: ${file.path}');
    // print(
    //     'func.path: ${'MapperData(type: "${obj.runtimeType.toString()}", func: ${prefix}.${className}.fromDTO)'}');
    _imports.add(
      '//import "${file.path}" as ${prefix};',
    );
    _funcs.add(
      '//MapperData(type: "${obj.runtimeType.toString()}", func: ${prefix}.${className}.fromDTO)',
    );
  }

  _writeFile(
      {String? path, String content = '', required BuildStep buildStep}) async {
    final outputId = AssetId(buildStep.inputId.package, path ?? filePath);
    await buildStep.writeAsString(outputId, content);
  }

  Future<String> _readFile({String? path, required BuildStep buildStep}) async {
    final inputId = AssetId(buildStep.inputId.package, path ?? filePath);
    if (await buildStep.canRead(inputId))
      return await buildStep.readAsString(inputId);
    return '';
  }
}

class GeneratedBuilderFactory {
  List? objects;
  String? path;
  String? prefix;

  GeneratedBuilderFactory({this.objects, this.path});
}

class GenModelsBuilderOutput {
  String? imports;
  String? funcs;
  String? path;

  GenModelsBuilderOutput({this.imports, this.funcs, this.path});
}
