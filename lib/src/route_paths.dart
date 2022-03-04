import 'package:angular_router/angular_router.dart';

const idParam = 'id';
const documentId = 'documentId';
const preLoad = 'preLoad';
const target = 'target';
const tab = 'currentTab';

class RoutePaths {
  static final dashboard = RoutePath(path: 'dashboard');
  static final login = RoutePath(path: 'login');

  static final list_users = RoutePath(path: 'users/list');
  static final general_list_users = RoutePath(path: 'users/general_list');
  static final view_user = RoutePath(path: 'users/view/:$idParam');
  static final new_user = RoutePath(path: 'users/new/:$idParam');
  static final edit_user = RoutePath(path: 'users/edit/:$idParam');

  static final list_alliances = RoutePath(path: 'alliances/list');
  static final view_alliance = RoutePath(path: 'alliances/view/:$idParam');
  static final edit_alliance = RoutePath(path: 'alliances/edit/:$idParam');

  static final list_alliance_credit_cards = RoutePath(path: 'alliance_credit_cards/list/:$idParam');
  static final edit_alliance_credit_card = RoutePath(path: 'alliance_credit_cards/edit/:$idParam');
  static final new_alliance_credit_card = RoutePath(path: 'alliance_credit_cards/new/:$idParam');

  static final service_levels = RoutePath(path: 'statistics/service_levels');
  static final reports = RoutePath(path: 'reports');
  static final list_cost_centers = RoutePath(path: 'cost_centers/general_list');
  static final general_list_cost_centers = RoutePath(path: 'cost_centers/list');
  static final view_cost_center = RoutePath(path: 'cost_centers/view/:$idParam');
  static final new_cost_center = RoutePath(path: 'cost_centers/new/:$idParam');
  static final edit_cost_center = RoutePath(path: 'cost_centers/edit/:$idParam');

  static final list_personal_credit_cards = RoutePath(path: 'personal_credit_cards/list');
  static final add_personal_credit_card = RoutePath(path: 'personal_credit_cards/add');

  static final list_trips = RoutePath(path: 'trips/list/:$target');
  static final new_trip = RoutePath(path: 'trips/new_trip');
  static final new_route = RoutePath(path: 'trips/new_route/:$preLoad');
  static final view_edit_trip = RoutePath(path: 'trips/edit/:$idParam');

  static final upload_routes_users = RoutePath(path: 'routes/upload_routes_users');
  static final list_routes_user_groups = RoutePath(path: 'routes/list_routes_user_groups');

  static final edit_profile = RoutePath(path: 'profile/edit');
  static final recovery_password = RoutePath(path: 'profile/recovery_password/:$target');
  static final fares = RoutePath(path: 'profile/fares');
  static final list_histories = RoutePath(path: 'profile/list_histories');
  static final list_payments = RoutePath(path: 'profile/list_payments');
  static final add_promo_code = RoutePath(path: 'profile/add_promo_code');
  static final add_personal_address = RoutePath(path: 'profile/personal_favorites/add_personal_address/:$idParam');
  static final add_personal_and_alliance_favorite = RoutePath(path: 'profile/personal_and_alliance_favorites/add_personal_and_alliance_favorite/:$idParam');
  static final list_personal_favorites = RoutePath(path: 'profile/personal_favorites/list_personal_favorites');

}

String getId(Map<String, String> parameters) {
  final id = parameters[idParam];
  return id;
}