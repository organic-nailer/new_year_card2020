import 'dart:async';
import 'dart:math';

import 'dart:js' as js;

import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_year_card_2020/viewModel.dart';

void main() {
  initializeApp(
    apiKey: "[YOUR_APIKEY]",
    authDomain: "[YOUR_AUTH_DOMAIN]",
    databaseURL: "[YOUR_DB_URL]",
    projectId: "[YOUR_PROJECT_ID]",
    storageBucket: "[YOUR_STORAGEBUCKET]",
    messagingSenderId: "[YOUR_MESSAGING_SENDER_ID]",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '年賀状 from Fastriver_org',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "NotoSansJP"
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("年賀状2020"),
              RaisedButton(
                child: Text("Play"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: "/"),
                        //builder: (context) => new MainPage(),
                        builder: (context) => new MyHomePage(),
                      )
                  );
                },
              ),
              RaisedButton(
                child: Text("遊び方"),
                onPressed: () => how2Play(context),
              ),
              Text("Created by",),
              Text("Fastriver_org", style: TextStyle(fontSize: 30),),
            ],
          ),
        ),
      ),
    );
  }
}

void how2Play(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("遊び方"),
          content: Text(
              "これは年賀状です。 \n \n"
                  + "穴のネズミがチーズを狙って飛び出してきます！あなたはそれを阻止するため、彼らをタップして退けなければなりません。\n"
                  + "但し、ネズミ以外は益虫だとされるため追い出してはいけません。\n\n"
                  + "なるべく長い間チーズを守り抜きましょう！！！"
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text("戻る")
            ),
          ],
        );
      },
      barrierDismissible: false
  );
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const double LIMIT = 1000;

class _MyHomePageState extends State<MyHomePage> {
  double cheese_locate;
  double limit;
  double basedLength;
  var stacks = List<Enemy>();

  StreamSubscription _gameOverListener;
  StreamSubscription _addEnemyListener;

  @override
  void initState() {
    super.initState();

    Timer.periodic(new Duration(milliseconds: 100), (t) {
      setState(() { });
      if(MainViewModel().isPauseFlag) t.cancel();
    });

    MainViewModel().start();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _gameOverListener = MainViewModel().gameOverStream.listen((data) {
      if(data) {
        gameOverDisplay(context, MainViewModel().score);
      }
    });

    _addEnemyListener = MainViewModel().addEnemyStream.listen((data) {
      if(data != null) {
        stacks.add((selectEnemy(data, cheese_locate, limit))..start());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            limit = constraints.biggest.width;
            basedLength = constraints.biggest.height > constraints.biggest.width ? constraints.biggest.height : constraints.biggest.width;
            cheese_locate = constraints.biggest.width * 0.8;
            return Center(
                child: Stack(
                  children: <Widget>[
                    background(constraints.biggest.height, constraints.biggest.width),
                    cheese(constraints.biggest.height, constraints.biggest.width),
                    Positioned.fill(
                      child: Stack(
                        children: stacks.mapIndexed<Widget>((i, s) => AnimatedPositioned(
                          child: new GestureDetector(
                            onTap: () => s.kill(),
                            child: Container(
                              height: basedLength * 0.15,
                              width: basedLength * 0.15,
                              child: s.killed ? Container() : Image.asset(s.img),
                            )
                          ),
                          duration: const Duration(milliseconds: 200),
                          bottom: basedLength * 0.05,
                          left: s.killed ? -1000 : s?.y,
                        )),
                      ),
                    ),
                    hole(constraints.biggest.height, constraints.biggest.width),
                    timerDisplay(),
                    scoreDisplay(),
                    tips(constraints.biggest.height),
                    /*Positioned( // for DEBUG
                      right: 0,
                      top: 0,
                      child: Text(
                        "constraint height: ${constraints.biggest.height} \n"
                            + "constraint width: ${constraints.biggest.width} \n"
                            + "cheese locate: $cheese_locate \n"
                            + "basedLength: $basedLength \n"
                            + "limit: $limit"
                      ),
                    )*/
                  ]
                )
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _addEnemyListener?.cancel();
    _gameOverListener?.cancel();
  }
}

const IMG_BACKGROUND = "img/bg.jpg";
const IMG_HOLE = "img/hole.png";

Positioned background(double height, double width) {
  if(height >= width) {
    return Positioned(
      bottom: 0,
      left: 0,
      height: height,
      child: Image.asset(IMG_BACKGROUND),
    );
  }
  else {
    return Positioned(
      bottom: 0,
      left: 0,
      width: width,
      child:Image.asset(IMG_BACKGROUND),
    );
  }
}

Positioned hole(double height, double width) {
  if(height >= width) {
    return Positioned(
        bottom: 0,
        left: 0,
        height: height * 0.25,
        child: Image.asset("img/hole.png")
    );
  }
  else {
    return Positioned(
        bottom: 0,
        left: 0,
        width: width * 0.125,
        child: Image.asset("img/hole.png")
    );
  }
}

Positioned cheese(double height, double width) {
  if(height >= width) {
    return Positioned(
        right: 0,
        bottom: 0,
        height: height * 0.2,
        child: Image.asset("img/cheese.png")
    );
  }
  else {
    return Positioned(
        bottom: 0,
        right: 0,
        width: width * 0.2,
        child: Image.asset("img/cheese.png")
    );
  }
}

Positioned timerDisplay() {
  return Positioned(
    top: 0,
    left: 0,
    child: StreamBuilder(
      stream: MainViewModel().elapsedTimeStream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if(!snapshot.hasData)
            return Text(0.toString());
        else {
          return Text(
              "TIME: ${snapshot.data / 1000.0} s",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50
              ),
          );
        }
        },
    ),
  );
}

Positioned scoreDisplay() {
  return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: StreamBuilder(
          stream: MainViewModel().scoreStream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if(!snapshot.hasData)
              return Text(
                0.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 200
                ),
              );
            else {
              return Text(
                  snapshot.data.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 200
                ),
              );
            }
          },
        ),
      )
  );
}

