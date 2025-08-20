// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Init value)?  init,TResult Function( _Loaded value)?  loaded,TResult Function( _Tracking value)?  tracking,TResult Function( _Finish value)?  finish,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Init() when init != null:
return init(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Tracking() when tracking != null:
return tracking(_that);case _Finish() when finish != null:
return finish(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Init value)  init,required TResult Function( _Loaded value)  loaded,required TResult Function( _Tracking value)  tracking,required TResult Function( _Finish value)  finish,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Init():
return init(_that);case _Loaded():
return loaded(_that);case _Tracking():
return tracking(_that);case _Finish():
return finish(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Init value)?  init,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Tracking value)?  tracking,TResult? Function( _Finish value)?  finish,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Init() when init != null:
return init(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Tracking() when tracking != null:
return tracking(_that);case _Finish() when finish != null:
return finish(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  init,TResult Function( MapOptions options,  MapController mapController)?  loaded,TResult Function()?  tracking,TResult Function()?  finish,TResult Function()?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Init() when init != null:
return init();case _Loaded() when loaded != null:
return loaded(_that.options,_that.mapController);case _Tracking() when tracking != null:
return tracking();case _Finish() when finish != null:
return finish();case _Error() when error != null:
return error();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  init,required TResult Function( MapOptions options,  MapController mapController)  loaded,required TResult Function()  tracking,required TResult Function()  finish,required TResult Function()  error,}) {final _that = this;
switch (_that) {
case _Init():
return init();case _Loaded():
return loaded(_that.options,_that.mapController);case _Tracking():
return tracking();case _Finish():
return finish();case _Error():
return error();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  init,TResult? Function( MapOptions options,  MapController mapController)?  loaded,TResult? Function()?  tracking,TResult? Function()?  finish,TResult? Function()?  error,}) {final _that = this;
switch (_that) {
case _Init() when init != null:
return init();case _Loaded() when loaded != null:
return loaded(_that.options,_that.mapController);case _Tracking() when tracking != null:
return tracking();case _Finish() when finish != null:
return finish();case _Error() when error != null:
return error();case _:
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
  const _Loaded({required this.options, required this.mapController});
  

 final  MapOptions options;
 final  MapController mapController;

/// Create a copy of MainState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.options, options) || other.options == options)&&(identical(other.mapController, mapController) || other.mapController == mapController));
}


@override
int get hashCode => Object.hash(runtimeType,options,mapController);

@override
String toString() {
  return 'MainState.loaded(options: $options, mapController: $mapController)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $MainStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 MapOptions options, MapController mapController
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
@pragma('vm:prefer-inline') $Res call({Object? options = null,Object? mapController = null,}) {
  return _then(_Loaded(
options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as MapOptions,mapController: null == mapController ? _self.mapController : mapController // ignore: cast_nullable_to_non_nullable
as MapController,
  ));
}


}

/// @nodoc


class _Tracking implements MainState {
  const _Tracking();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tracking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainState.tracking()';
}


}




/// @nodoc


class _Finish implements MainState {
  const _Finish();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Finish);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainState.finish()';
}


}




/// @nodoc


class _Error implements MainState {
  const _Error();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MainState.error()';
}


}




// dart format on
