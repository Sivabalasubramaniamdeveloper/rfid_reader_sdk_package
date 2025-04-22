### rfid_reader_sdk

RFID Reader SDK plugin for Flutter.

[//]: # (<img src="https://github.com/yagmure15/rfid_reader_sdk/raw/main/site/_rfd8500.png" alt="Zebra RFID Reader SDK Logo" width="300">)



## Android Setup 🔧

### Be Sure minSdkVersion 19 or Higher
```dart
defaultConfig {
   minSdkVersion 19
}    
```
## IOS Setup 🔧
### Be Sure min IOS Version 14.0 or Higher

Don't forget to change this line in the Podfile.
```dart
platform :ios, '14.0'
```
### Info.plist Setup
The following lines should be added to the project that will use the library.

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs bluetooth permission to listen tag events</string>
<key>UISupportedExternalAccessoryProtocols</key>
<array>
   <string>com..rfd8X00_easytext</string>
   <string>com..scanner.SSI</string>
</array>
```


------------------------------------------------------------------------------------------------


## Features
- Ability to connect to paired RFID reader.
- Ability to configure antenna power, beeper volume, and dynamic power.
- Seach and find spesific tag
- Read tags

## Usage

### Importing and Creating an Instance
```dart
import 'package:rfid_reader_sdk/rfid_reader_sdk.dart';
...
final _RfidReaderSdkPlugin = ZebraRfidReaderSdk();
```

### Connection
The 'connect' function has two parameters. The 'tagName' parameter specifies the name of the device to be connected to. The 'readerConfig' parameter is optional and is used to set antenna, sound, and dynamic power data.

*Note 1: Antenna power value should be between **120** and **300**.*

*Note 2: Please check Bluetooth scan and connection permissions before calling the connection function.*


```dart
  Future<void> requestAccess() async {
    await Permission.bluetoothScan.request().isGranted;
    await Permission.bluetoothConnect.request().isGranted;
  }
```

```dart
_RfidReaderSdkPlugin.connect(
      tagName,
      readerConfig: ReaderConfig(
        antennaPower: 300,
        beeperVolume: BeeperVolume.high,
        isDynamicPowerEnable: true,
      ),
    );
```
### Disconnection
```dart
 _RfidReaderSdkPlugin.disconnect();
```
### Get Available Reader List
It returns a list of paired devices, resulting in a list of **ReaderDevice**.
```dart
_RfidReaderSdkPlugin.getAvailableReaderList();
```

### Anntenna Power
This function is used to set the antenna power value for the Zebra RFID reader. The value parameter should be an integer between 120 and 300, indicating the desired power level.
```dart
_RfidReaderSdkPlugin.setAntennaPower(value);
```

### Beeper Volume
This function is used to adjust the volume of the beeper on the Zebra RFID reader. The value parameter represents the desired volume level, which should be an integer.
```dart
_RfidReaderSdkPlugin.setBeeperVolume(value);
```

### Dynamic Power
This function is used to configure the dynamic power settings for the Zebra RFID reader. The value parameter should be an boolean representing the desired dynamic power level.
```dart
_RfidReaderSdkPlugin.setDynamicPower(value);
```

### Listening Event
```dart
_RfidReaderSdkPlugin.connectedReaderDevice.listen((event) {
      final result = jsonDecode(event.toString());
      log(result.toString());
    });
```


### Tag Locationing
You can search for any tag with a specific pattern.
```dart
 _RfidReaderSdkPlugin.findTheTag('add_your_tag_pattern')
```