Positioned tips(double height) {
  return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: StreamBuilder(
          stream: MainViewModel().rewardStream,
          builder: (BuildContext context, AsyncSnapshot<Reward> snapshot) {
            if(!snapshot.hasData)
              return Container(
                height: 100,
                padding: EdgeInsets.only(top: height * 0.2),
                child: Card(
                  color: Colors.white,
                ),
              );
            else {
              return Container(
                padding: EdgeInsets.only(top: height * 0.2),
                child: Card(
                  color: Color(0x88ffffff),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(snapshot.data.img, height: 100,),
                        Text(snapshot.data.description)
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      )
  );
}

void gameOverDisplay(BuildContext context, int score) async {
  try {
    firestore().collection("Results").add({
      "score": score
    });
  } catch(e) {
    print(e);
  }
  showDialog(
      context: context,
    builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("ゲームオーバー"),
            content: Text("${HomeruText(score)}\n" + "スコア：$score"),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    share(score);
                  },
                  child: Text("Twitterで共有")
              ),
              new FlatButton(
                  onPressed: () async {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text("終わる")
              ),
            ],
          ),
        );
    },
    barrierDismissible: false
  );
}

String HomeruText(int score) {
  return score < 50 ? "残念だったね"
      : score < 100 ? "もうすこし がんばろう"
      : score < 200 ? "あけましておめでとう！"
      : score < 300 ? "おめでとう。今年はいいことないか、あるか、どっちかです。"
      : "💩";
}

void share(int score) {
  var tweetText = Uri.encodeComponent(
      "Fastriverからの年賀状、スコア：$score \n"
          + "https://year-greeting-condition2020.fastriver.dev/#/"
  );

  js.context.callMethod("open", ["https://twitter.com/intent/tweet?text=" + tweetText]);
}

class Enemy {
  double x;
  double y;
  double time;
  double speed;
  double _yLimit;
  double cheeseCoordinate;
  bool killed = false;
  String img;
  bool isMouse;

  Enemy(this.cheeseCoordinate, this._yLimit, this.img, this.isMouse) {
    speed = (Random().nextInt(20) as double) + 10;
  }

  void start() {
    time = 0;
    y = -100;
    new Timer.periodic(
        Duration(milliseconds: 100),
        (t) {
          if(MainViewModel().isPauseFlag || killed) t.cancel();

          time += 0.1;
          y = speed * time * calcSpeedCoefficient(time);

          if(isMouse && y > cheeseCoordinate) {
            killed = true;
            t.cancel();
            MainViewModel().cheeseEaten("by Enemy($img)");
          }

          if(y > _yLimit) {
            killed = true;
            t.cancel();
          }
        }
    );
  }

  void kill() {
    killed = true;
    time = 0;
    print("killed: ${this.img}, ${killed}");
    if(isMouse) MainViewModel().mouseKilled();
    else MainViewModel().otherKilled("$img killed");
  }
}


double calcSpeedCoefficient(double time) {
  return sqrt((time + 20000 ) / 500.0);
}

Enemy selectEnemy(int type, double cheeseCoordinate, double limit) {
  switch(type) {
    case 0:
      return new RogiInu(cheeseCoordinate, limit);
    case 1:
      return new KCSDragon(cheeseCoordinate, limit);
    case 2:
      return new IkidaneZushi(cheeseCoordinate, limit);
    case 3:
      return new Daihyo(cheeseCoordinate, limit);
    case 4:
      return new KoikeYuriko(cheeseCoordinate, limit);
    case 5:
      return new OrdinaryMouse(cheeseCoordinate, limit);
    case 6:
      return new Urayasu(cheeseCoordinate, limit);
  }
  return new Nazo(cheeseCoordinate, limit);
}

class RogiInu extends Enemy {
  RogiInu(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/inu.png", false);
}

class KCSDragon extends Enemy {
  KCSDragon(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/dragon.png", false);
}


class IkidaneZushi extends Enemy {
  IkidaneZushi(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/fish.png", false);
}


class Daihyo extends Enemy {
  Daihyo(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/daihyo.png", false);
}

class KoikeYuriko extends Enemy {
  KoikeYuriko(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/koike.png", true);
}

class OrdinaryMouse extends Enemy {
  OrdinaryMouse(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/mouse.png", true);
}
class Urayasu extends Enemy {
  Urayasu(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/urayasu.png", true);
}

class Nazo extends Enemy {
  Nazo(double cheeseCoordinate, double limit): super(cheeseCoordinate, limit, "img/cheese.png", false);
}


extension MyList<E, T> on List<T> {
  //https://stackoverflow.com/questions/54898767/enumerate-or-map-through-a-list-with-index-and-value-in-dart のやつを拡張関数に書き換えたやつ
  List<E> mapIndexed<E>(E Function(int index, T item) f) {
    var index = 0;
    var ret = List<E>();

    for (final item in this) {
      ret.add(f(index, item));
      index = index + 1;
    }
    return ret;
  }

  List<T> nonNull() {
    return this.where((t) => t != null).toList();
  }
}
