import 'package:get/get.dart';

import '../../onboarding_screen/onboarding_screen.dart';
import '../../splash_screen/splash_screen.dart';
import '../modules/bataspengeluaran/bindings/bataspengeluaran_binding.dart';
import '../modules/bataspengeluaran/views/bataspengeluaran_view.dart';
import '../modules/cashflow/bindings/cashflow_binding.dart';
import '../modules/cashflow/views/cashflow_view.dart';
import '../modules/creditcard/bindings/creditcard_binding.dart';
import '../modules/creditcard/views/creditcard_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/editsaldo/bindings/editsaldo_binding.dart';
import '../modules/editsaldo/views/editsaldo_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/masuk/bindings/masuk_binding.dart';
import '../modules/masuk/views/masuk_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/saldo/bindings/saldo_binding.dart';
import '../modules/saldo/views/saldo_view.dart';
import '../modules/statistic/bindings/statistic_binding.dart';
import '../modules/statistic/views/statistic_view.dart';
import '../modules/tambahakun/bindings/tambahakun_binding.dart';
import '../modules/tambahakun/views/tambahakun_view.dart';
import '../modules/tambahcc/bindings/tambahcc_binding.dart';
import '../modules/tambahcc/views/tambahcc_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.MASUK,
      page: () => MasukView(),
      binding: MasukBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SALDO,
      page: () => SaldoView(),
      binding: SaldoBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAHAKUN,
      page: () => TambahakunView(),
      binding: TambahakunBinding(),
    ),
    GetPage(
      name: _Paths.EDITSALDO,
      page: () => EditsaldoView(),
      binding: EditsaldoBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAHCC,
      page: () => const TambahccView(),
      binding: TambahccBinding(),
    ),
    GetPage(
      name: _Paths.CREDITCARD,
      page: () => const CreditcardView(),
      binding: CreditcardBinding(),
    ),
    GetPage(
      name: _Paths.BATASPENGELUARAN,
      page: () => BataspengeluaranView(),
      binding: BataspengeluaranBinding(),
    ),
    GetPage(
      name: _Paths.CASHFLOW,
      page: () => CashflowView(),
      binding: CashflowBinding(),
    ),
    GetPage(
      name: _Paths.STATISTIC,
      page: () => StatisticView(),
      binding: StatisticBinding(),
    ),
  ];
}
