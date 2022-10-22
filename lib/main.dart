import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
            print('Try to close');
            FlutterOverlayWindow.closeOverlay()
                .then((value) => print('STOPPED: alue: $value'));
          },
          child: Container(
            color: Colors.black.withOpacity(.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 18,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'This is a response' * 10,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String? _response;

  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    print("Started listening");
    FlutterOverlayWindow.overlayListener.listen((event) {
      print("$event");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    label: Text("Phone"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    label: Text("Amount"),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    _showOverlay();
                    setState(() {
                      isRunning = true;
                    });
                    String? res = await UssdAdvanced.sendAdvancedUssd(
                        code: phoneController.text, subscriptionId: 1);
                    setState(() {
                      _response = res;
                      isRunning = false;
                    });
                    /* String? res = await UssdAdvanced.multisessionUssd(
                        code: phoneController.text, subscriptionId: 1);
                    setState(() {
                      isRunning = true;
                      _response = res;
                    });
                    String? res2 = await UssdAdvanced.sendMessage('0');
                    setState(() {
                      _response = res2;
                    });
                    await UssdAdvanced.cancelSession();
                    setState(() {
                      isRunning = false;
                      _response = res;
                    }); */
                    // setState(() {
                    //   isRunning = !isRunning;
                    //   _response = res;
                    // });
                  },
                  child: const Text("Validator"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showOverlay() async {
    final status = await FlutterOverlayWindow.isPermissionGranted();

    if (!status) {
      final bool? res = await FlutterOverlayWindow.requestPermission();
      print("is permission granted: $status");
    } else {
      if (await FlutterOverlayWindow.isActive()) return;
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "X-SLAYER",
        overlayContent: 'Overlay Enabled',
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.centerLeft,
        visibility: NotificationVisibility.visibilityPrivate,
        positionGravity: PositionGravity.auto,
      );
    }
  }
}
