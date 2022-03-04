import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

@Component(selector: 'service-levels',
    styleUrls: ['style.css'],
    templateUrl: 'service_levels.html',
    directives: [ coreDirectives, formDirectives, routerDirectives, MenuTopComponent],
    pipes: [
      CurrencyPipe,
      GetErrorsPipe,
      IdPipe,
      NamePipe,
      DateFormat2Pipe,
      DateFormat3Pipe,
      I18NRPipe,
      CeilPipe,
      Dec2Pipe,
      OneDecimalPipe
    ])
class StatisticsServiceLevelsComponent extends DashboardComponent {
  Map<String,dynamic> s = {'lapse': 4};
  String group = 'hour';
  Map<String,dynamic> itemModal;
  String q = '';
  String z = '';
  String passenger_q, alliance_q, costcenter_q = '';
  Map<String,dynamic> report = {};
  List fragments = [];
  Map<String,dynamic> sections = {
    'kpi_general': true,
    'kpi_invoices': true,
    'kpi_alliances': true
  };
  Map<String,dynamic> show = {
    'kpi_general': {},
    'kpi_invoices': {},
    'kpi_alliances': {}
  };
  Map<String,dynamic> costcenter_item = {},
      alliance_item = {},
      passenger_item = {};
  List sections_r = [];
  List sections_p = [];
  List<dynamic> list_Alliances_child = [];
  Map<String,dynamic> keys = {};
  Map<String,dynamic> keys_valid = {};
  Map<String,dynamic> keys_show = {};
  bool loading = false;
  bool xfnum = true;

  StatisticsServiceLevelsComponent(Router router, AdminServices adminServices) : super(router, adminServices) {
    Future(() {
      ElementList<Element> tabs = querySelectorAll('#avancedTab a');
      tabs.onClick.listen((e) {
        e.preventDefault();
        js.context.callMethod(r'$', [e.target]).callMethod('tab', ['show']);
      });
      js.context.callMethod(r'$', ['#active']).callMethod('tab', ['show']);
    });
  }


  void searchStatisticsConnected(g, lapse) {
    group = g;
    Map<String,dynamic> body = {
      'lapse': lapse,
      'modules': ['connected'],
      'group': group,
      'sections': sections};
    if (s['fi'] != null) {
      body['fi'] = s['fi'];
    }
    if (alliance_item!= null) {
      body['alliance_id']=alliance_item['_id'];
    }
    if (costcenter_item!= null) {
      body['cost_center_id']=costcenter_item['_id'];
    } if(passenger_item!= null) {
      body['passenger_id']= passenger_item['_id'];
    }

    loading = true;
    report = {};
    sections_r = [];
    keys = {};
    keys_valid = {};
    keys_show = {};
    show.forEach((k, v) {
      show[k]= {};
    });

    adminServices.statistics.postGet('bi', body).then((request) {
      loading = false;
      //logica
      Map<String,dynamic>  res = jsonDecode(request.responseText);
      report = res['result'];
      sections_r = [];
      sections.forEach((s, vs) {
        if(vs) {
          sections_r.add(s);
          res['keys'][s].forEach((key) {
            if (!show[s].containsKey(key[1][0])) {
              show[s][key[1][0]] = {'show': true, 'expand': {}};
            }
            //iteracion de las partes
            key[1][1].forEach((kk) {
              if (!show[s][key[1][0]]['expand'].containsKey(kk)) {
                show[s][key[1][0]]['expand'][kk] = true;
              }
            });
          });
        }
      });
      //genera las llaves validas
      show.forEach((k, v) {
        keys_valid[k] = [];
        v.forEach((kk, vv) {
          var tv = {'name': kk, 'expand': []};
          var i = 0;
          vv['expand'].forEach((kkk, vvv) {
            if(kkk[0] != '_'){
              tv['expand'].add({'name': kkk, 'show': vvv, 'format': res['keys'][k][0][1][2][i], 'color': res['keys'][k][0][1][3][i]});
            }
            i++;
          });
          keys_valid[k].add(tv);
        });
      });

      keys = res['keys'];
      //valid();
    }, onError: (e) {
      loading = false;
      adminServices.evaluateError(e);
    });
  }

  // pasajero

  void searchPassagers() {
    adminServices.listUsers({
      'personal_info.firstname__like': passenger_q,
      'personal_info.lastname__like': passenger_q,
      'personal_info.phone__like': passenger_q,
      'email__like': passenger_q,
      'return': 'email,alliance_id,costs_centers_ids,personal_info,type_user,active',
      '_or': 'personal_info.firstname,personal_info.lastname,personal_info.phone,email',
      '_sort': '-active,personal_info.lastname'
    }.cast<String,dynamic>());
  }


  void selectPassengersModal() {
    q = '';
    searchPassagers();
    js.context.callMethod(r'$', ['#PassengersModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // allianzas

  void searchAlliance() {
    adminServices.alliances.getSub({'legal.name__like': alliance_q, 'legal.email__like': passenger_q,
      'legal.phone__like': passenger_q, '_or': 'legal.name, legal.email, legal.phone'}.cast<String,dynamic>()).then((request) {
      list_Alliances_child = jsonDecode(request.responseText)['result'];
    }, onError: (e) {
      adminServices.evaluateError(e);
    });
  }


  void selectAllianceModal() {
    q = '';
    searchAlliance();
    js.context.callMethod(r'$', ['#AllianceModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  // centro de costos

  void searchCostCenter() {
    Map<String,dynamic> s = {
      '_sort': '-active,name',
      'populate': 'alliance_father_id:legal.name|credit_card_id:number',
      'return': '_id,name,tags,active,alliance_father_id,budget,credit_card_id',
    };
    if(costcenter_q!=null){
      s['name__like']= costcenter_q.trim();
      s['tags__in']= costcenter_q.trim();
      s['_or']= 'name,tags';
    }
    adminServices.listCostsCenters(s);
  }

  void selectCostCenterModal() {
    q = '';
    searchCostCenter();
    js.context.callMethod(r'$', ['#CostCenter2Modal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

  void selectItem([Map item, String a = '']) {
    if (a == 'alliance') {
      alliance_item = item;
      js.context.callMethod(r'$', ['#AllianceModal']).callMethod('modal', ['hide']);
    } else if (a == 'costcenter') {
      costcenter_item = item;
      js.context.callMethod(r'$', ['#CostCenter2Modal']).callMethod('modal', ['hide']);
    } else {
      passenger_item = item;
      js.context.callMethod(r'$', ['#PassengersModal']).callMethod('modal', ['hide']);
    }
  }

  void deleteThis(String a) {
    if (a == 'alliance') {
      alliance_item = {};
    } else if (a == 'costcenter') {
      costcenter_item = {};
    } else {
      passenger_item = {};
    }
  }

}