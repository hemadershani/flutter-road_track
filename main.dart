import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(RoadRiskApp());
}

class RoadRiskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      home: RiskFormScreen(),
    );
  }
}

class RiskFormScreen extends StatefulWidget {
  @override
  _RiskFormScreenState createState() => _RiskFormScreenState();
}

class _RiskFormScreenState extends State<RiskFormScreen> {
  String roadType = "Highway";
  String weather = "Clear";
  String traffic = "Low";
  String lighting = "Day";
  bool potholes = false;

  int calculateRisk() {
    int score = 0;

    if (roadType == "Highway") score += 2;
    if (weather == "Rain") score += 3;
    if (weather == "Fog") score += 4;
    if (traffic == "Medium") score += 2;
    if (traffic == "High") score += 4;
    if (lighting == "Night") score += 3;
    if (potholes) score += 3;

    return score;
  }

  String getRiskLevel(int score) {
    if (score <= 4) return "Low";
    if (score <= 8) return "Medium";
    return "High";
  }

  String getSuggestion(String level) {
    if (level == "Low") return "Drive normally but stay alert.";
    if (level == "Medium") return "Reduce speed and stay cautious.";
    return "High risk! Avoid travel if possible.";
  }

  Future<void> saveReport(String level) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("history") ?? [];
    history.add("$level Risk - ${DateTime.now().toString().substring(0,16)}");
    await prefs.setStringList("history", history);
  }

  void submit() async {
    int score = calculateRisk();
    String level = getRiskLevel(score);
    await saveReport(level);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          level: level,
          suggestion: getSuggestion(level),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: SizedBox(),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 147, 27, 190), Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Road Risk Predictor",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                buildDropdown("Road Type", roadType,
                    ["Highway", "City", "Village"], (val) {
                  setState(() => roadType = val!);
                }),
                buildDropdown("Weather", weather,
                    ["Clear", "Rain", "Fog"], (val) {
                  setState(() => weather = val!);
                }),
                buildDropdown("Traffic Level", traffic,
                    ["Low", "Medium", "High"], (val) {
                  setState(() => traffic = val!);
                }),
                buildDropdown("Lighting", lighting,
                    ["Day", "Night"], (val) {
                  setState(() => lighting = val!);
                }),
                SwitchListTile(
                  activeColor: Colors.orange,
                  title: Text("Potholes Present",
                      style: TextStyle(color: Colors.white)),
                  value: potholes,
                  onChanged: (val) {
                    setState(() => potholes = val);
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: submit,
                  child: Text("Predict Risk",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final String level;
  final String suggestion;

  ResultScreen(
      {required this.score, required this.level, required this.suggestion});

  Color getColor() {
    if (level == "Low") return Colors.green;
    if (level == "Medium") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Risk Score: $score",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Risk Level: $level",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: getColor())),
                  SizedBox(height: 15),
                  Text(
                    suggestion,
                    textAlign: TextAlign.center,
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