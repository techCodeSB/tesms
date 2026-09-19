import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tesms/server/server.dart';
import 'package:flutter/services.dart';
import 'package:tesms/utils/generate_api_key.dart';
import 'package:tesms/utils/get_device_ip.dart';
import 'package:tesms/utils/sms_permission.dart';
import 'package:tesms/utils/store_data.dart';
import 'package:tesms/widgets/bottom_nav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SmsServer server = SmsServer();
  bool isStart = false;
  bool endPointCopy = false;
  bool keyCopy = false;
  String api = "";
  String apiKey = "";
  bool apiKeyActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });
  }

  Future<void> initializeApp() async {
    // Request SMS permission
    final granted = await requestSmsPermission();


    final pref = await SharedPreferences.getInstance();

    String? savedKey = pref.getString("api-key");
    apiKeyActive = pref.getString('api-key-status')?.toLowerCase() == 'true';

    if (savedKey != null && savedKey.isNotEmpty) {
      apiKey = savedKey;
    } else {
      apiKey = generateApiKey();

      await pref.setString("api-key", apiKey);
    }

    // Endpoint
    final ip = await getDeviceIp();

    api = "http://$ip:8080/api/send-sms";

    // UI update
    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(granted ? "Permission granted" : "Permission denied"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tesms",
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 3.0,
      ),
      body: ListView(
        padding: EdgeInsets.all(10.5),
        children: [
          Card(
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.blue.shade200,
                        size: 12.0,
                      ),
                      Text(
                        "\tServer Status: ${isStart ? "running..." : "stopped"}",
                        style: TextStyle(color: Colors.grey, fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          isStart = !isStart;
                        });

                        if (isStart) {
                          server.start();
                        } else {
                          server.stop();
                        }
                      },
                      padding: EdgeInsets.all(8.0),
                      minWidth: double.infinity,
                      color: isStart
                          ? Colors.red.shade400
                          : Colors.green.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(30.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isStart
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          Text(
                            "${isStart ? "Stop" : "Start"} Server",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // ====================== [END POINT CARD] ========================
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "End Point",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(api, softWrap: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: api));

                          setState(() {
                            endPointCopy = true;
                          });

                          Timer(Duration(seconds: 1), () {
                            setState(() {
                              endPointCopy = false;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                            top: 5.0,
                            bottom: 5.0,
                          ),
                          fixedSize: Size(90.0, 20.0),
                          backgroundColor: const Color.fromARGB(
                            155,
                            187,
                            222,
                            251,
                          ),
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 4, 4, 217),
                            fontWeight: FontWeight.bold,
                          ),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(endPointCopy ? Icons.check : Icons.copy),
                            const SizedBox(width: 5.0),
                            Text(endPointCopy ? "Copied.." : "Copy"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ====================== [API KEY AND ROTATE KEY CARD] ========================
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Api Key",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 35.0,
                        child: FittedBox(
                          child: Switch(
                            value: apiKeyActive,
                            onChanged: (v) {
                              setState(() {
                                apiKeyActive = v;
                              });

                              storeData("api-key-status", v.toString());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ======================= IS API KEY ACTIVE THEN SHOW THIS =================
                  if (apiKeyActive) ...[
                    SizedBox(height: 5.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(apiKey, softWrap: false),
                        ),
                      ),
                    ),

                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final pref = await SharedPreferences.getInstance();

                            setState(() {
                              apiKey = generateApiKey();
                            });

                            await pref.setString("api-key", apiKey);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            fixedSize: Size(90.0, 20.0),
                            backgroundColor: const Color.fromARGB(
                              155,
                              187,
                              222,
                              251,
                            ),
                            textStyle: TextStyle(
                              color: const Color.fromARGB(255, 4, 4, 217),
                              fontWeight: FontWeight.bold,
                            ),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.replay_outlined),
                              const SizedBox(width: 5.0),
                              Text("Rotate"),
                            ],
                          ),
                        ),

                        SizedBox(width: 5.0),

                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              keyCopy = true;
                            });

                            Timer(Duration(seconds: 1), () {
                              setState(() {
                                keyCopy = false;
                              });
                            });

                            await Clipboard.setData(
                              ClipboardData(text: apiKey),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            fixedSize: Size(90.0, 20.0),
                            backgroundColor: const Color.fromARGB(
                              155,
                              187,
                              222,
                              251,
                            ),
                            textStyle: TextStyle(
                              color: const Color.fromARGB(255, 4, 4, 217),
                              fontWeight: FontWeight.bold,
                            ),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(keyCopy ? Icons.check : Icons.copy),
                              const SizedBox(width: 5.0),
                              Text(keyCopy ? "Copied.." : "Copy"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNav(),
    );
  }
}
