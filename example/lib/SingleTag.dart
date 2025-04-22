import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rfid_reader_sdk/zebra_rfid_reader_sdk.dart';

class SingleTag extends StatefulWidget {
  final TagDataModel tagDataModel;
  final String distance;
  final int? scanCount;
  const SingleTag(
      {super.key,
      required this.tagDataModel,
      required this.distance,
      this.scanCount});

  @override
  State<SingleTag> createState() => _SingleTagState();
}

class _SingleTagState extends State<SingleTag> {
  final _RfidReaderSdkPlugin = ZebraRfidReaderSdk();
  ReaderDevice connectedReader = ReaderDevice.initial();
  String distance = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findTheTag(widget.tagDataModel.tagId);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("sssssssssssssssssss");
    stopFindingTheTag();
    print("sssssssssssssssssss");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Single Tag"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.tagDataModel.tagId),
          SizedBox(
            height: 10.h,
          ),
          // widget.scanCount != null
          //     ? Text("Count : ${widget.scanCount}")
          //     : SizedBox(),
          SizedBox(height: 10.h,),
          Center(
            child: SignalStrengthCircle(
              value: int.parse(widget.distance),
            ),
          )
        ],
      ),
    );
  }

  Future<void> stopFindingTheTag() async {
    await _RfidReaderSdkPlugin.stopFindingTheTag();
  }

  Future<void> findTheTag(String tagId) async {
    print("Finding tag: $tagId");

    // Start finding the tag
    await _RfidReaderSdkPlugin.findTheTag(tagId);
    _RfidReaderSdkPlugin.findingTag.listen((event) {});
    _RfidReaderSdkPlugin.connectedReaderDevice.listen((event) {
      final result = jsonDecode(event.toString());
      print("resultsssssssssssssssssssssssssssssssss");
      print(event);
      print("resultsssssssssssssssssssssssssssssssss");
      print(result);
      print(result);
      print(result);

      // _RfidReaderSdkPlugin.readTags.forEach((action){
      //   print(action);
      // });
      // _RfidReaderSdkPlugin.readTags.forEach((action){
      //   print(action);
      // });

      setState(() {
        connectedReader = ReaderDevice.fromJson(result);
      });
      _RfidReaderSdkPlugin.findingTag.forEach((action) {
        print("done1");
        print(action);

        if (action != null) {
          try {
            // Decode the string to a Map
            final decoded = jsonDecode(action);

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
              });

              double distanceInMeters = distanceInCm / 100;
              print("Distance: ${distanceInMeters.toStringAsFixed(2)} meters");
            }
          } catch (e) {
            print('Error while parsing distance: $e');
          }
        }
      });
    });
  }
}

class SignalStrengthCircle extends StatelessWidget {
  final int value; // From 0 to 100

  const SignalStrengthCircle({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // Clamp value between 0–100 and convert to 0.0–1.0
    final percentage = (value.clamp(0, 100)) / 100;

    // Choose color based on percentage
    Color getColor(double percent) {
      if (percent >= 0.75) return Colors.red;
      if (percent >= 0.5) return Colors.orange;
      return Colors.green;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: percentage),
      duration: const Duration(milliseconds: 500),
      builder: (context, double animatedValue, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  getColor(animatedValue),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi, size: 32, color: getColor(animatedValue)),
                const SizedBox(height: 8),
                Text(
                  "${(animatedValue * 100).toInt()}cm",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
