// import 'dart:async';
// import 'dart:io';
//
// import 'package:build_runner/build_runner.dart';
// import 'package:build_runner_core/build_runner_core.dart' show PackageGraph;
//
// // Nếu có generator custom, import và thêm vào builders dưới đây
// // import 'package:your_package/gen_models_generator.dart';
//
// Future<void> main(List<String> arguments) async {
//   // Build PackageGraph (phát hiện dependencies project)
//   final packageGraph = await PackageGraph.forThisPackage();
//
//   // Parse arguments từ CLI (arguments là List<String> từ main)
//   final parsedArgs = parseArguments(arguments);
//
//   // Config builders/phases: Để empty để dùng build.yaml, hoặc thêm custom
//   final buildActions = <BuildAction>[
//     // Ví dụ thêm action cho generator custom (thay GenModelsGenerator bằng class của bạn)
//     // BuildAction(GenModelsGenerator(), 'your_package', isEnabled: true),
//     // Hoặc dùng default từ build.yaml
//   ];
//
//   // Chạy build_runner với API mới: run()
//   await run(
//     buildActions,  // Phases/builders
//     arguments,     // Args gốc như ['build', '--delete-conflicting-outputs']
//     packageGraph: packageGraph,
//     // Options mimic CLI
//     deleteFilesByDefault: parsedArgs['delete-conflicting-outputs'] as bool? ?? true,
//     enableWatch: parsedArgs['watch'] as bool? ?? false,
//     // Thêm nếu cần: logLevel: Level.INFO,
//   );
//
//   // Exit với code nếu cần
//   exit(0);
// }
//
// // Helper parse args (mimic CLI parser của build_runner)
// Map<String, dynamic> parseArguments(List<String> args) {
//   final Map<String, dynamic> result = {};
//   for (var arg in args) {
//     if (arg == 'watch') result['watch'] = true;
//     if (arg == '--delete-conflicting-outputs') result['delete-conflicting-outputs'] = true;
//     // Thêm parse khác nếu cần (dùng arg_parser package cho phức tạp hơn)
//   }
//   return result;
// }