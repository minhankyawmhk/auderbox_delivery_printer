import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/ShopList.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'package:http/http.dart' as http;

import 'database/shopByUserNote.dart';

class Sync extends StatefulWidget {
  @override
  _SyncState createState() => _SyncState();
}

class _SyncState extends State<Sync> with SingleTickerProviderStateMixin {
  bool visible = false;
  AnimationController progressController;
  Animation<double> animation;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  // DateTime startDate;
  DateTime endDate;

  int _progress = 0;
  Timer timer;
  bool download = false;

  @override
  void initState() {
    super.initState();
    // getAllShop();
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 4000));
    animation = Tween<double>(begin: 0, end: 99).animate(progressController)
      ..addListener(() {
        // move();

        setState(() {
          var percent = animation.value.toInt();
          if (percent == 100) {
            // move();
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>NewPage()));
          }
        });
      });

    // startDate = DateTime.now();

    getshopallBytes = 0.0;
    getstockimgBytes = 0.0;
    getorderstockBytes = 0.0;
    getreturnstockBytes = 0.0;
  }

  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Color(0xffe53935),
      duration: Duration(seconds: 3),
    ));
  }

  void move() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    // String getOrgId = preferences.getString("OrgId").toString();
    // String merchandizer = preferences.getString("merchandizer");
    // String userType = preferences.getString("userType");

    orgId = preferences.getString("OrgId").toString();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShopList(date: preferences.getString("DateTime"))));
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          automaticallyImplyLeading: false,
          centerTitle: true,
          // title: Text("Data"),
          title: new Center(
              child: Text(
            "Sync",
            textAlign: TextAlign.center,
            style: new TextStyle(
                fontFamily: "Pyidaungsu",
                fontSize: 20,
                letterSpacing: 1.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          )),
        ),
        body: Column(
          children: <Widget>[
            Visibility(
                visible: true,
                child: visible == true
                    ? Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, top: 10, right: 5),
                          child: LinearPercentIndicator(
                            lineHeight: 20.0,
                            percent: visible == true ? _progress / 100 : 0,
                            center: Text(
                              "$_progress",
                              style: new TextStyle(color: Colors.white),
                            ),
                            linearStrokeCap: LinearStrokeCap.butt,
                            backgroundColor: Colors.grey[200],
                            progressColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Color(0xffCE8054)
                                    : Color(0xFFB71C1C),
                          ),
                        ),
                      )
                    : Container()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 60,
                child: Card(
                  child: ListTile(
                    leading: Text("Types"),
                    trailing: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Download",
                              style: TextStyle(color: Colors.black)),
                          WidgetSpan(
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 13,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(330),
              height: ScreenUtil().setHeight(80),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE57373), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFFB71C1C).withOpacity(.3),
                        offset: Offset(0.0, 8.0),
                        blurRadius: 8.0),
                  ]),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: download
                      ? null
                      : () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.mobile ||
                              connectivityResult == ConnectivityResult.wifi) {
                            visible = true;

                            progressController.forward();

                            setState(() {
                              download = true;
                            });

                            getShopFunction();

                          } else {
                            snackbarmethod1("Check your connection!");
                          }
                        },
                  child: Center(
                    child: Text(
                      "Start",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Pyidaungsu",
                          fontSize: 17,
                          letterSpacing: 1.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shopbyUsersave(note) async {
    if (note.id != null) {
      await shopbyUser.updateNote(note);
      print('update');
    } else {
      print('insert');
      await shopbyUser.insertNote(note).then((value) {
        shopCheck = "success";
      });
    }
    updateList();
  }

  Future<void> getShopFunction() async {
    datetime();
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    print(preferences.getString('spsyskey'));
    print(preferences.getString("OrgId"));
    var check;

    shopCheck = null;

    final url = '$domain' + 'shop/getshopall';
    var param = jsonEncode({
      "spsyskey": "${preferences.getString('spsyskey')}",
      "teamsyskey": "",
      "usertype": "delivery",
      "date": "$date"
      // "date": "20210102"
    });
    print(url);
    print(param);
    final response = await http
        .post(Uri.encodeFull(url), body: param, headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Content-Over": '${preferences.getString("OrgId")}',
        })
        .timeout(Duration(seconds: 20))
        .catchError((error) {
          check = 'Server Fail!';
        });

    if (response != null) {
      print("1");
      if (response.statusCode == 200) {
        print("2");
        getshopallBytes =
            (response.bodyBytes.length / response.contentLength) * 100;
        var result = json.decode(response.body);
        Future<int> sbuDataLength = shopbyUser.getCount();

        if (result['data']['shopsByUser'].length == 0) {
          check = "success";
          progressFunction();
        }

        sbuDataLength.then((value) {
          if (value == 0) {
            print(result['status']);
            print(result['data']);
            for (var i = 0; i < result['data']['shopsByUser'].length; i++) {
              _shopbyUsersave(ShopByUserNote(
                  result['data']['shopsByUser'][i]['isSaleOrderLessRouteShop']
                      .toString(),
                  result['data']['shopsByUser'][i]['address'].toString(),
                  result['data']['shopsByUser'][i]['shopnamemm'].toString(),
                  result['data']['shopsByUser'][i]['shopsyskey'].toString(),
                  result['data']['shopsByUser'][i]['long'].toString(),
                  result['data']['shopsByUser'][i]['phoneno'].toString(),
                  result['data']['shopsByUser'][i]['zonecode'].toString(),
                  result['data']['shopsByUser'][i]['shopcode'].toString(),
                  result['data']['shopsByUser'][i]['shopname'].toString(),
                  result['data']['shopsByUser'][i]['teamcode'].toString(),
                  result['data']['shopsByUser'][i]['location'].toString(),
                  result['data']['shopsByUser'][i]['comment'].toString(),
                  result['data']['shopsByUser'][i]['usercode'].toString(),
                  result['data']['shopsByUser'][i]['user'].toString(),
                  result['data']['shopsByUser'][i]['lat'].toString(),
                  result['data']['shopsByUser'][i]['email'].toString(),
                  result['data']['shopsByUser'][i]['username'].toString(),
                  result['data']['shopsByUser'][i]["status"]["currentType"]));

              print(i + 1);

              if (i == result['data']['shopsByUser'].length - 1) {
                check = "success";
                print(check);
                progressFunction();
              }
            }
          } else {}
        });
      } else {
        print(response.statusCode);
        check = "Server Error " + response.statusCode.toString() + " !";
        progressFunction();
      }
    } else {
      check = 'Connection Fail!';
      progressFunction();
    }
  }

  void progressFunction() {
    setState(() {
      _progress = 25;
    });
    print("last result ---------- " + _progress.toString());
    getStockImg().then((stockImageValue) {
      setState(() {
        _progress = 50;
      });
      print("last result ---------- " + _progress.toString());
      print("222222222 >>" + getstockimgBytes.toString());
      getOrderStock().then((orederstockValue) {
        setState(() {
          _progress = 75;
        });
        print("last result ---------- " + _progress.toString());
        print("333333333333 >>" + getorderstockBytes.toString());
        getReturnStocks().then((returnstockValue) {
          print("44444444444 >>" + getorderstockBytes.toString());
          setState(() {
            _progress = 100;
            move();
          });
          print("last result ---------- " + _progress.toString());
        });
      });
    });
  }
}
