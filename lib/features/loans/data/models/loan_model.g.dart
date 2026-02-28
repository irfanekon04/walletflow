// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

class LoanTypeAdapter extends TypeAdapter<LoanType> {
  @override
  final int typeId = 7;

  @override
  LoanType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanType.lent;
      case 1:
        return LoanType.owed;
      default:
        return LoanType.lent;
    }
  }

  @override
  void write(BinaryWriter writer, LoanType obj) {
    switch (obj) {
      case LoanType.lent:
        writer.writeByte(0);
        break;
      case LoanType.owed:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 8;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      id: fields[0] as String,
      type: fields[1] as LoanType,
      personName: fields[2] as String,
      originalAmount: fields[3] as double,
      remainingAmount: fields[4] as double,
      date: fields[5] as DateTime,
      note: fields[6] as String?,
      isCompleted: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
      userId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.personName)
      ..writeByte(3)
      ..write(obj.originalAmount)
      ..writeByte(4)
      ..write(obj.remainingAmount)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
