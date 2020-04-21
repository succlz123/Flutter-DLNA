import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dlna/dlna.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dlnaManager = DLNAManager();
  dlnaManager.enableCache();
  runApp(MyApp(dlnaManager));
}

class MyApp extends StatelessWidget {
  final DLNAManager dlnaManager;

  MyApp(this.dlnaManager);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(dlnaManager: dlnaManager));
  }
}

class MyHomePage extends StatefulWidget {
  final DLNAManager dlnaManager;

  MyHomePage({Key key, this.dlnaManager}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DLNADevice> _devices = [];
  VideoObject _didlObject;
  DLNADevice _dlnaDevice;
  String actionMessage = '';

  bool mute = false;
  int volume = 0;

  set setDlnaDevice(DLNADevice value) {
    this._dlnaDevice = value;
    widget.dlnaManager.setDevice(value);
    setState(() {});
  }

  _MyHomePageState() {
    var title = 'Simple DLNA Demo';
    var url =
        'https://tx-safety-video.acfun.cn/mediacloud/acfun/acfun_video/segment/1g-pPVjSpOg3_4D6nvhw7KiluHh3LpyE-NZ_E2wieRg56PHHRuMtWKHPNKocP1OH.m3u8?pkey=AAJGzPf9ILXLcxtiJQC0ZiFC2jpgYlRAZa2PKhWvP-j2pEXQaMEMuLVVwvzvbNwlKX9l-gc6hbgl7qtF8sYYnPxZkWALszZBrg4apKn1okNwYo2SDS7Ma7-T1Btfju0cTUMCzBwRYJFXgvJaD3_tSfPg2uOK6hYR02Gld5-5hC4WxS8tWyOSA2o5oHckoO4rHtfZL657h2iueCKRCWVsQ-wqUTkBTifBw_8sqxCux2mmeQ&safety_id=AALiHMNr8NZQFMcXpIGj-KRo';
    _didlObject = VideoObject(title, url, VideoObject.VIDEO_MP4);
    _didlObject.refreshPosition = true;
  }

  @override
  void initState() {
    super.initState();
    widget.dlnaManager.setRefresher(DeviceRefresher(onDeviceAdd: (dlnaDevice) {
      if (!_devices.contains(dlnaDevice)) {
        print('add ' + dlnaDevice.toString());
        _devices.add(dlnaDevice);
      }
      setState(() {});
    }, onDeviceRemove: (dlnaDevice) {
      print('remove ' + dlnaDevice.toString());
      _devices.remove(dlnaDevice);
      setState(() {});
    }, onDeviceUpdate: (dlnaDevice) {
      print('update ' + dlnaDevice.toString());
      setState(() {});
    }, onSearchError: (error) {
      print('error ' + error);
    }, onPlayProgress: (positionInfo) {
      print(_time2Str(DateTime.now().millisecondsSinceEpoch) +
          ' current play progress ' +
          positionInfo.relTime);
    }));
  }

  void showToast(String name) {
    Fluttertoast.showToast(
        msg: name,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 12.0);
  }

  void showActMessage(String name, DLNAActionResult result) {
    if (result.success) {
      actionMessage = name + ' >>> ' + (result.result?.toString() ?? 'Null');
    } else {
      actionMessage = name +
          ' >>> ' +
          (result.errorMessage ?? 'Failed ${result.httpContent}');
    }
    setState(() {});
  }

  String _time2Str(int intTime) {
    var time = DateTime.fromMillisecondsSinceEpoch(intTime);
    return "${time.year.toString()}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple DLNA Demo'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Text('Current Device:',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  )),
            ),
            Container(
              width: double.infinity,
              color: Colors.black12,
              padding: EdgeInsets.all(8.0),
              child: Text(
                  '${_dlnaDevice?.deviceName ?? ''}\n${_dlnaDevice?.location ?? ''}',
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  )),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Act Message:',
                maxLines: 3,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.black12,
              padding: EdgeInsets.all(8.0),
              child: Text(
                '$actionMessage',
                maxLines: 3,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Device List:',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
            ),
            DeviceListStatefulWidget(_devices, (DLNADevice device) {
              setDlnaDevice = device;
            }),
            Container(
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: GestureDetector(
                            onTap: () {
                              widget.dlnaManager.startSearch();
                            },
                            child: Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () {
                                _devices.clear();
                                widget.dlnaManager.forceSearch();
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Force',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("URL");
                                var result = await widget.dlnaManager
                                    .actSetVideoUrl(_didlObject);
                                showActMessage('URL', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'URL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("Play");
                                var result = await widget.dlnaManager.actPlay();
                                showActMessage('Play', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Play',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("Pause");
                                var result =
                                    await widget.dlnaManager.actPause();
                                showActMessage('Pause', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pause',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("Stop");
                                var result = await widget.dlnaManager.actStop();
                                showActMessage('Stop', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Stop',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                  ],
                )),
            Container(
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: () async {
                          int time = 100;
                          showToast("Seek $time");
                          var result = await widget.dlnaManager.actSeek(time);
                          showActMessage('Seek', result);
                        },
                        child: Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Seek',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("PositionInfo");
                                var result = await widget.dlnaManager
                                    .actGetPositionInfo();
                                showActMessage('Pos', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pos',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("Next");
                                var result = await widget.dlnaManager.actNext();
                                showActMessage('Next', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("Previous");
                                var result =
                                    await widget.dlnaManager.actPrevious();
                                showActMessage('Prev', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Prev',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                PlayMode playMode = PlayMode.NORMAL;
                                showToast("SetPlayMode ${playMode.name}");
                                var result = await widget.dlnaManager
                                    .actSetPlayMode(playMode);
                                showActMessage('Mode', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Mode',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("GetProtocolInfo");
                                var result = await widget.dlnaManager
                                    .actGetProtocolInfo();
                                showActMessage('Protocol', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Protocol',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                  ],
                )),
            Container(
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: GestureDetector(
                            onTap: () async {
                              showToast("GetMute");
                              var result =
                                  await widget.dlnaManager.actGetMute();
                              showActMessage('GetMute', result);
                            },
                            child: Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'GetMute',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("SetMute ${!mute}");
                                var result =
                                    await widget.dlnaManager.actSetMute(!mute);
                                mute = !mute;
                                showActMessage('SetMute', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'SetMute',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("GetLocal");
                                var deviceList =
                                    await widget.dlnaManager.getLocalDevices();
                                var actionResult = DLNAActionResult<String>();
                                actionResult.success = true;
                                actionResult.result =
                                    'size ${deviceList?.length} ${deviceList.first?.deviceName}';
                                showActMessage('GetLocal', actionResult);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'GetLocal',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("GetVolume");
                                var result =
                                    await widget.dlnaManager.actGetVolume();
                                showActMessage('GetVolume', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'GetVolume',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("SetVolume $volume");
                                var result = await widget.dlnaManager
                                    .actSetVolume(volume);
                                volume++;
                                if (volume > 60) {
                                  volume = 0;
                                }
                                showActMessage('SetVolume', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'SetVolume',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            )))
                  ],
                )),
            Container(
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: GestureDetector(
                            onTap: () async {
                              showToast("MediaInfo");
                              var result =
                                  await widget.dlnaManager.actGetMediaInfo();
                              showActMessage('MediaInfo', result);
                            },
                            child: Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'MediaInfo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("TransportInfo");
                                var result = await widget.dlnaManager
                                    .actGetTransportInfo();
                                showActMessage('TransportInfo', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'TransportInfo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("TransportActs");
                                var result = await widget.dlnaManager
                                    .actGetTransportActions();
                                showActMessage('TransportActs', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'TransportActs',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () async {
                                showToast("DeviceCapabilities");
                                var result = await widget.dlnaManager
                                    .actGetDeviceCapabilities();
                                showActMessage('DeviceCaps', result);
                              },
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'DeviceCaps',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ))),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class DeviceListStatefulWidget extends StatefulWidget {
  final List<DLNADevice> _devices;
  final Function(DLNADevice device) _onClickCallback;

  DeviceListStatefulWidget(this._devices, this._onClickCallback);

  @override
  State<StatefulWidget> createState() {
    return DeviceListState();
  }
}

class DeviceListState extends State<DeviceListStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: widget._devices.length,
          itemBuilder: (BuildContext context, int position) {
            return _getListData(position);
          },
        ),
      ),
    );
  }

  _getListData(int position) {
    return GestureDetector(
        onTap: () {
          widget._onClickCallback(widget._devices[position]);
        },
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget._devices[position].deviceName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                _listViewLine
              ],
            )));
  }

  get _listViewLine {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
        child: Container(
          color: Colors.black12,
          height: 1,
        ));
  }
}
