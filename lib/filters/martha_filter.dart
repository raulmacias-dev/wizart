import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';

class MarthaFilter extends ImageFilter {
  MarthaFilter(): super(name: "Martha") {
    this.addSubFilter(SepiaSubFilter(0.3));
    this.addSubFilter(SaturationSubFilter(0.15));
    this.addSubFilter(HueRotationSubFilter(25));
  }
}