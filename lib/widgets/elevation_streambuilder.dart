import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/barometer_provider.dart';
import '../data/flicker_provider.dart';

class ElevationDifferenceStreamBuilder extends StatelessWidget {
  ElevationDifferenceStreamBuilder({
    Key? key,
    required Stream<double> pressureStream,
    required double pZero,
    required flickerStream,
  })  : _tryStream = pressureStream,
        _pZero = pZero,
        _flickerStream = flickerStream,
        super(key: key);

  final Stream<double> _tryStream;
  final Stream<String> _flickerStream;
  final double _pZero;

  @override
  Widget build(BuildContext context) {
    // print('pZero = $pZero');
    final barometerProvider =
        Provider.of<BarometerProvider>(context, listen: false);
    final flickerProvider =
        Provider.of<FlickerProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        StreamBuilder(
            stream: _tryStream,
            builder: (BuildContext context, AsyncSnapshot<double> snap) {
              if (snap.hasError) return Text('Error: ${snap.error}');

              switch (snap.connectionState) {
                case ConnectionState.none:
                  return Text('Not connected to the stream or value == Null');
                case ConnectionState.waiting:
                  return Text('awaiting interaction');
                case ConnectionState.active:
                  final double altitude = 44330 *
                      ((1 - pow((snap.data! / _pZero), (1 / 5.255))) as double);
                  final String displayAltitude = (altitude).toStringAsFixed(1);
                  barometerProvider.setPreviousReading(snap.data!);
                  flickerProvider.changingElevationDiff = altitude;

                  return Column(
                    children: <Widget>[
                      Text('Elevation difference since last reset: ',
                          style: TextStyle(
                            color: Colors.black87,
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      FlickeringIcon(
                        stream: _flickerStream,
                        iconData: Icons.arrow_drop_up,
                        directionString: "Ascending",
                      ),
                      Text(
                        '${displayAltitude}m',
                        style: TextStyle(color: Colors.black87, fontSize: 40),
                      ),
                      FlickeringIcon(
                        stream: _flickerStream,
                        iconData: Icons.arrow_drop_down,
                        directionString: "Descending",
                      ),
                    ],
                  );
                case ConnectionState.done:
                  return Text('Stream has finished');
              }
            }),
      ],
    );
  }
}

class FlickeringIcon extends StatelessWidget {
  final Stream<String> stream;
  final IconData iconData;
  final String directionString;
  FlickeringIcon(
      {Key? key,
      required this.stream,
      required this.iconData,
      required this.directionString})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<String> snap) {
          if (snap.hasError)
            return Icon(
              iconData,
              size: 30,
              color: Color.fromRGBO(246, 246, 246, 1.0),
            );

          switch (snap.connectionState) {
            case ConnectionState.none:
              return Icon(
                iconData,
                size: 30,
                color: Color.fromRGBO(246, 246, 246, 1.0),
              );
            case ConnectionState.waiting:
              return Icon(
                iconData,
                size: 30,
                color: Color.fromRGBO(246, 246, 246, 1.0),
              );
            case ConnectionState.active:
              return snap.data == directionString
                  ? Icon(
                      iconData,
                      size: 30,
                      color: Colors.black87,
                    )
                  : Icon(
                      iconData,
                      size: 30,
                      color: Color.fromRGBO(246, 246, 246, 1.0),
                    );

            case ConnectionState.done:
              return Icon(
                iconData,
                size: 30,
                color: Color.fromRGBO(246, 246, 246, 1.0),
              );
          }
        });
  }
}
