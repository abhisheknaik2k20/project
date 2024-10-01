import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

void main() {
  runApp(MaterialApp(
    home: RewardsTimeline(),
  ));
}

class RewardsTimeline extends StatelessWidget {
  final int currSteps = 350; // Current steps
  final List<int> rewardSteps = [100, 300, 500, 1000, 1200]; // Step milestones

  final List<Reward> rewards = [
    Reward("Bronze Badge", "Complete 100 steps", Icons.emoji_events, Colors.brown),
    Reward("Silver Badge", "Complete 300 steps", Icons.emoji_events, Colors.grey),
    Reward("Gold Badge", "Complete 500 steps", Icons.emoji_events, Colors.amber),
    Reward("Platinum Badge", "Complete 1000 steps", Icons.emoji_events, Colors.blue),
    Reward("Diamond Badge", "Complete 1200 steps", Icons.emoji_events, Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards Timeline')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 15, 0, 0),
        child: ListView.builder(
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            // Determine if the current reward step is achieved
            bool isAchieved = currSteps >= rewardSteps[index];
            print(isAchieved);
            print(index);

            // Determine if the line after the current reward should be green
            bool isNextAchieved = (index < rewardSteps.length - 1) && (currSteps >= rewardSteps[index + 1]);

            return TimelineTile(
              alignment: TimelineAlign.start,
              isFirst: index == 0,
              isLast: index == rewards.length - 1,
              indicatorStyle: IndicatorStyle(
                width: 60, // Increase indicator size
                height: 60, // Increase height
                color: rewards[index].color,
                iconStyle: IconStyle(
                  iconData: rewards[index].icon,
                  color: isAchieved ? Colors.green : Colors.white,
                  fontSize: 30, // Increase icon size
                ),
              ),
              beforeLineStyle: LineStyle(
                color: isAchieved ? Colors.green : Colors.grey, // If achieved, turn green
                thickness: 4, // Line thickness
              ),
              afterLineStyle: LineStyle(
                color: isNextAchieved ? Colors.green : Colors.grey, // Turn green if next step is achieved
                thickness: 4, // Line thickness
              ),
              endChild: Padding(
                padding: const EdgeInsets.all(24.0), // Increase padding around text
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rewards[index].title,
                          style: TextStyle(
                            fontSize: 22, // Increase font size for title
                            fontWeight: FontWeight.bold,
                            color: isAchieved ? Colors.green : Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          rewards[index].description,
                          style: TextStyle(
                            fontSize: 18, // Increase font size for description
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    isAchieved ? Icon(Icons.done_all_rounded) : Container(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Reward {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Reward(this.title, this.description, this.icon, this.color);
}
