import 'package:flutter/material.dart';
import 'package:delivery_2/service.dart/AllService.dart';

class SaleSummary extends StatefulWidget {
  @override
  _SaleSummaryState createState() => _SaleSummaryState();
}

class _SaleSummaryState extends State<SaleSummary> {
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  Function mathFunc = (Match match) => '${match[1]},';

  @override
  void initState() {
    super.initState();
    delAmountSummary();
  }

  int subTotal = 0;
  int expiredAmt = 0;
  int specialDisAmt = 0;
  int total = 0;

  void delAmountSummary() {
    getDelAmountSummary().then((value) {

      if(value == "success") {
        setState(() {

        List subTotalList = [];
        List expiredAmtList = [];
        List specialDisAmtList = [];
        List totalList = [];

        for(var i = 0; i < getDelAmtSummary.length; i++) {
          subTotalList.add(int.parse("${getDelAmtSummary[i]["orderAmount"]}".substring(0, "${getDelAmtSummary[i]["orderAmount"]}".lastIndexOf("."))));
          expiredAmtList.add(int.parse("${getDelAmtSummary[i]["returnAmount"]}".substring(0, "${getDelAmtSummary[i]["returnAmount"]}".lastIndexOf("."))));
          specialDisAmtList.add(int.parse("${getDelAmtSummary[i]["specialAmount"]}".substring(0, "${getDelAmtSummary[i]["specialAmount"]}".lastIndexOf("."))));
          totalList.add(int.parse("${getDelAmtSummary[i]["totalAmount"]}".substring(0, "${getDelAmtSummary[i]["totalAmount"]}".lastIndexOf("."))));
        }

        for(var i = 0; i < subTotalList.length; i++) {
          subTotal += subTotalList[i];
        }

        for(var i = 0; i < expiredAmtList.length; i++) {
          expiredAmt += expiredAmtList[i];
        }

        for(var i = 0; i < specialDisAmtList.length; i++) {
          specialDisAmt += specialDisAmtList[i];
        }

        for(var i = 0; i < totalList.length; i++) {
          total += totalList[i];
        }

        loading = false;

      });
      }else if(value == "fail") {
        setState(() {
          loading = false;
        });
        snackbarmethod("FAIL!");
      }else {
        setState(() {
          loading = false;
        });
        snackbarmethod(value);
      }
      
    });
  }

  snackbarmethod(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }


  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: Colors.grey[400],
        ),
        children: [
          TableRow(children: [
            ListTile(
              leading: Text("Completed Stores",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),),
              trailing: Text("${getDelAmtSummary.length}",style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Sub Total",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$subTotal".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Expired Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$expiredAmt".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Special Discount Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)),
              trailing: Text("$specialDisAmt".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
          TableRow(children: [
            ListTile(
              leading: Text("Total Amount",style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),),
              trailing: Text("$total".replaceAllMapped(reg, mathFunc),style: TextStyle(fontSize:16)),
            ),
          ]),
        ],
      ),
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Center(
            child: CircularProgressIndicator(
          backgroundColor: Colors.red,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )),
      ),
    ]));


    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor:   Color(0xffe53935),
        centerTitle: true,
        title: Text("Sale Summary"),
      ),
        body: loading ? loadProgress : body);
  } 
}
