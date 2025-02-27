import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In App Update',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'In App Update'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double downloadProgress = 0.0;
  bool isDownloading = false;
  String downloadedFilePath = '';

  String _currentVersion = "...";

  showUpdateDialog(Map<String, dynamic> versionJson) {
    final version = versionJson['version'];
    final updates = versionJson['description'] as List;
    return showDialog(
      context: context,
      builder: (contex) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text('Latest version is $version'),
          children: [
            Text('What\'s new in $version'),
            const SizedBox(height: 8.0),
            ...updates
                .map(
                  (e) => Row(
                    children: [
                      Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        '$e',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
            const SizedBox(height: 8.0),
            if (version != _currentVersion)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (Platform.isMacOS) {
                    downloadNewVersion(versionJson['macos_file_name']);
                  }
                  if (Platform.isWindows) {
                    downloadNewVersion(versionJson['windows_file_name']);
                  }
                  if (Platform.isLinux) {
                    downloadNewVersion(versionJson['linux_file_name']);
                  }
                },
                icon: const Icon(Icons.update),
                label: const Text('Update'),
              )
          ],
        );
      },
    );
  }

  Future<void> openExeFile(String filePath) async {
    await Process.start(filePath, ["-t", "-l", "1000"]).then((value) {});
  }

  Future<void> openDebFile(String filePath) async {
    //TODO restart application after update (in implemntation)
    await Process.run('sh', [
      '-c',
      'x-terminal-emulator -e bash ~/Desktop/linux_installer.sh',
    ]);
  }

  Future<void> openDMGFile(String filePath) async {
    await Process.run('sh', [
      '-c',
      'hdiutil mount $filePath && cp -R /Volumes/InAppUpdateDesktop/in_app_update_desktop.app /Applications && hdiutil unmount /Volumes/InAppUpdateDesktop/ && rm $filePath',
    ]);
  }

  Future<void> _checkForUpdates() async {
    final jsonValue = await loadJsonFromGithub();
    debugPrint('Response: $jsonValue');
    showUpdateDialog(jsonValue);
  }

  Future<Map<String, dynamic>> loadJsonFromGithub() async {
    final response = await http.read(
      Uri.parse(
        'https://raw.githubusercontent.com/ltnghia97/in_app_update_desktop/refs/heads/master/app_version_check/version.json',
      ),
    );
    return jsonDecode(response);
  }

  Future downloadNewVersion(String appPath) async {
    final fileName = appPath.split('/').last;
    isDownloading = true;
    setState(() {});

    final Dio dio = Dio();
    downloadedFilePath = "${(await getDownloadsDirectory())!.path}/$fileName";

    await dio.download(
      'https://raw.githubusercontent.com/ltnghia97/in_app_update_desktop/master/app_version_check/$appPath',
      downloadedFilePath,
      onReceiveProgress: (received, total) {
        final progress = (received / total) * 100;
        downloadProgress = double.parse(progress.toStringAsFixed(1));
        setState(() {});
      },
    );
    debugPrint("File Downloaded Path: $downloadedFilePath");
    if (Platform.isWindows) {
      await openExeFile(downloadedFilePath);
    }
    if (Platform.isMacOS) {
      await openDMGFile(downloadedFilePath);
      //
      // String scriptPath = '/Users/nghiadev/Documents/personal/in_app_update_desktop/scripts/install_app.sh $downloadedFilePath';
      //
      // // Kiểm tra nếu script tồn tại
      // if (!File(scriptPath).existsSync()) {
      //   print('❌ Không tìm thấy file $scriptPath');
      //   return;
      // }
      //
      // // Cấp quyền thực thi cho script (nếu chưa có)
      // await Process.run('chmod', ['+x', scriptPath]);
      //
      // // Chạy script
      // ProcessResult result = await Process.run(scriptPath, []);
      //
      // // In kết quả
      // print('📜 Output: ${result.stdout}');
      // print('⚠️ Error: ${result.stderr}');
    }
    if (Platform.isLinux) {
      await openDebFile(downloadedFilePath);
    }
    isDownloading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  void _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              "https://cdn.shopify.com/s/files/1/0086/0795/7054/files/Golden-Retriever.jpg?v=1645179525",
              height: 300,
            ),
            SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  'Current version is $_currentVersion',
                ),
              ),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: _checkForUpdates,
                child: const Text('Check updates'),
              ),
            ],
          ),
          if (isDownloading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(width: 8.0),
                Text('${downloadProgress.toStringAsFixed(0)} %'),
              ],
            ),
        ],
      ),
    );
  }
}
