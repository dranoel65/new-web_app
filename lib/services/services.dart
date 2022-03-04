import 'dart:convert';

import 'dart:html';

import 'package:angular_router/angular_router.dart';

import 'package:web_app/src/config.dart';
import 'model.dart';

class AdminServices {

  AdminServices();

  List<Map<dynamic, dynamic>> errors = [];
  List<dynamic> list_countries = [];
  List<dynamic> list_regions = [];
  List<dynamic> list_zones = [];
  List<dynamic> list_types_services = [];
  List<dynamic> list_services = [];
  Map list_scan_services = {};
  List<dynamic> list_alliances = [];
  List<dynamic> list_cars = [];
  List<dynamic> list_costs_centers = [];
  List<dynamic> list_drivers = [];
  List<dynamic> list_califications = [];
  List<dynamic> list_users = [];
  List<dynamic> list_companies = [];
  List<dynamic> list_trips = [];
  List<dynamic> list_alert_trips = [];
  List<dynamic> list_near_drivers = [];
  List<dynamic> list_favorites = [];
  List<dynamic> list_promos = [];
  List<dynamic> list_gdrivers = [];
  List<dynamic> list_galliances = [];
  List<dynamic> list_credits_cards = [];
  List<dynamic> list_alliance_credits_cards = [];
  List<dynamic> list_histories = [];
  List<dynamic> list_payments = [];
  List<dynamic> codes_countries = [];
  List<dynamic> list_trips_with_driver = [];
  List<dynamic> list_upload_users_routes = [];
  List<dynamic> list_recommendeds = [];

  List count_histories = [];
  List count_payments = [];
  Map page_histories = {};
  Map page_payments = {};
  Map page_recommendeds = {};

  Map page_users = {};
  Map page_alliances = {};
  Map page_costs_centers = {};
  Map page_trips = {};

  List count_users = [];
  List count_alliances = [];
  List count_costs_centers = [];
  List count_trips = [];
  List count_recommendeds = [];

  Map excelData = {};

  ModelService countries = ModelService('countries');
  ModelService regions = ModelService('regions');
  ModelService zones = ModelService('zones');
  ModelService types_services = ModelService('types-services');
  ModelService services = ModelService('services');
  ModelService scan_map = ModelService('services');
  ModelService alliances = ModelService('alliances');
  ModelService cars = ModelService('cars');
  ModelService costs_centers = ModelService('costs-centers');
  ModelService drivers = ModelService('drivers');
  ModelService califications = ModelService('califications');
  ModelService users = ModelService('users');
  ModelService companies = ModelService('companies');
  ModelService trips = ModelService('trips');
  ModelService trips_with_driver = ModelService('trips-with-driver');
  ModelService favorites = ModelService('favorites');
  ModelService promos = ModelService('promos_codes/redeem');
  ModelService groupdrivers = ModelService('drivers-groups');
  ModelService groupalliances = ModelService('alliances-groups');
  ModelService credits_cards = ModelService('users/credits_cards');
  ModelService alliance_credits_cards =
  ModelService('alliances/credits-cards');
  ModelService histories = ModelService('histories');
  ModelService payments = ModelService('payments');
  ModelService statistics = ModelService('statistics');
  ModelService area_codes = ModelService('area-codes');
  ModelService route = ModelService('route');
  ModelService upload_users_routes = ModelService('recommended');
  ModelService recommendeds = ModelService('recommendeds-routes');
  ModelService geo = ModelService('geo');
  ModelService fares_tickets = ModelService('fares-tickets');

  Config config = Config();
  Storage localStorage = window.localStorage;
  Router _router;
  List<dynamic> alliances_all = [];
  bool routes_active = false;

  Future userMe([Map<String,dynamic> queryParameters]) async {
    if (queryParameters == null) {
      queryParameters = {
        'return':
        'personal_info,alliance_id,type_user,email,balance,credit_card_id'
      };
    }

    return users.get('me', queryParameters);
  }

  void evaluateError(e) {
    HttpRequest request = e.target;
    if (request.status == 400) {
      var ee = jsonDecode(request.responseText);
      if (ee is List) {
        errors = ee;
      } else {
        errors = [ee];
      }
    } else if (request.status == 0) {
      errors.add({
        'param': 'errorAny',
        'title': 'Error Internet Connection',
        'errorMessage': 'internetNotFound'
      });
    } else {
      errors.add({
        'param': 'errorAny',
        'title': 'Error ' + request.status.toString(),
        'errorMessage': request.responseText
      });
    }
  }

