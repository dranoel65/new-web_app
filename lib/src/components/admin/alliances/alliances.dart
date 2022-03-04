import 'dart:async';
import 'dart:convert';
import 'package:angular_router/angular_router.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

class AlliancesComponent extends DashboardComponent {
  Map<String,dynamic> alliance = {
    'legal': {},
    'alliance_father_id': null,
    'domains': [],
    'info': {},
    'price': {},
    'budget': {}
  };
  String populate = 'country_id:name|alliance_father_id:legal.name';
  String str_return = 'legal,country_id,alliance_father_id,active,info,balance,budget';
  Map<String,dynamic> error = {};

//  Map<String,dynamic> cost_center = {'alliance_father_id': null, 'budget': {}, 'tags': [], 'restrictions':[]};

  Map<String,dynamic> user_view = {'personal_info': {}, 'alliance_id': null};

  bool edit = false;

  String q = '';
  String d = '';
  String logo = '';

  List<dynamic> father_alliance = [];
  String children_alliance = '';

  AlliancesComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  void getFather(alliance_id) {
    adminServices.alliances.query({}).then((request) {
      Map data = jsonDecode(request.responseText);
      father_alliance = data['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }

  Future getChildren(alliance_id) {
    return adminServices.alliances.get(alliance_id, {}, '/childrens');
  }

  void addDomains() {
    String domain = d.toLowerCase();
    RegExp exp = new RegExp(r"^((?:[\w]+\.)+)([a-zA-Z]{2,4})");
    if (!exp.hasMatch(domain)) {
      error = {'errorMessage': 'domainIsNoValid', 'title': 'domainIsNoValid'};
    } else {
      if (!alliance.containsKey('domains')) {
        alliance.addAll({
          'domains': [domain]
        });
        d = '';
      } else {
        alliance['domains'].add(domain);
        d = '';
      }
    }
  }

  void deleteDomain(int i) {
    alliance['domains'].removeAt(i);
  }

  void clearError() {
    error = {};
  }
}
