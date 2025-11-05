import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:gen_models/constants/build_option_keys.dart';
import 'package:gen_models/mapper_factory.dart';
import 'package:source_gen/source_gen.dart';

import 'gen_models_builder.dart';
import '../generator.dart';

Builder genBuilder(BuilderOptions options) {
  final libBuilder = GenModelsBuilder(GenModelsGenerator(options: options),
      generatedExtension: '.mapper.dart', options: options);

  // Trả builder "bọc"
  return IndexingBuilder(libBuilder);
}

final String markHeader = '//__markHeader__';
final String markBody = '//__markBody__';

class IndexingBuilder implements Builder {
  final GenModelsBuilder _inner;
  bool isDeleted = false;
  Set<String> allFiles = Set();
  final String fileSeparator = '//__start file__';
  Map<String, String> allFileContents = {};

  IndexingBuilder(this._inner);

  @override
  Map<String, List<String>> get buildExtensions => _inner.buildExtensions;

  @override
  Future<void> build(BuildStep buildStep) async {
    File indexFile = File('lib/mapper_generated.mapper.dart');
    MapperData a;
    String content = _fileContent;
    if (indexFile.existsSync() && !isDeleted) {
      content = indexFile.readAsStringSync();
      indexFile.deleteSync();
    }

    final resutl = await _inner.getBuildOutput(buildStep);
    content = content
        .replaceAll(markHeader, '${resutl.imports}\n${markHeader}')
        .replaceAll(markBody, '${resutl.funcs}\n${markBody}');
    indexFile.writeAsStringSync(content, mode: FileMode.write);
    // if (resutl.imports?.isEmpty == true) return;
    //   if (indexFile.existsSync() && !isDeleted) {
    //     indexFile.deleteSync();
    //   }
    //   indexFile.createSync(recursive: true);
    //   String content = '''
    // //__start file__11111
    // //${resutl.path}
    //  ${resutl.imports ?? ''}\n${resutl.funcs ?? ''}\n
    //   ''';
    //   if (resutl.imports?.isNotEmpty == true ||
    //       resutl.funcs?.isNotEmpty == true) {
    //     indexFile.writeAsStringSync(content, mode: FileMode.append);
    //   }
    //   isDeleted = true;
  }
}

String _fileContent = '''
import 'package:gen_models/mapper_factory.dart';
${markHeader}
List<MapperData> get getMapperData => [
${markBody}
      
];
''';
