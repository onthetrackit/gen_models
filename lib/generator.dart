import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:gen_models/annotations.dart';
import 'package:source_gen/source_gen.dart';

class GenModelsGenerator
    extends GeneratorForAnnotation<
        GenModels> {
  @override
  Future<String>
      generateForAnnotatedElement(
          Element element,
          ConstantReader annotation,
          BuildStep buildStep) async {
    final buffer = StringBuffer();
    // final imports =
    //     _cloneImports(element.library!);
    // buffer.writeln(imports);
    // final constructors =
    //     _cloneConstructors(
    //         element.library!);
    // buffer.writeln(constructors);
    buffer.writeln(_getBody(element.library!));
    return buffer.toString();
  }

// Hàm hỗ trợ clone imports
  String _cloneImports(
      LibraryElement library) {
    final reader =
        LibraryReader(library);
    final importStrings = <String>[];

    for (final import
        in reader.allElements.where(
      (element) => element
          is LibraryImportElement,
    )) {
      if (!import.isSynthetic) {
        importStrings.add(
            _convertImport(import
                .getDisplayString()));
      }
    }
    // for (final import in reader.classes){
    //   import.constructors.forEach((element) {
    //     importStrings.add(getConstructor(element));
    //   },);
    // }
    PropertyAccessorElement a;
    return importStrings.join('\n');
  }
  String _getBody( LibraryElement library){
    final reader =
    LibraryReader(library);

    final importStrings = <String>[];
    final setName=Set<String>();
    reader.classes.forEach((e) {
      e..children.forEach((element) {
        if(element is FieldElement){
          element.children.forEach((element) => importStrings.add("${element.getDisplayString()}"));
          FieldElement e=element as FieldElement;
          // importStrings.add("${element.name}");
          importStrings.add("${element.getDisplayString()}");
        }
      },);
    });
    return importStrings.join('\n');
  }
  String getPropertyAccessorElement(PropertyAccessorElement element){
    List<String> info = [
       "isGetter:  ${element.isGetter}",
       "isSetter:  ${element.isSetter}",
       "isPrivate:  ${element.isPrivate}",
       "isPublic:  ${element.isPublic}",
       "isSynthetic:  ${element.isSynthetic}",
       "isExternal:  ${element.isExternal}",

    ];
    return info.join("\n");
  }
  getConstructor(
      ConstructorElement? constructor) {
    if(constructor==null) return '';
    String params="";
    if(constructor.augmentation!=null) {
      params=getConstructor(constructor.augmentation as ConstructorElement);
    }

    final info = [
      '_________________________________ ${constructor==constructor.declaration}',
      'children=${constructor.children?.map((e) => e.getDisplayString(),)?.join('\n')?.toString()}',
      'context=${constructor.context?.toString()}',
      'context=${constructor.location}',
      'augmentation=${constructor.augmentation?.toString()}',
      'typeParameters=${constructor.typeParameters.length?.toString()}',
      'parameters=${constructor.parameters.length?.toString()}',
          'augmentationTarget=${constructor.augmentationTarget?.toString()}',
          'declaration=${constructor.declaration?.toString()}',
          'displayName=${constructor.displayName?.toString()}',
          'enclosingElement=${constructor.enclosingElement?.toString()}',
      'isConst=${constructor.isConst?.toString()}',
      'isDefaultConstructor=${constructor.isDefaultConstructor?.toString()}',
      'isFactory=${constructor.isFactory?.toString()}',
      'isGenerative=${constructor.isGenerative?.toString()}',
      'name=${constructor.name?.toString()}',
      'nameEnd=${constructor.nameEnd?.toString()}',
      'periodOffset=${constructor.periodOffset?.toString()}',
      'redirectedConstructor=${constructor.redirectedConstructor?.toString()}',
      'returnType=${constructor.returnType?.toString()}',
      'superConstructor=${constructor.superConstructor?.toString()}'
      '++++++++++++'
    ];
    info.add(params);
    info.add('redirectedConstructor=${getConstructor(constructor.redirectedConstructor)}');
    info.add('superConstructor=${getConstructor(constructor.superConstructor)}');
    info.add('augmentationTarget=${getConstructor(constructor.augmentationTarget)}');
    return info.join('\n_________');
  }

  String _cloneConstructors(
      LibraryElement library) {
    final reader =
        LibraryReader(library);
    final importStrings = <String>[];
    // reader.allElements.forEach((e) {
    //   importStrings
    //       .add(e.getDisplayString());
    //   importStrings.add(
    //       e.runtimeType.toString());
    // });
    for (final item
        in reader.allElements.where(
      (element) =>
          element is ClassElement,
    )) {
      ClassElement e =
          item as ClassElement;
      e.constructors.forEach(
        (element) {
          importStrings.add(
              getConstructor(element
                  as ConstructorElement));
        },
      );
    }
    return importStrings.join('\n');
  }

  String _convertImport(String text) {
    final splits = text.split(" ");
    final packages = splits[2]
        .substring(1)
        .split("/");
    String result =
        "${splits[0]} 'package:${packages.first}/${packages.last}';";
    return result;
  }
}

String getElementInfo(Element element) {
  return '''
children: ${element.children}
context: ${element.context}
declaration: ${element.declaration}
displayName: ${element.displayName}
documentationComment: ${element.documentationComment}
enclosingElement: ${element.enclosingElement}
hasAlwaysThrows: ${element.hasAlwaysThrows}
hasDeprecated: ${element.hasDeprecated}
hasDoNotStore: ${element.hasDoNotStore}
hasDoNotSubmit: ${element.hasDoNotSubmit}
hasFactory: ${element.hasFactory}
hasImmutable: ${element.hasImmutable}
hasInternal: ${element.hasInternal}
hasIsTest: ${element.hasIsTest}
hasIsTestGroup: ${element.hasIsTestGroup}
hasJS: ${element.hasJS}
hasLiteral: ${element.hasLiteral}
hasMustBeConst: ${element.hasMustBeConst}
hasMustBeOverridden: ${element.hasMustBeOverridden}
hasMustCallSuper: ${element.hasMustCallSuper}
hasNonVirtual: ${element.hasNonVirtual}
hasOptionalTypeArgs: ${element.hasOptionalTypeArgs}
hasOverride: ${element.hasOverride}
hasProtected: ${element.hasProtected}
hasRedeclare: ${element.hasRedeclare}
hasReopen: ${element.hasReopen}
hasRequired: ${element.hasRequired}
hasSealed: ${element.hasSealed}
hasUseResult: ${element.hasUseResult}
hasVisibleForOverriding: ${element.hasVisibleForOverriding}
hasVisibleForTemplate: ${element.hasVisibleForTemplate}
hasVisibleForTesting: ${element.hasVisibleForTesting}
hasVisibleOutsideTemplate: ${element.hasVisibleOutsideTemplate}
id: ${element.id}
isPrivate: ${element.isPrivate}
isPublic: ${element.isPublic}
isSynthetic: ${element.isSynthetic}
kind: ${element.kind}
library: ${element.library}
location: ${element.location}
metadata: ${element.metadata}
name: ${element.name}
nameLength: ${element.nameLength}
nameOffset: ${element.nameOffset}
nonSynthetic: ${element.nonSynthetic}
session: ${element.session}
sinceSdkVersion: ${element.sinceSdkVersion}
''';
}
