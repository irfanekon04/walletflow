// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 0;

  @override
  AccountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccountType.cash;
      case 1:
        return AccountType.bank;
      case 2:
        return AccountType.mfs;
      case 3:
        return AccountType.creditCard;
      default:
        return AccountType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    switch (obj) {
      case AccountType.cash:
        writer.writeByte(0);
        break;
      case AccountType.bank:
        writer.writeByte(1);
        break;
      case AccountType.mfs:
        writer.writeByte(2);
        break;
      case AccountType.creditCard:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = 1;

  @override
  AccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as AccountType,
      balance: fields[3] as double,
      creditLimit: fields[4] as double?,
      icon: fields[5] as String,
      color: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isSynced: fields[9] as bool,
      userId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.creditLimit)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
