import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/shopByUserDatabase.dart';
import '../service.dart/AllService.dart';

import '../Login.dart';
import '../OrderDetailData.dart';
import 'DiscountDetail.dart';
import 'DiscountStock.dart';
import 'ShowImage.dart';

class AddOrderStock extends StatefulWidget {
  String shopName;
  String shopNameMm;
  String address;
  String shopSyskey;
  String date;
  String mcdCheck;
  String userType;
  String title;
  String phone;
  List stockList1 = [];
  List returnList = [];
  List orderDeleted = [];
  List returnDeleted = [];
  String isSaleOrderLessRouteShop;
  AddOrderStock(
      {Key key,
      @required this.shopName,
      @required this.shopNameMm,
      @required this.address,
      @required this.phone,
      this.shopSyskey,
      this.date,
      this.mcdCheck,
      this.userType,
      this.title,
      this.stockList1,
      this.returnList,
      @required this.orderDeleted,
      @required this.returnDeleted,
      @required this.isSaleOrderLessRouteShop})
      : super(key: key);
  @override
  _AddOrderStockState createState() => _AddOrderStockState();
}

List stockList = [];
List newList = [];
List originalQty = [];

class _AddOrderStockState extends State<AddOrderStock> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List searchList = [];
  List searchPrice = [];
  List totalItem = [];
  bool searchVisible = false;
  String ownerName;
  List originalList = [];
  
  
  bool disItemList = false;
  List stockAllList = [];
  List categoryDesc = [];
  List orderStock = [];
  List allSearchList = [];
  TextEditingController searchCtrl = TextEditingController();
  ShopsbyUser helperShopsbyUser = ShopsbyUser();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  Future<void> getReturnProducts() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      List subCateGoryList = [];

      
      
      stockAllList = json.decode(preferences.getString("AddOrder"));

      // List returnStock = [];
      for (var a = 0; a < stockAllList.length; a++) {
        if(categoryDesc.length == 0) {
          categoryDesc.add({
            "categoryCode" : "All",
            "categoryCodeDesc" : "All",
            "subCategoryList" : [],
            "choose" : true
          });
          categoryDesc.add({
            "categoryCode" : stockAllList[a]["categoryCode"],
            "categoryCodeDesc" : stockAllList[a]["categoryCodeDesc"],
            "subCategoryList" : [],
            "choose" : false
          });

          
        } else {
          if(categoryDesc.where((element) => element["categoryCode"].toString() == stockAllList[a]["categoryCode"].toString()).toList().length == 0) {
            categoryDesc.add({
              "categoryCode" : stockAllList[a]["categoryCode"],
              "categoryCodeDesc" : stockAllList[a]["categoryCodeDesc"],
              "subCategoryList" : [],
              "choose" : false
            });
          }else {
            // do not need to add CategoryCodeDesc
          }
        }

        if(subCateGoryList.length == 0) {
          subCateGoryList.add({
            "categoryCode" : stockAllList[a]["categoryCode"],
            "subCategoryCode" : stockAllList[a]["subCategoryCode"],
            "subCategoryCodeDesc" : stockAllList[a]["subCategoryCodeDesc"],
            "choose" : false
          });
        } else {
          if(subCateGoryList.where((element) => element["subCategoryCode"] == stockAllList[a]["subCategoryCode"]).toList().length == 0) {
            subCateGoryList.add({
              "categoryCode" : stockAllList[a]["categoryCode"],
              "subCategoryCode" : stockAllList[a]["subCategoryCode"],
              "subCategoryCodeDesc" : stockAllList[a]["subCategoryCodeDesc"],
              "choose" : false
            });
          }
        }

        
        for (var b = 0; b < stockAllList[a]["details"].length; b++) {
          orderStock.add({
            "categoryCode" : stockAllList[a]["categoryCode"],
            "categoryCodeDesc" : stockAllList[a]["categoryCodeDesc"],
            "subCategoryCode" : stockAllList[a]["subCategoryCode"],
            "subCategoryCodeDesc" : stockAllList[a]["subCategoryCodeDesc"],
            "packSizeDescription" : stockAllList[a]["packSizeDescription"],
            "stockSyskey": stockAllList[a]["syskey"],
            "image": stockAllList[a]["img"],
            "brandOwnerSyskey": stockAllList[a]["brandOwnerSyskey"],
            "brandOwnerName": stockAllList[a]["brandOwnerName"],
            "stockCode": stockAllList[a]["code"],
            "stockName": stockAllList[a]["desc"],
            "wareHouseSyskey": stockAllList[a]["whSyskey"],
            "lvlSyskey": stockAllList[a]["details"][b]["u31Syskey"],
            "qty": 1,
            "totalAmount": int.parse(stockAllList[a]["details"][b]["price"].toString().substring(0, stockAllList[a]["details"][b]["price"].toString().lastIndexOf("."))),
            "check": false,
          });

        }

        
      }

      

      for(var i = 0; i < categoryDesc.length; i++) {
        categoryDesc[i]["subCategoryList"] = subCateGoryList.where((element) => element["categoryCode"].toString() == categoryDesc[i]["categoryCode"].toString()).toList().toSet().toList();

        print(categoryDesc[i]["subCategoryList"]);
        if(categoryDesc[i]["subCategoryList"].length != 0) {
          categoryDesc[i]["subCategoryList"][0]["choose"] = true;
        }
        
      }

      stockList = orderStock;
      originalList = widget.stockList1;
      newList = widget.stockList1;
      print("6");

      for (var v = 0; v < newList.length; v++) {
        for (var j = 0; j < newList[v]["stockData"].length; j++) {
          originalQty.add({
            "stockCode": "${newList[v]["stockData"][j]["stockCode"]}",
            "qty": newList[v]["stockData"][j]["qty"]
          });
        }
      }

      print("7");
    });
  }

  void onChanged(String value) {
    setState(() {
      if (value == null || value == '') {
        searchList = stockList;
      } else {
        List tempoList = stockList;
        searchList = [];
        setState(() {
          searchList = tempoList
              .where((element) =>
                  element["stockName"]
                      .toString()
                      .toLowerCase()
                      .contains(value.toString().toLowerCase()) ||
                  element["stockCode"]
                      .toString()
                      .toLowerCase()
                      .contains(value.toString().toLowerCase()))
              .toList();
        });

        print(searchList);

        allSearchList = searchList;

        for (var i = 0; i < searchList.length; i++) {
          stockList.add({
            "categoryCode" : searchList[i]["categoryCode"],
            "categoryCodeDesc" : searchList[i]["categoryCodeDesc"],
            "subCategoryCode" : searchList[i]["subCategoryCode"],
            "subCategoryCodeDesc" : searchList[i]["subCategoryCodeDesc"],
            "packSizeDescription" : searchList[i]["packSizeDescription"],
            "stockSyskey": searchList[i]["syskey"],
            "image": searchList[i]["img"],
            "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
            "brandOwnerName": searchList[i]["brandOwnerName"],
            "stockCode": searchList[i]["code"],
            "stockName": searchList[i]["desc"],
            "wareHouseSyskey": searchList[i]["whSyskey"],
            "qty": int.parse(searchList[i]["qty"].toString().substring(
                0, searchList[i]["qty"].toString().lastIndexOf("."))),
            "totalAmount": int.parse(searchList[i]["price"]
                .toString()
                .substring(
                    0, searchList[i]["price"].toString().lastIndexOf("."))),
            "check": "${searchList[i]["check"]}",
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getReturnProducts();
    // getList();
    setState(() {
      if(widget.stockList1.where((element) => element["stockData"].length == 0).toList().length == widget.stockList1.length) {
        widget.stockList1 = [];
      }
      stockList = [];
      // newList = [];
      originalQty = [];
      newList = widget.stockList1;
      originalList = widget.stockList1;
      print("Original List == >  " + widget.stockList1.toString());
      
    });
  }

  NumberPicker integerNumberPicker;

  Future _showIntDialog(var currentPrice) async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 99999,
          step: 1,
          initialIntegerValue: currentPrice,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          currentPrice = value;
        });
        // integerNumberPicker.animateInt(currentPrice);
      }
    });
    return currentPrice;
  }

  
  void toOrderDetailBack() {
    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderDetailData(
                              shopName: widget.shopName,
                              shopNameMm: widget.shopNameMm,
                              address: widget.address,
                              shopSyskey: widget.shopSyskey,
                              orderDate: widget.date,
                              deliveryDate: date,
                              mcdCheck: widget.mcdCheck,
                              userType: widget.userType,
                              ownerName: ownerName,
                              phone: widget.phone,
                              back: "WithBackButton",
                              stockList: originalList,
                              returnList: widget.returnList,
                              orderDeleted: widget.orderDeleted,
                              returnDeleted: widget.returnDeleted,
                              isSaleOrderLessRouteShop:
                                  widget.isSaleOrderLessRouteShop,
                            )));
  }


  int chooseCategory = 0;
  @override
  Widget build(BuildContext context) {

    newList = widget.stockList1;
    originalList = widget.stockList1;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("${widget.title}"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                datetime();

                List checkList = orderStock.where((element) => element["check"] == true).toList();

                if (getdeliverylist == [] || getdeliverylist.length == 0) {
                  for (var a = 0; a < stockByBrandDel.length; a++) {
                    for (var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {
                      for (var c = 0; c < checkList.length; c++) {
                        if (stockByBrandDel[a]["stockData"][b]["stockCode"] == checkList[c]["stockCode"]) {
                          stockByBrandDel[a]["stockData"][b]["qty"] = stockByBrandDel[a]["stockData"][b]["qty"] - checkList[c]["qty"];
                        }

                        if(c == checkList.length-1) {
                          if(b == stockByBrandDel[a]["stockData"].length-1) {
                            if(a == stockByBrandDel.length-1) {
                              stockByBrandDel[a]["stockData"].removeWhere((element) => element["qty"] == 0 || element["qty"] < 0);
                              
                            }
                          }
                        }
                      }
                    }

                    
                  }
                } else {
                  print("CheckList ==> ${checkList.length}");
                  for (var c = 0; c < checkList.length; c++) {
                  for (var a = 0; a < getdeliverylist.length; a++) {
                    if(getdeliverylist[a]["brandOwnerSyskey"] == checkList[c]["brandOwnerSyskey"]) {
                      for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
                      
                        if (getdeliverylist[a]["stockData"][b]["stockCode"] == checkList[c]["stockCode"]) {
                          getdeliverylist[a]["stockData"][b]["qty"] = getdeliverylist[a]["stockData"][b]["qty"] - checkList[c]["qty"];
                        }
                        if(b == getdeliverylist[a]["stockData"].length-1) {
                          if(a == getdeliverylist.length-1) {
                            if(c == checkList.length-1) {
                              print(getdeliverylist[a]["stockData"][b]);
                              getdeliverylist[a]["stockData"].removeWhere((element) => element["qty"] <= 0 || element["qty"] < 0);
                              // toOrderDetailBack();
                            }
                          }
                        }
                        
                      }
                    }
                    
                    }
                  }
                }

                toOrderDetailBack();
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (searchVisible == false) {
                  setState(() {
                    searchVisible = true;
                  });
                } else if (searchVisible == true) {
                  setState(() {
                    searchVisible = false;
                    searchCtrl.text = "";
                  });
                }
              },
            ),
            SizedBox(width: 15)
          ],
        ),
        body: Column(
          children: <Widget>[
            Visibility(
              visible: searchVisible,
              child: Container(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    controller: searchCtrl,
                    cursorColor: Color(0xffe53935),
                    decoration: InputDecoration(
                      labelText: "Search",
                      labelStyle:
                          TextStyle(color: Colors.grey, fontSize: 15.0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffe53935)),
                      ),
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
            disItemList == false ?
            Padding(
              padding: searchVisible ? const EdgeInsets.only(left: 10, right: 10, top: 0) : const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryDesc.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              categoryDesc.where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                              
                              categoryDesc[i]["choose"] = true;

                              chooseCategory = i;

                              if(categoryDesc[i]["categoryCode"].toString() == "All") {
                                
                                if(searchCtrl.text.length == 0 || searchCtrl.text == '' || searchCtrl.text == null) {
                                  stockList = orderStock;
                                } else {
                                  searchList = allSearchList;
                                }
                              } else {
                                categoryDesc[chooseCategory]["subCategoryList"].where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                                categoryDesc[i]["subCategoryList"][0]["choose"] = true;
                                
                                if(searchCtrl.text.length == 0 || searchCtrl.text == '' || searchCtrl.text == null) {
                                  stockList = orderStock.where((element) => element["categoryCode"].toString() == categoryDesc[i]["categoryCode"].toString()).toList();
                                } else {
                                  searchList = allSearchList.where((element) => element["categoryCode"].toString() == categoryDesc[i]["categoryCode"].toString()).toList();
                                }
                              }
                            });
                          },
                          child: Card(
                            color: categoryDesc[i]["choose"] ? Color(0xffe53935) : Colors.red[100],
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Center(child: Text("${categoryDesc[i]["categoryCodeDesc"]}", style: TextStyle(fontSize: 15, color: categoryDesc[i]["choose"] ? Colors.white : Colors.black),)),
                              ),
                            ),
                          ),
                        );
                    }),
                  ),
                  Visibility(
                    visible: categoryDesc[chooseCategory]["subCategoryList"].length == 0 ? false : true,
                    child: Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryDesc[chooseCategory]["subCategoryList"].length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                categoryDesc[chooseCategory]["subCategoryList"].where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                              
                                categoryDesc[chooseCategory]["subCategoryList"][i]["choose"] = true;

                                if(searchCtrl.text.length == 0 || searchCtrl.text == '' || searchCtrl.text == null) {
                                  stockList = orderStock.where((element) => element["subCategoryCode"].toString() == categoryDesc[chooseCategory]["subCategoryList"][i]["subCategoryCode"].toString() && 
                                              element["categoryCode"].toString() == categoryDesc[chooseCategory]["subCategoryList"][i]["categoryCode"].toString()).toList();

                                  print(stockList);
                                } else {
                                  searchList = allSearchList.where((element) => element["subCategoryCode"].toString() == categoryDesc[chooseCategory]["subCategoryList"][i]["subCategoryCode"].toString() && 
                                              element["categoryCode"].toString() == categoryDesc[chooseCategory]["subCategoryList"][i]["categoryCode"].toString()).toList();
                                }
                              });
                            },
                            child: Card(
                              color: categoryDesc[chooseCategory]["subCategoryList"][i]["choose"] ? Color(0xffe53935) : Colors.red[100],
                              child: Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Center(child: Text("${categoryDesc[chooseCategory]["subCategoryList"][i]["subCategoryCodeDesc"]}", style: TextStyle(fontSize: 15, color: categoryDesc[chooseCategory]["subCategoryList"][i]["choose"] ? Colors.white : Colors.black),)),
                                ),
                              ),
                            ),
                          );
                      }),
                    ),
                  ),
                ],
              ),
            ) :
            Padding(
              padding: searchVisible ? const EdgeInsets.only(left: 10, right: 10, top: 0) : const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: disCategoryList.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          disCategoryList.where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                          disCategoryList[i]["choose"] = true;

                          if(searchCtrl.text.length == 0 || searchCtrl.text == '' || searchCtrl.text == null) {
                            stockList = orderStock.where((element) => disCategoryList[i]["list"].where((value) => value["promoItemSyskey"].toString() == element["stockSyskey"].toString()).toList().length != 0).toList();
                          }else {
                            searchList = allSearchList.where((element) => disCategoryList[i]["list"].where((value) => value["promoItemSyskey"].toString() == element["stockSyskey"].toString()).toList().length != 0).toList();
                          }

                          
                        });
                      },
                      child: Card(
                        color: disCategoryList[i]["choose"] ? Color(0xffe53935) : Colors.red[100],
                        child: Container(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Center(child: Text("${disCategoryList[i]["categoryCodeDesc"]}", style: TextStyle(fontSize: 15, color: disCategoryList[i]["choose"] ? Colors.white : Colors.black),)),
                          ),
                        ),
                      ),
                    );
                }),
              ),
            ),
            Visibility(
              visible: disCategoryList.length == 0 ? false : true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () async {
                    List disItemList = [];
                    stockList = orderStock;
                    // categoryDesc[chooseCategory]["subCategoryList"].where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                    // categoryDesc[chooseCategory]["subCategoryList"][0]["choose"] = false;
                    chooseCategory = 0;
                    categoryDesc.where((element) => element["choose"] == true).toList()[0]["choose"] = false;
                    categoryDesc[0]["choose"] = true;
                    for(var a = 0; a < disCategoryList.length; a++) {
                      disItemList.add({
                        "categoryCode" : disCategoryList[a]["categoryCode"],
                        "categoryCodeDesc" : disCategoryList[a]["categoryCodeDesc"],
                        "hdrSyskey" : disCategoryList[a]["hdrSyskey"],
                        "choose" : false,
                        "StockList" : disCategoryList[a]["list"],
                      });
                    }
                    for(var a = 0; a < disItemList.length; a++) {
                      List categoryStockList = [];
                      for(var b = 0; b < disItemList[a]["StockList"].length; b++) {
                        if(stockList.where((element) => element["stockSyskey"] == disItemList[a]["StockList"][b]["promoItemSyskey"]).toList().length != 0) {
                          if(categoryStockList.length == 0) {
                            print(categoryStockList.length);
                            print(stockList);
                            categoryStockList.add(stockList.where((element) => element["stockSyskey"] == disItemList[a]["StockList"][b]["promoItemSyskey"]).toList()[0]);
                          } else {
                            print("Seven");
                            if(categoryStockList.where((element) => element["stockSyskey"] == disItemList[a]["StockList"][b]["promoItemSyskey"]).toList().length == 0) {
                              print("Eight");
                              categoryStockList.add(stockList.where((element) => element["stockSyskey"] == disItemList[a]["StockList"][b]["promoItemSyskey"]).toList()[0]);
                            }
                          }
                        }
                        

                        print("Eleven");
                        

                      }

                      print("Nine");

                      disItemList[a]["StockList"] = categoryStockList;

                    }
                    print("new List ==> $newList");
                    var discountStockList = await Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountStock(disItemList: disItemList)));

                    setState(() {
                      discountStockList = stockList;
                      print("Ten");
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey[300])
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Discount Items"),
                          Icon(Icons.arrow_forward, color: Colors.grey[600],)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: searchVisible
                ? categoryDesc[chooseCategory]["subCategoryList"].length == 0 ? disCategoryList.length == 0 ? MediaQuery.of(context).size.height - 267 : MediaQuery.of(context).size.height - 315 : disCategoryList.length == 0 ? MediaQuery.of(context).size.height - 317 : MediaQuery.of(context).size.height - 365
                : categoryDesc[chooseCategory]["subCategoryList"].length == 0 ? disCategoryList.length == 0 ? MediaQuery.of(context).size.height - 197 : MediaQuery.of(context).size.height - 245 : disCategoryList.length == 0 ? MediaQuery.of(context).size.height - 247 : MediaQuery.of(context).size.height - 295,
              child: searchCtrl.text.length == 0 ||
                    searchCtrl.text == '' ||
                    searchCtrl.text == null
                ? ListView.builder(
                    itemCount: stockList.length,
                    itemBuilder: (context, i) {
                      return Stack(
                        children: <Widget>[
                          Card(
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  leading: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 64,
                                        maxHeight: 80,
                                      ),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShowImage(
                                                              image: Image.asset(
                                                                  "assets/coca.png"))));
                                            },
                                            child: Image.asset(
                                                "assets/coca.png",
                                                fit: BoxFit.cover),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ShowImage(
                                                          image: CachedNetworkImage(
                                                              imageUrl:
                                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockList[i]["image"]}"))));
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${stockList[i]["image"]}",
                                            ),
                                          ),
                                        ],
                                      )),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Checkbox(
                                              activeColor: Color(0xffe53935),
                                              value: stockList[i]["check"],
                                              onChanged: (val) async {
                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                print(stockList[i]["stockSyskey"]);
                                                setState(() {
                                                  stockList[i]["check"] = val;

                                                  var check = "";

                                                  if (stockList[i]["check"] == true) {
                                                    List sameBrandownerKey = [];
                                                    // print("StockList length ==> ${widget.stockList1.length}");
                                                    if (widget.stockList1.length == 0 || widget.stockList1 == []) {
                                                      print("no stock to add");
                                                      newList.add({
                                                        "brandOwnerName": stockList[i]["brandOwnerName"],
                                                        "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                        "visible": true,
                                                        "stockData": [
                                                          {
                                                            "syskey": "0",
                                                            "recordStatus": 1,
                                                            "stockCode": "${stockList[i]["stockCode"]}",
                                                            "stockName": "${stockList[i]["stockName"]}",
                                                            "saleCurrCode": "MMK",
                                                            "stockSyskey" : "${stockList[i]["stockSyskey"]}",
                                                            "n1": "0",
                                                            "wareHouseSyskey": "${stockList[i]["wareHouseSyskey"]}",
                                                            "binSyskey": "0",
                                                            "qty": double.parse("${stockList[i]["qty"]}.0"),
                                                            "lvlSyskey": "${stockList[i]["lvlSyskey"]}",
                                                            "lvlQty": 1.0,
                                                            "n8": 1.0,
                                                            "n9": 0.0,
                                                            "taxAmount": 0.0,
                                                            "totalAmount": double.parse("${stockList[i]["qty"] * stockList[i]["totalAmount"]}.0"),
                                                            "price": double.parse("${stockList[i]["totalAmount"]}.0"),
                                                            "normalPrice" : double.parse("${stockList[i]["totalAmount"]}.0"),
                                                            "taxCodeSK": "0",
                                                            "isTaxInclusice": 0,
                                                            "taxPercent": 0.0,
                                                            "discountAmount": 0.0,
                                                            "discountPercent": 0.0,
                                                            "promotionStockList" : [],
                                                            "brandOwnerSyskey": "${stockList[i]["brandOwnerSyskey"]}",
                                                            "stockType": "NORMAL"
                                                          }
                                                        ]
                                                      });
                                                      print(getdeliverylist);
                                                      print(stockByBrandDel);
                                                      if (getdeliverylist.length != 0) {
                                                        var checkValue = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == stockList[i]["brandOwnerSyskey"]){
                                                            checkValue = 1;
                                                            var r = {
                                                              "stockCode": stockList[i]["stockCode"],
                                                              "stockName": stockList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : stockList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": stockList[i]["qty"],
                                                              "lvlSyskey": stockList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": stockList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(checkValue == 0){
                                                            getdeliverylist.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": stockList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": stockList[i]["stockCode"],
                                                              "stockName": stockList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : stockList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": stockList[i]["qty"],
                                                              "lvlSyskey": stockList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": stockList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                        }
                                                        print("add to deliveryList");
                                                       
                                                        for(var a = 0; a < getdeliverylist.length;a++){
                                                          print("add to deliveryList22222" + getdeliverylist[a].toString());
                                                        }
                                                        // print("add to deliveryList22222$getdeliverylist");
                                                      } else {
                                                        print(
                                                            "add to delivery list stockbybrandDelivery");
                                                        stockByBrandDel.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": stockList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": stockList[i]["stockCode"],
                                                              "stockName": stockList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : stockList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": stockList[i]["qty"],
                                                              "lvlSyskey": stockList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": stockList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                      }
                                                    } else {
                                                      sameBrandownerKey = newList.where((element) => element["brandOwnerSyskey"].toString() == stockList[i]["brandOwnerSyskey"].toString()).toList();

                                                      // print(sameBrandownerKey);
                                                      if (sameBrandownerKey.toString() == "[]") {
                                                        print("add new brandname");
                                                        newList.add({
                                                          "brandOwnerName": stockList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                          "visible": true,
                                                          "stockData": [
                                                            {
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${stockList[i]["stockCode"]}",
                                                              "stockName": "${stockList[i]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${stockList[i]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${stockList[i]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${stockList[i]["qty"]}.0"),
                                                              "lvlSyskey": "${stockList[i]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${stockList[i]["qty"] * stockList[i]["totalAmount"]}.0"),
                                                              "price": double.parse("${stockList[i]["totalAmount"]}.0"),
                                                              "normalPrice" : double.parse("${stockList[i]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${stockList[i]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL"
                                                            }
                                                          ]
                                                        });

                                                        if (getdeliverylist.length.toString() != "0") {
                                                          var checkValue = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == stockList[i]["brandOwnerSyskey"]){
                                                            checkValue = 1;
                                                            var r = {
                                                              "stockCode": stockList[i]["stockCode"],
                                                              "stockName": stockList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : stockList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": stockList[i]["qty"],
                                                              "lvlSyskey": stockList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": stockList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(checkValue == 0){
                                                            getdeliverylist.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": stockList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": stockList[i]["stockCode"],
                                                              "stockName": stockList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : stockList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": stockList[i]["qty"],
                                                              "lvlSyskey": stockList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": stockList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                        }
                                                        } else {
                                                          stockByBrandDel.add({
                                                            "syskey": "0",
                                                            "autokey": "0",
                                                            "createddate": date,
                                                            "modifieddate": date,
                                                            "userid": preferences.getString("userId"),
                                                            "username": preferences.getString("userName"),
                                                            "saveStatus": 1,
                                                            "recordStatus": 1,
                                                            "syncStatus": 0,
                                                            "syncBatch": "",
                                                            "transType": "DeliveryOrder",
                                                            "docummentDate": date,
                                                            "brandOwnerCode": "001",
                                                            "brandOwnerName": stockList[i]["brandOwnerName"],
                                                            "brandOwnerSyskey": stockList[i]["brandOwnerSyskey"],
                                                            "orderSyskey": "0",
                                                            "totalamount": 0.0,
                                                            "orderTotalAmount": 0.0,
                                                            "returnTotalAmount": 0.0,
                                                            "discountamount": 0.0,
                                                            "taxSyskey": "0",
                                                            "taxPercent": 0.0,
                                                            "taxAmount": 0.0,
                                                            "orderDiscountPercent": 0.0,
                                                            "returnDiscountPercent": 0.0,
                                                            "payment1": 0.0,
                                                            "payment2": 0.0,
                                                            "cashamount": 0.0,
                                                            "creditAmount": 0.0,
                                                            "promotionList" : [],
                                                            "stockData": [
                                                              {
                                                                "stockCode": stockList[i]["stockCode"],
                                                                "stockName": stockList[i]["stockName"],
                                                                "recordStatus": 1,
                                                                "saleCurrCode": "MMK",
                                                                "stockSyskey" : stockList[i]["stockSyskey"],
                                                                "n1": "0",
                                                                "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                                "binSyskey": "0",
                                                                "qty": stockList[i]["qty"],
                                                                "lvlSyskey": stockList[i]["lvlSyskey"],
                                                                "lvlQty": 0.0,
                                                                "n8": 0.0,
                                                                "price": stockList[i]["totalAmount"].toDouble(),
                                                                "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                                "n9": 0.0,
                                                                "taxAmount": 0.0,
                                                                "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                                "taxCodeSK": "0",
                                                                "isTaxInclusice": 0,
                                                                "taxPercent": 0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "discountStock": false,
                                                                "promotionStockList" : []
                                                              }
                                                            ],
                                                            "stockReturnData": []
                                                          });
                                                          // print(stockByBrandDel);

                                                        }
                                                      } else {
                                                        
                                                        print("add stock to the same brandname");
                                                        for (var x = 0; x < sameBrandownerKey.length; x++) {
                                                          
                                                          if (sameBrandownerKey[x]["stockData"].length == 0) {
                                                            print("same brandname but no stock");
                                                            sameBrandownerKey[x]["stockData"].add({
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${stockList[i]["stockCode"]}",
                                                              "stockName": "${stockList[i]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${stockList[i]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${stockList[i]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${stockList[i]["qty"]}.0"),
                                                              "lvlSyskey": "${stockList[i]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${stockList[i]["qty"] * stockList[i]["totalAmount"]}.0"),
                                                              "price": double.parse("${stockList[i]["totalAmount"]}.0"),
                                                              "normalPrice" : double.parse("${stockList[i]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${stockList[i]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL"
                                                            });

                                                            if(getdeliverylist.length == 0) {
                                                            for (var j = 0; j < stockByBrandDel.length; j++) {
                                                              if (stockByBrandDel[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                stockByBrandDel[j]["stockData"].add({
                                                                  "stockCode": stockList[i]["stockCode"],
                                                                  "stockName": stockList[i]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : stockList[i]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty":
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                  "lvlSyskey":
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price": stockList[i]["totalAmount"].toDouble(),
                                                                  "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            } else {
                                                            for (var j = 0; j < getdeliverylist.length; j++) {
                                                              if (getdeliverylist[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                getdeliverylist[j]["stockData"].add({
                                                                  "stockCode": stockList[i]["stockCode"],
                                                                  "stockName": stockList[i]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : stockList[i]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": stockList[i]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty":
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                  "lvlSyskey":
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price":
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                  "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            }
                                                            
                                                          } else {
                                                            if (sameBrandownerKey[
                                                                            x][
                                                                        "stockData"]
                                                                    .where((element) =>
                                                                        element[
                                                                            "stockCode"] ==
                                                                        stockList[i]
                                                                            [
                                                                            "stockCode"])
                                                                    .toList()
                                                                    .toString() ==
                                                                "[]") {
                                                              check = "true";
                                                            } else {
                                                              check = "";
                                                            }
                                                            if (check ==
                                                                "true") {
                                                              print(
                                                                  "add new stock to the same brandname");
                                                              for(var p = 0; p < newList.length; p++) {
                                                                if(newList[p]["brandOwnerSyskey"] == stockList[i]["brandOwnerSyskey"]) {
                                                                  print("3newList ==> ${newList[0]["stockData"]}");
                                                                  newList[p]["stockData"].add({
                                                                "syskey": "0",
                                                                "recordStatus":
                                                                    1,
                                                                "stockCode":
                                                                    "${stockList[i]["stockCode"]}",
                                                                "stockName":
                                                                    "${stockList[i]["stockName"]}",
                                                                "saleCurrCode":
                                                                    "MMK",
                                                                "stockSyskey" : "${stockList[i]["stockSyskey"]}",
                                                                "n1": "0",
                                                                "wareHouseSyskey":
                                                                    "${stockList[i]["wareHouseSyskey"]}",
                                                                "binSyskey":
                                                                    "0",
                                                                "qty": double.parse(
                                                                    "${stockList[i]["qty"]}.0"),
                                                                "lvlSyskey":
                                                                    "${stockList[i]["lvlSyskey"]}",
                                                                "lvlQty": 1.0,
                                                                "n8": 1.0,
                                                                "n9": 0.0,
                                                                "taxAmount":
                                                                    0.0,
                                                                "totalAmount":
                                                                    double.parse(
                                                                        "${stockList[i]["totalAmount"] * stockList[i]["qty"]}.0"),
                                                                "price": double.parse("${stockList[i]["totalAmount"]}.0"),
                                                                "normalPrice" : double.parse("${stockList[i]["totalAmount"]}.0"),
                                                                "taxCodeSK":
                                                                    "0",
                                                                "isTaxInclusice":
                                                                    0,
                                                                "taxPercent":
                                                                    0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "promotionStockList" : [],
                                                                "brandOwnerSyskey":
                                                                    "${stockList[i]["brandOwnerSyskey"]}",
                                                                "stockType":
                                                                    "NORMAL"
                                                              });
                                                              if (getdeliverylist
                                                                      .toString() !=
                                                                  "[]") {
                                                                for (var j = 0;
                                                                    j <
                                                                        getdeliverylist
                                                                            .length;
                                                                    j++) {
                                                                  if (getdeliverylist[j]["brandOwnerSyskey"].toString() ==
                                                                      stockList[i]["brandOwnerSyskey"].toString()) {
                                                                    
                                                                    getdeliverylist[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          stockList[i]
                                                                              [
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          stockList[i]
                                                                              [
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : stockList[i]
                                                                              [
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          stockList[i]
                                                                              [
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": stockList[i]["qty"],
                                                                      "lvlSyskey":
                                                                          stockList[i]
                                                                              [
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": stockList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                      "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount":
                                                                          0.0,
                                                                      "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          getdeliverylist[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(getdeliverylist[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }

                                                                  if(newList[p]["stockData"].where((element) => element["stockSyskey"] == stockList[i]["stockSyskey"]).toList().length != 0) {
                                                                    newList[p]["stockData"].removeWhere((element) => element["qty"].runtimeType.toString() == "int");
                                                                  }
                                                                }
                                                              } else {
                                                                for (var j = 0;
                                                                    j <
                                                                        stockByBrandDel
                                                                            .length;
                                                                    j++) {
                                                                  if (stockByBrandDel[j]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString() ==
                                                                      sameBrandownerKey[x]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString()) {
                                                                    stockByBrandDel[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          stockList[i]
                                                                              [
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          stockList[i]
                                                                              [
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : stockList[i]
                                                                              [
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          stockList[i]
                                                                              [
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": stockList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                      "lvlSyskey":
                                                                          stockList[i]
                                                                              [
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": stockList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                      "normalPrice" : stockList[i]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount":
                                                                          0.0,
                                                                      "totalAmount": stockList[i]["qty"] * stockList[i]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          stockByBrandDel[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(stockByBrandDel[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }
                                                                }
                                                              }

                                                              

                                                                }

                                                              }

                                                              
                                                            } else if (check ==
                                                                "") {
                                                              print("add stockQty with same stock and same brandname");
                                                              for (var n = 0; n < sameBrandownerKey[x]["stockData"].length; n++) {
                                                                if (sameBrandownerKey[x]["stockData"][n]["stockSyskey"] == stockList[i]["stockSyskey"]) {
                                                                  sameBrandownerKey[x]["stockData"][n]["qty"] =
                                                                      double.parse(
                                                                          "${sameBrandownerKey[x]["stockData"][n]["qty"] + stockList[i]["qty"]}");

                                                                  print(sameBrandownerKey[x]["stockData"][n]["qty"]);
                                                                  
                                                                  // sameBrandownerKey[x]["stockData"][n]["totalAmount"] = sameBrandownerKey[x]["stockData"][n]["price"] * sameBrandownerKey[x]["stockData"][n]["qty"];

                                                                  if(discountStockList.contains(stockList[i]["stockSyskey"]) == true) {
                                                                    
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param = jsonEncode(
                                                                        {
	                                                                        "itemSyskey": "${stockList[i]["stockSyskey"]}",
	                                                                        "itemDesc": "${stockList[i]["stockName"]}",
	                                                                        "itemAmount": stockList[i]["totalAmount"].toInt(),
	                                                                        "itemTotalAmount": sameBrandownerKey[x]["stockData"][n]["qty"].toInt() * stockList[i]["totalAmount"].toInt(),
	                                                                        "itemQty": sameBrandownerKey[x]["stockData"][n]["qty"].toInt(),
	                                                                        "shopSyskey": "${val[0]["shopsyskey"]}"
                                                                        }
                                                                      );

                                                                      getVolDisCalculation(param, sameBrandownerKey[x]["stockData"]).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          // if(newStockList.length != 0) {
                                                                          //   sameBrandownerKey[x]["stockData"] = newStockList;
                                                                          //   newList[x]["stockData"] = newStockList;

                                                                          //   print(newList[x]["stockData"]);
                                                                          // }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
                                                                      });
                                                                    });
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  } else if (stockList[i]["check"] == false) {
                                                    for (var x = 0; x < newList.length; x++) {
                                                      if (newList[x]["brandOwnerSyskey"] == stockList[i]["brandOwnerSyskey"]) {
                                                        for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                          if (newList[x]["stockData"][y]["stockSyskey"] == stockList[i]["stockSyskey"]) {
                                                            print("Stock Qty ==> " +stockList[i]["qty"].toString());
                                                            print("New List Qty ==> " + newList[x]["stockData"][y]["qty"].toString());
                                                            print(stockList[i]["qty"].runtimeType);
                                                            print(stockList[i]["qty"].runtimeType);
                                                            newList[x]["stockData"][y]["qty"] = double.parse("${newList[x]["stockData"][y]["qty"] - stockList[i]["qty"]}");

                                                            print("New List Qty ==> " + newList[x]["stockData"][y]["qty"].toString());

                                                            if(discountStockList.contains(stockList[i]["stockSyskey"]) == true) {
                                                              if(newList[x]["stockData"][y]["qty"].toString() != "0.0") {
                                                                 ShopsbyUser helperShopsbyUser = ShopsbyUser();
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param = jsonEncode(
                                                                        {
	                                                                        "itemSyskey": "${stockList[i]["stockSyskey"]}",
	                                                                        "itemDesc": "${stockList[i]["stockName"]}",
	                                                                        "itemAmount": newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                        "itemTotalAmount": newList[x]["stockData"][y]["qty"].toInt() * newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                        "itemQty": newList[x]["stockData"][y]["qty"].toInt(),
	                                                                        "shopSyskey": "${val[0]["shopsyskey"]}"
                                                                        }
                                                                      );

                                                                      getVolDisCalculation(param, newList[x]["stockData"]).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          // if(newStockList.length != 0) {
                                                                          //   stockList = newStockList;
                                                                          // }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
                                                                      });
                                                                    });
                                                              }
                                                                   
                                                                  }

                                                            if (getdeliverylist == [] || getdeliverylist.length == 0) {
                                                              for (var a = 0; a < stockByBrandDel.length; a++) {
                                                                for (var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {
                                                                  if (stockByBrandDel[a]["stockData"][b]["stockCode"] == stockList[i]["stockCode"]) {
                                                                    stockByBrandDel[a]["stockData"][b]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                  }
                                                                }

                                                                stockByBrandDel[a]["stockData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                              }
                                                            } else {
                                                              for (var a = 0; a < getdeliverylist.length; a++) {
                                                                for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
                                                                    if (getdeliverylist[a]["stockData"][b]["stockCode"] == stockList[i]["stockCode"]) {
                                                                      getdeliverylist[a]["stockData"][b]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                    }

                                                                  print("getdeliverylist[a]['stockData'] ==> " +getdeliverylist[a]["stockData"][b].toString());
                                                                }

                                                                getdeliverylist[a]["stockData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                              }
                                                            }

                                                            // print(newList[x]["stockData"]);
                                                            if(newList[x]["stockData"].length != 0) {
                                                              if (newList[x]["stockData"][y]["qty"].toString() == "0.0") {
                                                                newList[x]["stockData"].removeWhere((element) => element["qty"].toString() == "0.0" || element["qty"] < 0);

                                                              // newList.removeWhere((element) => element["stockData"].length == 0);

                                                              // stockData.removeWhere((element) => element["qty"] == 0.0);
                                                              }
                                                            }
                                                            
                                                            
                                                            // for (var v = 0; v < stockData.length; v++) {
                                                            //   if (stockData[v]["stockCode"] == stockList[i]["stockCode"]) {
                                                            //     stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                            //   }
                                                            // }

                                                            
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                });
                                              }),
                                          SizedBox(width: 10),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  171,
                                              height: 40,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "${stockList[i]["stockName"]}",
                                                    // overflow:
                                                    //     TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                              ))
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (stockList[i][
                                                                        "qty"] ==
                                                                    1 ||
                                                                stockList[i][
                                                                        "qty"] <
                                                                    1) {
                                                            } else {
                                                              setState(() {
                                                                stockList[i]
                                                                    ["qty"]--;

                                                              });

                                                              if (stockList[i][
                                                                      "check"] ==
                                                                  true) {
                                                                for (var x = 0;
                                                                    x <
                                                                        newList
                                                                            .length;
                                                                    x++) {
                                                                  if (newList[x]
                                                                          [
                                                                          "brandOwnerSyskey"] ==
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "brandOwnerSyskey"]) {
                                                                    for (var y =
                                                                            0;
                                                                        y < newList[x]["stockData"].length;
                                                                        y++) {
                                                                      if (newList[x]["stockData"][y]
                                                                              [
                                                                              "stockCode"] ==
                                                                          stockList[i]
                                                                              [
                                                                              "stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]
                                                                                ["qty"] -
                                                                            1;
                                                                        newList[x]["stockData"][y]["totalAmount"] = stockList[i]["totalAmount"].toDouble() * stockList[i]["qty"];
                                                                        for (var v =
                                                                                0;
                                                                            v < stockData.length;
                                                                            v++) {
                                                                          if (stockData[v]["stockCode"] ==
                                                                              stockList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] =
                                                                                newList[x]["stockData"][y]["qty"];
                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] *
                                                                                newList[x]["stockData"][y]["totalAmount"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                            }
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          const IconData(0xe15b,
                                                              fontFamily:
                                                                  'MaterialIcons'),
                                                          color: Colors.white,
                                                          size: 19,
                                                        )),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffe53935),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showIntDialog(
                                                                stockList[i]
                                                                    ["qty"])
                                                            .then((value) {
                                                          setState(() {
                                                            stockList[i]
                                                                ["qty"] = value;

                                                            if (stockList[i]
                                                                    ["check"] ==
                                                                true) {
                                                              List dropdown =
                                                                  [];

                                                              dropdown = originalQty
                                                                  .where((element) =>
                                                                      element[
                                                                          "stockCode"] ==
                                                                      stockList[
                                                                              i]
                                                                          [
                                                                          "stockCode"])
                                                                  .toList();

                                                              if (dropdown ==
                                                                      [] ||
                                                                  dropdown.length ==
                                                                      0) {
                                                                for (var x = 0;
                                                                    x <
                                                                        newList
                                                                            .length;
                                                                    x++) {
                                                                  for (var y =
                                                                          0;
                                                                      y <
                                                                          newList[x]["stockData"]
                                                                              .length;
                                                                      y++) {
                                                                    if (newList[x]["stockData"][y]
                                                                            [
                                                                            "stockCode"] ==
                                                                        stockList[i]
                                                                            [
                                                                            "stockCode"]) {
                                                                      newList[x]["stockData"][y]
                                                                              [
                                                                              "qty"] =
                                                                          double.parse(
                                                                              "$value");

                                                                      newList[x]["stockData"][y]["totalAmount"] = stockList[i]["totalAmount"].toDouble() * double.parse("$value");

                                                                      // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                      for (var v =
                                                                              0;
                                                                          v < stockData.length;
                                                                          v++) {
                                                                        if (stockData[v]["stockCode"] ==
                                                                            stockList[i]["stockCode"]) {
                                                                          stockData[v]
                                                                              [
                                                                              "qty"] = newList[x]["stockData"]
                                                                                  [y]
                                                                              [
                                                                              "qty"];
                                                                          stockData[v]
                                                                              ["totalAmount"] = newList[x]["stockData"][y]["qty"] * newList[x]["stockData"][y]["totalAmount"];
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              if (dropdown !=
                                                                      [] ||
                                                                  dropdown.length !=
                                                                      0) {
                                                                for (var v = 0;
                                                                    v <
                                                                        dropdown
                                                                            .length;
                                                                    v++) {
                                                                  for (var x =
                                                                          0;
                                                                      x <
                                                                          newList
                                                                              .length;
                                                                      x++) {
                                                                    for (var y =
                                                                            0;
                                                                        y < newList[x]["stockData"].length;
                                                                        y++) {
                                                                      if (newList[x]["stockData"][y]
                                                                              [
                                                                              "stockCode"] ==
                                                                          dropdown[v]
                                                                              [
                                                                              "stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] =
                                                                            double.parse("${value + dropdown[v]["qty"]}");

                                                                        newList[x]["stockData"][y]["totalAmount"] = stockList[i]["totalAmount"].toDouble() * stockList[i]["qty"];

                                                                        // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                        for (var v =
                                                                                0;
                                                                            v < stockData.length;
                                                                            v++) {
                                                                          if (stockData[v]["stockCode"] ==
                                                                              stockList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] =
                                                                                newList[x]["stockData"][y]["qty"];

                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"] *
                                                                                newList[x]["stockData"][y]["qty"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                            } else {}
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        child: Center(
                                                            child: Text(
                                                                "${stockList[i]["qty"]}")),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            bottom: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            left: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                            right: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        height: 27,
                                                        width: 45,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (stockList[i]
                                                                  ["qty"] >=
                                                              99999) {
                                                          } else {
                                                            setState(() {
                                                              stockList[i]["qty"]++;

                                                              if (stockList[i][
                                                                      "check"] ==
                                                                  true) {
                                                                for (var x = 0; x < newList.length; x++) {
                                                                  if (newList[x]["brandOwnerSyskey"] == stockList[i]["brandOwnerSyskey"]) {
                                                                    for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                      if (newList[x]["stockData"][y]["stockCode"] == stockList[i]["stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] + 1;

                                                                        newList[x]["stockData"][y]["totalAmount"] = stockList[i]["totalAmount"].toDouble() * stockList[i]["qty"];

                                                                        for (var v = 0; v < stockData.length; v++) {
                                                                          if (stockData[v]["stockCode"] == stockList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"] * newList[x]["stockData"][y]["qty"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                                if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                            });
                                                          }
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                                Icons.add,
                                                                size: 19,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        color:
                                                            Color(0xffe53935),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                    "${stockList[i]["totalAmount"]}"),
                                                SizedBox(width: 40),
                                                Text(
                                                    "${stockList[i]["totalAmount"] * stockList[i]["qty"]}"),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: discountStockList.length == 0
                             ? false : 
                             "${discountStockList.where((element) => element.toString() == stockList[i]["stockSyskey"].toString()).toList().length}" == "0"
                             ? false : true,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    
                                    _handleSubmit(context);
                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                    String headerSyskey = "";
                                    if(disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == stockList[i]["stockSyskey"].toString()).toList().length != 0).toList().length != 0) {
                                      headerSyskey = disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == stockList[i]["stockSyskey"].toString()).toList().length != 0).toList()[0]["hdrSyskey"];

                                      print(headerSyskey);
                                    }

                                    
                                    getSysKey.then((val) {
                                      getPromoItemDetail("${val[0]["shopsyskey"]}", "", stockList[i]["stockSyskey"], stockList[i]["brandOwnerSyskey"]).then((promoDetailVal) {
                                        Navigator.pop(context);
                                        if(promoDetailVal == "success") {
                                          setState(() {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: stockList[i],)));
                                          });
                                        }else {
                                          snackbarmethod("FAIL!");
                                        }
                                      });
                                    });

                                  },
                                  child: Image.asset("assets/discount.png", width: 27,)),
                              ),
                            ),
                          )
                        ],
                      );
                    })
                : ListView.builder(
                    itemCount: searchList.length,
                    itemBuilder: (context, i) {
                      return Stack(
                        children: <Widget>[
                          Card(
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  leading: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 64,
                                        maxHeight: 80,
                                      ),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShowImage(
                                                              image: Image.asset(
                                                                  "assets/coca.png"))));
                                            },
                                            child: Image.asset(
                                                "assets/coca.png",
                                                fit: BoxFit.cover),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ShowImage(
                                                          image: CachedNetworkImage(
                                                              imageUrl:
                                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${searchList[i]["image"]}"))));
                                            },
                                            // child: Image.network(
                                            //     "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${searchList[i]["image"]}",
                                            //     fit: BoxFit.cover),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  "${domain.substring(0, domain.lastIndexOf("8084/"))}8084/${searchList[i]["image"]}",
                                            ),
                                          ),
                                        ],
                                      )),
                                  title: Column(
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Checkbox(
                                              activeColor: Color(0xffe53935),
                                              value: searchList[i]["check"],
                                              onChanged: (val) async {
                                                final SharedPreferences preferences = await SharedPreferences.getInstance();
                                                print(searchList[i]["stockSyskey"]);
                                                setState(() {
                                                  searchList[i]["check"] = val;

                                                  var check = "";

                                                  if (searchList[i]["check"] == true) {
                                                    List sameBrandownerKey = [];
                                                    // print("StockList length ==> ${widget.stockList1.length}");
                                                    if (widget.stockList1.length == 0 || widget.stockList1 == []) {
                                                      print("no stock to add");
                                                      newList.add({
                                                        "brandOwnerName": searchList[i]["brandOwnerName"],
                                                        "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                        "visible": true,
                                                        "stockData": [
                                                          {
                                                            "syskey": "0",
                                                            "recordStatus": 1,
                                                            "stockCode": "${searchList[i]["stockCode"]}",
                                                            "stockName": "${searchList[i]["stockName"]}",
                                                            "saleCurrCode": "MMK",
                                                            "stockSyskey" : "${searchList[i]["stockSyskey"]}",
                                                            "n1": "0",
                                                            "wareHouseSyskey": "${searchList[i]["wareHouseSyskey"]}",
                                                            "binSyskey": "0",
                                                            "qty": double.parse("${searchList[i]["qty"]}.0"),
                                                            "lvlSyskey": "${searchList[i]["lvlSyskey"]}",
                                                            "lvlQty": 1.0,
                                                            "n8": 1.0,
                                                            "n9": 0.0,
                                                            "taxAmount": 0.0,
                                                            "totalAmount": double.parse("${searchList[i]["qty"] * searchList[i]["totalAmount"]}.0"),
                                                            "price": double.parse("${searchList[i]["totalAmount"]}.0"),
                                                            "normalPrice" : double.parse("${searchList[i]["totalAmount"]}.0"),
                                                            "taxCodeSK": "0",
                                                            "isTaxInclusice": 0,
                                                            "taxPercent": 0.0,
                                                            "discountAmount": 0.0,
                                                            "discountPercent": 0.0,
                                                            "promotionStockList" : [],
                                                            "brandOwnerSyskey": "${searchList[i]["brandOwnerSyskey"]}",
                                                            "stockType": "NORMAL"
                                                          }
                                                        ]
                                                      });
                                                      print(getdeliverylist);
                                                      print(stockByBrandDel);
                                                      if (getdeliverylist.length != 0) {
                                                        var checkValue = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == searchList[i]["brandOwnerSyskey"]){
                                                            checkValue = 1;
                                                            var r = {
                                                              "stockCode": searchList[i]["stockCode"],
                                                              "stockName": searchList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : searchList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": searchList[i]["qty"],
                                                              "lvlSyskey": searchList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": searchList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(checkValue == 0){
                                                            getdeliverylist.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": searchList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": searchList[i]["stockCode"],
                                                              "stockName": searchList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : searchList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": searchList[i]["qty"],
                                                              "lvlSyskey": searchList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": searchList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                        }
                                                        print("add to deliveryList");
                                                       
                                                        for(var a = 0; a < getdeliverylist.length;a++){
                                                          print("add to deliveryList22222" + getdeliverylist[a].toString());
                                                        }
                                                        // print("add to deliveryList22222$getdeliverylist");
                                                      } else {
                                                        print(
                                                            "add to delivery list stockbybrandDelivery");
                                                        stockByBrandDel.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": searchList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": searchList[i]["stockCode"],
                                                              "stockName": searchList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : searchList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": searchList[i]["qty"],
                                                              "lvlSyskey": searchList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": searchList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                      }
                                                    } else {
                                                      sameBrandownerKey = newList.where((element) => element["brandOwnerSyskey"].toString() == searchList[i]["brandOwnerSyskey"].toString()).toList();

                                                      // print(sameBrandownerKey);
                                                      if (sameBrandownerKey.toString() == "[]") {
                                                        print("add new brandname");
                                                        newList.add({
                                                          "brandOwnerName": searchList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                          "visible": true,
                                                          "stockData": [
                                                            {
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${searchList[i]["stockCode"]}",
                                                              "stockName": "${searchList[i]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${searchList[i]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${searchList[i]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${searchList[i]["qty"]}.0"),
                                                              "lvlSyskey": "${searchList[i]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${searchList[i]["qty"] * searchList[i]["totalAmount"]}.0"),
                                                              "price": double.parse("${searchList[i]["totalAmount"]}.0"),
                                                              "normalPrice" : double.parse("${searchList[i]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${searchList[i]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL"
                                                            }
                                                          ]
                                                        });

                                                        if (getdeliverylist.length.toString() != "0") {
                                                          var checkValue = 0;
                                                        for(var l = 0; l < getdeliverylist.length;l++){
                                                          if(getdeliverylist[l]["brandOwnerSyskey"] == searchList[i]["brandOwnerSyskey"]){
                                                            checkValue = 1;
                                                            var r = {
                                                              "stockCode": searchList[i]["stockCode"],
                                                              "stockName": searchList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : searchList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": searchList[i]["qty"],
                                                              "lvlSyskey": searchList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": searchList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            };
                                                           getdeliverylist[l]["stockData"].add(r);
                                                          }
                                                        }
                                                        if(checkValue == 0){
                                                            getdeliverylist.add({
                                                          "syskey": "0",
                                                          "autokey": "0",
                                                          "createddate": date,
                                                          "modifieddate": date,
                                                          "userid": preferences.getString("userId"),
                                                          "username": preferences.getString("userName"),
                                                          "saveStatus": 1,
                                                          "recordStatus": 1,
                                                          "syncStatus": 0,
                                                          "syncBatch": "",
                                                          "transType": "DeliveryOrder",
                                                          "docummentDate": date,
                                                          "brandOwnerCode": "001",
                                                          "brandOwnerName": searchList[i]["brandOwnerName"],
                                                          "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                          "orderSyskey": "0",
                                                          "totalamount": 0.0,
                                                          "orderTotalAmount": 0.0,
                                                          "returnTotalAmount": 0.0,
                                                          "discountamount": 0.0,
                                                          "taxSyskey": "0",
                                                          "taxPercent": 0.0,
                                                          "taxAmount": 0.0,
                                                          "orderDiscountPercent": 0.0,
                                                          "returnDiscountPercent": 0.0,
                                                          "payment1": 0.0,
                                                          "payment2": 0.0,
                                                          "cashamount": 0.0,
                                                          "creditAmount": 0.0,
                                                          "promotionList" : [],
                                                          "stockData": [
                                                            {
                                                              "stockCode": searchList[i]["stockCode"],
                                                              "stockName": searchList[i]["stockName"],
                                                              "recordStatus": 1,
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : searchList[i]["stockSyskey"],
                                                              "n1": "0",
                                                              "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                              "binSyskey": "0",
                                                              "qty": searchList[i]["qty"],
                                                              "lvlSyskey": searchList[i]["lvlSyskey"],
                                                              "lvlQty": 0.0,
                                                              "n8": 0.0,
                                                              "price": searchList[i]["totalAmount"].toDouble(),
                                                              "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "discountStock": false,
                                                              "promotionStockList" : []
                                                            }
                                                          ],
                                                          "stockReturnData": []
                                                        });
                                                        }
                                                        } else {
                                                          stockByBrandDel.add({
                                                            "syskey": "0",
                                                            "autokey": "0",
                                                            "createddate": date,
                                                            "modifieddate": date,
                                                            "userid": preferences.getString("userId"),
                                                            "username": preferences.getString("userName"),
                                                            "saveStatus": 1,
                                                            "recordStatus": 1,
                                                            "syncStatus": 0,
                                                            "syncBatch": "",
                                                            "transType": "DeliveryOrder",
                                                            "docummentDate": date,
                                                            "brandOwnerCode": "001",
                                                            "brandOwnerName": searchList[i]["brandOwnerName"],
                                                            "brandOwnerSyskey": searchList[i]["brandOwnerSyskey"],
                                                            "orderSyskey": "0",
                                                            "totalamount": 0.0,
                                                            "orderTotalAmount": 0.0,
                                                            "returnTotalAmount": 0.0,
                                                            "discountamount": 0.0,
                                                            "taxSyskey": "0",
                                                            "taxPercent": 0.0,
                                                            "taxAmount": 0.0,
                                                            "orderDiscountPercent": 0.0,
                                                            "returnDiscountPercent": 0.0,
                                                            "payment1": 0.0,
                                                            "payment2": 0.0,
                                                            "cashamount": 0.0,
                                                            "creditAmount": 0.0,
                                                            "promotionList" : [],
                                                            "stockData": [
                                                              {
                                                                "stockCode": searchList[i]["stockCode"],
                                                                "stockName": searchList[i]["stockName"],
                                                                "recordStatus": 1,
                                                                "saleCurrCode": "MMK",
                                                                "stockSyskey" : searchList[i]["stockSyskey"],
                                                                "n1": "0",
                                                                "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                                "binSyskey": "0",
                                                                "qty": searchList[i]["qty"],
                                                                "lvlSyskey": searchList[i]["lvlSyskey"],
                                                                "lvlQty": 0.0,
                                                                "n8": 0.0,
                                                                "price": searchList[i]["totalAmount"].toDouble(),
                                                                "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                                "n9": 0.0,
                                                                "taxAmount": 0.0,
                                                                "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                                "taxCodeSK": "0",
                                                                "isTaxInclusice": 0,
                                                                "taxPercent": 0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "discountStock": false,
                                                                "promotionStockList" : []
                                                              }
                                                            ],
                                                            "stockReturnData": []
                                                          });
                                                          // print(stockByBrandDel);

                                                        }
                                                      } else {
                                                        
                                                        print("add stock to the same brandname");
                                                        for (var x = 0; x < sameBrandownerKey.length; x++) {
                                                          
                                                          if (sameBrandownerKey[x]["stockData"].length == 0) {
                                                            print("same brandname but no stock");
                                                            sameBrandownerKey[x]["stockData"].add({
                                                              "syskey": "0",
                                                              "recordStatus": 1,
                                                              "stockCode": "${searchList[i]["stockCode"]}",
                                                              "stockName": "${searchList[i]["stockName"]}",
                                                              "saleCurrCode": "MMK",
                                                              "stockSyskey" : "${searchList[i]["stockSyskey"]}",
                                                              "n1": "0",
                                                              "wareHouseSyskey": "${searchList[i]["wareHouseSyskey"]}",
                                                              "binSyskey": "0",
                                                              "qty": double.parse("${searchList[i]["qty"]}.0"),
                                                              "lvlSyskey": "${searchList[i]["lvlSyskey"]}",
                                                              "lvlQty": 1.0,
                                                              "n8": 1.0,
                                                              "n9": 0.0,
                                                              "taxAmount": 0.0,
                                                              "totalAmount": double.parse("${searchList[i]["qty"] * searchList[i]["totalAmount"]}.0"),
                                                              "price": double.parse("${searchList[i]["totalAmount"]}.0"),
                                                              "normalPrice" : double.parse("${searchList[i]["totalAmount"]}.0"),
                                                              "taxCodeSK": "0",
                                                              "isTaxInclusice": 0,
                                                              "taxPercent": 0.0,
                                                              "discountAmount": 0.0,
                                                              "discountPercent": 0.0,
                                                              "promotionStockList" : [],
                                                              "brandOwnerSyskey": "${searchList[i]["brandOwnerSyskey"]}",
                                                              "stockType": "NORMAL"
                                                            });

                                                            if(getdeliverylist.length == 0) {
                                                            for (var j = 0; j < stockByBrandDel.length; j++) {
                                                              if (stockByBrandDel[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                stockByBrandDel[j]["stockData"].add({
                                                                  "stockCode": searchList[i]["stockCode"],
                                                                  "stockName": searchList[i]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : searchList[i]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                  "lvlSyskey":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                  "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            } else {
                                                            for (var j = 0; j < getdeliverylist.length; j++) {
                                                              if (getdeliverylist[j]["brandOwnerSyskey"].toString() == sameBrandownerKey[x]["brandOwnerSyskey"].toString()) {
                                                                getdeliverylist[j]["stockData"].add({
                                                                  "stockCode": searchList[i]["stockCode"],
                                                                  "stockName": searchList[i]["stockName"],
                                                                  "recordStatus": 1,
                                                                  "saleCurrCode": "MMK",
                                                                  "stockSyskey" : searchList[i]["stockSyskey"],
                                                                  "n1": "0",
                                                                  "wareHouseSyskey": searchList[i]["wareHouseSyskey"],
                                                                  "binSyskey": "0",
                                                                  "qty":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                  "lvlSyskey":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "lvlSyskey"],
                                                                  "lvlQty": 0.0,
                                                                  "n8": 0.0,
                                                                  "price":
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                  "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                                  "n9": 0.0,
                                                                  "taxAmount":
                                                                      0.0,
                                                                  "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                                  "taxCodeSK":
                                                                      "0",
                                                                  "isTaxInclusice":
                                                                      0,
                                                                  "taxPercent":
                                                                      0.0,
                                                                  "discountAmount": 0.0,
                                                                  "discountPercent": 0.0,
                                                                  "discountStock": false,
                                                                  "promotionStockList" : []
                                                                });
                                                              }
                                                            }
                                                            }
                                                            
                                                          } else {
                                                            if (sameBrandownerKey[
                                                                            x][
                                                                        "stockData"]
                                                                    .where((element) =>
                                                                        element[
                                                                            "stockCode"] ==
                                                                        searchList[i]
                                                                            [
                                                                            "stockCode"])
                                                                    .toList()
                                                                    .toString() ==
                                                                "[]") {
                                                              check = "true";
                                                            } else {
                                                              check = "";
                                                            }
                                                            if (check ==
                                                                "true") {
                                                              print(
                                                                  "add new stock to the same brandname");
                                                              for(var p = 0; p < newList.length; p++) {
                                                                if(newList[p]["brandOwnerSyskey"] == searchList[i]["brandOwnerSyskey"]) {
                                                                  print("3newList ==> ${newList[0]["stockData"]}");
                                                                  newList[p]["stockData"].add({
                                                                "syskey": "0",
                                                                "recordStatus":
                                                                    1,
                                                                "stockCode":
                                                                    "${searchList[i]["stockCode"]}",
                                                                "stockName":
                                                                    "${searchList[i]["stockName"]}",
                                                                "saleCurrCode":
                                                                    "MMK",
                                                                "stockSyskey" : "${searchList[i]["stockSyskey"]}",
                                                                "n1": "0",
                                                                "wareHouseSyskey":
                                                                    "${searchList[i]["wareHouseSyskey"]}",
                                                                "binSyskey":
                                                                    "0",
                                                                "qty": double.parse(
                                                                    "${searchList[i]["qty"]}.0"),
                                                                "lvlSyskey":
                                                                    "${searchList[i]["lvlSyskey"]}",
                                                                "lvlQty": 1.0,
                                                                "n8": 1.0,
                                                                "n9": 0.0,
                                                                "taxAmount":
                                                                    0.0,
                                                                "totalAmount":
                                                                    double.parse(
                                                                        "${searchList[i]["totalAmount"] * searchList[i]["qty"]}.0"),
                                                                "price": double.parse("${searchList[i]["totalAmount"]}.0"),
                                                                "normalPrice" : double.parse("${searchList[i]["totalAmount"]}.0"),
                                                                "taxCodeSK":
                                                                    "0",
                                                                "isTaxInclusice":
                                                                    0,
                                                                "taxPercent":
                                                                    0.0,
                                                                "discountAmount": 0.0,
                                                                "discountPercent": 0.0,
                                                                "promotionStockList" : [],
                                                                "brandOwnerSyskey":
                                                                    "${searchList[i]["brandOwnerSyskey"]}",
                                                                "stockType":
                                                                    "NORMAL"
                                                              });
                                                              if (getdeliverylist
                                                                      .toString() !=
                                                                  "[]") {
                                                                for (var j = 0;
                                                                    j <
                                                                        getdeliverylist
                                                                            .length;
                                                                    j++) {
                                                                  if (getdeliverylist[j]["brandOwnerSyskey"].toString() ==
                                                                      searchList[i]["brandOwnerSyskey"].toString()) {
                                                                    
                                                                    getdeliverylist[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          searchList[i]
                                                                              [
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          searchList[i]
                                                                              [
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : searchList[i]
                                                                              [
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          searchList[i]
                                                                              [
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": searchList[i]["qty"],
                                                                      "lvlSyskey":
                                                                          searchList[i]
                                                                              [
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": searchList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                      "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount": 
                                                                          0.0,
                                                                      "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          getdeliverylist[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(getdeliverylist[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }

                                                                  if(newList[p]["stockData"].where((element) => element["stockSyskey"] == searchList[i]["stockSyskey"]).toList().length != 0) {
                                                                    newList[p]["stockData"].removeWhere((element) => element["qty"].runtimeType.toString() == "int");
                                                                  }
                                                                }
                                                              } else {
                                                                for (var j = 0;
                                                                    j <
                                                                        stockByBrandDel
                                                                            .length;
                                                                    j++) {
                                                                  if (stockByBrandDel[j]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString() ==
                                                                      sameBrandownerKey[x]
                                                                              [
                                                                              "brandOwnerSyskey"]
                                                                          .toString()) {
                                                                    stockByBrandDel[j]
                                                                            [
                                                                            "stockData"]
                                                                        .add({
                                                                      "stockCode":
                                                                          searchList[i]
                                                                              [
                                                                              "stockCode"],
                                                                      "stockName":
                                                                          searchList[i]
                                                                              [
                                                                              "stockName"],
                                                                      "recordStatus":
                                                                          1,
                                                                      "saleCurrCode":
                                                                          "MMK",
                                                                      "stockSyskey" : searchList[i]
                                                                              [
                                                                              "stockSyskey"],
                                                                      "n1": "0",
                                                                      "wareHouseSyskey":
                                                                          searchList[i]
                                                                              [
                                                                              "wareHouseSyskey"],
                                                                      "binSyskey":
                                                                          "0",
                                                                      "qty": searchList[
                                                                              i]
                                                                          [
                                                                          "qty"],
                                                                      "lvlSyskey":
                                                                          searchList[i]
                                                                              [
                                                                              "lvlSyskey"],
                                                                      "lvlQty":
                                                                          0.0,
                                                                      "n8": 0.0,
                                                                      "price": searchList[
                                                                              i]
                                                                          [
                                                                          "totalAmount"].toDouble(),
                                                                      "normalPrice" : searchList[i]["totalAmount"].toDouble(),
                                                                      "n9": 0.0,
                                                                      "taxAmount":
                                                                          0.0,
                                                                      "totalAmount": searchList[i]["qty"] * searchList[i]["totalAmount"].toDouble(),
                                                                      "taxCodeSK":
                                                                          "0",
                                                                      "isTaxInclusice":
                                                                          0,
                                                                      "taxPercent":
                                                                          0.0,
                                                                      "discountAmount": 0.0,
                                                                      "discountPercent": 0.0,
                                                                      "discountStock": false,
                                                                      "promotionStockList" : []
                                                                    });
                                                                  }

                                                                  for (var m =
                                                                          0;
                                                                      m <
                                                                          stockByBrandDel[j]["stockData"]
                                                                              .length;
                                                                      m++) {
                                                                    print(stockByBrandDel[
                                                                            j][
                                                                        "stockData"][m]);
                                                                  }
                                                                }
                                                              }

                                                              

                                                                }

                                                              }

                                                              
                                                            } else if (check ==
                                                                "") {
                                                              print("add stockQty with same stock and same brandname");
                                                              for (var n = 0; n < sameBrandownerKey[x]["stockData"].length; n++) {
                                                                if (sameBrandownerKey[x]["stockData"][n]["stockSyskey"] == searchList[i]["stockSyskey"]) {
                                                                  sameBrandownerKey[x]["stockData"][n]["qty"] =
                                                                      double.parse(
                                                                          "${sameBrandownerKey[x]["stockData"][n]["qty"] + searchList[i]["qty"]}");

                                                                  print(sameBrandownerKey[x]["stockData"][n]["qty"]);
                                                                  
                                                                  // sameBrandownerKey[x]["stockData"][n]["totalAmount"] = sameBrandownerKey[x]["stockData"][n]["price"] * sameBrandownerKey[x]["stockData"][n]["qty"];

                                                                  if(discountStockList.contains(searchList[i]["stockSyskey"]) == true) {
                                                                    
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param = jsonEncode(
                                                                        {
	                                                                        "itemSyskey": "${searchList[i]["stockSyskey"]}",
	                                                                        "itemDesc": "${searchList[i]["stockName"]}",
	                                                                        "itemAmount": searchList[i]["totalAmount"].toInt(),
	                                                                        "itemTotalAmount": sameBrandownerKey[x]["stockData"][n]["qty"].toInt() * searchList[i]["totalAmount"].toInt(),
	                                                                        "itemQty": sameBrandownerKey[x]["stockData"][n]["qty"].toInt(),
	                                                                        "shopSyskey": "${val[0]["shopsyskey"]}"
                                                                        }
                                                                      );

                                                                      getVolDisCalculation(param, sameBrandownerKey[x]["stockData"]).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          // if(newStockList.length != 0) {
                                                                          //   sameBrandownerKey[x]["stockData"] = newStockList;
                                                                          //   newList[x]["stockData"] = newStockList;

                                                                          //   print(newList[x]["stockData"]);
                                                                          // }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
                                                                      });
                                                                    });
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  } else if (searchList[i]["check"] == false) {
                                                    for (var x = 0; x < newList.length; x++) {
                                                      if (newList[x]["brandOwnerSyskey"] == searchList[i]["brandOwnerSyskey"]) {
                                                        for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                          if (newList[x]["stockData"][y]["stockSyskey"] == searchList[i]["stockSyskey"]) {
                                                            print("Stock Qty ==> " +searchList[i]["qty"].toString());
                                                            print("New List Qty ==> " + newList[x]["stockData"][y]["qty"].toString());
                                                            print(searchList[i]["qty"].runtimeType);
                                                            print(searchList[i]["qty"].runtimeType);
                                                            newList[x]["stockData"][y]["qty"] = double.parse("${newList[x]["stockData"][y]["qty"] - searchList[i]["qty"]}");

                                                            print("New List Qty ==> " + newList[x]["stockData"][y]["qty"].toString());

                                                            if(discountStockList.contains(searchList[i]["stockSyskey"]) == true) {
                                                              if(newList[x]["stockData"][y]["qty"].toString() != "0.0") {
                                                                 ShopsbyUser helperShopsbyUser = ShopsbyUser();
                                                                    _handleSubmit(context);
                                                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                                                    getSysKey.then((val) {
                                                                      var param = jsonEncode(
                                                                        {
	                                                                        "itemSyskey": "${searchList[i]["stockSyskey"]}",
	                                                                        "itemDesc": "${searchList[i]["stockName"]}",
	                                                                        "itemAmount": newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                        "itemTotalAmount": newList[x]["stockData"][y]["qty"].toInt() * newList[x]["stockData"][y]["totalAmount"].toInt(),
	                                                                        "itemQty": newList[x]["stockData"][y]["qty"].toInt(),
	                                                                        "shopSyskey": "${val[0]["shopsyskey"]}"
                                                                        }
                                                                      );

                                                                      getVolDisCalculation(param, newList[x]["stockData"]).then((getVolDisCalculationValue) {
                                                                        if(getVolDisCalculationValue == "success") {
                                                                          // if(newStockList.length != 0) {
                                                                          //   stockList = newStockList;
                                                                          // }
                                                                          Navigator.pop(context);
                                                                          
                                                                        }else if(getVolDisCalculationValue == "fail") {
                                                                          Navigator.pop(context);
                                                                          snackbarmethod("FAIL!");
                                                                        }else {
                                                                          Navigator.pop(context);
                                                                          getVolDisCalculationDialog(param, getVolDisCalculationValue.toString());
                                                                        }
                                                                      });
                                                                    });
                                                              }
                                                                   
                                                                  }

                                                            if (getdeliverylist == [] || getdeliverylist.length == 0) {
                                                              for (var a = 0; a < stockByBrandDel.length; a++) {
                                                                for (var b = 0; b < stockByBrandDel[a]["stockData"].length; b++) {
                                                                  if (stockByBrandDel[a]["stockData"][b]["stockCode"] == searchList[i]["stockCode"]) {
                                                                    stockByBrandDel[a]["stockData"][b]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                  }
                                                                }

                                                                stockByBrandDel[a]["stockData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                              }
                                                            } else {
                                                              for (var a = 0; a < getdeliverylist.length; a++) {
                                                                for (var b = 0; b < getdeliverylist[a]["stockData"].length; b++) {
                                                                    if (getdeliverylist[a]["stockData"][b]["stockCode"] == searchList[i]["stockCode"]) {
                                                                      getdeliverylist[a]["stockData"][b]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                    }

                                                                  print("getdeliverylist[a]['stockData'] ==> " +getdeliverylist[a]["stockData"][b].toString());
                                                                }

                                                                getdeliverylist[a]["stockData"].removeWhere((element) => element["qty"] == 0.0 || element["qty"] < 0);
                                                              }
                                                            }

                                                            // print(newList[x]["stockData"]);
                                                            if(newList[x]["stockData"].length != 0) {
                                                              if (newList[x]["stockData"][y]["qty"].toString() == "0.0") {
                                                                newList[x]["stockData"].removeWhere((element) => element["qty"].toString() == "0.0" || element["qty"] < 0);

                                                              // newList.removeWhere((element) => element["stockData"].length == 0);

                                                              // stockData.removeWhere((element) => element["qty"] == 0.0);
                                                              }
                                                            }
                                                            
                                                            
                                                            // for (var v = 0; v < stockData.length; v++) {
                                                            //   if (stockData[v]["stockCode"] == stockList[i]["stockCode"]) {
                                                            //     stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                            //   }
                                                            // }

                                                            
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                });
                                              }),
                                          SizedBox(width: 10),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  171,
                                              height: 40,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "${searchList[i]["stockName"]}",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ))
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          // SizedBox(width: 15),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Row(
                                              children: <Widget>[
                                                // Text(
                                                //   "Qty : ",
                                                //   style: TextStyle(fontSize: 16),
                                                // ),
                                                // SizedBox(width: 14),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (searchList[i][
                                                                        "qty"] ==
                                                                    1 ||
                                                                searchList[i][
                                                                        "qty"] <
                                                                    1) {
                                                            } else {
                                                              setState(() {
                                                                searchList[i]
                                                                    ["qty"]--;

                                                              });

                                                              if (searchList[i][
                                                                      "check"] ==
                                                                  true) {
                                                                for (var x = 0;
                                                                    x <
                                                                        newList
                                                                            .length;
                                                                    x++) {
                                                                  if (newList[x]
                                                                          [
                                                                          "brandOwnerSyskey"] ==
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "brandOwnerSyskey"]) {
                                                                    for (var y =
                                                                            0;
                                                                        y < newList[x]["stockData"].length;
                                                                        y++) {
                                                                      if (newList[x]["stockData"][y]
                                                                              [
                                                                              "stockCode"] ==
                                                                          searchList[i]
                                                                              [
                                                                              "stockCode"]) {
                                                                        newList[x]["stockData"][y]
                                                                            [
                                                                            "qty"] = newList[x]["stockData"][y]
                                                                                ["qty"] -
                                                                            1;

                                                                        newList[x]["stockData"][y]["totalAmount"] = searchList[i]["totalAmount"].toDouble() * searchList[i]["qty"];

                                                                        // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                        for (var v =
                                                                                0;
                                                                            v < stockData.length;
                                                                            v++) {
                                                                          if (stockData[v]["stockCode"] ==
                                                                              searchList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] =
                                                                                newList[x]["stockData"][y]["qty"];

                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] *
                                                                                newList[x]["stockData"][y]["totalAmount"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                                if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                            }
                                                          });
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          const IconData(0xe15b,
                                                              fontFamily:
                                                                  'MaterialIcons'),
                                                          color: Colors.white,
                                                          size: 19,
                                                        )),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffe53935),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showIntDialog(
                                                                searchList[i]
                                                                    ["qty"])
                                                            .then((value) {
                                                          setState(() {
                                                            searchList[i]
                                                                ["qty"] = value;

                                                            if (searchList[i]
                                                                    ["check"] ==
                                                                true) {
                                                              List dropdown =
                                                                  [];

                                                              dropdown = originalQty
                                                                  .where((element) =>
                                                                      element[
                                                                          "stockCode"] ==
                                                                      searchList[
                                                                              i]
                                                                          [
                                                                          "stockCode"])
                                                                  .toList();

                                                              if (dropdown ==
                                                                      [] ||
                                                                  dropdown.length ==
                                                                      0) {
                                                                for (var x = 0;
                                                                    x <
                                                                        newList
                                                                            .length;
                                                                    x++) {
                                                                  for (var y =
                                                                          0;
                                                                      y <
                                                                          newList[x]["stockData"]
                                                                              .length;
                                                                      y++) {
                                                                    if (newList[x]["stockData"][y]
                                                                            [
                                                                            "stockCode"] ==
                                                                        searchList[i]
                                                                            [
                                                                            "stockCode"]) {
                                                                      newList[x]["stockData"][y]
                                                                              [
                                                                              "qty"] =
                                                                          double.parse(
                                                                              "$value");

                                                                      newList[x]["stockData"][y]["totalAmount"] = searchList[i]["totalAmount"].toDouble() * searchList[i]["qty"];

                                                                      // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                      for (var v =
                                                                              0;
                                                                          v < stockData.length;
                                                                          v++) {
                                                                        if (stockData[v]["stockCode"] ==
                                                                            searchList[i]["stockCode"]) {
                                                                          stockData[v]
                                                                              [
                                                                              "qty"] = newList[x]["stockData"]
                                                                                  [y]
                                                                              [
                                                                              "qty"];

                                                                          stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] *
                                                                                newList[x]["stockData"][y]["totalAmount"];
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                              if (dropdown !=
                                                                      [] ||
                                                                  dropdown.length !=
                                                                      0) {
                                                                for (var v = 0;
                                                                    v <
                                                                        dropdown
                                                                            .length;
                                                                    v++) {
                                                                  for (var x =
                                                                          0;
                                                                      x <
                                                                          newList
                                                                              .length;
                                                                      x++) {
                                                                    for (var y =
                                                                            0;
                                                                        y < newList[x]["stockData"].length;
                                                                        y++) {
                                                                      if (newList[x]["stockData"][y]
                                                                              [
                                                                              "stockCode"] ==
                                                                          dropdown[v]
                                                                              [
                                                                              "stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] =
                                                                            double.parse("${value + dropdown[v]["qty"]}");

                                                                        newList[x]["stockData"][y]["totalAmount"] = searchList[i]["totalAmount"].toDouble() * searchList[i]["qty"];

                                                                        // stockData[y]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                        for (var v =
                                                                                0;
                                                                            v < stockData.length;
                                                                            v++) {
                                                                          if (stockData[v]["stockCode"] ==
                                                                              searchList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] =
                                                                                newList[x]["stockData"][y]["qty"];

                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["qty"] *
                                                                                newList[x]["stockData"][y]["totalAmount"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }

                                                              if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                            } else {}
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        child: Center(
                                                            child: Text(
                                                                "${searchList[i]["qty"]}")),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            bottom: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey),
                                                            left: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                            right: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        height: 27,
                                                        width: 45,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (searchList[i]
                                                                  ["qty"] >=
                                                              99999) {
                                                          } else {
                                                            setState(() {
                                                              searchList[i]
                                                                  ["qty"]++;

                                                              if (searchList[i][
                                                                      "check"] ==
                                                                  true) {
                                                                for (var x = 0; x < newList.length; x++) {
                                                                  if (newList[x]["brandOwnerSyskey"] == searchList[i]["brandOwnerSyskey"]) {
                                                                    for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                      if (newList[x]["stockData"][y]["stockCode"] == searchList[i]["stockCode"]) {
                                                                        newList[x]["stockData"][y]["qty"] = newList[x]["stockData"][y]["qty"] + 1;

                                                                        newList[x]["stockData"][y]["totalAmount"] = searchList[i]["totalAmount"].toDouble() * searchList[i]["qty"];

                                                                        for (var v = 0; v < stockData.length; v++) {
                                                                          if (stockData[v]["stockCode"] == searchList[i]["stockCode"]) {
                                                                            stockData[v]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                            stockData[v]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"] * newList[x]["stockData"][y]["qty"];
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                print(newList);

                                                                if(getdeliverylist.length == 0) {
                                                                  for(var m = 0; m < stockByBrandDel.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(stockByBrandDel[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < stockByBrandDel[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(stockByBrandDel[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              stockByBrandDel[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              stockByBrandDel[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                } else {
                                                                  for(var m = 0; m < getdeliverylist.length; m++) {
                                                                    for (var x = 0; x < newList.length; x++) {
                                                                      if(getdeliverylist[m]["brandOwnerSyskey"] == newList[x]["brandOwnerSyskey"]) {
                                                                        for(var n = 0; n < getdeliverylist[m]["stockData"].length; n++) {
                                                                          for (var y = 0; y < newList[x]["stockData"].length; y++) {
                                                                            if(getdeliverylist[m]["stockData"][n]["stockSyskey"] == newList[x]["stockData"][y]["stockSyskey"]) {
                                                                              getdeliverylist[m]["stockData"][n]["qty"] = newList[x]["stockData"][y]["qty"];
                                                                              getdeliverylist[m]["stockData"][n]["totalAmount"] = newList[x]["stockData"][y]["totalAmount"];
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              } else {}
                                                            });
                                                          }
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                                Icons.add,
                                                                size: 19,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        color:
                                                            Color(0xffe53935),
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          bottom: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          left: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                          right: BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      height: 23,
                                                      width: 25,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                    "${searchList[i]["totalAmount"]}"),
                                                SizedBox(width: 40),
                                                Text(
                                                    "${searchList[i]["totalAmount"] * searchList[i]["qty"]}"),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: discountStockList.length == 0
                             ? false : 
                             "${discountStockList.where((element) => element.toString() == searchList[i]["stockSyskey"].toString()).toList().length}" == "0"
                             ? false : true,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () async {
                                    _handleSubmit(context);
                                    final SharedPreferences preferences = await SharedPreferences.getInstance();
                                    var getSysKey = helperShopsbyUser.getShopSyskey(preferences.getString('shopname'));
                                    String headerSyskey = "";
                                    if(disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == searchList[i]["stockSyskey"].toString()).toList().length != 0).toList().length != 0) {
                                      headerSyskey = disCategoryList.where((element) => element["list"].where((value) => value["promoItemSyskey"].toString() == searchList[i]["stockSyskey"].toString()).toList().length != 0).toList()[0]["hdrSyskey"];
                                    }
                                    getSysKey.then((val) {
                                      getPromoItemDetail("${val[0]["shopsyskey"]}", "", searchList[i]["stockSyskey"], searchList[i]["brandOwnerSyskey"]).then((promoDetailVal) {
                                        Navigator.pop(context);
                                        if(promoDetailVal == "success") {
                                          setState(() {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => DiscountDetail(detail: promoItemDetailList, stockDetail: searchList[i]),));
                                          });
                                        }else {
                                          snackbarmethod("FAIL!");
                                        }
                                      });
                                    });
                                  },
                                  child: Image.asset("assets/discount.png", width: 27,)),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
            ),
            
          ],
        ),
        bottomNavigationBar: Container(
          height: 50.0,
          child: GestureDetector(
            onTap: () async {

              final SharedPreferences preferences =
                  await SharedPreferences.getInstance();

              ShopsbyUser helperShopsbyUser = ShopsbyUser();

              List chosenProduct = [];

              chosenProduct = stockList
                  .where((element) => element["check"] == true)
                  .toList();

              var toOrderDetailPage;

              if (chosenProduct.length == 0) {
                toOrderDetailDataPage();
              } else {                
                for (var i = 0; i < chosenProduct.length; i++) {
                  if (discountStockList
                          .contains(chosenProduct[i]["stockSyskey"]) ==
                      true) {
                    _handleSubmit(context);
                    print(newList);
                    var getSysKey = helperShopsbyUser
                        .getShopSyskey(preferences.getString('shopname'));
                    getSysKey.then((val) {
                      var param;
                      List sameStock = newList[0]["stockData"].where((element) => element["stockSyskey"].toString() == chosenProduct[i]["stockSyskey"].toString()).toList();

                      print("Same Stock ==> " + sameStock.toString());
                      if(sameStock.length == 0) {
                        print(newList[0]["stockData"]);
                        param = jsonEncode({
                          "itemSyskey": "${chosenProduct[i]["stockSyskey"]}",
                          "itemDesc": "${chosenProduct[i]["stockName"]}",
                          "itemAmount": chosenProduct[i]["totalAmount"].toInt(),
                          "itemTotalAmount": chosenProduct[i]["qty"].toInt() * chosenProduct[i]["totalAmount"].toInt(),
                          "itemQty": chosenProduct[i]["qty"].toInt(),
                          "shopSyskey": "${val[0]["shopsyskey"]}"
                        });
                      } else {
                        print(sameStock);
                        sameStock[0]["totalAmount"] = sameStock[0]["qty"] * chosenProduct[i]["totalAmount"];
                        param = jsonEncode({
                          "itemSyskey": "${chosenProduct[i]["stockSyskey"]}",
                          "itemDesc": "${chosenProduct[i]["stockName"]}",
                          "itemAmount": chosenProduct[i]["totalAmount"].toInt(),
                          "itemTotalAmount": sameStock[0]["qty"].toInt() * chosenProduct[i]["totalAmount"].toInt(),
                          "itemQty": sameStock[0]["qty"].toInt(),
                          "shopSyskey": "${val[0]["shopsyskey"]}"
                        });
                      }
                      

                      print(param);

                      getVolDisCalculation(param, sameStock)
                          .then((getVolDisCalculationValue) {
                        if (getVolDisCalculationValue == "success") {
                          
                          if(i == chosenProduct.length-1) {
                            Navigator.pop(context);
                            sameStock = newStockList;
                            print("Same Stock ==> $sameStock");
                            toOrderDetailDataPage();
                          }
                        } else if (getVolDisCalculationValue == "fail") {
                          Navigator.pop(context);
                          snackbarmethod("FAIL!");
                        } else {
                          Navigator.pop(context);
                          getVolDisCalculationDialog(
                              param, getVolDisCalculationValue.toString());
                        }
                      });
                    });
                  } else {
                    setState(() {
                      toOrderDetailPage = true;
                    });
                    if(i == chosenProduct.length -1 && toOrderDetailPage == true) {
                      toOrderDetailDataPage();
                    }
                  }
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xffe53935),
                    borderRadius: BorderRadius.circular(10)),
                constraints: BoxConstraints(maxWidth: 200, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text(
                  "Add Product",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toOrderDetailDataPage() {
    datetime();

    // print("Stockbybrand Del ==>  " + stockByBrandDel.toString());
    // for(var a = 0; a < getdeliverylist.length;a++){
    //   print("to order detail data" + getdeliverylist[a].toString());
    // }

    for(var a = 0;a < newList.length; a++) {
      for(var b = 0; b < newList[a]["stockData"].length; b++) {
        print(newList[a]["stockData"][b]);
      }
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderDetailData(
                  shopName: widget.shopName,
                  shopNameMm: widget.shopNameMm,
                  address: widget.address,
                  shopSyskey: widget.shopSyskey,
                  orderDate: widget.date,
                  deliveryDate: date,
                  mcdCheck: widget.mcdCheck,
                  userType: widget.userType,
                  stockList: newList,
                  ownerName: ownerName,
                  phone: widget.phone,
                  returnList: widget.returnList,
                  back: "FromButton",
                  orderDeleted: widget.orderDeleted,
                  returnDeleted: widget.returnDeleted,
                  isSaleOrderLessRouteShop: widget.isSaleOrderLessRouteShop,
                )));
  }

  Future<void> getVolDisCalculationDialog(var param, String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    "$title",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Try again',
                  style: TextStyle(color: Color(0xffe53935)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  getVolDisCalculation(param, []);
                },
              ),
              SizedBox(
                width: 50,
              ),
              FlatButton(
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xffe53935))),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        );
      },
    );
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
