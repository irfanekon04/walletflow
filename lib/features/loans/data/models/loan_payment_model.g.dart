// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_payment_model.dart';

class LoanPaymentModelAdapter extends TypeAdapter<LoanPaymentModel> {
  @override
  final int typeId = 9;

  @override
  LoanPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanPaymentModel(
      id: fields[0] as String,
      loanId: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      note: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      isSynced: fields[6] as bool,
      userId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanPaymentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.loanId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanPaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
