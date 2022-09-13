import 'dart:async';
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';

import 'models/CurrentCityDataModel.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:intl/intl.dart';

import 'models/ForcastDaysModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController et_cityName = TextEditingController();
  var apiKey = "a304b45cb82e8e2b163d9f7185187deb";
  var cityName = "tabriz";
  var lat;
  var lon;

  late StreamController<CurrentCityDataModel> currentWeatherFuture=StreamController<CurrentCityDataModel>();
  late StreamController<List<ForcastDaysModel>> streamForcastDays;

  int _theme = 0;
  void change_theme() {
    setState(() {
      if (_theme == 0) {
        _theme = 1;
      } else {
        _theme = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    sendRequestCurrentWeather(cityName);
    streamForcastDays = StreamController<List<ForcastDaysModel>>();
  }

  void sendRequestCurrentWeather(
      String cityName) async {
    var response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {'q': cityName, 'appid': apiKey, 'units': 'metric'});

    lat = response.data['coord']['lat'];
    lon = response.data['coord']['lon'];

    var dataModel = CurrentCityDataModel(
      response.data['name'],
      response.data['coord']['lon'],
      response.data['coord']['lat'],
      response.data['weather'][0]['main'],
      response.data['weather'][0]['description'],
      response.data['main']['temp'],
      response.data['main']['temp_min'],
      response.data['main']['temp_max'],
      response.data['main']['pressure'],
      response.data['main']['humidity'],
      response.data['wind']['speed'],
      response.data['dt'],
      response.data['sys']['country'],
      response.data['sys']['sunrise'],
      response.data['sys']['sunset'],
      response.data['weather'][0]['icon'],
    );

    currentWeatherFuture.add(dataModel);

  }

  void sendRequest7dayForcast(lat, lon) async {
    List<ForcastDaysModel> _list = [];
    var respons = await Dio().get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric'
        });
    int counter_item = 0;
    for (int i = 0; i < respons.data['list'].length; i++) {
      var model = respons.data['list'][i];

      var dt1 = model['dt_txt'].split(" ")[0].split("-")[1];
      var dt2 = model['dt_txt'].split(" ")[0].split("-")[2];

      var dt3 = dt1.toString() + '/' + dt2.toString();

      ForcastDaysModel forcastmodeldata = ForcastDaysModel(
        dt3,
        model['main']['temp'],
        model['weather'][0]['main'],
        model['weather'][0]['description'],
        model['weather'][0]['icon'],
      );

      if (counter_item == 0) {
        _list.add(forcastmodeldata);
      } else if (counter_item == 7) {
        counter_item = -1;
      }

      counter_item++;
    }
    streamForcastDays.add(_list);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: _theme == 0 ? Brightness.dark : Brightness.light),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Whether App',
              style: TextStyle(//color: Colors.white38
              )),
          // backgroundColor: Colors.black,
          actions: [
            GestureDetector(
              onTap: change_theme,
              child: Icon(_theme == 0 ? Icons.wb_sunny : Icons.brightness_2),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('setting'),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.settings),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('account'),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.account_balance),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('exit'),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.exit_to_app),
                      ],
                    ),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 3) {
                  SystemNavigator.pop();
                }
              },
            )
          ],
          elevation: 0,
        ),
        body: StreamBuilder<CurrentCityDataModel>(
          stream: currentWeatherFuture.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              CurrentCityDataModel? CityDatas = snapshot.data;
              sendRequest7dayForcast(lat, lon);
              final formatter = DateFormat.jm();
              var SunRise = formatter.format(
                  new DateTime.fromMicrosecondsSinceEpoch(
                      CityDatas!.sunrise * 1000,
                      isUtc: true));
              var SunSet = formatter.format(
                  new DateTime.fromMicrosecondsSinceEpoch(
                      CityDatas!.sunset * 1000,
                      isUtc: true));

              return Container(
                // color: Colors.black,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(_theme == 0
                          ? 'assets/images/bg1.jpg'
                          : 'assets/images/bg2.jpg'),
                      fit: BoxFit.cover),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(

                        child: Column(

                            children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {

                                            sendRequestCurrentWeather(
                                                et_cityName.text);
                                      });
                                    },
                                    child: Text('Find')),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: TextField(
                                        controller: et_cityName,
                                        decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText: 'type a city name ... '),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              CityDatas!.cityName,
                              style: TextStyle(
                                //color: Colors.white,
                                  fontSize: 30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              CityDatas!.discription,
                              style: TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Image(
                                  image: NetworkImage(
                                      'https://openweathermap.org/img/wn/' +
                                          CityDatas!.icon +
                                          '@2x.png'),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              CityDatas.temp.toString() + '\u00B0',
                              style: TextStyle(
                                fontSize: 75, //color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Max',
                                    style: TextStyle(
                                      fontSize: 15, //color: Colors.white38
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      CityDatas.temp_max.toString() + '\u00B0',
                                      style: TextStyle(
                                        fontSize: 15, //color: Colors.white
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  height: 35,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Min',
                                    style: TextStyle(
                                      fontSize: 15, //color: Colors.white38
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      CityDatas.temp_min.toString() + '\u00B0',
                                      style: TextStyle(
                                        fontSize: 15, //color: Colors.white
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                height: 115,
                                child: Center(
                                  child: StreamBuilder<List<ForcastDaysModel>>(
                                    stream: streamForcastDays.stream,
                                    builder: ((context, snapshot) {
                                      if (snapshot.hasData) {
                                        List<ForcastDaysModel>? datasModel =
                                            snapshot.data;
                                        return ListView.builder(
                                            itemCount: 4,
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemBuilder:
                                                (BuildContext context, int pos) {
                                              return itemDayBuild(
                                                  datasModel![pos + 1]);
                                            });
                                      } else {
                                        return Center(
                                            child: JumpingText('Loding...'));
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'wind speed',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        CityDatas.windSpeed.toString() + 'm/s',
                                        style: TextStyle(//color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    width: 1,
                                    height: 35,
                                    color: Colors.grey,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'sunrise',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        SunRise,
                                        style: TextStyle(//color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    width: 1,
                                    height: 35,
                                    color: Colors.grey,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'sunset',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        SunSet,
                                        style: TextStyle(//color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    width: 1,
                                    height: 35,
                                    color: Colors.grey,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'humidity',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        CityDatas.humidity.toString() + '%',
                                        style: TextStyle(//color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: JumpingText('Loding...'));
            }
          },
        ),
      ),
    );
  }

  Container itemDayBuild(ForcastDaysModel model) {
    return Container(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(children: [
          Text(
            model.dateTime,
            style: TextStyle(color: Colors.grey),
          ),
          Container(
            height: 60,
            width: 60,
            child: Image(
              image: NetworkImage('https://openweathermap.org/img/wn/' +
                  model.icon +
                  '@2x.png'),
            ),
          ),
          Text(
            model.temp.round().toString() + '\u00B0',
            style: TextStyle(//color: Colors.grey
            ),
          ),
        ]),
      ),
    );
  }
}
