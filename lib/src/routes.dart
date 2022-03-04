import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';
import 'dashboard/dashboard.template.dart' as dashboard_template;
import 'login/login.template.dart' as login_template;
import 'profile/edit/edit_profile.template.dart' as edit_profile_template;
import 'profile/recovery/recovery_profile.template.dart' as recovery_password_template;

import 'components/admin/users/list/list_users.template.dart' as list_users_template;
import 'components/admin/users/general_list/general_list_users.template.dart' as general_list_users_template;
import 'components/admin/users/view/view_user.template.dart' as view_user_template;
import 'components/admin/users/new/new_user.template.dart' as new_user_template;
import 'components/admin/users/edit/edit_user.template.dart' as edit_user_template;
import 'components/admin/alliances/list/list_alliances.template.dart' as list_alliances_template;
import 'components/admin/alliances/view/view_alliance.template.dart' as view_alliance_template;

import 'components/admin/alliances/edit/edit_alliance.template.dart' as edit_alliance_template;
import 'components/admin/alliance_credit_cards/list/list_alliance_credit_cards.template.dart' as list_alliance_credit_cards_template;
import 'components/admin/alliance_credit_cards/edit/edit_alliance_credit_card.template.dart' as edit_alliance_credit_card_template;
import 'components/admin/alliance_credit_cards/new/new_alliance_credit_card.template.dart' as new_alliance_credit_card_template;
import 'components/admin/statistics/service_levels/service_levels.template.dart' as service_levels_template;
import 'components/admin/reports/reports.template.dart' as reports_template;

import 'components/admin/cost_centers/general_list/general_list_cost_centers.template.dart' as list_cost_centers_template;
import 'components/admin/cost_centers/list/list_cost_centers.template.dart' as list_cost_centers_template;

import 'components/admin/cost_centers/edit/new_cost_center.template.dart' as new_cost_center_template;
import 'components/admin/cost_centers/edit/edit_cost_center.template.dart' as edit_cost_center_template;

import 'components/profile/personal_credit_cards/add_personal_credit_card/add_personal_credit_card.template.dart' as add_personal_credit_card_template;
import 'components/profile/personal_credit_cards/list_personal_credit_cards/list_personal_credit_cards.template.dart' as list_personal_credit_cards_template;

import 'components/trips_services/trips/list/list_trips.template.dart' as list_trips_template;
import 'components/trips_services/trips/new/new_trip.template.dart' as new_trip_template;
import 'components/trips_services/trips/new/new_route.template.dart' as new_route_template;

import 'components/trips_services/trips/view_edit/view_edit_trip.template.dart' as view_edit_trip_template;
import 'components/trips_services/routes/upload_routes_users/upload_routes_users.template.dart' as upload_routes_users_template;
import 'components/trips_services/routes/list_routes_user_groups/list_routes_user_groups.template.dart' as list_routes_user_groups_template;

import 'components/profile/fares/fares.template.dart' as fares_template;
import 'components/profile/list_histories/list_histories.template.dart' as list_histories_template;
import 'components/profile/list_payments/list_payments.template.dart' as list_payments_template;
import 'components/profile/add_promo_code/add_promo_code.template.dart' as add_promo_code_template;
import 'components/profile/favorites_and_address/add_personal_address/add_personal_address.template.dart' as add_personal_address_template;
import 'components/profile/favorites_and_address/add_personal_and_alliance_favorite/add_personal_and_alliance_favorite.template.dart' as add_personal_and_alliance_favorite_template;
import 'components/profile/favorites_and_address/list_personal_favorites/list_personal_favorites.template.dart' as list_personal_favorites_template;

export 'route_paths.dart';

class Routes {
  static final Dashboard = RouteDefinition(
    routePath: RoutePaths.dashboard,
    component: dashboard_template.DashboardComponentNgFactory,
  );
  static final Login = RouteDefinition(
      routePath: RoutePaths.login,
      component: login_template.LoginComponentNgFactory,
      useAsDefault: true
  );
  static final EditProfile = RouteDefinition(
      routePath: RoutePaths.edit_profile,
      component: edit_profile_template.EditProfileComponentNgFactory
  );
  static final RecoveryPassword = RouteDefinition(
      routePath: RoutePaths.recovery_password,
      component: recovery_password_template.RecoveryPasswordProfileComponentNgFactory
  );

//ADMIN
  static final ListUsers = RouteDefinition(
      routePath: RoutePaths.list_users,
      component: list_users_template.ListUsersComponentNgFactory
  );
  static final GeneralListUsers = RouteDefinition(
      routePath: RoutePaths.general_list_users,
      component: general_list_users_template.GeneralListUsersComponentNgFactory
  );
  static final ViewUser = RouteDefinition(
      routePath: RoutePaths.view_user,
      component: view_user_template.ViewUserComponentNgFactory
  );
  static final NewUser = RouteDefinition(
      routePath: RoutePaths.new_user,
      component: new_user_template.NewUserComponentNgFactory
  );
  static final EditUser = RouteDefinition(
      routePath: RoutePaths.edit_user,
      component: edit_user_template.EditUserComponentNgFactory
  );
  static final ListAlliances = RouteDefinition(
      routePath: RoutePaths.list_alliances,
      component: list_alliances_template.ListAlliancesComponentNgFactory
  );
  static final ViewAlliance = RouteDefinition(
      routePath: RoutePaths.view_alliance,
      component: view_alliance_template.ViewAllianceComponentNgFactory
  );
  static final EditAlliance = RouteDefinition(
      routePath: RoutePaths.edit_alliance,
      component: edit_alliance_template.EditAllianceComponentNgFactory
  );
  static final NewAllianceCreditCard = RouteDefinition(
      routePath: RoutePaths.new_alliance_credit_card,
      component: new_alliance_credit_card_template.NewAllianceCreditCardComponentNgFactory
  );
  static final EditAllianceCreditCard = RouteDefinition(
      routePath: RoutePaths.edit_alliance_credit_card,
      component: edit_alliance_credit_card_template.EditAllianceCreditCardComponentNgFactory
  );
  static final ListAllianceCreditCards = RouteDefinition(
      routePath: RoutePaths.list_alliance_credit_cards,
      component: list_alliance_credit_cards_template.ListAllianceCreditCardsComponentNgFactory
  );
  static final ServiceLevels = RouteDefinition(
      routePath: RoutePaths.service_levels,
      component: service_levels_template.StatisticsServiceLevelsComponentNgFactory
  );

