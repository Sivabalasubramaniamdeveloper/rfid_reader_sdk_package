import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rfid_reader_sdk/zebra_rfid_reader_sdk.dart';
import 'SingleTag.dart';
import 'TagCard.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zebraRfidReaderSdkPlugin = ZebraRfidReaderSdk();
  List<ReaderDevice> availableReaderList = [];
  List<TagDataModel> readTags = [];
  ReaderDevice connectedReader = ReaderDevice.initial();
  double antennaPower = 270;
  double beeperVolume = 3;
  bool isDynamicPowerEnable = true;
  TextEditingController searchController = TextEditingController();
  List<TagDataModel> filteredTags = [];
  TagDataModel? selectedTag;
  int scanCount = 0;
  String TagId = "";
  String distance = "";
  @override
  void initState() {
    super.initState();
    listenToEvent();
    listenToReadTags();
    requestAccess();
    stopFindingTheTag();
  }

  void listenToReadTags() {
    _zebraRfidReaderSdkPlugin.readTags.listen((event) {
      print("sssssssssss");
      final result = jsonDecode(event.toString());
      final readTag = TagDataModel.fromJson(result);
      readTags.removeWhere((element) => element.tagId == readTag.tagId);
      print("sssssssssss2");
      setState(() {
        readTags.insert(0, readTag);
      });
      print("sssssssssss3");
    });
  }

  void listenToEvent() {
    _zebraRfidReaderSdkPlugin.connectedReaderDevice.listen((event) {
      print("done11");
      final result = jsonDecode(event.toString());
      print("done12");
      setState(() {
        connectedReader = ReaderDevice.fromJson(result);
      });
      print("done13");
      _zebraRfidReaderSdkPlugin.findingTag.forEach((action) {
        print("done1");
        print(action);

        if (action != null) {
          try {
            // Decode the string to a Map
            final decoded = jsonDecode(action);
            print(decoded);

            if (decoded is Map && decoded.containsKey('distanceAsPercentage')) {
              print('Raw percentage: ${decoded['distanceAsPercentage']}');

              double percentage = decoded['distanceAsPercentage'].toDouble();
              double maxDistanceCm = 100.0;

              // Inverse the percentage: lower percentage = farther distance
              double inversePercentage = 100 - percentage;

              double distanceInCm = (inversePercentage / 100) * maxDistanceCm;
              print("Distance: ${distanceInCm.toStringAsFixed(2)} cm");
              setState(() {
                distance = distanceInCm.toString();
                scanCount++;
              });

              double distanceInMeters = distanceInCm / 100;
              print("Distance: ${distanceInMeters.toStringAsFixed(2)} meters");
            } else {
              print('hhhhh');
              print(decoded);
            }
          } catch (e) {
            print('Error while parsing distance: $e');
          }
        }
      });
    });
  }

  void stopListening() {
    _zebraRfidReaderSdkPlugin.connectedReaderDevice.listen(null);
  }

  String hexToFCode(String hex) {
    if (hex.startsWith('BDBD') && hex.length == 24) {
      return 'F-${int.parse(hex.substring(18, 24), radix: 16)}';
    }
    return hex;
  }

  Future<void> connectToZebra(String tagName) async {
    await requestAccess();
    await _zebraRfidReaderSdkPlugin.connect(tagName);
  }

  void disconnectToZebra() async {
    await requestAccess();
    _zebraRfidReaderSdkPlugin.disconnect();
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('DisConneted!!'),
      ),
    );
  }

  Future<void> requestAccess() async {
    await Permission.bluetoothScan.request().isGranted;
    await Permission.bluetooth.request().isGranted;
    await Permission.bluetoothConnect.request().isGranted;
    await Permission.location.request().isGranted;
  }

  Future<void> getAvailableReaderList() async {
    print("result");
    final result = await _zebraRfidReaderSdkPlugin.getAvailableReaderList();
    setState(() {
      availableReaderList = result;
    });
  }

  Future<void> setAntennaPower(int value) async {
    await _zebraRfidReaderSdkPlugin.setAntennaPower(value);
  }

  Future<void> setBeeperVolume(int value) async {
    await _zebraRfidReaderSdkPlugin.setBeeperVolume(value);
  }

  Future<void> setDynamicPower(bool value) async {
    await _zebraRfidReaderSdkPlugin.setDynamicPower(value);
  }

  Future<void> stopFindingTheTag() async {
    await _zebraRfidReaderSdkPlugin.stopFindingTheTag();
  }

  Future<void> multiplefind(List<String> tags) async {
    await _zebraRfidReaderSdkPlugin.findTheTag(tags.first);
    // await _zebraRfidReaderSdkPlugin.findMultipleTag(tags);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        designSize: const Size(412, 846),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.blue.shade400,
                title: Text(
                  'RFID READER',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEVICES',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      Text(
                        'Reading Devices (${availableReaderList.length})',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),

                      // Readers List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableReaderList.length,
                        itemBuilder: (context, index) {
                          final reader = availableReaderList[index];
                          final isSelected =
                              connectedReader.name == reader.name;
                          final status = isSelected
                              ? connectedReader.connectionStatus
                              : null;

                          Color tileBackgroundColor() {
                            if (status == ConnectionStatus.connected)
                              return Colors.green.shade100;
                            if (status == ConnectionStatus.connecting)
                              return Colors.yellow.shade100;
                            if (isSelected &&
                                status != ConnectionStatus.connected) {
                              return Colors.red.shade100;
                            }
                            return Colors.red.shade200;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: tileBackgroundColor(),
                              onTap: () async {
                                if (connectedReader.connectionStatus ==
                                    ConnectionStatus.connecting) {
                                  return;
                                } else if (isSelected &&
                                    connectedReader.connectionStatus ==
                                        ConnectionStatus.connected) {
                                  disconnectToZebra();
                                } else {
                                  await connectToZebra(reader.name!);
                                  Fluttertoast.showToast(
                                    msg: "Connected Successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                              contentPadding: const EdgeInsets.all(8),
                              title: Text(
                                reader.name ?? "Unknown Device",
                                style: TextStyle(fontSize: 15.sp),
                              ),
                              subtitle: isSelected &&
                                      connectedReader.connectionStatus ==
                                          ConnectionStatus.connected
                                  ? Text(
                                      'Battery ${connectedReader.batteryLevel ?? '0'}%')
                                  : null,
                              trailing: Text(
                                isSelected
                                    ? connectedReader.connectionStatus.name
                                    : 'Not Connected',
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                          onPressed: () {
                            multiplefind(readTags.map((e) => e.tagId).toList());
                          },
                          child: Text("find multiple")),
                      SizedBox(height: 16.h),
                      readTags.isNotEmpty
                          ? TextField(
                              controller: searchController,
                              onChanged: (value) {
                                filterTags();
                              },
                              style: TextStyle(
                                fontSize: 15.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search tags...',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 16.0)
                                    .r,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12).r,
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            )
                          : SizedBox(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchController.text.isEmpty
                            ? readTags.length
                            : filteredTags.length,
                        itemBuilder: (context, index) {
                          final result = searchController.text.isEmpty
                              ? readTags
                              : filteredTags;
                          return TagCard(
                            tagId: result[index].tagId,
                            lastUpdate:
                                formatLastSeenTime(result[index].lastSeenTime),
                            distance:
                                distance.isEmpty ? 0 : double.parse(distance),
                            count: 5,
                            isSelected: TagId == result[index].tagId,
                            onTap: () {
                              setState(() {
                                distance = '';
                                scanCount = 0;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SingleTag(
                                            tagDataModel: result[index],
                                            scanCount: scanCount,
                                            distance: distance.isEmpty
                                                ? '0'
                                                : double.parse(distance)
                                                    .toStringAsFixed(0),
                                          )));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // readTags.isNotEmpty
                      //     ? ElevatedButton(
                      //         onPressed: stopFindingTheTag,
                      //         child: const Text("Stop Tag"),
                      //       )
                      //     : SizedBox(),

                      const SizedBox(height: 8),

                      availableReaderList.isEmpty
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: getAvailableReaderList,
                                child: const Text(
                                    'Get Available ReaderDevice List'),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  String formatLastSeenTime(String rawTime) {
    try {
      // Example: Tue Apr 08 11:10:11 GMT+05:30 2025
      final parts = rawTime.split(' ');

      // Extract parts
      final month = parts[1]; // Apr
      final day = parts[2]; // 08
      final time = parts[3]; // 11:10:11

      return "$month $day $time"; // Apr 08 11:10:11
    } catch (e) {
      print("Error parsing time: $e");
      return rawTime;
    }
  }

  void filterTags() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTags = readTags.where((tag) {
        return tag.tagId.toLowerCase().contains(query) ||
            tag.lastSeenTime.toLowerCase().contains(query);
      }).toList();
    });
  }
}
