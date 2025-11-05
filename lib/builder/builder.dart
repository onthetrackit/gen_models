import 'dart:io';
import 'dart:math';

import 'package:build/build.dart';
import 'package:gen_models/constants/build_option_keys.dart';
import 'package:gen_models/mapper_factory.dart';
import 'package:gen_models/string_utils.dart';
import 'package:source_gen/source_gen.dart';

import 'gen_models_builder.dart';
import '../generator.dart';

Builder genBuilder(BuilderOptions options) {
  final libBuilder = GenModelsBuilder(GenModelsGenerator(options: options),
      generatedExtension: '.mapper.dart', options: options);

  // Trả builder "bọc"
  return libBuilder;
}

