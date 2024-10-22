import 'dart:io';

void main() {
  final directory = Directory('assets/icons');
  final files = directory.listSync();

  final assetLines = files.map((file) => '    - ${file.path}').join('\n');

  final yamlContent = '''
flutter:
  assets:
$assetLines
''';

  final file = File('pubspec.yaml');
  file.writeAsStringSync(yamlContent);
  print('pubspec.yaml updated with assets!');
}
