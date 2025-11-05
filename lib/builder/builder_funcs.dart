import 'gen_models_builder.dart';

abstract class BuilderFunc{

  void onDetectedClassPaths({required GeneratedBuilderFactory data});

  bool checkAndAddDuplicateClassName(String className);
  bool checkAndAddDuplicateMapperClassName(String className);
  String getPrefix();
}