## 3.0.1
* BREAKING CHANGE: == and hashCode behaves differently in collection and == operations for GeoFirePoint fixes #162

## 3.0.0-nullsafety.4
* Updated example - add button for testing Stream, fixed minor issues.
* Fixed unwrapping Object returned by Firestore


## 3.0.0-nullsafety.3
* Updated dependencies, https://github.com/DarshanGowda0/GeoFlutterFire/pull/158 (contributor https://github.com/xmany )

## 3.0.0-nullsafety.2
* Removes suspicious GeoFireCollectionRef.data(id) method. Resolves #113
* Updated example

## 3.0.0-nullsafety.1
* Added null safety.
* Updated example app

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

