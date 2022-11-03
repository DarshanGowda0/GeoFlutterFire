## 3.0.3
Applied fixes and upgrades from the community ♥

This update made by https://github.com/LucaDillenburg

### Support for Cloud Firestore type annotation and ```withConverter``` method
- **Problem:** The last version of the package did not work well with the new ```Repository<T>``` and ```Query<T>``` types, because the code was not type annotated. Also, it couldn't work with the ```withConverter``` method from the ```cloud_firestore``` package.
- **Solution**: The code was refactored to add type annotation and another class was created to both:
1. Maintain compatibility with the last version
2. Enable users to use the package with the ```withConverter``` method with little to no change. As explained in the README, the ```GeoFireCollectionWithConverterRef<T>``` class can be used instead of the original ```GeoFireCollectionRef``` with the only change needed to ```within``` method that now requires an extra parameter to actually get the ```GeoPoint``` from the ```T``` class.

### Minor Tweaks
- Linting was added and the warnings were resolved
- Static types were prioritized instead of dynamic types
- Create ```withinWithDistance``` method that returns the DocumentSnapshot with the calculated distance (to avoid recalculations)

## 3.0.2
Applied fixes and upgrades from the community ♥
* upgraded dependencies, fixed errors

## 2.2.2
* upgraded dependencies, latest before Flutter 2.0 and null safety

## 2.2.1
* upgraded dependencies

## 2.1.0
* fixed breaking changes
* would not be able to access data using `doc.data['distance']` anymore

## 2.0.3+8
* upgraded dependencies
* fix for iOS build errors
* fixes for breaking changes from 2.0.3 for stream builders
* added a bug-fix for supporting stream builders 

## 2.0.2
* added support for filtering documents strictly/easily with respect to radius 

## 2.0.1+1
* bumped up the versions of kotlin-plugin and gradle. 
* Support for GeoPoints nested inside the firestore document

## 2.0.0
* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.
* reverted to flutter stable channel from master.

## 1.0.2
* Refactored code to adhere to best practices(again)

## 1.0.1
* Refactored code to adhere to best practices

## 1.0.0
* Initial Release

