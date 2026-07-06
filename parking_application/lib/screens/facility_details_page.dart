import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FacilityDetailsPage extends StatefulWidget {
  const FacilityDetailsPage({Key? key}) : super(key: key);

  @override
  State<FacilityDetailsPage> createState() => _FacilityDetailsPageState();
}

class _FacilityDetailsPageState extends State<FacilityDetailsPage> {
  String selectedDay = 'Monday';
  bool loadingPredictions = true;

  @override
  void initState() {
    super.initState();
  } 
  
  List<FlSpot> buildPredictionSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < predictions.length; i++) {
      spots.add(FlSpot(i.toDouble(), predictions[i]['occupied'].toDouble(),),);
    }
    return spots;
  }

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  Map<String, dynamic>?facility;
  Map<String, dynamic>? facilityDetails;
  bool loading = true;
  List<Map<String, dynamic>> predictions = [];

  Future<void> fetchFacilityDetails() async {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/facilities/${facility!['id']}/?day=$selectedDay'),);
      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          setState(() {
            facilityDetails = data;
            predictions = List<Map<String, dynamic>>.from(data['predictions'],);
          });
          loading = false;
        });
      } 
    } 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    print("Facility Arguments = $args");

    if (args != null && facility == null) {
      facility = args as Map<String, dynamic>;
      fetchFacilityDetails();
  }
}
  @override
  Widget build(BuildContext context) {
    if (facility == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No facility selected",),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&q=80&w=800',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.5),
                colorBlendMode: BlendMode.darken,
              ),
              title:  Text(facility!['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Available', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text( 
                               loading ? 'Loading...' : '${facilityDetails!['available_slots']} /' '${facilityDetails!['total_slots']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green,),),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Live Slots Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Updated Live Slots Preview Grid
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Middle Dashed Line replacement
                        Container(width: 2, height: 260, color: Colors.grey.withValues(alpha: 0.3)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                _buildSlot(true, 'A1'),
                                const SizedBox(height: 16),
                                _buildSlot(false, 'B1'),
                                const SizedBox(height: 16),
                                _buildSlot(true, 'C1'),
                              ],
                            ),
                            const SizedBox(width: 40), 
                            Column(
                              children: [
                                _buildSlot(false, 'A2'),
                                const SizedBox(height: 16),
                                _buildSlot(true, 'B2'),
                                const SizedBox(height: 16),
                                _buildSlot(false, 'C2'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Added Dropdown Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Occupancy Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedDay,
                            icon: const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            items: days.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(value),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) async {
                              selectedDay = newValue!;
                              await fetchFacilityDetails();
                              setState(() {
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Updated Chart with Axes and realism
                  Container(
                    height: 220,
                    padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot){
                                return LineTooltipItem(
                                 '${spot.y.toInt()}occupied', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.1),
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() % 4 == 0 && value.toInt() < predictions.length){
                                  return Padding(padding: const EdgeInsets.only(top: 8,), child: Text(predictions[value.toInt()]['time'], style: const TextStyle(color: Colors.grey, fontSize: 10,),),);
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(predictions.length, (index) => FlSpot(index.toDouble(), predictions[index]['occupied'].toDouble(),),),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: predictions.isEmpty ? 0 : (predictions.length - 1).toDouble(),
                        minY: 0,
                        maxY: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(bool occupied, String id) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: occupied ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
        border: Border.all(
          color: occupied ? Colors.red.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (occupied) BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
          if (!occupied) BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1),
        ]
      ),
      child: Center(
        child: occupied
            ? const Icon(Icons.directions_car, color: Colors.red, size: 32)
            : Text(id, style: TextStyle(color: Colors.green.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
      ),
    );
  }
}