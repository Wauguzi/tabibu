/// Corner radii. One radius per job: heroes are the roundest, pills are
/// fully round, and everything else sits between (§2.4).
abstract final class AppRadii {
  static const double hero = 32;
  static const double tile = 28;
  static const double card = 24;
  static const double field = 20;
  static const double notice = 20;
  static const double pill = 999;
}
