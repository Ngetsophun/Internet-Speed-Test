import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedTestInternet extends StatefulWidget {
  const SpeedTestInternet({Key? key}) : super(key: key);

  @override
  State<SpeedTestInternet> createState() => _SpeedTestInternetState();
}

class _SpeedTestInternetState extends State<SpeedTestInternet> {
  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  double _displayRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  bool _isServerSelectionInProgress = false;

  String? _ip;
  String? _asn;
  String? _isp;

  String _unitText = 'Mbps';
  String? isp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  Future<void> fetchISP(String ipAddress) async {
    try {
      final ispResponse = await getISP(ipAddress);
      var data = jsonDecode(ispResponse);
      setState(() {
        isp = data['isp'];
      });
    } catch (e) {
      print('Error fetching ISP: $e');
    }
  }

  Future<String> getISP(String ipAddress) async {
    final response =
    await http.get(Uri.parse('http://ip-api.com/json/$ipAddress'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get ISP information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
            onTap: () {
              reset();
              Get.back();
            },
            child: Container(
                margin: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).secondaryHeaderColor,
                  size: 26,
                ))),
        centerTitle: false,
        title: Text(
          'Speed Test',
          style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.file_download_outlined,
                            color: Colors.cyan,
                            weight: 24,
                            size: 32,
                          ),
                          Text(
                            'Download',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 24,
                        padding: EdgeInsets.only(left: 4),
                        child:
                        //  _downloadProgress != '100'
                        // ? Container(
                        //     width: 100,
                        //     height: 10,
                        //     padding: EdgeInsets.all(8),
                        //     child: LoadingIndicator(
                        //       indicatorType: Indicator.ballBeat,
                        //       colors: [
                        //         Colors.cyan.shade400,
                        //         Colors.cyan.shade600
                        //       ],
                        //     ))
                        //     :
                        Row(
                          children: [
                            Text(
                              _downloadRate.toStringAsFixed(2),
                              style: GoogleFonts.openSans(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              _unitText.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).secondaryHeaderColor),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.file_upload_outlined,
                            color: Colors.deepPurpleAccent,
                            weight: 24,
                            size: 32,
                          ),
                          Text(
                            'Upload',
                            style: GoogleFonts.openSans(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 24,
                        padding: EdgeInsets.only(left: 4),
                        child:
                        // _uploadProgress != "100"
                        //     ? Container(
                        //         width: 100,
                        //         height: 10,
                        //         padding: EdgeInsets.all(8),
                        //         child: LoadingIndicator(
                        //           indicatorType: Indicator.ballBeat,
                        //           colors: [
                        //             Colors.deepPurpleAccent.shade400,
                        //             Colors.deepPurpleAccent.shade700
                        //           ],
                        //         ))
                        //     :
                        Row(
                          children: [
                            Text(
                              _uploadRate.toStringAsFixed(2),
                              style: GoogleFonts.openSans(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              _unitText.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Theme.of(context).secondaryHeaderColor),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            SfRadialGauge(axes: <RadialAxis>[
              RadialAxis(
                  minimum: 0,
                  maximum: 180,
                  interval: 30,
                  radiusFactor: .9,
                  tickOffset: 8,
                  showTicks: false,
                  minorTicksPerInterval: 1,
                  showLastLabel: true,
                  labelOffset: 36,
                  useRangeColorForAxis: true,
                  axisLabelStyle: GaugeTextStyle(color: Colors.white),
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startWidth: 24,
                      endWidth: 24,
                      startValue: 0,
                      endValue: 180,
                      color: Theme.of(context).secondaryHeaderColor,
                      gradient: _uploadProgress != "0"
                          ? SweepGradient(colors: [
                        Colors.deepPurpleAccent.shade100,
                        Colors.deepPurpleAccent.shade200,
                        Colors.deepPurpleAccent.shade400
                      ])
                          : SweepGradient(colors: [
                        Colors.cyan.shade100,
                        Colors.cyan.shade200,
                        Colors.cyan.shade400
                      ]),
                      labelStyle: GaugeTextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w800),
                    ),
                    // GaugeRange(
                    //     startWidth: 15,
                    //     endWidth: 15,
                    //     startValue: 60,
                    //     endValue: 120,
                    //     color: Colors.orange),
                    // GaugeRange(
                    //     startWidth: 15,
                    //     endWidth: 15,
                    //     startValue: 120,
                    //     endValue: 180,
                    //     color: Colors.green)
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: _displayRate,
                      enableAnimation: true,
                      animationDuration: 100,
                      gradient: _uploadProgress != "0"
                          ? LinearGradient(colors: [
                        Colors.deepPurpleAccent.shade100,
                        Colors.deepPurpleAccent.shade200,
                        Colors.deepPurpleAccent.shade400
                      ])
                          : LinearGradient(colors: [
                        Colors.cyan.shade100,
                        Colors.cyan.shade400
                      ]),
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Padding(
                          padding: const EdgeInsets.only(top: 56),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${_displayRate.toStringAsFixed(2)}',
                                  style: GoogleFonts.openSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _uploadProgress != "0"
                                        ? Icons.file_download_outlined
                                        : Icons.file_upload_outlined,
                                    color: _uploadProgress != "0"
                                        ? Colors.deepPurpleAccent.shade400
                                        : Colors.cyan,
                                    size: 32,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text('${_unitText}',
                                      style: GoogleFonts.openSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5)
                  ])
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _ip == null ? null : Icons.wifi,
                    color: _uploadProgress != "0"
                        ? Colors.deepPurpleAccent.shade400
                        : Colors.cyan,
                    size: 40,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _isServerSelectionInProgress
                      ? Container()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isp ?? "",
                          style: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .secondaryHeaderColor)),
                      Text(_ip ?? "",
                          style: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .secondaryHeaderColor)),
                    ],
                  )
                ],
              ),
            ),

            // if (!_testInProgress) ...{
            InkWell(
              onTap: _testInProgress
                  ? null
                  : () async {
                reset();
                await internetSpeedTest.startTesting(onStarted: () {
                  setState(() => _testInProgress = true);
                }, onCompleted: (TestResult download, TestResult upload) {
                  if (kDebugMode) {
                    print(
                        'the transfer rate ${download.transferRate}, ${upload.transferRate}');
                  }
                  setState(() {
                    _downloadRate = download.transferRate;
                    _unitText =
                    download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                    _downloadProgress = '100';
                    _displayRate = _downloadRate;
                    _downloadCompletionTime = download.durationInMillis;
                  });
                  setState(() {
                    _uploadRate = upload.transferRate;
                    _unitText =
                    upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                    _uploadProgress = '100';
                    _displayRate = _uploadRate;
                    _uploadCompletionTime = upload.durationInMillis;
                    _testInProgress = false;
                  });
                }, onProgress: (double percent, TestResult data) {
                  if (kDebugMode) {
                    print(
                        'the transfer rate $data.transferRate, the percent $percent');
                  }
                  setState(() {
                    _unitText =
                    data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                    if (data.type == TestType.download) {
                      _downloadRate = data.transferRate;
                      _displayRate = _downloadRate;
                      _downloadProgress = percent.toStringAsFixed(2);
                    } else {
                      _uploadRate = data.transferRate;
                      _displayRate = _uploadRate;
                      _uploadProgress = percent.toStringAsFixed(2);
                    }
                  });
                }, onError: (String errorMessage, String speedTestError) {
                  if (kDebugMode) {
                    print(
                        'the errorMessage $errorMessage, the speedTestError $speedTestError');
                  }
                  reset();
                }, onDefaultServerSelectionInProgress: () {
                  setState(() {
                    _isServerSelectionInProgress = true;
                  });
                }, onDefaultServerSelectionDone: (Client? client) {
                  setState(() {
                    _ip = client?.ip;
                    _asn = client?.asn;
                    _isp = client?.isp;
                    fetchISP(_ip!).then(
                            (value) => _isServerSelectionInProgress = false);
                  });
                }, onDownloadComplete: (TestResult data) {
                  setState(() {
                    _downloadRate = data.transferRate;

                    _unitText =
                    data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                    _downloadCompletionTime = data.durationInMillis;
                  });
                }, onUploadComplete: (TestResult data) {
                  setState(() {
                    _uploadRate = data.transferRate;
                    _unitText =
                    data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                    _uploadCompletionTime = data.durationInMillis;
                  });
                }, onCancel: () {
                  reset();
                });
              },
              child: Container(
                height: 48,
                width: MediaQuery.of(context).size.width * .85,
                decoration: BoxDecoration(
                  color: _uploadProgress != "0"
                      ? Colors.deepPurpleAccent.shade400
                      : Colors.cyan,
                  borderRadius: BorderRadius.circular(8),
                  gradient: _uploadProgress != "0"
                      ? LinearGradient(colors: [
                    Colors.deepPurpleAccent.shade100,
                    Colors.deepPurpleAccent.shade200,
                    Colors.deepPurpleAccent.shade400
                  ])
                      : LinearGradient(
                      colors: [Colors.cyan.shade100, Colors.cyan.shade400]),
                ),
                alignment: Alignment.center,
                child: _testInProgress
                    ? CircularProgressIndicator()
                    : Text('Start Testing',
                    style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            )
            // } else ...{
            //   const CircularProgressIndicator(),
            //   Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: TextButton.icon(
            //       onPressed: () => internetSpeedTest.cancelTest(),
            //       icon: const Icon(Icons.cancel_rounded),
            //       label: const Text('Cancel'),
            //     ),
            //   )
            // },
          ],
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      {
        _testInProgress = false;
        _downloadRate = 0;
        _uploadRate = 0;
        _displayRate = 0;
        _downloadProgress = '0';
        _uploadProgress = '0';
        _unitText = 'Mbps';
        _downloadCompletionTime = 0;
        _uploadCompletionTime = 0;

        _ip = null;
        _asn = null;
        _isp = null;
      }
    });
  }
}