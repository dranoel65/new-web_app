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
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class PersonalFavoriteComponent extends DashboardComponent {
  Map favorite = {
    'user_id': '',
    'name': '',
    'start': {'address': '', 'position': []},
    'end': {'address': 'null', 'position': []}
  };

  PersonalFavoriteComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    adminServices.regions.query({'active': 'true', 'return': 'name,center'}).then(
        (request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_regions = data['result'];
      Map first = adminServices.list_regions.first;
      //center = LatLng(first['center'][0], first['center'][1]);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  List<Marker> markers = [];

  Polyline estimate_path;
  final geocoder = Geocoder();
  final infowindow = InfoWindow();

  Map estimate;
  String xcenter = '';
  GMap map;

  void setCenter() {
    Future(() {
      List<String> c = xcenter.split(',');
      map.center = LatLng(num.parse(c[0]), num.parse(c[1]));
    });
  }

  void getEstimate([Map trip, List<Map> stops]) {
    int n = 0;
    markers.forEach((Marker item) {
      if (item.position != null) {
        n++;
      }
    });

    if (n <= 1) {
      return;
    }
    List points = [];
    markers.forEach((Marker marker) {
      var m = marker.position;
      points.add([m.lat, m.lng]);
    });
    Map options = {
      'type_service_id': '58cac00c7c16d817ed7edbf6',
      'type_trip': 'instantly',
      'points': points
    };
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

  Future FavoriteUser() async {
    var news = adminServices.listFavoritesUser({
      'active': 'true',
      'return': 'name,start.position,start,end,alliance_id'
    });
    await news.then((content) {
      Future(() {});
    });
    await adminServices.users.query({'_id': user['_id'], 'return': 'routes'}).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_users = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }
}
