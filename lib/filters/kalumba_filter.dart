import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';

class KalumbaFilter extends ImageFilter {
  KalumbaFilter(): super(name: "Kalumba") {
    this.addSubFilter(GrayScaleSubFilter());
    this.addSubFilter(SaturationSubFilter(0.5));
  }
}