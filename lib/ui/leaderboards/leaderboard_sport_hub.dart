import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import 'sport_leaderboard.dart';

class LeaderboardSportHubScreen extends StatefulWidget {
  final List<String> sports;

  const LeaderboardSportHubScreen({super.key, required this.sports});

  @override
  LeaderboardSportHubScreenState createState() => LeaderboardSportHubScreenState();
}

class LeaderboardSportHubScreenState extends State<LeaderboardSportHubScreen> {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );
    final sizeDefault = textStyle.fontSize! * 2;

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
                        style: textStyle,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Icon(Icons.chevron_right, size: sizeDefault),
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
