import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:google_maps/google_maps.dart';
import 'package:google_maps/google_maps_geometry.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';
import '../trips.dart';

@Component(selector: 'view-edit-trip',
    styleUrls: ['../style.css'],
    templateUrl: 'view_edit_trip.html',
    directives: [coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [
      CurrencyPipe,
      GetErrorsPipe,
      IdPipe,
      NamePipe,
      CarBrandPipe,
      DateFormatPipe,
      TimeLapsePipe,
      MoneyPipe,
      I18NPipe,
      StatusItemPassengersUser
    ],
    exports: [RoutePaths, Routes])
class ViewEditTripComponent extends TripsComponent implements OnActivate {

  Timer timer;
  bool flagActions = false;
  String flagAction = null;
  Map<String,dynamic> trip = {}; //gmaps
  Map polylines = {};
  var map;
  final mapOptions = MapOptions()
    ..styles = Config.mapStyles
    ..zoom = 14
    ..center = LatLng(4.6634163, -74.0920055)
    ..streetViewControl= false;

//  Timer reload;
  Map<String,dynamic> current_trip = {};
  String estimate_date = '';
  String text = '';
  String passenger_q = '';
  bool block_passengers = true;
  String correction_request = '';
  Map postData = {'comments':'',
    'createdAt':js.context.callMethod('moment', []),
    'end':{'address':'','date':'',
      'start':{},
      'trip_id':'',
      'driver_id':'',
      'statuses':[]}};
  String alert_message = 'show';
  List<dynamic> stops = [];
  String tripId;

  @override
  void onActivate(_, RouterState current) {
    tripId = current.parameters['id'];
    getTrip();
  }

  String goToListTrips(key) => RoutePaths.list_trips.toUrl(parameters: {target: key});

  ViewEditTripComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  double roundNumber(number) {
    return double.parse((number).toStringAsFixed(1));
  }

  void sendCorrectionRequest() {
    Map<String,dynamic> postData = {
      'comments':correction_request,
      'createdAt':js.context.callMethod('moment', []).callMethod('format', ['MMMM D, YYYY k:mm']),
      'end':{'address':trip['end']['pickup_location'],'date':trip['end']['date']}.cast<String,dynamic>(),
      'start':{'address':trip['start']['pickup_address'],'date':trip['start']['date']}.cast<String,dynamic>(),
      'trip_id':trip['_id'],
      'driver_id': trip['driver_id'] == null ? null : trip['driver_id']['_id'],
      'type': 'Correción de Tarifa',
      'custom_fields': {'fecha_asignacin': js.context.callMethod('moment', []).callMethod('format', ['YYYY-MM-DD']).toString()}.cast<String,dynamic>(),
      'statuses':[{'status':'created','driver_id': trip['driver_id'] == null ? null : trip['driver_id']['_id'],
        'date':js.context.callMethod('moment', []).callMethod('format', ['MMMM D, YYYY k:mm']),
        'comments':correction_request}.cast<String,dynamic>()]
    };

    if(correction_request.length > 10) {
      adminServices.fares_tickets.post(postData).then((request) {
        alert_message = 'success';
      }, onError: (e) {
        adminServices.evaluateError(e);
      });
    }
    else{
      alert_message = 'error';
    }
  }

  void sendCorrectionModal(){
    alert_message='show';
    js.context.callMethod(r'$', ['#sendCorrectionModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  num updateFare2020(value) {
    if (trip == null) {
      return 0;
    }
    return trip['price']['twenty_twenty_surcharge_percent'] == null ? 0 :
    ( value * (((trip['price']['twenty_twenty_surcharge_percent'] ?? -100) / 100) + 1 )).ceil();
  }


  void setMap(poly) {
    if (polylines[poly].map == null) {
      polylines[poly].map = map;
    } else {
      polylines[poly].map = null;
    }
  }

  void setStartTrip() {
    adminServices.trips.put('${trip['_id']}/started', {}).then((request) {
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void setCancelTrip() {
    adminServices.trips.put('${trip['_id']}/cancelled', {}).then((request) {
      getTrip();
      flagAction = '';
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void setFinishedTrip() {
    adminServices.trips.put('${trip['_id']}/finished', {}).then((request) {
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void addMarker() {
    if(trip['passengers'].length>0) {
      trip['passengers'].forEach((m){
        if(trip['type_route']=='allforone') {
          stops.insert(0,
              {
                'address': m['pickup_address'],
                'location': [m['pickup_location'][0], m['pickup_location'][1]]
              });
          createMarker(0, [m['pickup_location'][0], m['pickup_location'][1]],m['pickup_address'],false);
        }
        if(trip['type_route']=='oneforall') {
          stops.insert(1,
              {
                'address': m['pickup_address'],
                'location': [m['pickup_location'][0], m['pickup_location'][1]]
              });
          createMarker(0, [m['pickup_location'][0], m['pickup_location'][1]], m['pickup_address'], false);
        }
      });
    }
  }

  Future chained_marker() async {
    await driverConnected();
    Marker chained = Marker(MarkerOptions()
      ..optimized = false
      ..map = map
      ..position = LatLng(current_trip['pickup_location'][0], current_trip['pickup_location'][1])
      ..title = 'El águila asignada esta dejando un usuario en este lugar.'
      ..icon = (Icon()
        ..url = 'assets/icons/trip/map/marker.png'
        ..scaledSize = Size(32, 32)));
    chained.onClick.listen((e) {
      infowindow.open(map, chained);
      infowindow.content = 'El águila asignada esta dejando un usuario en este lugar.';
    });

    return chained;
  }

  void createMarker(i, latlng, address_i, [bool draggable = false]) {
    Marker marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = draggable
      ..map = map
      ..position = LatLng(latlng[0], latlng[1])
      ..title = address_i == false ? '':address_i
      ..icon = (Icon()
        ..url = i == 0
            ? 'assets/icons/trip/map/ic_marker_origin_anim.gif'
            : 'assets/icons/trip/map/ic_marker_destination_anim.gif'
        ..scaledSize = Size(32, 32)));

    marker.onDragend.listen((_) {
      geocoder.geocode(
          GeocoderRequest()..location = marker.position, (results, status) {
        if (status == GeocoderStatus.OK) {
          if (results[0] != null) {
            stops[i]['address'] = results[0].formattedAddress;
            stops[i]['location'] = [marker.position.lat, marker.position.lng];
            infowindow.content = results[0].formattedAddress;
            infowindow.open(map, marker);

            getEstimate();
          } else {
            window.alert('No results found');
          }
        } else {
          window.alert('Geocoder failed due to: ${status}');
        }
      });
    });

    if(trip['type_route']=='oneforall' && i==1){
      marker.set('map', null);
    }
    if(trip['type_route']=='allforone' && i==0){
      marker.set('map', null);
    }

    markers.add(marker);
  }

  Future stops_marker(lat,lng,address,dat,n) async {
    Marker stops_marker = Marker(MarkerOptions()
      ..optimized = false
      ..map = map
      ..position = LatLng(lat,lng)
      ..title = address
      ..icon = (Icon()
        ..url = 'assets/icons/trip/map/stops.png'
        ..scaledSize = Size(32, 32)));
    stops_marker.onClick.listen((e) {
      infowindow.open(map, stops_marker);
      infowindow.content = '<div class="row info-monitor pl-3 pt-2 pre-scrollable up-space">'
          '<div class="col-4 pl-0 pr-5">'
          '<img src="${dat['personal_info']['image']}" class="rounded-circle img-info" alt="${dat['personal_info']['firstname']} ${dat['personal_info']['lastname']}">'
          '</div>'
          '<div class="col-8 pl-2 pr-0">'
          '<div><b>Parada #${n}</b></div>'
          '<div>'
          '<span class="text-primary">ID:</span> '
          '<a href="javascript:void(0)" class="click-id" data-type="driver" data="${dat['_id']}">${dat['_id'].substring(16)}</a>'
          '</div>'
          '<div><span class="text-primary">Pasajero:</span> ${dat['personal_info']['firstname']} ${dat['personal_info']['lastname']}</div>'
          '<div><span class="text-primary">Correo:</span> ${dat['email']}</div>'
          '<div>'
          '<span class="text-primary">Celular:</span> '
          '<a href="tel:${dat['personal_info']['phone']}" title="Llamar al Águila">${dat['personal_info']['phone']}</a>'
          '</div>'
          '<div>'
          '<span class="text-primary">Dirección:</span> '
          '<a>${address}</a>'
          '</div>'
          '</div>'
          '</div>';
    });

    return stops_marker;

  }

  Marker mark;

  Future driverConnected() async {
    if (trip['driver_id'] != null &&
        (['starting', 'onWay', 'near', 'arrived', 'started']
            .indexOf(trip['status'])) !=
            -1) {
      await adminServices.drivers.get('location/${trip['driver_id']['_id']}').then(
              (request) {
            Map position_driver = jsonDecode(request.responseText);
            if (mark == null) {
              mark = Marker(MarkerOptions()
                ..map = map
                ..position = LatLng(num.parse(position_driver['latitude']),
                    num.parse(position_driver['longitude']))
                ..icon = 'assets/icons/trip/status/onWay.png');
              mark.onClick.listen((e) {
                infowindow.open(map, mark);
                infowindow.content = 'El águila se encuentra actualmente aquí';
              });
              return mark;
            }
            mark.position = LatLng(num.parse(position_driver['latitude']),
                num.parse(position_driver['longitude']));
          }, onError: (e) {
        adminServices.evaluateError(e);
      });
    }
  }

  void getTrip() {
    adminServices.trips.get(tripId,
        {
          'populate': 'statuses+user_id:email,personal_info,admin|statuses+driver_id:email,personal_info|region_id:name|passenger_id:email,personal_info|requester_id:email,personal_info|type_service_id:name|alliance_id:legal.name|driver_id:email,personal_info,current_trip|cost_center_id:name|passengers+passenger_id:personal_info,email|car_id:info'
        }.cast<String,dynamic>())
        .then((request) {
      trip = jsonDecode(request.responseText);
      if(trip['status']=='created' || trip['status']=='finding' || trip['status']=='reserving' || trip['status']=='reserved'){
        block_passengers=false;
      }
      else {
        block_passengers=true;
      }
//      if (trip['passengers'] is List) {
//        trip['passengers'] = trip['passengers'].reversed.toList();
//      }
      if(trip['category']=='route') {
        trip['passengers'].forEach((pas) {
          if (trip['type_trip'] == 'instantly') {
            pas['duration'] = js.context.callMethod('moment', [])
                .callMethod(
                'add', [(pas['duration'] ?? 1 / 60) + 10, 'minutes'])
                .callMethod('format', ['MMMM D, YYYY k:mm']);
          }
          else if (trip['type_trip'] == 'reservation' &&
              trip['start']['date'] != '') {
            pas['duration'] =
                js.context.callMethod('moment', [trip['start']['date']])
                    .callMethod(
                    'add', [pas['duration'] ?? 1 / 60, 'minutes'])
                    .callMethod('format', ['MMMM D, YYYY k:mm']);
          }
        });
      }

      if(trip['status']!='cancelled' && trip['status']!='normalized' && trip['status']!='unattended' && trip['status']!='finished' && trip['driver_id']!=null) {
        if(trip['status']!='started') {
          estimate_date = js.context.callMethod('moment', [])
              .callMethod(
              'add', [trip['arrived']['estimate_time'] / 60, 'minutes'])
              .callMethod('format', ['MMMM D, YYYY k:mm']);
        }
        if(trip['status']=='started'){
          estimate_date = js.context.callMethod('moment', [])
              .callMethod(
              'add', [trip['finished']['estimate_time']/60, 'minutes'])
              .callMethod('format', ['MMMM D, YYYY k:mm']);
        }
      }
//      timerProcess();
      timer = Timer(Duration(seconds: 1), () {
        var mc = querySelector('#map-canvas');
        if (mc != null) {
          mapOptions.center = LatLng((trip['start']['pickup_location'][0] +
              trip['end']['pickup_location'][0]) / 2,
              (trip['start']['pickup_location'][1] +
                  trip['end']['pickup_location'][1]) / 2);
          map = GMap(mc, mapOptions);
          //ruta estimada para recalcular
          estimate_path = Polyline(PolylineOptions()
            ..geodesic = true
            ..strokeColor = '#0404B4'
            ..strokeOpacity = 1.0
            ..strokeWeight = 2
            ..map = map);
          if(trip['status']=='finished' || trip['status']=='cancelled' || trip['status']=='unattended') {
            current_path = Polyline(PolylineOptions()
              ..geodesic = true
              ..strokeColor = '#0064CE'
              ..strokeOpacity = 1.0
              ..strokeWeight = 2
              ..map = map);
          }

          //agrega las paradas
          stops.add({
            'address': trip['start']['pickup_address'],
            'location': trip['start']['pickup_location']
          });
          stops.add({
            'address': trip['end']['pickup_address'],
            'location': trip['end']['pickup_location']
          });
          if(trip['type_trip']=='route' || trip['category']=='route') {
//            addMarker();
            num n = 0;
            trip['passengers'].forEach((p){
              n++;
              stops_marker(p['pickup_location'][0], p['pickup_location'][1],p['pickup_address'], p['passenger_id'],n);
            });
          }
          //agrega los markers de paradas
          createMarker(0, trip['start']['pickup_location'], false);
          createMarker(1, trip['end']['pickup_location'], false);

          //line de vehículo a zona de inicio
          if (trip['arrived']['estimate_path'] != null) {
            polylines['estimate_line'] = Polyline(PolylineOptions()
              ..path = encoding.decodePath(trip['arrived']['estimate_path'])
              ..geodesic = true
              ..strokeColor = '#04B4AE'
              ..strokeOpacity = 1.0
              ..strokeWeight = 2
              ..map = map);
          }

          //ruta estimada origen destino
          if (trip['start']['estimate_path'] != null) {
            polylines['estimate_path'] = Polyline(PolylineOptions()
              ..path = encoding.decodePath(trip['start']['estimate_path'])
              ..geodesic = true
              ..strokeColor = '#61A749'
              ..strokeOpacity = 1.0
              ..strokeWeight = 2
              ..map = map);

//              ..path = encoding.decodePath(trip['start']['estimate_path'])
//              ..geodesic = true
//              ..strokeOpacity = 0
//              ..strokeWeight = 8
//              ..icons = [
//                IconSequence()
//                  ..icon = (GSymbol()
//                    ..path = 'M 0,-1 0,1'
//                    ..strokeOpacity = 1
//                    ..strokeColor = '#999999'
//                    ..scale = 1)
//                  ..offset = '0'
//                  ..repeat = '5px'
//              ]
//              ..map = map);
          }

          //ruta normalizada tomada por el conductor
          if (trip['path'] != null) {
            polylines['route_path'] = Polyline(PolylineOptions()
              ..path = encoding.decodePath(trip['path'])
              ..geodesic = true
              ..strokeColor = '#0404B4'
              ..strokeOpacity = 1.0
              ..strokeWeight = 2
              ..map = map);
          }

          if(trip['status']=='finished' || trip['status']=='cancelled' || trip['status']=='unattended') {
            //ruta actual
            if (trip['finished']['estimate_path'] != null) {
              polylines['current_path'] = Polyline(PolylineOptions()
                ..path = encoding.decodePath(trip['finished']['estimate_path'])
                ..geodesic = true
                ..strokeColor = '#0064CE'
                ..strokeOpacity = 1.0
                ..strokeWeight = 2
                ..map = map);
            }
          }

          //marca original
          Marker(MarkerOptions()
            ..map = map
            ..position = LatLng(trip['start']['marker_location'][0],
                trip['start']['marker_location'][1])
            ..icon = (GSymbol()
              ..path = SymbolPath.CIRCLE
              ..strokeColor = '#FFBF00'
              ..strokeWeight = 1
              ..fillColor = '#FFBF00'
              ..fillOpacity = 0.5
              ..scale = 5));

          if(trip['driver_id']!=null && trip['status']!='cancelled' && trip['status']!='normalized' && trip['status']!='unattended' && trip['status']!='finished') {
            if (trip['driver_id']['current_trip'] != null &&
                trip['driver_id']['current_trip'] != '' && trip['driver_id']['current_trip'] != trip['_id']) {
              adminServices.trips.get(trip['driver_id']['current_trip'], {'return': 'end'}.cast<String,dynamic>()).then(
                  ((request) {
                    Map end_trip = jsonDecode(request.responseText);
                    current_trip = end_trip['end'];
                    if (current_trip != '' || current_trip != null) {
                      chained_marker();
                    }
                  }));
            }
          }

//          if(trip['type_trip']=='route'){
//            trip['passengers'].forEach((p){
//              stops_marker(p['pickup_location'][0], p['pickup_location'][0],p['pickup_address'], p['passenger_id']);
//            });
//          }
        }
      });
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void changeStatus(){
    adminServices.route.put('${trip['_id']}/${j['passenger_id']['_id']}/cancelled',{}).then((request) {
      getTrip();
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void confirmChangeModal(i){
    j=i;
    js.context.callMethod(r'$', ['#confirmChangeModal']).callMethod(
        'modal', [js.JsObject.jsify({'show': true})]);
  }

  void passengersUpdateModal() {
//    group_id=item;
    searchPassagers();
    js.context.callMethod(r'$', ['#passengersUpdateModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void removePassenger(rp){
    trip['passengers'].remove(rp);
  }

  String alertLimitPassengers;

  void addPassenger(ap){
    alertLimitPassengers = null;
    if((trip['passengers'].length <= 3 && trip['type_service_id']['name'] == 'Suv') || (trip['passengers'].length <= 12 && trip['type_service_id']['_id'] == '5b858c124cd1e9101ef790ff')) {
      alertLimitPassengers = null;
      trip['passengers'].add(formatDataForAddPassenger(ap.cast<String,dynamic>()));
    } else {
      alertLimitPassengers = 'La cantidad de pasajeros excede el cupo del vehículo.';
    }

  }

  Map<String,dynamic> formatDataForAddPassenger(passengerInfo) {
    Map<String,dynamic> user_add = {
      'passenger_id': {
        '_id': passengerInfo['_id'],
        'email': passengerInfo['email'],
        'personal_info': {
          'firstname': passengerInfo['personal_info']['firstname'],
          'lastname': passengerInfo['personal_info']['lastname'],
          'name': passengerInfo['personal_info']['name'],
          'phone': passengerInfo['personal_info']['phone'],
          'phone_country': passengerInfo['personal_info']['phone_country'],
          'image': passengerInfo['personal_info']['image']
        }
      }.cast<String,dynamic>(),
      'pickup_address': passengerInfo['routes'][0]['name'],
      'pickup_location': passengerInfo['routes'][0]['position'],
      'check': 'waiting'
    };
    return user_add;
  }

  void updatePassengers(){
    processing = true;
    adminServices.route.put('${trip['_id']}/passengers', {'passengers':trip['passengers']}.cast<String,dynamic>()).then((request) {
      getTrip();
      js.context.callMethod(r'$', ['#passengersUpdateModal']).callMethod('modal', ['hide']);
    }, onError: (e) {
      processing = false;
      HttpRequest request = e.target;
//      showErros(jsonDecode(request.responseText));
    });
  }

  void searchPassagers() {
    adminServices.listUsers({
      'alliance_id__in': alliances_all.join(','),
      'personal_info.firstname__like': passenger_q,
      'personal_info.lastname__like': passenger_q,
      'personal_info.phone__like': passenger_q,
      'email__like': passenger_q,
      'return': 'email,personal_info,active,routes',
      '_or': 'personal_info.firstname,personal_info.lastname,personal_info.phone,email'
    }.cast<String,String>());
  }

//  Future timerProcess() async {
//    if(trip['status']!='cancelled' && trip['status']!='normalized' && trip['status']!='unattended') {
//      String pr ='trips/view/${trip['_id']}';
//      if ((Uri.base.path.contains(RegExp(r'trips/view')) ||
//          Uri.base.path.contains(RegExp(r'trips/actives')) ||
//          Uri.base.path.contains(RegExp(r'alliances/view')) ||
//          Uri.base.path.contains(RegExp(r'trips/all')))) {
//        reload = Timer(Duration(seconds: 30), () {
//          reload.cancel();
//          if ((Uri.base.path.contains(RegExp(r'trips/view')) ||
//              Uri.base.path.contains(RegExp(r'trips/actives')) ||
//              Uri.base.path.contains(RegExp(r'alliances/view')) ||
//              Uri.base.path.contains(RegExp(r'trips/all')))) {
//            getTrip();
//          }
//        });
//      }
//    }
//  }

//detalles de cobros a tc


//tajetas de credito
}

