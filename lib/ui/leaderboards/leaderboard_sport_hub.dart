import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import 'sport_leaderboard.dart';

class LeaderboardSportHubScreen extends StatefulWidget {
  final List<String> sports;

  const LeaderboardSportHubScreen({Key? key, required this.sports}) : super(key: key);

  @override
  LeaderboardSportHubScreenState createState() => LeaderboardSportHubScreenState();
}

class LeaderboardSportHubScreenState extends State<LeaderboardSportHubScreen> {
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headlineMedium!.apply(fontFamily: fontFamily);
    _sizeDefault = _textStyle.fontSize! * 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard Sports')),
      body: ListView(
        children: widget.sports
            .map(
              (sport) => Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () => Get.to(() => SportLeaderboardScreen(sport: sport)),
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
    );
  }
}