  Future listServices(num lat, num lng) async {
    return services.get('${lat},${lng}').then((request) {
      list_services = jsonDecode(request.responseText);
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listScanServices(num lat, num lng) async {
    return scan_map.get('${lat},${lng}').then((request) {
      list_scan_services = jsonDecode(request.responseText);
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listTypesServices([Map<String,dynamic> queryParameters]) async {
    return types_services.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_types_services = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listCars([Map<String,dynamic> queryParameters]) async {
    return cars.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_cars = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listCostsCenters([Map<String,dynamic> queryParameters]) async {
    return costs_centers.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_costs_centers = data['result'];
      page_costs_centers = data['pagination'];

      costs_centers.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_costs_centers = pagination(page_costs_centers, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listAlliances([Map<String,dynamic> queryParameters]) async {
    return alliances.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_alliances = data['result'];
      page_alliances = data['pagination'];

      alliances.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_alliances = pagination(page_alliances, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future downloadTrips([Map<String,dynamic> queryParameters, List<String> options]) async {
    Config config = Config();

    return trips.excel(queryParameters, options).then((request) {
//      Map data = jsonDecode(request.responseText);
//
//      excelData = data;
//      Uri uri = Uri(
//          scheme: config.scheme,
//          host: config.client_host,
//          port: config.client_port,
//          path: excelData['file']
//      );
//      excelData['path'] = uri.toString();

//      window.location.href = excelData['path'];
//      window.location.href = excelData['file'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future downloadActives([Map<String,dynamic> queryParameters, List<dynamic> options]) async {
    Config config = Config();

    return trips.listActives(queryParameters, options).then((request) {
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listDrivers([Map<String,dynamic> queryParameters]) async {
    return drivers.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_drivers = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listCalifications([Map<String,dynamic> queryParameters]) async {
    return califications.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_califications = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listUsers([Map<String,dynamic> queryParameters]) async {
    return users.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_users = data['result'];
      page_users = data['pagination'];

      users.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_users = pagination(page_users, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listCountries([Map<String,dynamic> queryParameters]) async {
    return countries.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_countries = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listRegions([Map<String,dynamic> queryParameters]) async {
    return regions.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_regions = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listZones([Map<String,dynamic> queryParameters]) async {
    return zones.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_zones = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listTrips([Map<String,dynamic> queryParameters]) async {
    return trips.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_trips = data['result'];
      page_trips = data['pagination'];

      trips.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_trips = pagination(page_trips, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listTripsWithDriver([Map<String,dynamic> queryParameters]) async {
    return trips_with_driver.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_trips_with_driver = data['result'];
//      page_trips = data['pagination'];

//      trips.get('count', queryParameters).then((request) {
//        Map data = jsonDecode(request.responseText);
//        count_trips = pagination(page_trips,data['result']);
//      }, onError: (e) {
//        evaluateError(e);
//      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listHistories([Map<String,dynamic> queryParameters]) async {
    return histories.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_histories = data['result'];
      page_histories = data['pagination'];

      histories.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_histories = pagination(page_histories, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listPayments([Map<String,dynamic> queryParameters]) async {
    return payments.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_payments = data['result'];
      page_payments = data['pagination'];

      payments.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_payments = pagination(page_payments, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

  List pagination(page, c) {
    List count = [];
    for (num i = 1; i <= (c / page['limit']).ceil(); i++) {
      count.add(i);
    }
    return count;
  }

  Future listCompanies([Map<String,dynamic> queryParameters]) async {
    return companies.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_companies = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listFavoritesUser([Map<String,dynamic> queryParameters]) async {
    return users.get('favorites', queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_favorites = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listFavoritesAlliance([Map<String,dynamic> queryParameters]) async {
    return alliances.get('favorites', queryParameters).then(
            (request) {
          Map data = jsonDecode(request.responseText);
          list_favorites = data['result'];
        }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listPromos([Map<String,dynamic> queryParameters]) async {
    return promos.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_promos = data['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listGroupDrivers([Map<String,dynamic> queryParameters]) async {
    return groupdrivers.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_gdrivers = data['result'];
    }, onError: (e) {});
  }

  Future listGroupAlliances([Map<String,dynamic> queryParameters]) async {
    return groupalliances.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_galliances = data['result'];
    }, onError: (e) {});
  }

  Future listCreditsCards([Map<String,dynamic> queryParameters]) async {
    return credits_cards.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_credits_cards = data['result'];
    }, onError: (e) {});
  }

  Future listAllianceCreditsCards([Map<String,dynamic> queryParameters]) async {
    return alliance_credits_cards.query(queryParameters).then(
            (request) {
          Map data = jsonDecode(request.responseText);
          list_alliance_credits_cards = data['result'];
        }, onError: (e) {});
  }

  Future listAreaCodes([Map<String,dynamic> queryParameters]) async {
    return area_codes.query(queryParameters).then((request) {
      codes_countries = jsonDecode(request.responseText)['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listUploadUsersRoutes([Map<String,dynamic> queryParameters]) async {
    return upload_users_routes.query(queryParameters).then((request) {
      list_upload_users_routes = jsonDecode(request.responseText)['result'];
    }, onError: (e) {
      evaluateError(e);
    });
  }

  Future listRecommendeds([Map<String,dynamic> queryParameters]) async {
    return recommendeds.query(queryParameters).then((request) {
      Map data = jsonDecode(request.responseText);
      list_recommendeds = data['result'];
      page_recommendeds = data['pagination'];

      recommendeds.get('count', queryParameters).then((request) {
        Map data = jsonDecode(request.responseText);
        count_recommendeds = pagination(page_recommendeds, data['result']);
      }, onError: (e) {
        evaluateError(e);
      });
    }, onError: (e) {
      evaluateError(e);
    });
  }

}