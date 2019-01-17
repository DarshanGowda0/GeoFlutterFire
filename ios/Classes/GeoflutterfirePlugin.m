#import "GeoflutterfirePlugin.h"
#import <geoflutterfire/geoflutterfire-Swift.h>

@implementation GeoflutterfirePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGeoflutterfirePlugin registerWithRegistrar:registrar];
}
@end
