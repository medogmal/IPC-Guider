// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 0;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      id: fields[0] as String?,
      timestamp: fields[1] as DateTime,
      toolType: fields[2] as String,
      title: fields[3] as String,
      inputs: Map<String, String>.from(fields[4] as Map),
      result: fields[5] as String,
      notes: fields[6] as String? ?? '',
      contextTag: fields[7] as String?,
      tags: (fields[8] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.toolType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.inputs)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.contextTag)
      ..writeByte(8)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
