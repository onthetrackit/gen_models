// part of 'generator.dart';
//
// String printNonNullProperties(
//     LibraryImportElement importElement) {
//       StringBuffer sb=StringBuffer();
//       final primitiveFields = [
//         'id: ${importElement.id}',
//         'nameLength: ${importElement.nameLength}',
//         'nameOffset: ${importElement.nameOffset}',
//
//         'hasAlwaysThrows: ${importElement.hasAlwaysThrows}',
//         'hasDeprecated: ${importElement.hasDeprecated}',
//         'hasDoNotStore: ${importElement.hasDoNotStore}',
//         'hasDoNotSubmit: ${importElement.hasDoNotSubmit}',
//         'hasFactory: ${importElement.hasFactory}',
//         'hasImmutable: ${importElement.hasImmutable}',
//         'hasInternal: ${importElement.hasInternal}',
//         'hasIsTest: ${importElement.hasIsTest}',
//         'hasIsTestGroup: ${importElement.hasIsTestGroup}',
//         'hasJS: ${importElement.hasJS}',
//         'hasLiteral: ${importElement.hasLiteral}',
//         'hasMustBeConst: ${importElement.hasMustBeConst}',
//         'hasMustBeOverridden: ${importElement.hasMustBeOverridden}',
//         'hasMustCallSuper: ${importElement.hasMustCallSuper}',
//         'hasNonVirtual: ${importElement.hasNonVirtual}',
//         'hasOptionalTypeArgs: ${importElement.hasOptionalTypeArgs}',
//         'hasOverride: ${importElement.hasOverride}',
//         'hasProtected: ${importElement.hasProtected}',
//         'hasRedeclare: ${importElement.hasRedeclare}',
//         'hasReopen: ${importElement.hasReopen}',
//         'hasRequired: ${importElement.hasRequired}',
//         'hasSealed: ${importElement.hasSealed}',
//         'hasUseResult: ${importElement.hasUseResult}',
//         'hasVisibleForOverriding: ${importElement.hasVisibleForOverriding}',
//         'hasVisibleForTemplate: ${importElement.hasVisibleForTemplate}',
//         'hasVisibleForTesting: ${importElement.hasVisibleForTesting}',
//         'hasVisibleOutsideTemplate: ${importElement.hasVisibleOutsideTemplate}',
//
//         'isPrivate: ${importElement.isPrivate}',
//         'isPublic: ${importElement.isPublic}',
//         'isSynthetic: ${importElement.isSynthetic}',
//
//         'name: ${importElement.name}',
//         'displayName: ${importElement.displayName}',
//         'documentationComment: ${importElement.documentationComment}',
//       ];
//     sb.write(primitiveFields.join('\n'));
//     return sb.toString();
// }
// // void printNonNullProperties1(
// //     LibraryImportElement importElement) {
// //   if (importElement == null) {
// //     print('Input là null!');
// //     return;
// //   }
// //
// //   print(
// //       'Non-null properties của LibraryImportElement:');
// //
// // // Field: combinators (List<NamespaceCombinator> - object phức tạp, dùng hàm mới)
// //   final combinators = importElement
// //       .combinators;
// //   if (combinators.isNotEmpty) {
// //     final text = getTextFromCombinators(
// //         combinators);
// //     print('combinators: $text');
// //   }
// //
// // // Field: enclosingElement3 (object phức tạp, dùng hàm đã tạo)
// //   final enclosingElement3 = importElement
// //       .enclosingElement3;
// //   if (enclosingElement3 != null) {
// //     final text = getTextFromCompilationUnitElement(
// //         enclosingElement3);
// //     print('enclosingElement3: $text');
// //   }
// //
// // // Field: importedLibrary (object phức tạp, dùng hàm đã tạo)
// //   final importedLibrary = importElement
// //       .importedLibrary;
// //   if (importedLibrary != null) {
// //     final text = getTextFromLibraryElement(
// //         importedLibrary);
// //     print('importedLibrary: $text');
// //   }
// //
// // // Field: importKeywordOffset (primitive int, print trực tiếp)
// //   final importKeywordOffset = importElement
// //       .importKeywordOffset;
// //   if (importKeywordOffset != 0 &&
// //       importKeywordOffset !=
// //           -1) { // Assume -1/0 là default null-like
// //     print(
// //         'importKeywordOffset: $importKeywordOffset');
// //   }
// //
// // // Field: namespace (object phức tạp, dùng hàm đã tạo)
// //   final namespace = importElement
// //       .namespace;
// //   if (namespace != null) {
// //     final text = getTextFromNamespace(
// //         namespace);
// //     print('namespace: $text');
// //   }
// //
// // // Field: prefix (object phức tạp, dùng hàm đã tạo)
// //   final prefix = importElement.prefix;
// //   if (prefix != null) {
// //     final text = getTextFromImportElementPrefix(
// //         prefix);
// //     print('prefix: $text');
// //   }
// //
// // // Field: uri (object phức tạp, dùng hàm đã tạo)
// //   final uri = importElement.uri;
// //   if (uri != null) {
// //     final text = getTextFromDirectiveUri(
// //         uri);
// //     print('uri: $text');
// //   }
// // }
// //
// // // Các hàm đã tạo trước (giữ nguyên, copy để đầy đủ)
// // String getTextFromCompilationUnitElement(
// //     CompilationUnitElement element) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'Name: ${element.name}');
// //   buffer.writeln(
// //       'Source URI: ${element.source
// //           .uri}');
// //   buffer.writeln(
// //       'Has directives: ${element
// //           .directives.isNotEmpty}');
// //   return buffer.toString().trim();
// // }
// //
// // String getTextFromLibraryElement(
// //     LibraryElement element) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'Display name: ${element
// //           .displayName}');
// //   buffer.writeln('Identifier: ${element
// //       .identifier}');
// //   buffer.writeln(
// //       'Imports count: ${element.imports
// //           .length}');
// //   buffer.writeln(
// //       'Exports count: ${element.exports
// //           .length}');
// //   return buffer.toString().trim();
// // }
// //
// // String getTextFromNamespace(
// //     Namespace namespace) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'Defined names count: ${namespace
// //           .definedNames.length}');
// //   buffer.writeln(
// //       'Keys: ${namespace.definedNames
// //           .keys.take(5).join(
// //           ', ')}${namespace.definedNames
// //           .length > 5
// //           ? '...'
// //           : ''}'); // Limit để ngắn
// //   return buffer.toString().trim();
// // }
// //
// // String getTextFromImportElementPrefix(
// //     ImportElementPrefix prefix) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'Name: ${prefix.name}');
// //   buffer.writeln(
// //       'Element display name: ${prefix
// //           .element.displayName}');
// //   return buffer.toString().trim();
// // }
// //
// // String getTextFromDirectiveUri(
// //     DirectiveUri uri) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'URI string: ${uri.uri}');
// //   buffer.writeln(
// //       'Source URI: ${uri.sourceUri}');
// //   if (uri is DirectiveUriWithLibrary) {
// //     buffer.writeln(
// //         'Library source: ${uri
// //             .librarySource.uri}');
// //   }
// //   return buffer.toString().trim();
// // }
// //
// // // Hàm mới cho combinators (List<NamespaceCombinator> - extract chi tiết)
// // String getTextFromCombinators(List<
// //     NamespaceCombinator> combinators) {
// //   final buffer = StringBuffer();
// //   buffer.writeln(
// //       'Count: ${combinators.length}');
// //   for (int i = 0; i <
// //       combinators.length; i++) {
// //     final comb = combinators[i];
// //     if (comb is ShowElementCombinator) {
// //       buffer.writeln(
// //           '  [$i] ShowCombinator: shows ${comb
// //               .shownNames.join(
// //               ', ')} (offset: ${comb
// //               .offset})');
// //     } else
// //     if (comb is HideElementCombinator) {
// //       buffer.writeln(
// //           '  [$i] HideCombinator: hides ${comb
// //               .hiddenNames.join(
// //               ', ')} (offset: ${comb
// //               .offset})');
// //     } else {
// //       buffer.writeln(
// //           '  [$i] Unknown combinator: ${comb
// //               .runtimeType}');
// //     }
// //   }
// //   return buffer.toString().trim();
// // }