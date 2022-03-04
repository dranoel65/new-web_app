import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:google_maps/google_maps.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../../../../config.dart';
import '../favorites.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(
    selector: 'add-personal-and-alliance-favorite',
    styleUrls: ['../new.css'],
    templateUrl: 'add_personal_and_alliance_favorite.html',
    directives: [coreDirectives, formDirectives, routerDirectives,
      MenuTopComponent
    ],
    pipes: [GetErrorsPipe, MoneyPipe, IdPipe, NamePipe],
    exports: [RoutePaths, Routes])
class AddPersonalAndAllianceFavoriteComponent extends PersonalFavoriteComponent implements OnActivate {

  Timer timer;

  List<dynamic> stops = [];
  String msg_error = '';
  List<dynamic> geo_data = [];
  List<dynamic> addressGeo = [];
  Timer timer_search;
  String alliance_id;

  Map trip = {'start': {}, 'end': {}, 'type_trip': 'instantly'};

  //gmaps
  String xcenter = '';
  LatLng center = LatLng(4.6634163, -74.0920055);
  final mapOptions = MapOptions()
    ..styles = Config.mapStyles
    ..zoom = 12
    ..streetViewControl= false;

  @override
  void onActivate(_, RouterState current) {
   alliance_id = current.parameters['id'];
  }

  AddPersonalAndAllianceFavoriteComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    timer = Timer(Duration(seconds: 1), () {
      var mc = querySelector('#map-canvas');
      if (mc != null) {
        timer.cancel();
        map = GMap(mc, mapOptions);
        map.center = center;

        createStop('Origen');
        createStop('Destino (opcional)');

        estimate_path = Polyline(PolylineOptions()
          ..geodesic = true
          ..strokeColor = '#0404B4'
          ..strokeOpacity = 1.0
          ..strokeWeight = 2
          ..map = map);
      }
    });
    adminServices.regions.query({'return': 'name,center'}).then((request) {
      Map data = jsonDecode(request.responseText);
      adminServices.list_regions = data['result'];
      Map first = adminServices.list_regions.first;
      center = LatLng(first['center'][0], first['center'][1]);
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  void showAutocomplete(i) {
    document.getElementById('label_$i').hidden = true;
    (document.getElementById('stop_$i') as InputElement).hidden = false;
    stops[i]['ready'] = false;
  }

  void hideAutocomplete(i, text) {
    document.getElementById('label_address_$i').innerHtml = text;
    document.getElementById('label_$i').hidden = false;
    (document.getElementById('stop_$i') as InputElement).hidden = true;
    stops[i]['ready'] = true;
  }

  void createMarker(i) {
    Marker marker = Marker(MarkerOptions()
      ..optimized = false
      ..draggable = true
      ..icon = (Icon()
        ..url = i == 0
            ? 'assets/icons/trip/map/ic_marker_origin_anim.gif'
            : 'assets/icons/trip/map/ic_marker_destination_anim.gif'
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
        (document.getElementById('stop_$i') as InputElement).value=data['result']['address'];

        infowindow.content = data['result']['address'];
        infowindow.open(map, marker);

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
  }

  void geoSearch(dynamic event, i) {

    if(timer_search!=null){
      timer_search.cancel();
    }

    timer_search = Timer(Duration(seconds: 1), () {
      geo_data=[];
      var mc = querySelector('#stop_$i');
      if (mc != null) {
        timer_search.cancel();
        String test = '#autocomple_' + i.toString();
        if (event.target.value
            .toString().isNotEmpty && querySelector(test) != null) {
          if(i==0) {
            querySelector('#autocomple_0').style.display = 'block';
          }
          else {
            querySelector('#autocomple_1').style.display = 'block';
          }
        }
        else if (querySelector(test) != null) {
          if(i==0) {
            querySelector(test).style.display = 'none';
          }
          else {
            querySelector(test).style.display = 'none';
          }
        }


        adminServices.geo.get('addresses-places', {
          'keyword': event.target.value,
          'lat': map.bounds.center.lat.toString(),
          'lng': map.bounds.center.lng.toString()
        })
            .then((request) {
          if(jsonDecode(request.responseText)['result'].isNotEmpty) {
            addressGeo = jsonDecode(request.responseText)['result'];
            addressGeo.forEach((geo_address) {
              if (geo_address.containsKey('name')) {
                geo_data.add({
                  'formatted_address': geo_address['name'] + ', ' +
                      geo_address['vicinity'],
                  'geometry': geo_address['geometry']
                });
              }
              else {
                geo_data.add({
                  'formatted_address': geo_address['formatted_address'],
                  'geometry': geo_address['geometry']
                });
              }
            });
          }else{
            geo_data = [];
          }

        }, onError: (e) {
          adminServices.evaluateError(e);
        });

      } else {
        timer_search.cancel();
      }
    });

  }

  void loadAddress(address_item,i){
    String test = '#autocomple_' + i.toString();

    if(i==0) {
      querySelector(test).style.display = 'none';
    }
    else {
      querySelector(test).style.display = 'none';
    }

    //Pone la pos a el marker
    markers[i].position = LatLng(address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
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

    hideAutocomplete(i, address_item['formatted_address']);

    stops[i]['address'] = address_item['formatted_address'];
    stops[i]['location'] = LatLng(address_item['geometry']['location']['lat'], address_item['geometry']['location']['lng']);
    stops[i]['location']=[stops[i]['location'].lat.toString()+','+stops[i]['location'].lng.toString()];
    (document.getElementById('stop_$i') as InputElement).value=address_item['formatted_address'];
  }

  void showErros(var e) {
    switch (e['title']) {
      case 'valueError':
        msg_error =
        '¡Error, por favor intente recargando nuevamente la pagina!';
        break;
      case 'valueName':
        msg_error = '¡Por favor escriba un nombre para el favorito!';
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

  void favoriteCreate() {
    if (stops.isNotEmpty) {
      favorite['start']['address'] = stops[0]['address'];
      favorite['start']['position'] = stops[0]['location'];
      favorite['end']['address'] = stops[1]['address'];
      favorite['end']['position'] = stops[1]['location'];
      if (favorite['name'] == '') {
        return showErros({'title': 'valueName'});
      } else if (favorite['start']['address'] == null ||
          favorite['start']['position'] == null) {
        return showErros({'title': 'valueStart'});
      }
    }

    Map new_favorite = Map.from(favorite);

    if (alliance_id.length > 10) {
      favorite['alliance_id'] = alliance_id;
      adminServices.alliances.postGet('favorites', new_favorite).then((request) {
        router.navigate(RoutePaths.view_alliance.toUrl(parameters: {idParam: alliance_id}));
      }, onError: (e) {
        adminServices.evaluateError(e);
      });
    } else {
      favorite['user_id'] = user['_id'];
      adminServices.users.postGet('favorites', new_favorite).then((request) {
        router.navigate(RoutePaths.list_personal_favorites.toUrl());
      }, onError: (e) {
        adminServices.evaluateError(e);
      });
    }
  }
}
