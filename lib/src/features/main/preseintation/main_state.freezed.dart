// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MainState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MainState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MainState()';
}


}

/// @nodoc
class $MainStateCopyWith<$Res>  {
$MainStateCopyWith(MainState _, $Res Function(MainState) __);
}


/// Adds pattern-matching-related methods to [MainState].
extension MainStatePatterns on MainState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Init value)?  init,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Init() when init != null:
return init(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Init value)  init,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Init():
return init(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Init value)?  init,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Init() when init != null:
return init(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  init,TResult Function( TrackingStatus trackingStatus,  UserPosition? userPosition,  LatLng initialMapCenter,  double initialMapZoom,  List<TrackPoint> recordingPoints,  double distanceMeters,  Duration elapsedTime,  double? currentSpeedKmh,  double averageSpeedKmh,  bool showRecenterButton,  List<Marker> trackMarkers,  String? saveError,  String? sessionInterruptedMessage)?  loaded,TResult Function( Object error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Init() when init != null:
return init();case _Loaded() when loaded != null:
return loaded(_that.trackingStatus,_that.userPosition,_that.initialMapCenter,_that.initialMapZoom,_that.recordingPoints,_that.distanceMeters,_that.elapsedTime,_that.currentSpeedKmh,_that.averageSpeedKmh,_that.showRecenterButton,_that.trackMarkers,_that.saveError,_that.sessionInterruptedMessage);case _Error() when error != null:
return error(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  init,required TResult Function( TrackingStatus trackingStatus,  UserPosition? userPosition,  LatLng initialMapCenter,  double initialMapZoom,  List<TrackPoint> recordingPoints,  double distanceMeters,  Duration elapsedTime,  double? currentSpeedKmh,  double averageSpeedKmh,  bool showRecenterButton,  List<Marker> trackMarkers,  String? saveError,  String? sessionInterruptedMessage)  loaded,required TResult Function( Object error)  error,}) {final _that = this;
switch (_that) {
case _Init():
return init();case _Loaded():
return loaded(_that.trackingStatus,_that.userPosition,_that.initialMapCenter,_that.initialMapZoom,_that.recordingPoints,_that.distanceMeters,_that.elapsedTime,_that.currentSpeedKmh,_that.averageSpeedKmh,_that.showRecenterButton,_that.trackMarkers,_that.saveError,_that.sessionInterruptedMessage);case _Error():
return error(_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  init,TResult? Function( TrackingStatus trackingStatus,  UserPosition? userPosition,  LatLng initialMapCenter,  double initialMapZoom,  List<TrackPoint> recordingPoints,  double distanceMeters,  Duration elapsedTime,  double? currentSpeedKmh,  double averageSpeedKmh,  bool showRecenterButton,  List<Marker> trackMarkers,  String? saveError,  String? sessionInterruptedMessage)?  loaded,TResult? Function( Object error)?  error,}) {final _that = this;
switch (_that) {
case _Init() when init != null:
return init();case _Loaded() when loaded != null:
return loaded(_that.trackingStatus,_that.userPosition,_that.initialMapCenter,_that.initialMapZoom,_that.recordingPoints,_that.distanceMeters,_that.elapsedTime,_that.currentSpeedKmh,_that.averageSpeedKmh,_that.showRecenterButton,_that.trackMarkers,_that.saveError,_that.sessionInterruptedMessage);case _Error() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Init implements MainState {
  const _Init();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Init);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MainState.init()';
}


}




/// @nodoc


class _Loaded implements MainState {
  const _Loaded({required this.trackingStatus, required this.userPosition, required this.initialMapCenter, this.initialMapZoom = 16.0,  List<TrackPoint> recordingPoints = const <TrackPoint>[], this.distanceMeters = 0.0, this.elapsedTime = Duration.zero, this.currentSpeedKmh, this.averageSpeedKmh = 0.0, this.showRecenterButton = false,  List<Marker> trackMarkers = const <Marker>[], this.saveError, this.sessionInterruptedMessage}): _recordingPoints = recordingPoints,_trackMarkers = trackMarkers;
  

 final  TrackingStatus trackingStatus;
 final  UserPosition? userPosition;
 final  LatLng initialMapCenter;
@JsonKey() final  double initialMapZoom;
 final  List<TrackPoint> _recordingPoints;
@JsonKey() List<TrackPoint> get recordingPoints {
  if (_recordingPoints is EqualUnmodifiableListView) return _recordingPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recordingPoints);
}

@JsonKey() final  double distanceMeters;
@JsonKey() final  Duration elapsedTime;
 final  double? currentSpeedKmh;
@JsonKey() final  double averageSpeedKmh;
@JsonKey() final  bool showRecenterButton;
 final  List<Marker> _trackMarkers;
@JsonKey() List<Marker> get trackMarkers {
  if (_trackMarkers is EqualUnmodifiableListView) return _trackMarkers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackMarkers);
}

 final  String? saveError;
 final  String? sessionInterruptedMessage;

/// Create a copy of MainState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.trackingStatus, trackingStatus) || other.trackingStatus == trackingStatus)&&(identical(other.userPosition, userPosition) || other.userPosition == userPosition)&&(identical(other.initialMapCenter, initialMapCenter) || other.initialMapCenter == initialMapCenter)&&(identical(other.initialMapZoom, initialMapZoom) || other.initialMapZoom == initialMapZoom)&&const DeepCollectionEquality().equals(other.recordingPoints, _recordingPoints)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.elapsedTime, elapsedTime) || other.elapsedTime == elapsedTime)&&(identical(other.currentSpeedKmh, currentSpeedKmh) || other.currentSpeedKmh == currentSpeedKmh)&&(identical(other.averageSpeedKmh, averageSpeedKmh) || other.averageSpeedKmh == averageSpeedKmh)&&(identical(other.showRecenterButton, showRecenterButton) || other.showRecenterButton == showRecenterButton)&&const DeepCollectionEquality().equals(other.trackMarkers, _trackMarkers)&&(identical(other.saveError, saveError) || other.saveError == saveError)&&(identical(other.sessionInterruptedMessage, sessionInterruptedMessage) || other.sessionInterruptedMessage == sessionInterruptedMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trackingStatus,userPosition,initialMapCenter,initialMapZoom,const DeepCollectionEquality().hash(_recordingPoints),distanceMeters,elapsedTime,currentSpeedKmh,averageSpeedKmh,showRecenterButton,const DeepCollectionEquality().hash(_trackMarkers),saveError,sessionInterruptedMessage);
}

