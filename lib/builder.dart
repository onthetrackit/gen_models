import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

Builder genBuilder(BuilderOptions options) =>
    LibraryBuilder(GenModelsGenerator(), generatedExtension: '.my.dart');
