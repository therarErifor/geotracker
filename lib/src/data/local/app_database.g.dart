// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TracksTable extends Tracks with TableInfo<$TracksTable, TrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingDurationMsMeta = const VerificationMeta(
    'movingDurationMs',
  );
  @override
  late final GeneratedColumn<int> movingDurationMs = GeneratedColumn<int>(
    'moving_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stoppedDurationMsMeta = const VerificationMeta(
    'stoppedDurationMs',
  );
  @override
  late final GeneratedColumn<int> stoppedDurationMs = GeneratedColumn<int>(
    'stopped_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _averageSpeedMpsMeta = const VerificationMeta(
    'averageSpeedMps',
  );
  @override
  late final GeneratedColumn<double> averageSpeedMps = GeneratedColumn<double>(
    'average_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSpeedMpsMeta = const VerificationMeta(
    'maxSpeedMps',
  );
  @override
  late final GeneratedColumn<double> maxSpeedMps = GeneratedColumn<double>(
    'max_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startedAt,
    finishedAt,
    durationMs,
    movingDurationMs,
    stoppedDurationMs,
    distanceMeters,
    averageSpeedMps,
    maxSpeedMps,
    elevationGainMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('moving_duration_ms')) {
      context.handle(
        _movingDurationMsMeta,
        movingDurationMs.isAcceptableOrUnknown(
          data['moving_duration_ms']!,
          _movingDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('stopped_duration_ms')) {
      context.handle(
        _stoppedDurationMsMeta,
        stoppedDurationMs.isAcceptableOrUnknown(
          data['stopped_duration_ms']!,
          _stoppedDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_mps')) {
      context.handle(
        _averageSpeedMpsMeta,
        averageSpeedMps.isAcceptableOrUnknown(
          data['average_speed_mps']!,
          _averageSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_mps')) {
      context.handle(
        _maxSpeedMpsMeta,
        maxSpeedMps.isAcceptableOrUnknown(
          data['max_speed_mps']!,
          _maxSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      movingDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_duration_ms'],
      )!,
      stoppedDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stopped_duration_ms'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      averageSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_mps'],
      )!,
      maxSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed_mps'],
      )!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class TrackRow extends DataClass implements Insertable<TrackRow> {
  final String id;
  final String name;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int durationMs;
  final int movingDurationMs;
  final int stoppedDurationMs;
  final double distanceMeters;
  final double averageSpeedMps;
  final double maxSpeedMps;
  final double elevationGainMeters;
  const TrackRow({
    required this.id,
    required this.name,
    required this.startedAt,
    this.finishedAt,
    required this.durationMs,
    required this.movingDurationMs,
    required this.stoppedDurationMs,
    required this.distanceMeters,
    required this.averageSpeedMps,
    required this.maxSpeedMps,
    required this.elevationGainMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['moving_duration_ms'] = Variable<int>(movingDurationMs);
    map['stopped_duration_ms'] = Variable<int>(stoppedDurationMs);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['average_speed_mps'] = Variable<double>(averageSpeedMps);
    map['max_speed_mps'] = Variable<double>(maxSpeedMps);
    map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      name: Value(name),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      durationMs: Value(durationMs),
      movingDurationMs: Value(movingDurationMs),
      stoppedDurationMs: Value(stoppedDurationMs),
      distanceMeters: Value(distanceMeters),
      averageSpeedMps: Value(averageSpeedMps),
      maxSpeedMps: Value(maxSpeedMps),
      elevationGainMeters: Value(elevationGainMeters),
    );
  }

  factory TrackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      movingDurationMs: serializer.fromJson<int>(json['movingDurationMs']),
      stoppedDurationMs: serializer.fromJson<int>(json['stoppedDurationMs']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      averageSpeedMps: serializer.fromJson<double>(json['averageSpeedMps']),
      maxSpeedMps: serializer.fromJson<double>(json['maxSpeedMps']),
      elevationGainMeters: serializer.fromJson<double>(
        json['elevationGainMeters'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'movingDurationMs': serializer.toJson<int>(movingDurationMs),
      'stoppedDurationMs': serializer.toJson<int>(stoppedDurationMs),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'averageSpeedMps': serializer.toJson<double>(averageSpeedMps),
      'maxSpeedMps': serializer.toJson<double>(maxSpeedMps),
      'elevationGainMeters': serializer.toJson<double>(elevationGainMeters),
    };
  }

  TrackRow copyWith({
    String? id,
    String? name,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? durationMs,
    int? movingDurationMs,
    int? stoppedDurationMs,
    double? distanceMeters,
    double? averageSpeedMps,
    double? maxSpeedMps,
    double? elevationGainMeters,
  }) => TrackRow(
    id: id ?? this.id,
    name: name ?? this.name,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    durationMs: durationMs ?? this.durationMs,
    movingDurationMs: movingDurationMs ?? this.movingDurationMs,
    stoppedDurationMs: stoppedDurationMs ?? this.stoppedDurationMs,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    averageSpeedMps: averageSpeedMps ?? this.averageSpeedMps,
    maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
    elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
  );
  TrackRow copyWithCompanion(TracksCompanion data) {
    return TrackRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      movingDurationMs: data.movingDurationMs.present
          ? data.movingDurationMs.value
          : this.movingDurationMs,
      stoppedDurationMs: data.stoppedDurationMs.present
          ? data.stoppedDurationMs.value
          : this.stoppedDurationMs,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      averageSpeedMps: data.averageSpeedMps.present
          ? data.averageSpeedMps.value
          : this.averageSpeedMps,
      maxSpeedMps: data.maxSpeedMps.present
          ? data.maxSpeedMps.value
          : this.maxSpeedMps,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('movingDurationMs: $movingDurationMs, ')
          ..write('stoppedDurationMs: $stoppedDurationMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('averageSpeedMps: $averageSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('elevationGainMeters: $elevationGainMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startedAt,
    finishedAt,
    durationMs,
    movingDurationMs,
    stoppedDurationMs,
    distanceMeters,
    averageSpeedMps,
    maxSpeedMps,
    elevationGainMeters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.durationMs == this.durationMs &&
          other.movingDurationMs == this.movingDurationMs &&
          other.stoppedDurationMs == this.stoppedDurationMs &&
          other.distanceMeters == this.distanceMeters &&
          other.averageSpeedMps == this.averageSpeedMps &&
          other.maxSpeedMps == this.maxSpeedMps &&
          other.elevationGainMeters == this.elevationGainMeters);
}

class TracksCompanion extends UpdateCompanion<TrackRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> durationMs;
  final Value<int> movingDurationMs;
  final Value<int> stoppedDurationMs;
  final Value<double> distanceMeters;
  final Value<double> averageSpeedMps;
  final Value<double> maxSpeedMps;
  final Value<double> elevationGainMeters;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.movingDurationMs = const Value.absent(),
    this.stoppedDurationMs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.averageSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    required String name,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.movingDurationMs = const Value.absent(),
    this.stoppedDurationMs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.averageSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       startedAt = Value(startedAt);
  static Insertable<TrackRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? durationMs,
    Expression<int>? movingDurationMs,
    Expression<int>? stoppedDurationMs,
    Expression<double>? distanceMeters,
    Expression<double>? averageSpeedMps,
    Expression<double>? maxSpeedMps,
    Expression<double>? elevationGainMeters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (movingDurationMs != null) 'moving_duration_ms': movingDurationMs,
      if (stoppedDurationMs != null) 'stopped_duration_ms': stoppedDurationMs,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (averageSpeedMps != null) 'average_speed_mps': averageSpeedMps,
      if (maxSpeedMps != null) 'max_speed_mps': maxSpeedMps,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? durationMs,
    Value<int>? movingDurationMs,
    Value<int>? stoppedDurationMs,
    Value<double>? distanceMeters,
    Value<double>? averageSpeedMps,
    Value<double>? maxSpeedMps,
    Value<double>? elevationGainMeters,
    Value<int>? rowid,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      durationMs: durationMs ?? this.durationMs,
      movingDurationMs: movingDurationMs ?? this.movingDurationMs,
      stoppedDurationMs: stoppedDurationMs ?? this.stoppedDurationMs,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      averageSpeedMps: averageSpeedMps ?? this.averageSpeedMps,
      maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (movingDurationMs.present) {
      map['moving_duration_ms'] = Variable<int>(movingDurationMs.value);
    }
    if (stoppedDurationMs.present) {
      map['stopped_duration_ms'] = Variable<int>(stoppedDurationMs.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (averageSpeedMps.present) {
      map['average_speed_mps'] = Variable<double>(averageSpeedMps.value);
    }
    if (maxSpeedMps.present) {
      map['max_speed_mps'] = Variable<double>(maxSpeedMps.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('movingDurationMs: $movingDurationMs, ')
          ..write('stoppedDurationMs: $stoppedDurationMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('averageSpeedMps: $averageSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    latitude,
    longitude,
    altitude,
    speed,
    accuracy,
    timestamp,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPointRow extends DataClass implements Insertable<TrackPointRow> {
  final int id;
  final String trackId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? accuracy;
  final DateTime timestamp;
  final int orderIndex;
  const TrackPointRow({
    required this.id,
    required this.trackId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.accuracy,
    required this.timestamp,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      trackId: Value(trackId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      timestamp: Value(timestamp),
      orderIndex: Value(orderIndex),
    );
  }

  factory TrackPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPointRow(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      speed: serializer.fromJson<double?>(json['speed']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'speed': serializer.toJson<double?>(speed),
      'accuracy': serializer.toJson<double?>(accuracy),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  TrackPointRow copyWith({
    int? id,
    String? trackId,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    DateTime? timestamp,
    int? orderIndex,
  }) => TrackPointRow(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    speed: speed.present ? speed.value : this.speed,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    timestamp: timestamp ?? this.timestamp,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  TrackPointRow copyWithCompanion(TrackPointsCompanion data) {
    return TrackPointRow(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointRow(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('timestamp: $timestamp, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    latitude,
    longitude,
    altitude,
    speed,
    accuracy,
    timestamp,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPointRow &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.timestamp == this.timestamp &&
          other.orderIndex == this.orderIndex);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPointRow> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double?> speed;
  final Value<double?> accuracy;
  final Value<DateTime> timestamp;
  final Value<int> orderIndex;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    required DateTime timestamp,
    required int orderIndex,
  }) : trackId = Value(trackId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp),
       orderIndex = Value(orderIndex);
  static Insertable<TrackPointRow> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<DateTime>? timestamp,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (timestamp != null) 'timestamp': timestamp,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double?>? speed,
    Value<double?>? accuracy,
    Value<DateTime>? timestamp,
    Value<int>? orderIndex,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('timestamp: $timestamp, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tracks, trackPoints];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TracksTableCreateCompanionBuilder =
    TracksCompanion Function({
      required String id,
      required String name,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> durationMs,
      Value<int> movingDurationMs,
      Value<int> stoppedDurationMs,
      Value<double> distanceMeters,
      Value<double> averageSpeedMps,
      Value<double> maxSpeedMps,
      Value<double> elevationGainMeters,
      Value<int> rowid,
    });
typedef $$TracksTableUpdateCompanionBuilder =
    TracksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> durationMs,
      Value<int> movingDurationMs,
      Value<int> stoppedDurationMs,
      Value<double> distanceMeters,
      Value<double> averageSpeedMps,
      Value<double> maxSpeedMps,
      Value<double> elevationGainMeters,
      Value<int> rowid,
    });

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, TrackRow> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPointRow>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'tracks__id__track_points__track_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingDurationMs => $composableBuilder(
    column: $table.movingDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stoppedDurationMs => $composableBuilder(
    column: $table.stoppedDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingDurationMs => $composableBuilder(
    column: $table.movingDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stoppedDurationMs => $composableBuilder(
    column: $table.stoppedDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingDurationMs => $composableBuilder(
    column: $table.movingDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stoppedDurationMs => $composableBuilder(
    column: $table.stoppedDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedMps => $composableBuilder(
    column: $table.averageSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          TrackRow,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (TrackRow, $$TracksTableReferences),
          TrackRow,
          PrefetchHooks Function({bool trackPointsRefs})
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> movingDurationMs = const Value.absent(),
                Value<int> stoppedDurationMs = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double> averageSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                name: name,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationMs: durationMs,
                movingDurationMs: movingDurationMs,
                stoppedDurationMs: stoppedDurationMs,
                distanceMeters: distanceMeters,
                averageSpeedMps: averageSpeedMps,
                maxSpeedMps: maxSpeedMps,
                elevationGainMeters: elevationGainMeters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> movingDurationMs = const Value.absent(),
                Value<int> stoppedDurationMs = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double> averageSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                name: name,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationMs: durationMs,
                movingDurationMs: movingDurationMs,
                stoppedDurationMs: stoppedDurationMs,
                distanceMeters: distanceMeters,
                averageSpeedMps: averageSpeedMps,
                maxSpeedMps: maxSpeedMps,
                elevationGainMeters: elevationGainMeters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, TrackRow>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (trackPointsRefs) db.trackPoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackPointsRefs)
                    await $_getPrefetchedData<
                      TrackRow,
                      $TracksTable,
                      TrackPointRow
                    >(
                      currentTable: table,
                      referencedTable: $$TracksTableReferences
                          ._trackPointsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TracksTableReferences(
                        db,
                        table,
                        p0,
                      ).trackPointsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.trackId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      TrackRow,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (TrackRow, $$TracksTableReferences),
      TrackRow,
      PrefetchHooks Function({bool trackPointsRefs})
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required String trackId,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      Value<double?> speed,
      Value<double?> accuracy,
      required DateTime timestamp,
      required int orderIndex,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double?> speed,
      Value<double?> accuracy,
      Value<DateTime> timestamp,
      Value<int> orderIndex,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPointRow> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('track_points__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPointRow,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPointRow, $$TrackPointsTableReferences),
          TrackPointRow,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                trackId: trackId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                speed: speed,
                accuracy: accuracy,
                timestamp: timestamp,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                required DateTime timestamp,
                required int orderIndex,
              }) => TrackPointsCompanion.insert(
                id: id,
                trackId: trackId,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                speed: speed,
                accuracy: accuracy,
                timestamp: timestamp,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackPointsTable, TrackPointRow>(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$TrackPointsTableReferences
                                    ._trackIdTable(db),
                                referencedColumn: $$TrackPointsTableReferences
                                    ._trackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPointRow,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPointRow, $$TrackPointsTableReferences),
      TrackPointRow,
      PrefetchHooks Function({bool trackId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
}
