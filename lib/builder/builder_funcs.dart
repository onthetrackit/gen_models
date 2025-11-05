import 'gen_models_builder.dart';

abstract class BuilderFunc{

  void onDetectedClassPaths({required GeneratedBuilderFactory data});

  bool checkDuplicateClassName(String className);
  String getPrefix();
}