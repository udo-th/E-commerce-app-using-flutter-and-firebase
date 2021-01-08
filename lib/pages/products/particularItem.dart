import 'package:app_frontend/components/header.dart';
import 'package:app_frontend/components/item/colorGroupButton.dart';
import 'package:app_frontend/sizeConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParticularItem extends StatefulWidget {
  final Map <String,dynamic> itemDetails;
  final bool editOrder;

  ParticularItem({var key, this.itemDetails, this.editOrder}):super(key: key);

  @override
  _ParticularItemState createState() => _ParticularItemState();
}

class _ParticularItemState extends State<ParticularItem> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List <Map<Color,bool>> productColors = new List<Map<Color,bool>>();
  List <Map<String,bool>> productSizes = new List();
  List <bool> sizeBoolList = new List();

  setColorList(List colors){
    List <Map<Color,bool>> colorList = new List<Map<Color,bool>>();
    colors.forEach((value){
      Map<Color,bool> colorMap = new Map();
      colorMap[Color(int.parse(value))] = false;
      colorList.add(colorMap);
    });
    this.setState(() {
      productColors = colorList;
    });
  }

  setSizeList(List size){
    List<Map<String,bool>> sizeList = new List();
    size.forEach((value) {
      Map<String,bool> size = new Map();
      size[value] = false;
      sizeList.add(size);
    });
    this.setState(() {
      productSizes = sizeList;
    });
  }

  setItemDetails(item){
    sizeBoolList = List.generate(widget.itemDetails['size'].length, (_) => false);
    setColorList(item['color']);
  }

  selectProductColor(int index){

  }

  @override
  Widget build(BuildContext context) {
    print(widget.itemDetails);
    SizeConfig().init(context);
    setItemDetails(widget.itemDetails);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header('Item', _scaffoldKey, true, context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.25,0.2],
            colors: [Color(0xff4CEEFB), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SizeConfig.safeBlockHorizontal * 4.5,
            SizeConfig.topPadding,
            SizeConfig.safeBlockHorizontal * 4.5,
            SizeConfig.topPadding * 2
          ),
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)
              ),
              color: Colors.white,
              elevation: 10.0,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:BorderRadius.circular(30.0),
                      child: Image.network(
                        widget.itemDetails['image'],
                        height: SizeConfig.screenHeight / 2.65,
                      )
                  ),
                  Expanded(
                    child: Container(
                      width: SizeConfig.screenWidth,
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: SizeConfig.safeBlockHorizontal * 5
                      ),
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Color(0xff4CCEFB),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'T-Shirt',
                                style: TextStyle(
                                  fontFamily: 'NovaSquare',
                                  fontSize: 30.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0
                                ),
                              ),
                              Text(
                                "\$${widget.itemDetails['price']}.00",
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontFamily: 'NovaSquare',
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            widget.itemDetails['name'],
                            style: TextStyle(
                              fontFamily: 'NovaSquare',
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          SizedBox(
                            width: SizeConfig.screenWidth,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              elevation: 8.0,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Color',
                                      style: TextStyle(
                                        fontFamily: 'NovaSquare',
                                        fontSize: 22,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 6.0),
                                      child: ColorGroupButton(productColors, selectProductColor),
                                    ),
                                    Text(
                                      'Size',
                                      style: TextStyle(
                                        fontFamily: 'NovaSquare',
                                        fontSize: 22,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Container(
                                      height: 55.0,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context,index){
                                          return Container(
                                            width: 45.0,
                                            margin: EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(100.0),
                                              border: Border.all(
                                                width: 2.0,
                                                style: BorderStyle.solid,
                                                color: Colors.black
                                              )
                                            ),
                                            child: Center(
                                              child: Text(
                                                widget.itemDetails['size'][index],
                                                style: TextStyle(
                                                  fontFamily: 'NovaSquare',
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              )
                                            ),
                                          );
                                        },
                                        itemCount: widget.itemDetails['size'].length,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          RaisedButton(onPressed: (){})
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
