import 'package:mason/mason.dart';

class BrickContext {
  final MasonBundle bundle;
  final MasonGenerator generator;

  const BrickContext({
    required this.bundle,
    required this.generator,
  });
}
