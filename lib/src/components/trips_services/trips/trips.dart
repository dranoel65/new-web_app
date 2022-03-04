import 'dart:async';
import 'dart:convert';
import 'dart:html' hide Point, Events;
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:google_maps/google_maps.dart';
import 'package:google_maps/google_maps_geometry.dart';
import 'package:google_maps/google_maps_places.dart';

import 'package:web_app/classes/User.dart';
import 'package:intl/intl.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';
import 'package:web_app/classes/pipes.dart';

import '../../../config.dart';
import '../../../route_paths.dart';
import '../../../routes.dart';

class TripsComponent extends DashboardComponent {
  bool processing = false;
  String q = '';
  String fi = '';
  String ff = '';
  String r = '';
  String s = '';
  String year = '2020';
  List<Map> months = [
    { 'name': 'Mes', 'v': '00'},
    { 'name': 'Enero', 'v': '01'},
    { 'name': 'Febrero', 'v': '02'},
    { 'name': 'Marzo', 'v': '03'},
    { 'name': 'Abril', 'v': '04'},
    { 'name': 'Mayo', 'v': '05'},
    { 'name': 'Junio', 'v': '06'},
    { 'name': 'Julio', 'v': '07'},
    { 'name': 'Agosto', 'v': '08'},
    { 'name': 'Septiembre', 'v': '09'},
    { 'name': 'Octubre', 'v': '10'},
    { 'name': 'Noviembre', 'v': '11'},
    { 'name': 'Diciembre', 'v': '12'}
  ];

  String pay = 'alliance';

//  Map user = User.user;
  bool new_route = false;
  Map j = {};


  TripsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    var dateNow = DateTime.now();
    year = dateNow.year.toString();
  }
  String status = 'created';
  List<Marker> markers = [];
  List<Marker> stop_markers = [];

  Polyline estimate_path;
  Polyline current_path;
  final geocoder = Geocoder();
  final infowindow = InfoWindow();
  String msg_error = '';
  double update_fare_2020 = 1.06;

  Map estimate;

  void getEstimate([Map<dynamic,dynamic> trip, List<dynamic> stops, String month, String day, Map time, String meridiem]) {
    int n = 0;
    markers.forEach((Marker item) {
      if (item.position != null) {
        n++;
      }
    });

    if (n <= 1 || new_route) {
      return;
    }
    if (trip['alliance_id'] == null || trip['passenger_id'] == null) {
      return;
    }
    List points = [];
    markers.forEach((Marker marker) {
      var m = marker.position;
      points.add([m.lat, m.lng]);
    });
    Map options = {
      'type_service_id': trip['type_service_id'],
      'type_trip': trip['type_trip'],
      'category': new_route==true ? 'route' : 'traditional',
      'points': points,
      'service_trip': {},
      'price': {'night': 0}
    };
    options['alliance_id']=User.user['alliance_id']['_id'];
    if (options['service_trip']['know_driver']==true){
      options['service_trip']['pool']=false;
      options['service_trip']['places']=null;
    }

    if (options['service_trip']['pool']==true) {
      options['service_trip']['know_driver'] = false;
    }

    if (options['service_trip']['know_driver']==false && options['service_trip']['pool']==false){
      options['service_trip']={};
    }

    options['pay'] = pay;

    if (options['type_trip'] == 'reservation') {
      options['start'] = {'date': ''};

      if (year != null && month != '00' && day != '') {
        String start = js.context.callMethod('moment', [
          '$year-$month-$day ${time['hour']}:${time['minute']} $meridiem',
          'YYYY-MM-DD hh:mm A'
        ]).callMethod('toISOString');
        String when = js.context.callMethod('moment', [start]).callMethod(
            'fromNow');

        if (when.contains('ago') || when.contains('hace')) {
          processing = false;
          options['start']['date'] = start;
          showErros({'title': 'dateIsInPass'});
        } else {
          options['start']['date'] = start;
        }
      } else {
        processing = false;
        return showErros({'title': 'completeDate'});
      }
    }

    adminServices.trips.postGet('estimate', options).then((request) {
      estimate = jsonDecode(request.responseText);
      //ruta estimada origen destino
      List path = encoding.decodePath(estimate['path']);
      estimate_path.path = path;
      if (trip != null) {
        //actualiza inicio y fin del trip
        Map first = stops.first;
        Map last = stops.last;
        trip['start']['pickup_location'] = [path.first.lat, path.first.lng];
        trip['start']['pickup_address'] = first['address'];
        trip['start']['marker_location'] = first['location'];
        trip['start']['real_location'] = first['location'];

        trip['end']['pickup_location'] = [path.last.lat, path.last.lng];
        trip['end']['pickup_address'] = last['address'];
      }
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }


  void showErros(var e) {
    switch (e['title']) {
      case 'typeServiceIdRequired':
        msg_error = 'Debe seleccionar un Tipo de Servicio';
        break;
      case 'stopsNotReady':
      case 'startPickupLocationRequired':
        msg_error = 'Puntos de partida, destino y paradas no estan confirmadas';
        break;
      case 'valuesInit':
        msg_error = 'Debe seleccionar pasajero y/o un centro de costo';
        break;
      case 'guestNameRequired':
      case 'guest':
        msg_error = 'Debe completar los datos personales del invitado';
        break;
      case 'notCostsCenters':
        msg_error = 'No hay centros de costos';
        break;
      case 'notCreditCard':
        msg_error = 'No tiene una tarjeta de cédito agregada';
        break;
      case 'user':
        msg_error = 'Su perfil de usuario solo permite viajes personales';
        break;
      case 'concept':
        msg_error =
        'Es obligatorio ingresar el concepto para este viaje, ej: visita a cliente';
        break;
      case 'type_trip':
        msg_error = 'Seleccione el tipo de viaje';
        break;
      case 'completeDate':
        msg_error = 'Por favor complete la fecha';
        break;
      case 'dateIsInPass':
        msg_error = 'La fecha que ha seleccionado esta en el pasado';
        break;
      case 'userSuspended':
        msg_error = 'Tarjeta de crédito bloqueada';
        break;
      case 'creditCardSuspended':
        msg_error = 'Tarjeta de crédito bloqueada';
        break;
      case 'addressError':
        msg_error = 'La dirección de destino debe ser diferente a la de origen';
        break;
      case 'emailNotValid':
        msg_error = 'El correo del invitado no es válido, ingrese uno valido o en caso de no tener use el correo "sincorreo@miaguila.com"';
        break;
      case 'limitChairsExceeded':
        msg_error =
        'La cantidad de pasajeros excede el cupo del vehículo.';
        break;
      default:
        msg_error = e['title'];
    }
    js.context.callMethod(r'$', ['#tripNewError']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  int changeM(String m) {
    return js.context.callMethod(
        'moment', ['${year}-${m}', 'YYYY-MM']).callMethod(
        'daysInMonth');
  }

}
