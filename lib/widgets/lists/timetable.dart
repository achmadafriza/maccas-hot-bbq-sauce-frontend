import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maccas_sticky_hot_bbq_sauce/models/stop_model.dart';
import 'package:maccas_sticky_hot_bbq_sauce/models/stop_time_model.dart';
import 'package:maccas_sticky_hot_bbq_sauce/screens/trip_screen.dart';
import 'package:maccas_sticky_hot_bbq_sauce/widgets/buttons/route_button.dart';
import 'package:maccas_sticky_hot_bbq_sauce/widgets/cards/bus_card.dart';

class Timetable extends StatefulWidget {
  const Timetable({Key? key, required this.stop}) : super(key: key);

  final StopModel stop;

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  int index = 0;
  int filterIndex = 0;
  String routeFilterId = "";
  List<StopTimeModel> filteredStopTimes = [];

  void generateFilteredList() {
    filteredStopTimes = [];
    for (int i = 0; i < widget.stop.stopTimes.length; i++) {
      if (routeFilterId == widget.stop.stopTimes[i].trip!.route.routeId) {
        filteredStopTimes.add(widget.stop.stopTimes[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    StopModel stop = widget.stop;

    Timer.periodic(const Duration(seconds: 10), (timer) {
      for (int i = index; i < stop.stopTimes.length; i++) {
        if (stop.stopTimes[i].departure.isAfter(DateTime.now())) {
          stop.stopTimes.removeRange(0, i);
          index = 0;
          break;
        }
      }
    });

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(0, 40, 0, 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  filterIndex == 0 ? null : filterIndex -= 1;
                  print(index);
                  setState(() {});
                },
                child: const Icon(
                  Icons.keyboard_arrow_left_sharp,
                  size: 100.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  routeFilterId = "";
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF1B4B87),
                  onPrimary: const Color(0xFFFFE832),
                  fixedSize: const Size(109, 74),
                ),
                child: const Text(
                  'All',
                  style: TextStyle(
                    fontFamily: 'helvetica-neue',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                ),
              ),
              ...[
                for (int i = filterIndex;
                    i < filterIndex + 4 && i < stop.routes.length;
                    i++)
                  RouteButton(
                      text: stop.routes[stop.routes.keys.toList()[i]]!,
                      onPressed: () {
                        routeFilterId = stop.routes.keys.toList()[i];
                        generateFilteredList();
                        setState(() {});
                      })
              ],
              InkWell(
                onTap: () {
                  filterIndex + 4 > stop.routes.length - 1
                      ? null
                      : filterIndex += 1;
                  setState(() {});
                },
                child: const Icon(
                  Icons.keyboard_arrow_right_sharp,
                  size: 100.0,
                ),
              )
            ],
          ),
        ),
        if (stop.stopTimes.length - index > 0) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    index == 0 ? null : index -= 1;
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up_sharp,
                    size: 100.0,
                  ),
                ),
                for (int i = index;
                    i < index + 5 &&
                        i <
                            (routeFilterId == ""
                                ? stop.stopTimes.length
                                : filteredStopTimes.length);
                    i++)
                  BusCard(
                    busNumber: routeFilterId == ""
                        ? stop.stopTimes[i].trip!.route.shortName
                        : filteredStopTimes[i].trip!.route.shortName,
                    busStop: routeFilterId == ""
                        ? stop.stopTimes[i].trip!.headsign
                        : filteredStopTimes[i].trip!.headsign,
                    routeColor: routeFilterId == ""
                        ? stop.stopTimes[i].trip!.route.routeColor
                        : filteredStopTimes[i].trip!.route.routeColor,
                    platform:
                        (stop.platformCode != null) ? stop.platformCode! : '',
                    time: routeFilterId == ""
                        ? stop.stopTimes[i].arrival
                        : filteredStopTimes[i].arrival,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripScreen(
                              tripId: stop.stopTimes[i].trip!.tripId,
                              platform: stop.platformCode,
                              stopTime: stop.stopTimes[i],
                              stopId: stop.stopId,
                            ),
                          ));
                    },
                  ),
                if ((stop.stopTimes.length - 1) - index > 5)
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: InkWell(
                      onTap: () {
                        index + 5 > stop.stopTimes.length - 1
                            ? null
                            : index += 1;
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        size: 100.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ] else
          const Text('tai'),
      ],
    );
  }
}
