import 'package:flutter/material.dart';

typedef ShapeAlg = Shape Function(
    double shoulder, double bust, double waist, double hips);

class ShapeCategorizer extends StatefulWidget {
  const ShapeCategorizer({super.key});

  @override
  State<ShapeCategorizer> createState() => _ShapeCategorizerState();
}

class _ShapeCategorizerState extends State<ShapeCategorizer> {
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _bustController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();

  Map<String, ShapeAlg> algorithms = {};

  String dropdownValue = 'Basic';

  @override
  void initState() {
    algorithms = {
      'Basic': basicAlgorithm,
      'Scoring Algorithm': scoringAlgorithm,
      'Threshold': threshHoldAlgorithm,
      'Relative proportion': relativeProportionAlgorithm,
      'Gemini': geminiAlgorithm,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shape Categorizer'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40),
                const Text('Enter your measurements in inches',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                //Dropdown button for user to select an algorithm
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text('Select Algorithm:'),
                      const SizedBox(width: 16,),
                      Expanded(
                        child : DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          isDense: false,
                          isExpanded: true,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items:
                              algorithms.keys.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _shoulderController,
                    decoration: const InputDecoration(
                      labelText: 'Shoulder',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _bustController,
                    decoration: const InputDecoration(
                      labelText: 'Bust',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _waistController,
                    decoration: const InputDecoration(
                      labelText: 'Waist',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _hipsController,
                    decoration: const InputDecoration(
                      labelText: 'Hips',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    double shoulder = double.parse(_shoulderController.text);
                    double bust = double.parse(_bustController.text);
                    double waist = double.parse(_waistController.text);
                    double hips = double.parse(_hipsController.text);

                    Shape shape =
                        algorithms[dropdownValue]!(shoulder, bust, waist, hips);

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Shape Categorization'),
                          content: Text('Your shape is: ${shape.name.toUpperCase()}'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Categorize Shape'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Shape basicAlgorithm(
      double shoulder, double bust, double waist, double hips) {
    if (shoulder < bust && bust < waist && waist < hips) {
      return Shape.pear;
    } else if (shoulder > bust && bust > waist && waist > hips) {
      return Shape.invertedTriangle;
    } else if (waist > bust &&
        waist > hips &&
        bust < shoulder &&
        hips < shoulder) {
      return Shape.apple;
    } else if ((bust - waist).abs() <= 1 && (waist - hips).abs() <= 1) {
      return Shape.rectangle;
    } else if ((bust - hips).abs() <= 1 &&
        (shoulder - hips).abs() <= 1 &&
        waist < bust) {
      return Shape.hourGlass;
    }
    // Default case
    return Shape.rectangle;
  }

  Shape scoringAlgorithm(
      double shoulder, double bust, double waist, double hips) {
    Map<Shape, int> scores = {
      Shape.pear: 0,
      Shape.invertedTriangle: 0,
      Shape.apple: 0,
      Shape.rectangle: 0,
      Shape.hourGlass: 0,
    };

    // Calculate differences between measurements
    double shoulderDiff = (shoulder - bust).abs();
    double bustDiff = (bust - waist).abs();
    double waistDiff = (waist - hips).abs();
    double hipsDiff = (hips - shoulder).abs();

    // Calculate scores based on the differences
    scores[Shape.pear] =
        shoulder < bust && bust < waist && waist < hips ? 1 : 0;
    scores[Shape.invertedTriangle] =
        shoulder > bust && bust > waist && waist > hips ? 1 : 0;
    scores[Shape.apple] =
        waist > bust && waist > hips && bust < shoulder && hips < shoulder
            ? 1
            : 0;
    scores[Shape.rectangle] =
        (bustDiff <= 1 && waistDiff <= 1 && hipsDiff <= 1) ? 1 : 0;
    scores[Shape.hourGlass] =
        (waistDiff > 1 && bustDiff < waistDiff && hipsDiff < waistDiff) ? 1 : 0;

    // Find the shape with the highest score
    Shape result =
        scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return result;
  }

  Shape threshHoldAlgorithm(
      double shoulder, double bust, double waist, double hips) {
    // Define thresholds for each shape
    const double pearThreshold = 1.0;
    const double invertedTriangleThreshold = 1.0;
    const double appleThreshold = 1.0;
    const double rectangleThreshold = 1.0;
    const double hourGlassWaistThreshold = 1.0;

    // Calculate differences between measurements
    double shoulderDiff = (shoulder - bust).abs();
    double bustDiff = (bust - waist).abs();
    double waistDiff = (waist - hips).abs();
    double hipsDiff = (hips - shoulder).abs();

    // Check if the measurements fit the criteria for each shape
    if (shoulder < bust - pearThreshold &&
        bust < waist - pearThreshold &&
        waist < hips - pearThreshold) {
      return Shape.pear;
    } else if (shoulder > bust + invertedTriangleThreshold &&
        bust > waist + invertedTriangleThreshold &&
        waist > hips + invertedTriangleThreshold) {
      return Shape.invertedTriangle;
    } else if (waist > bust + appleThreshold &&
        waist > hips + appleThreshold &&
        bust < shoulder - appleThreshold &&
        hips < shoulder - appleThreshold) {
      return Shape.apple;
    } else if (waistDiff > hourGlassWaistThreshold &&
        bustDiff < waistDiff &&
        hipsDiff < waistDiff) {
      return Shape.hourGlass;
    } else if (bustDiff <= rectangleThreshold &&
        waistDiff <= rectangleThreshold &&
        hipsDiff <= rectangleThreshold) {
      return Shape.rectangle;
    }

    // Default case
    return Shape.rectangle;
  }

  Shape relativeProportionAlgorithm(
      double shoulder, double bust, double waist, double hips) {
    // Calculate proportions between measurements
    double bustToShoulderRatio = bust / shoulder;
    double waistToBustRatio = waist / bust;
    double hipsToWaistRatio = hips / waist;
    double shoulderToHipsRatio = shoulder / hips;

    // Define thresholds for each shape
    const double pearThreshold = 0.8;
    const double invertedTriangleThreshold = 1.2;
    const double appleThreshold = 1.1;
    const double hourGlassWaistThreshold = 0.9;

    // Check if the proportions fit the criteria for each shape
    if (shoulderToHipsRatio > pearThreshold &&
        waistToBustRatio < pearThreshold &&
        hipsToWaistRatio > pearThreshold) {
      return Shape.pear;
    } else if (shoulderToHipsRatio < invertedTriangleThreshold &&
        waistToBustRatio > invertedTriangleThreshold &&
        hipsToWaistRatio < invertedTriangleThreshold) {
      return Shape.invertedTriangle;
    } else if (waistToBustRatio > appleThreshold &&
        hipsToWaistRatio > appleThreshold &&
        bustToShoulderRatio < appleThreshold &&
        shoulderToHipsRatio > appleThreshold) {
      return Shape.apple;
    } else if (waistToBustRatio < hourGlassWaistThreshold &&
        hipsToWaistRatio < hourGlassWaistThreshold &&
        bustToShoulderRatio > hourGlassWaistThreshold &&
        shoulderToHipsRatio > hourGlassWaistThreshold) {
      return Shape.hourGlass;
    }

    // Default case
    return Shape.rectangle;
  }

  Shape geminiAlgorithm(double shoulder, double bust, double waist, double hips) {
    // Calculate size differences
    double bustWaistDiff = bust - waist;
    double hipWaistDiff = hips - waist;
    double shoulderHipDiff = shoulder - hips;

    // Classify based on differences
    if (bustWaistDiff.abs() <= 5 && hipWaistDiff.abs() <= 5) {
      return Shape.rectangle;
    } else if (hipWaistDiff > bustWaistDiff && shoulderHipDiff <= 0) {
      return Shape.pear;
    } else if (bustWaistDiff > hipWaistDiff && shoulderHipDiff > 0) {
      return Shape.invertedTriangle;
    } else if (bustWaistDiff > hipWaistDiff && hipWaistDiff > 0) {
      return Shape.hourGlass;
    } else {
      return Shape.apple;
    }
  }
}

enum Shape {
  rectangle,
  hourGlass,
  invertedTriangle,
  pear,
  apple,
}
