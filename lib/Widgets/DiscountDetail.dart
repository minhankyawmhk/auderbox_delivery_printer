import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_2/service.dart/AllService.dart';
import 'ShowImage.dart';

class DiscountDetail extends StatefulWidget {
  final List detail;
  final stockDetail;
  DiscountDetail({Key key, @required this.detail, @required this.stockDetail})
      : super(key: key);
  @override
  _DiscountDetailState createState() => _DiscountDetailState();
}

class _DiscountDetailState extends State<DiscountDetail> {
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';
  bool loading = true;
  List getStockDetail = [];
  Future<void> getImage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    stockImage = json.decode(preferences.getString("StockImageList"));
    getStockDetail = json.decode(preferences.getString("AddOrder"));
    if (stockImage.length != 0) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffe53935),
          title: Text("Discount Detail"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
              }),
        ),
        body: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImage(
                                image: Image.asset("assets/coca.png"))));
                  },
                  child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset("assets/coca.png", fit: BoxFit.cover)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImage(
                                image: CachedNetworkImage(
                                    imageUrl:
                                        "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == widget.stockDetail["stockCode"]).toList()[0]["image"]}"))));
                  },
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: loading == true
                        ? Container()
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                "${domain.substring(0, domain.lastIndexOf("8084/"))}8084${stockImage.where((element) => element["stockCode"] == widget.stockDetail["stockCode"]).toList()[0]["image"]}",
                          ),
                  ),
                ),
              ],
            ),
            // Text("${widget.detail}"),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${widget.detail[0]["PromoItemDesc"]}",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Color(0xffe53935),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                "assets/price-tag.png",
                                color: Colors.white,
                                width: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["categoryCodeDesc"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color(0xffe53935),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                "assets/price-tag.png",
                                color: Colors.white,
                                width: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["subCategoryCodeDesc"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Detail",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Pack size",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text("Category",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text("Subcategory",
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      ),
                      Container(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["packSizeDescription"]}",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["categoryCode"]}",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                            Text(
                                "${getStockDetail.where((element) => element["syskey"] == widget.detail[0]["PromoItemSyskey"]).toList()[0]["subCategoryCode"]}",
                                style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Promotion",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 20,
                  ),
                  for(var b = 0; b < widget.detail[0]["HeaderList"].length; b++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          borderRadius: BorderRadius.circular(0)),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                // color: Color(0xffe53935),
                                borderRadius: BorderRadius.circular(0)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][0]["DiscountType"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        " Discount with ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][0]["PromoType"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Expired On : ${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(6, 8)}/${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(4, 6)}/${widget.detail[0]["HeaderList"][b]["ToDate"].toString().substring(0, 4)}",
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Buy",
                                    style: TextStyle(
                                      color: Color(0xffe53935),
                                      fontSize: 16,
                                    )),
                                Text("Get",
                                    style: TextStyle(
                                      color: Color(0xffe53935),
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[400],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 7),
                            child: Column(
                              children: <Widget>[
                                for (var a = 0; a < widget.detail[0]["HeaderList"][b]["DetailList"].length; a++)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                      .toString() ==
                                                  "between"
                                                   &&
                                              widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountType"] ==
                                                  "Inkind"
                                                   &&
                                              (widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"].toString().length > 2 ||
                                              widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"].toString().length > 2)
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Text("Between ", style: TextStyle(fontSize: 13),),
                                                    Text(
                                                      "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"]} ".replaceAllMapped(reg, mathFunc),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                    widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" ?
                                                    Text("", style: TextStyle(fontSize: 13),) :
                                                    Text("ks ", style: TextStyle(fontSize: 13),)
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Text("to ", style: TextStyle(fontSize: 13),),
                                                    Text(
                                                      "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                    widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" ?
                                                    Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                    Text("ks", style: TextStyle(fontSize: 13),)
                                                  ],
                                                )
                                              ],
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  // Text("${a + 1}. "),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "between")
                                                    Text("Between ", style: TextStyle(fontSize: 13),),
                                                  Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount"]} "
                                                        .replaceAllMapped(
                                                            reg, mathFunc),
                                                    style: TextStyle(
                                                        color: Color(0xffe53935), fontSize: 13),
                                                  ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                          ["PromoType"] ==
                                                      "Amount")
                                                    Text("ks "),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoType"] == "Qty" &&
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() !=
                                                          "between")
                                                    Text("( pcs )", style: TextStyle(fontSize: 13),),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "less than")
                                                    Text(
                                                      " under",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "end" ||
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "equal" ||
                                                      widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                              .toString() ==
                                                          "null")
                                                    Text(""),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "greater than")
                                                    Text(
                                                      " above",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                          color:
                                                              Color(0xffe53935)),
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "equal and greater than")
                                                    Row(
                                                      children: <Widget>[
                                                        Text(" and", style: TextStyle(fontSize: 13),),
                                                        Text(
                                                          " above",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color: Color(
                                                                  0xffe53935)),
                                                        ),
                                                      ],
                                                    ),
                                                  if (widget.detail[0]["HeaderList"][b]["DetailList"][a]["Operator"]
                                                          .toString() ==
                                                      "between")
                                                    Row(
                                                      children: <Widget>[
                                                        Text(" to", style: TextStyle(fontSize: 13),),
                                                        Text(
                                                          " ${widget.detail[0]["HeaderList"][b]["DetailList"][a]["PromoAmount2"]} ".replaceAllMapped(reg, mathFunc),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                              color: Color(
                                                                  0xffe53935)),
                                                        ),
                                                        
                                                        widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                                ["PromoType"] ==
                                                            "Qty" ?
                                                          Text("(pcs)", style: TextStyle(fontSize: 13),) :
                                                          Text("ks ", style: TextStyle(fontSize: 13),),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                  ["DiscountType"] ==
                                              "Inkind")
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2) -
                                                      35,
                                                  child: Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountItemDesc"]}",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Color(
                                                                0xffe53935))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 7),
                                                      child: Text(
                                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountItemQty"]}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color: Color(
                                                                0xffe53935)),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                  ["DiscountType"] ==
                                              "Price")
                                            Row(
                                              children: <Widget>[
                                                if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                        ["DiscountPriceType"] ==
                                                    "Price")
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountAmount"]}".replaceAllMapped(reg, mathFunc),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                      Text(
                                                        " ks",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                            color:
                                                                Color(0xffe53935)),
                                                      ),
                                                    ],
                                                  ),
                                                if (widget.detail[0]["HeaderList"][b]["DetailList"][a]
                                                        ["DiscountPriceType"] ==
                                                    "Percentage")
                                                  Text(
                                                    "${widget.detail[0]["HeaderList"][b]["DetailList"][a]["DiscountAmount"]}%",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                        color:
                                                            Color(0xffe53935)),
                                                  ),
                                                Text(" off", style: TextStyle(fontSize: 13),)
                                              ],
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
