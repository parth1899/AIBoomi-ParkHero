import 'package:flutter/material.dart';

import '../screens/booking_confirmation_screen.dart';
import '../screens/floor_map_screen.dart';
import '../screens/home_shell.dart';
import '../screens/parking_detail_screen.dart';
import '../screens/parking_list_screen.dart';
import '../screens/auth_landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/seller_list_spot_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/search_map_screen.dart';
import '../types/models.dart';
import 'app_routes.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeShell());
    case AppRoutes.authLanding:
      return MaterialPageRoute(builder: (_) => const AuthLandingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case AppRoutes.roleSelect:
      return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
    case AppRoutes.sellerListing:
      return MaterialPageRoute(builder: (_) => const SellerListSpotScreen());
    case AppRoutes.parkingDetail:
      final lot = settings.arguments as ParkingLot;
      return MaterialPageRoute(
        builder: (_) => ParkingDetailScreen(lot: lot),
      );
    case AppRoutes.parkingList:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => ParkingListScreen(
          centerLat: args?['lat'] as double?,
          centerLon: args?['lon'] as double?,
        ),
      );
    case AppRoutes.floorMap:
      final floorArgs = settings.arguments as FloorMapArgs;
      return MaterialPageRoute(
        builder: (_) => FloorMapScreen(args: floorArgs),
      );
    case AppRoutes.navigation:
      final lot = settings.arguments as ParkingLot;
      return MaterialPageRoute(
        builder: (_) => NavigationScreen(lot: lot),
      );
    case AppRoutes.searchMap:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => SearchMapScreen(
          label: args['label'] as String,
          latitude: args['lat'] as double,
          longitude: args['lon'] as double,
        ),
      );
    case AppRoutes.bookingConfirmation:
      final booking = settings.arguments as Booking;
      return MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: booking),
      );
    default:
      return MaterialPageRoute(builder: (_) => const HomeShell());
  }
}
