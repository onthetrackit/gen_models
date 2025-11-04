import 'package:build_runner/build_runner.dart' as build_runner;
import 'package:build_config/build_config.dart';
import 'package:gen_models/builder/builder.dart';

Future<void> main() async {
  await build_runner.run([
    'build',
    '--delete-conflicting-outputs',
    '--verbose',
  ],[]);
}