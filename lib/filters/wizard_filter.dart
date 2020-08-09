
import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';

class WizardFilter extends ImageFilter {
  WizardFilter(): super(name: "Wizard") {
    this.addSubFilter(SaturationSubFilter(0.2));
    this.addSubFilters([BrightnessSubFilter(0.02), HueRotationSubFilter(70)]);
  }
}