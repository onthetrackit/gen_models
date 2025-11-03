import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:glob/glob.dart';

Builder mergeBuilder(BuilderOptions options) =>
    AggregateBuilder(options);
class AggregateBuilder implements Builder {
  final BuilderOptions options;

  AggregateBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['generated/all_models.dart']  // Output file
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Tìm tất cả file .dart trong lib/models/ (hoặc bất kỳ pattern nào)
    print('cai gi the');
    final models = Glob('build/mapper_index.tmp');

    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED FILE - DO NOT EDIT');
    buffer.writeln('part of "all_models.dart========1111";');
    buffer.writeln();

    await for (final input in buildStep.findAssets(models)) {

      final content = await buildStep.readAsString(input);

        buffer.writeln('import "${input.path}";');
        buffer.writeln('final List<Type> _allModels = [');
        buffer.writeln('  $content,');
        buffer.writeln('];');
    }
    final indexFile = File('build/mapper_index.tmp');
    buffer.writeln(indexFile.readAsString());
    buffer.writeln();
    buffer.writeln('====___List<Type> get allModelTypes => _allModels;');

    // Ghi ra file output
    final outputId = AssetId(buildStep.inputId.package, 'lib/generated/all_models.dart');
    await buildStep.writeAsString(outputId, buffer.toString());
  }

  String? _extractClassName(String content, String fileName) {
    final classRegExp = RegExp(r'class\s+(\w+)');
    final match = classRegExp.firstMatch(content);
    return match?.group(1);
  }
}