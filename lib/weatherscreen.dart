import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/additional_info_item.dart';
import 'package:weatherapp/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/secrets.dart';

class Weatherscreen extends StatefulWidget {
const Weatherscreen({super.key});

  @override
  State<Weatherscreen> createState() => _WeatherscreenState();
}

class _WeatherscreenState extends State<Weatherscreen> {
  
  
Future<Map<String , dynamic>> getCurrentWeather() async {
  try {

  String cityName = 'London';
  final res = await http.get(
    Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherAPIKey')
    );
    
    final data = jsonDecode(res.body);

    if(data['cod'] != '200'){
      throw 'An unexpected error ocuur';
    }
    
    return data;
    
      
   
  } catch (e) {
    throw e.toString();
  }
  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
                 IconButton(
                  onPressed: () {
                    setState(() {

                      
                      
                    });
                  }, 
                  icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder:(context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];

          final currentSKy = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];

          final currentWindSpeed = currentWeatherData['wind']['speed'];

          final currentHumidity = currentWeatherData['main']['humidity'];

          return Column(
          children: [
            SizedBox(
               width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('$currentTemp K',style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold 
                      ),
                      ),
                        const SizedBox(
                        height: 16,
                      ),
                        Icon(
                       currentSKy == 'Clouds' || currentSKy == 'Rain' ?
                        Icons.cloud : Icons.sunny,
                        size: 64,
                      ),
                        Text(
                        currentSKy,
                        style: const TextStyle(
                          fontSize: 20
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 20,
            ),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Hourly Forecast",style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),),
            ),
            const SizedBox(
              height: 8,
            ),

            SizedBox( 
              height: 120,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index){
                  final hourlyForecast = data['list'][index+1];
                  final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                  return HourlyForecastItem(
                    time: DateFormat.j().format(time), 
                    temperature: hourlyForecast['main']['temp'].toString(), 
                    icon: hourlySky  == 'Clouds' || hourlySky == 'Rain'
                       ? Icons.cloud
                      : Icons.sunny,
                    );
                }),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Additional Information",style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),),
              const SizedBox(
              height: 16,
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AdditionalInfoItem(
                  icon: Icons.water_drop,
                  label: "Humidity",
                  value: currentHumidity.toString(),),
                AdditionalInfoItem(
                  icon: Icons.air,
                  label: "Wind Speed",
                  value: currentWindSpeed.toString(),
                ),
                AdditionalInfoItem(
                  icon: Icons.beach_access,
                  label: "Pressure",
                  value: currentPressure.toString(),
                )
              ],
            )
          ],
        );
        },
      ),

    );
    
  }
}


