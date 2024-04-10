class Question {
  final String prompt;
  final List<String> addonNames;
  final bool isMultiple;
  final bool isOptional;

  Question({
    required this.prompt,
    required this.addonNames,
    this.isMultiple = false,
    this.isOptional = true,
  });
}