  static final Reports = RouteDefinition(
      routePath: RoutePaths.reports,
      component: reports_template.ReportsComponentNgFactory
  );

  static final GeneralListCostCenters = RouteDefinition(
      routePath: RoutePaths.general_list_cost_centers,
      component: list_cost_centers_template.GeneralListCostCentersComponentNgFactory
  );
  static final ListCostCenters = RouteDefinition(
      routePath: RoutePaths.list_cost_centers,
      component: list_cost_centers_template.ListCostCentersComponentNgFactory
  );

  static final NewCostCenter = RouteDefinition(
      routePath: RoutePaths.new_cost_center,
      component: new_cost_center_template.NewCostCenterComponentNgFactory
  );
  static final EditCostCenter = RouteDefinition(
      routePath: RoutePaths.edit_cost_center,
      component: edit_cost_center_template.EditCostCenterComponentNgFactory
  );

  static final AddPersonalCreditCard = RouteDefinition(
    routePath: RoutePaths.add_personal_credit_card,
    component: add_personal_credit_card_template.AddPersonalCreditCardComponentNgFactory
  );
  static final ListPersonalCreditCards = RouteDefinition(
    routePath: RoutePaths.list_personal_credit_cards,
    component: list_personal_credit_cards_template.ListPersonalCreditCardsComponentNgFactory
  );

//
//TRIPS SERVICE
  static final ListTrips = RouteDefinition(
      routePath: RoutePaths.list_trips,
      component: list_trips_template.ListTripsUserComponentNgFactory
  );
  static final NewTrip = RouteDefinition(
      routePath: RoutePaths.new_trip,
      component: new_trip_template.NewTripComponentNgFactory
  );
  static final NewRoute = RouteDefinition(
      routePath: RoutePaths.new_route,
      component: new_route_template.NewRouteComponentNgFactory
  );
  static final ViewEditTrip = RouteDefinition(
      routePath: RoutePaths.view_edit_trip,
      component: view_edit_trip_template.ViewEditTripComponentNgFactory
  );
  static final UploadRoutesUsers = RouteDefinition(
      routePath: RoutePaths.upload_routes_users,
      component: upload_routes_users_template.UploadUsersRoutesComponentNgFactory
  );
  static final ListRoutesUserGroups = RouteDefinition(
      routePath: RoutePaths.list_routes_user_groups,
      component: list_routes_user_groups_template.ListRoutesUserGroupsComponentNgFactory
  );

  static final Fares = RouteDefinition(
      routePath: RoutePaths.fares,
      component: fares_template.FaresComponentNgFactory
  );
  static final ListHistories = RouteDefinition(
      routePath: RoutePaths.list_histories,
      component: list_histories_template.ListHistoriesComponentNgFactory
  );
  static final ListPayments = RouteDefinition(
      routePath: RoutePaths.list_payments,
      component: list_payments_template.ListPaymentsComponentNgFactory
  );
  static final AddPromoCode = RouteDefinition(
      routePath: RoutePaths.add_promo_code,
      component: add_promo_code_template.AddPromoCodeComponentNgFactory
  );
  static final AddPersonalAddress = RouteDefinition(
      routePath: RoutePaths.add_personal_address,
      component: add_personal_address_template.AddPersonalAddressComponentNgFactory
  );
  static final AddPersonalAndAllianceFavorite = RouteDefinition(
      routePath: RoutePaths.add_personal_and_alliance_favorite,
      component: add_personal_and_alliance_favorite_template.AddPersonalAndAllianceFavoriteComponentNgFactory
  );
  static final ListPersonalFavorites = RouteDefinition(
      routePath: RoutePaths.list_personal_favorites,
      component: list_personal_favorites_template.ListPersonalFavoritesComponentNgFactory
  );


  static final all = <RouteDefinition>[
    Dashboard,
    Login,
    EditProfile,
    RecoveryPassword,
    ListUsers,
    GeneralListUsers,
    ViewUser,
    NewUser,
    EditUser,
    ListAlliances,
    ViewAlliance,
    NewAllianceCreditCard,
    EditAllianceCreditCard,
    ListAllianceCreditCards,
    EditAlliance,
    ServiceLevels,
    Reports,
    GeneralListCostCenters,
    ListCostCenters,
    NewCostCenter,
    EditCostCenter,
    AddPersonalCreditCard,
    ListPersonalCreditCards,
//
    //TRIPS SERVICE
    ListTrips,
    NewTrip,
    NewRoute,
    ViewEditTrip,
    UploadRoutesUsers,
    ListRoutesUserGroups,
    Fares,
    ListHistories,
    ListPayments,
    AddPromoCode,
    AddPersonalAddress,
    AddPersonalAndAllianceFavorite,
    ListPersonalFavorites,
  RouteDefinition.redirect(
      path: '',
      redirectTo: RoutePaths.login.toUrl(),
    ),
  ];
}
