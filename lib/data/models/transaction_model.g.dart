// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      case 2:
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
      case TransactionType.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 3;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      accountId: fields[1] as String,
      type: fields[2] as TransactionType,
      amount: fields[3] as double,
      categoryId: fields[4] as String?,
      note: fields[5] as String?,
      date: fields[6] as DateTime,
      toAccountId: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
      userId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.toAccountId)
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
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
