import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:flutter_tilt/flutter_tilt.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool show = true;
  DateTime currentDate = DateTime.now();
  List<FlSpot> _sleepData = [
    FlSpot(0, 6),
    FlSpot(1, 5),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
  ];

  List<FlSpot> _stepData = [
    FlSpot(0, 500),
    FlSpot(1, 100),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
  ];

  void toggle() {
    setState(() {
      show = !show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Tracker")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: toggle,
              child: Text(show ? "Steps Graph" : "Sleep Graph"),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              padding: EdgeInsets.all(20),
              child: show ? sleepGraph() : stepGraph(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15)
              ),
              height: 100,
              width: 200,
              child: Tilt(
                tiltConfig: TiltConfig(disable: false),
                lightConfig: LightConfig(disable: true),
                shadowConfig: ShadowConfig(disable: true),
                child: ElevatedButton(
                  onPressed: (){
                    _showInputDialog(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      color: Colors.blueAccent,
                    ),
                    width: 200,
                    height: 100,
                    alignment: Alignment.center,
        
                    child: const Text(
                      'Check Health',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    // Create a GlobalKey for the Form

    final _formKey = GlobalKey<FormState>();
    List<String> list = ['Age', 'Duration of sleep', 'Quality of sleep', 'Physical activity', 'Stress level','Number of steps'];

    // Initialize variables to hold input values
    String selectedGender = 'Male'; // Default value
    List<double> integerValues = List<double>.filled(7, 0, growable: true);
    integerValues.insert(0, 0);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Form'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for Gender
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(labelText: 'Select Gender'),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedGender = newValue;
                        selectedGender=='Male'?integerValues.insert(0, 0):integerValues.insert(0, 1);
                      }
                    },
                    items: <String>['Male', 'Female']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 7 Integer Fields
                  for (int i = 0; i < 6; i++)
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: list[i],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        }
                        // Optional: Check if the input is a valid integer
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null; // Return null if input is valid
                      },
                      onChanged: (value) {
                        // Convert input value to integer
                        integerValues[i+1] = double.tryParse(value) ?? 0;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Perform actions with the input values
                  print('Selected Gender: $selectedGender');
                  print('Integer Values: $integerValues');
                  double temp = integerValues[0]*(-0.91)+integerValues[1]*(0.91)+integerValues[2]*(-0.008)+
                      integerValues[3]*(0.93)+integerValues[4]*(0.91)+integerValues[5]*(0.15)+integerValues[6]*(-0.001)+0.5;
                  print(temp);
                  integerValues.clear();
                  Navigator.of(context).pop();
                  showDialog(context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          actions: [
                            ElevatedButton(onPressed: () {
                                Navigator.pop(context);
                            }, child: Text("OK"))
                          ],
                          title: Text("Health Message"),
                          content: Text(temp<95&&temp>80?"No anomolies detected":"Anomolies Detected", style: TextStyle(fontSize: 20),),
                        );
                      });
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                integerValues.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget sleepGraph() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _sleepData,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true),
          ),
        ],
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text("30");
                  case 1:
                    return Text('1');
                  case 2:
                    return Text('2');
                  case 3:
                    return Text('3');
                  case 4:
                    return Text('4');
                  case 5:
                    return Text('5');
                  case 6:
                    return Text('6');
                  default:
                    return Text('7');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} hrs');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 10,
      ),
      curve: Curves.linear,
    );
  }

  Widget stepGraph() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _stepData,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true),
          ),
        ],
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text("30");
                  case 1:
                    return Text('1');
                  case 2:
                    return Text('2');
                  case 3:
                    return Text('3');
                  case 4:
                    return Text('4');
                  case 5:
                    return Text('5');
                  case 6:
                    return Text('6');
                  default:
                    return Text('7');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} Steps');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 4000,
      ),
      curve: Curves.linear,
    );
  }

}
