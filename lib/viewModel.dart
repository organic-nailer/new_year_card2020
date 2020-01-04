import 'dart:async';

import 'dart:math';

class MainViewModel {
  static final MainViewModel _mainViewModel = MainViewModel._internal();
  MainViewModel._internal();

  factory MainViewModel() {
    return _mainViewModel;
  }
/*
  final _startController = StreamController<bool>.broadcast();
  Sink get startSink => _startController;
  Stream<bool> get startStream => _startController.stream;
*/
  final _gameOverController = StreamController<bool>.broadcast();
  Sink get gameOverSink => _gameOverController;
  Stream<bool> get gameOverStream => _gameOverController.stream;

  final _elapsedTimeController = StreamController<int>.broadcast();
  Sink get elapsedTimeSink => _elapsedTimeController;
  Stream<int> get elapsedTimeStream => _elapsedTimeController.stream;

  final _scoreController = StreamController<int>.broadcast();
  Sink get scoreSink => _scoreController;
  Stream<int> get scoreStream => _scoreController.stream;

  final _rewardController = StreamController<Reward>.broadcast();
  Sink get rewardSink => _rewardController;
  Stream<Reward> get rewardStream => _rewardController.stream;

  final _pauseController = StreamController<bool>.broadcast();
  Sink get pauseOverSink => _pauseController;
  Stream<bool> get pauseStream => _pauseController.stream;

  final _addEnemyController = StreamController<int>.broadcast();
  Sink get addEnemySink => _addEnemyController;
  Stream<int> get addEnemyStream => _addEnemyController.stream;

  int score;

  //Timer _timer;
  int time;

  bool isPauseFlag =false;

  void start() {
    score = 0;
    time = 0;
    isPauseFlag = false;
    gameOverSink.add(false);
    scoreSink.add(score);
    //startSink.add(true);

    new Timer.periodic(Duration(milliseconds: 100), (t) {
      time += 100;
      elapsedTimeSink.add(time);
      if(isPauseFlag) t.cancel();

      if(Random().nextInt(calcEnemySpan(time)) == 0) {
        addEnemy();
      }

      if((time % 70000) % 10000 == 0) {
        changeTips(((time % 70000) / 10000).round());
      }
    });
  }

  void stop() {
    isPauseFlag = true;
    _addEnemyController.close();
  }

  void mouseKilled() {
    score += 10;
    scoreSink.add(score);
  }

  void otherKilled(String reason) {
    isPauseFlag = true;
    print("otherKilled: $reason");
    gameOverSink.add(true);
  }

  void cheeseEaten(String reason) {
    isPauseFlag = true;
    print("cheeseEaten: $reason");
    gameOverSink.add(true);
  }

  void addEnemy() {
    var type = Random().nextInt(7);
    addEnemySink.add(type);
  }

  void changeTips(int type) {
    //var type = Random().nextInt(7);
    print("Reward: $type");
    rewardSink.add(Rewards[type]);
  }
}


int calcEnemySpan(int time) {
  return (500000.0 / (time + 20000.0)).round();
}

class Reward {
  String img;
  String description;

  Reward(this.img, this.description);
}

var Rewards = [
  Reward("img/dragon.png", "KCSのキャラクター。生態は謎。"),
  Reward("img/fish.png", "某GMSの寿司コーナーで暴れる粋な魚。"),
  Reward("img/inu.png", "ロ技研のアイドル。毒舌。猫願望がある？"),
  Reward("img/koike.png", "「バンクシー作品らしきネズミの絵」"),
  Reward("img/mouse.png", "ペイントで描いた。他もそう。"),
  Reward("img/daihyo.png", "我らが代表。"),
  Reward("img/urayasu.png", "消されそう。")
];