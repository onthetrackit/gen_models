import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:source_gen/source_gen.dart';

class GenModelsGenerator extends GeneratorForAnnotation<GenModels> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'Annotation can only be applied to classes', element: element);
    }

    // Đọc file abc.txt
    String configContent = '';
    try {
      final configAsset = AssetId(buildStep.inputId.package, 'abc.txt');
      configContent = await buildStep.readAsString(configAsset);
    } catch (e) {
      log.warning('Không thể đọc file abc.txt: $e');
      configContent = '';
    }

    // Phân tích nội dung abc.txt
    final extraFields = configContent
        .split('\n')
        .where((line) => line.startsWith('- '))
        .map((line) => line.substring(2).trim())
        .toList();

    final className = element.name;
    final fields = element.fields
        .where((f) => !f.isStatic)
        .map((f) => '${f.type} ${f.name}')
        .toList();

    // Kết hợp các field từ code và abc.txt
    fields.addAll(extraFields);

    // Tạo tham số cho copyWith
    final copyWithParams = fields.join(', ');
    final copyWithAssignments = element.fields
        .where((f) => !f.isStatic)
        .map((f) => '${f.name}: ${f.name} ?? this.${f.name}')
        .join(', ');

    return '''
      // Generated code for $className
      // Config from abc.txt: ${extraFields.join(', ')}
      extension ${className}Ext on $className {
        $className copyWith({$copyWithParams}) {
          return $className(
            $copyWithAssignments
          );
        }
      }
    ''';
  }
}