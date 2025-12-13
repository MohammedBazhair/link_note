import 'package:skeletonizer/skeletonizer.dart';

class StylesConsts {
  StylesConsts._();

  static const shimmerEffect = ShimmerEffect(
    baseColor: Color(0xFFCCC4C4),
    highlightColor: Color(0xFFEFEEEE),
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.centerRight,
  );
}
