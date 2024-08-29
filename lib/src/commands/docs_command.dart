import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

class DocsCommand extends Command<void> {
  @override
  String get description => 'Open official devmy documentation site';

  @override
  String get name => 'docs';

  @override
  FutureOr<void> run() {
    _openUrl('https://clidocs-devmy-pillars-projects.vercel.app');
  }

  void _openUrl(String url) {
    if (Platform.isWindows) {
      Process.run('start', [url], runInShell: true);
    } else if (Platform.isMacOS) {
      Process.run('open', [url]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [url]);
    } else {
      print('Unsupported platform');
    }
  }
}