@override
String toString() {
    return 'MainState.loaded(trackingStatus: $trackingStatus, userPosition: $userPosition, initialMapCenter: $initialMapCenter, initialMapZoom: $initialMapZoom, recordingPoints: $recordingPoints, distanceMeters: $distanceMeters, elapsedTime: $elapsedTime, currentSpeedKmh: $currentSpeedKmh, averageSpeedKmh: $averageSpeedKmh, showRecenterButton: $showRecenterButton, trackMarkers: $trackMarkers, saveError: $saveError, sessionInterruptedMessage: $sessionInterruptedMessage)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $MainStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 TrackingStatus trackingStatus, UserPosition? userPosition, LatLng initialMapCenter, double initialMapZoom, List<TrackPoint> recordingPoints, double distanceMeters, Duration elapsedTime, double? currentSpeedKmh, double averageSpeedKmh, bool showRecenterButton, List<Marker> trackMarkers, String? saveError, String? sessionInterruptedMessage
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of MainState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trackingStatus = null,Object? userPosition = freezed,Object? initialMapCenter = null,Object? initialMapZoom = null,Object? recordingPoints = null,Object? distanceMeters = null,Object? elapsedTime = null,Object? currentSpeedKmh = freezed,Object? averageSpeedKmh = null,Object? showRecenterButton = null,Object? trackMarkers = null,Object? saveError = freezed,Object? sessionInterruptedMessage = freezed,}) {
  return _then(_Loaded(
trackingStatus: null == trackingStatus ? _self.trackingStatus : trackingStatus // ignore: cast_nullable_to_non_nullable
as TrackingStatus,userPosition: freezed == userPosition ? _self.userPosition : userPosition // ignore: cast_nullable_to_non_nullable
as UserPosition?,initialMapCenter: null == initialMapCenter ? _self.initialMapCenter : initialMapCenter // ignore: cast_nullable_to_non_nullable
as LatLng,initialMapZoom: null == initialMapZoom ? _self.initialMapZoom : initialMapZoom // ignore: cast_nullable_to_non_nullable
as double,recordingPoints: null == recordingPoints ? _self._recordingPoints : recordingPoints // ignore: cast_nullable_to_non_nullable
as List<TrackPoint>,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,elapsedTime: null == elapsedTime ? _self.elapsedTime : elapsedTime // ignore: cast_nullable_to_non_nullable
as Duration,currentSpeedKmh: freezed == currentSpeedKmh ? _self.currentSpeedKmh : currentSpeedKmh // ignore: cast_nullable_to_non_nullable
as double?,averageSpeedKmh: null == averageSpeedKmh ? _self.averageSpeedKmh : averageSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,showRecenterButton: null == showRecenterButton ? _self.showRecenterButton : showRecenterButton // ignore: cast_nullable_to_non_nullable
as bool,trackMarkers: null == trackMarkers ? _self._trackMarkers : trackMarkers // ignore: cast_nullable_to_non_nullable
as List<Marker>,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,sessionInterruptedMessage: freezed == sessionInterruptedMessage ? _self.sessionInterruptedMessage : sessionInterruptedMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Error implements MainState {
  const _Error({required this.error});
  

 final  Object error;

/// Create a copy of MainState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'MainState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MainStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of MainState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Error(
error: null == error ? _self.error : error ,
  ));
}


}

// dart format on
