import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/OrderDetailData.dart';
import 'package:delivery_2/database/shopByUserDatabase.dart';
import 'package:delivery_2/navigation_bar.dart';
import 'package:delivery_2/service.dart/AllService.dart';

import 'Login.dart';

class OrderDetail extends StatefulWidget {
  final String shopName;
  final String shopNameMm;
  final String address;
  final String mcdCheck;
  final String userType;
  final String phone;
  OrderDetail(
      {Key key,
      @required this.shopName,
      @required this.shopNameMm,
      @required this.address,
      @required this.phone,
      this.mcdCheck,
      this.userType})
      : super(key: key);
  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List data = [];
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  String dateformat;

  List orderData = orderDetailData;

  @override
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    setState(() {
      data = orderDetailData.toSet().toList();

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Order List"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                final SharedPreferences preferences = await SharedPreferences.getInstance();
                orderDetailData = [];
                // Navigator.pop(context);
                stockData.clear();
                brandOwnerName.clear();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NavigationBar(
                            "", widget.mcdCheck, widget.userType, preferences.getString("DateTime"))));
              }),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400])),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Shop',
                                      textAlign: TextAlign.start,
                                      style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width - 150,
                                  child: Text(widget.shopNameMm == null || widget.shopNameMm == "" ? "  - ${widget.shopName}" :'  - ${widget.shopName} (${widget.shopNameMm})',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Text('Phone',
                                    textAlign: TextAlign.start,
                                    style: TextStyle()),
                                ),
                                Text('  - ${widget.phone}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Address',
                                      textAlign: TextAlign.start,
                                      style: TextStyle()),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width - 150,
                                  child: Text("  - ${widget.address}",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: MediaQuery.of(context).size.height - 317,
                child: data.length == 0 || data == []
                    ? Center(
                        child: Text(
                          "No Data",
                          style:
                              TextStyle(fontSize: 25, color: Colors.grey[400]),
                        ),
                      )
                    : 
                  ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                bool loading = false;
                                final SharedPreferences preferences =
                                    await SharedPreferences
                                        .getInstance();
                                var getSysKey = helperShopsbyUser
                                    .getShopSyskey(preferences
                                        .getString('shopname'));

                                setState(() {
                                  loading = true;
                                });

                                if (loading == true) {
                                  _handleSubmit(context);
                                }

                                getSysKey.then((val) {
                                    setState(() {
                                      getStock(val[0]["shopcode"],
                                              data[i]["syskey"])
                                          .then((value) {
                                        // print(brandOwnerName);

                                        if (value == "success") {
                                          setState(() {
                                            loading = false;
                                          });
                                          datetime();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              OrderDetailData(
                                                                shopName:
                                                                    widget.shopName,
                                                                address:
                                                                    widget.address,
                                                                shopNameMm: widget.shopNameMm,
                                                                orderDate:
                                                                    "${data[i]["date"].toString().substring(6, 8)}/${data[i]["date"].toString().substring(4, 6)}/${data[i]["date"].toString().substring(0, 4)}",
                                                                deliveryDate: date,
                                                                phone:
                                                                    widget.phone,
                                                                shopSyskey:
                                                                    data[i]["syskey"],
                                                                mcdCheck:
                                                                    widget.mcdCheck,
                                                                userType:
                                                                    widget.userType,
                                                                orderDeleted: [],
                                                                returnDeleted: [],
                                                                isSaleOrderLessRouteShop: "false",
                                                              )));
                                        } else if (value == "fail") {
                                          setState(() {
                                            loading = false;
                                          });
                                          Navigator.pop(context);
                                          snackbarmethod("FAIL!");
                                        } else {
                                          setState(() {
                                            loading = false;
                                          });
                                          Navigator.pop(context);
                                          snackbarmethod(value);
                                        }
                                      });
                                    });
                                });
                              },
                              child: Card(
                                child: Container(
                                  height: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: <Widget>[
                                        Text("${data[i]["syskey"]}"),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                                "${data[i]["date"].toString().substring(6, 8)}/${data[i]["date"].toString().substring(4, 6)}/${data[i]["date"].toString().substring(0, 4)}"),
                                            Icon(Icons
                                                .keyboard_arrow_right)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  snackbarmethod1(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ));
  }

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }


  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<void> _handleSubmit(BuildContext context) async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader);
    } catch (error) {
      print(error);
    }
  }
}
