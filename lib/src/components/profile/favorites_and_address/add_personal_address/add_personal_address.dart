import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:google_maps/google_maps.dart';
import 'package:google_maps/google_maps_places.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../favorites.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'add-personal-address',
    styleUrls: ['../new.css'],
    templateUrl: 'add_personal_address.html',
    directives: [coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent
    ],
    pipes: [GetErrorsPipe, MoneyPipe, IdPipe, NamePipe],
    exports: [RoutePaths, Routes])
class AddPersonalAddressComponent extends PersonalFavoriteComponent implements OnActivate {
  Timer timer;

  List<dynamic> stops = [];
  List<Autocomplete> autocompletes = [];
  String msg_error = '';
  String user_id = '';
  List<dynamic> list_directions = [];
  Map direction_form = {
    'field_1': 'Calle',
    'field_2': '',
    'field_3': '',
    'field_4': '',
    'field_5': '',
    'field_6': ''
  };
  Map address = {'type': '', 'name': '', 'address': '', 'position': []};
  String address_label = '';
  List<dynamic> addressGeo = [];

  //gmaps
//  GMap map;
  String xcenter = '';
  LatLng center = LatLng(4.6634163, -74.0920055);
  final mapOptions = MapOptions()
    ..styles = Config.mapStyles
    ..zoom = 12
    ..streetViewControl= false;

  Map region = {};

  @override
  void onActivate(_, RouterState current) {
    user_id = current.parameters['id'];
    getUser();
  }

  String goToViewUser(id) => RoutePaths.view_user.toUrl(parameters: {idParam: '$id'});

