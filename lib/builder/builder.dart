import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:gen_models/constants/build_option_keys.dart';
import 'package:source_gen/source_gen.dart';

import 'gen_models_builder.dart';
import '../generator.dart';

Builder genBuilder(BuilderOptions options) {
  final libBuilder = GenModelsBuilder(GenModelsGenerator(options: options),
      generatedExtension: '.mapper.dart',options: options);

  // Trả builder "bọc"
  return IndexingBuilder(libBuilder);
}

class IndexingBuilder implements Builder {
  final GenModelsBuilder _inner;
  bool isDeleted = false;
  Set<String> allFiles = Set();
  final String fileSeparator = '__start file__';
  Map<String, String> allFileContents = {};

  IndexingBuilder(this._inner);

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

