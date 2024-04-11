extension MustacheArray<T> on Iterable<T> {
  dynamic toMustacheArray() {
    List<dynamic> array = toList();
    List<dynamic> items = [];

    for (int i = 0; i < array.length; i++) {
      items.add({
        'value': array[i],
        'index': i,
        'isLast': i == array.length - 1,
        'isFirst': i == 0,
      });
    }

    return {
      'first': items.firstOrNull,
      'last': items.lastOrNull,
      'length': items.length,
      'items': items,
      'isEmpty': items.isEmpty,
      'isNotEmpty': items.isNotEmpty,
    };
  }
}