  AddPersonalAddressComponent(Router router, AdminServices adminServices) : super(router, adminServices) {

    timer = Timer(Duration(seconds: 1), () {
      var mc = querySelector("#map-canvas");
      if (mc != null) {
        timer.cancel();
        map = GMap(mc, mapOptions);
        map.center = center;

        createStop('Dirección');

        estimate_path = Polyline(PolylineOptions()
          ..geodesic = true
          ..strokeColor = '#0404B4'
          ..strokeOpacity = 1.0
          ..strokeWeight = 2
          ..map = map);
      }
    });

    adminServices.regions.query({'return': 'name,center'}.cast<String,dynamic>()).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_regions = data['result'];
      Map first = adminServices.list_regions.first;
      center = LatLng(first['center'][0], first['center'][1]);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void getUser() {
    adminServices.users.query({'_id': user_id, 'return': 'routes,personal_info'}.cast<String,dynamic>()).then(
            (request) {
          Map data = jsonDecode(request.responseText);
          adminServices.list_users = data['result'];
        }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void showAutocomplete(i) {
    document.getElementById('label_$i').hidden = true;
    markers[i].set('map', null);
    markers.clear();
    stops.clear();
    createStop('Dirección');
  }

  void hideAutocomplete(i, text) {
    document.getElementById('label_address_$i').innerHtml = text;
    document.getElementById('label_$i').hidden = false;
    stops[i]['ready'] = true;
  }

  void createMarker(i) {
    Marker marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = true
      ..icon = (Icon()
        ..url = 'assets/icons/trip/map/ic_marker_origin_anim.gif'
        ..scaledSize = Size(32, 32)));

    marker.onDragend.listen((_) {
      adminServices.geo.get('reverse-geocode', {
        'lat': marker.position.lat.toString(),
        'lng': marker.position.lng.toString()
      }).then((request) {
        Map data = jsonDecode(request.responseText);
        if (data['result'].isEmpty) {
          return window.alert('No hay resultados');
        }
        hideAutocomplete(i, data['result']['address']);
        stops[i]['address'] = data['result']['address'];
        stops[i]['location'] = [marker.position.lat, marker.position.lng];
      }, onError: (e) {
        adminServices.evaluateError(e);
      });
    });
    markers.add(marker);
  }

  void createStop(
      String name,
      ) {
    num i = stops.length;
    stops.add({
      'ready': false,
      'name': name,
      'pickup_address': null,
      'pickup_location': null,
      'marker_location': null
    });

    createMarker(i);
    createAutoComplete(i);
  }

  void createAutoComplete(i) {
    Timer timer;

    timer = Timer(Duration(seconds: 1), () {
      var mc = querySelector('#stop_$i');
      if (mc != null) {
        timer.cancel();
        Autocomplete autocomplete = Autocomplete(
            document.getElementById('stop_$i') as InputElement,
            AutocompleteOptions()..types = ['geocode']);
        autocomplete.bindTo('bounds', map);
        autocompletes.add(autocomplete);
        autocomplete.onPlaceChanged.listen((_) {
          final place = autocompletes[i].place;

          if (place.geometry == null) {
            window.alert("Autocomplete's returned place contains no geometry");
            return;
          }
          //Pone la pos a el marker
          markers[i].position = place.geometry.location;
          markers[i].map = map;

          double lats = 0.0;
          double lngs = 0.0;
          int n = 0;

          markers.forEach((Marker item) {
            if (item.position != null) {
              lats += item.position.lat;
              lngs += item.position.lng;
              n++;
            }
          });
          //centra el mapa
          if (n > 0) {
            map.center = LatLng(lats / n, lngs / n);
          }

          hideAutocomplete(i, place.formattedAddress);

          stops[i]['address'] = place.formattedAddress;
          stops[i]['location'] = [
            place.geometry.location.lat,
            place.geometry.location.lng
          ];
        });
      } else {
        timer.cancel();
        createAutoComplete(i);
      }
    });
  }

  @override
  void setCenter() {
    Future(() {
      List<String> c = xcenter.split(',');
      adminServices.list_regions.forEach((r){
        if(r['center'][0].toString()==c[0].toString()){
          region=r;
        }
      });
      map.center = LatLng(num.parse(c[0]), num.parse(c[1]));
    });
  }

  void showErros(var e) {
    switch (e['title']) {
      case 'valueError':
        msg_error =
        '¡Error, por favor intente recargando nuevamente la pagina!';
        break;
      case 'valueName':
        msg_error = '¡Por favor escriba un nombre para la nueva dirección!';
        break;
      case 'valueStart':
        msg_error = '¡Por favor seleccione una dirección de origen!';
        break;

      default:
        msg_error = e['title'];
    }
    js.context.callMethod(r'$', ['#tripNewError']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  void addressCreate() {
    List<dynamic> r = [];

    if (stops.isNotEmpty) {
      address['address'] = stops[0]['address'];
      address['position'] = stops[0]['location'];
      if (address['name'] == '') {
        return showErros({'title': 'valueName'});
      } else if (address['address'] == null || address['position'] == null) {
        return showErros({'title': 'valueStart'});
      }
    }

    r = adminServices.list_users[0]['routes'];
    if (r == null) {
      r = [address];
    } else {
      r.add(address);
    }

    adminServices.users.put('${user_id}/routes', {'routes': r}.cast<String,dynamic>()).then((request) {
      router.navigate(RoutePaths.view_user.toUrl(parameters: {idParam: user_id}));
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void searchDirection() {
    js.context.callMethod(r'$', ['#searchDirection']).callMethod('modal', [
      js.JsObject.jsify({'show': true})
    ]);
  }

  Future searchDirectionRequest() {
    Map<String,dynamic> x = {
      'Antioquia': 'medellin',
      'Cundinamarca': 'bogota',
      'Valle': 'cali',
      'Bolivar': 'cartagena',
      'Atlantico': 'barranquilla',
    };
    list_directions.clear();
    address_label =
        '${direction_form['field_1']} ${direction_form['field_2']} #${direction_form['field_3']}-${direction_form['field_4']}, ${direction_form['field_5']}'
            .trim();
    //TODO: Cambiar ciudad según la región. Requerido para el api
    return adminServices.geo
        .get('addresses-places', {'address': address_label, 'city': '${direction_form['field_6'] == '' ?  x[region['name']] : direction_form['field_6']}', 'keyword': address_label, 'version': 'v4'}).then((request) {
          Map data = jsonDecode(request.responseText);

          if (data['result'].isNotEmpty) {
            addressGeo = jsonDecode(request.responseText)['result'];
            addressGeo.forEach((geo_address) {
              if (geo_address.containsKey('name')) {
                list_directions.add({
                  'formatted_address': geo_address['name'] + ', ' +
                      geo_address['vicinity'],
                  'geometry': geo_address['geometry']
                });
              }
              else {
                list_directions.add({
                  'formatted_address': geo_address['formatted_address'],
                  'geometry': geo_address['geometry']
                });
              }
            });
          }else{
            list_directions.clear();
          }
        }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void selectItem(Map<String,dynamic> item) {
    item['formatted_address'] = address_label;
    stops[0]['address'] = item['formatted_address'];
    stops[0]['location'] = [item['geometry']['location']['lat'], item['geometry']['location']['lng']];
    createMarker(0);
    markers[0].position =
        LatLng(item['geometry']['location']['lat'], item['geometry']['location']['lng']);
    markers[0].map = map;
    Future(() {
      map.center = LatLng(markers[0].position.lat, markers[0].position.lng);
    });

    direction_form['field_6'] = '';
    hideAutocomplete(0, address_label);
    js.context
        .callMethod(r'$', ['#searchDirection']).callMethod('modal', ['hide']);
    direction_form = {
      'field_1': 'Calle',
      'field_2': '',
      'field_3': '',
      'field_4': '',
      'field_5': ''
    };
    list_directions = [];
  }
}
