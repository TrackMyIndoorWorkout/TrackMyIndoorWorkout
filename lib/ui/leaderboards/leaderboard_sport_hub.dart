import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import 'sport_leaderboard.dart';

class LeaderboardSportHubScreen extends StatefulWidget {
  final List<String> sports;

  LeaderboardSportHubScreen({Key key, @required this.sports})
      : assert(sports != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LeaderboardSportHubScreenState(sports: sports);
}

class LeaderboardSportHubScreenState extends State<LeaderboardSportHubScreen> {
  final List<String> sports;
  double _sizeDefault;
  TextStyle _textStyle;

  LeaderboardSportHubScreenState({@required this.sports}) : assert(sports != null);

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline3.apply(
      fontFamily: FONT_FAMILY,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize * 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard Sports')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sports
              .map(
                (sport) => Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: () => Get.to(SportLeaderboardScreen(sport: sport)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextOneLine(
                          sport,
                          style: _textStyle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Icon(Icons.chevron_right, size: _sizeDefault),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
