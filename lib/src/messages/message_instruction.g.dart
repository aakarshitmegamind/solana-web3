// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_instruction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageInstruction _$MessageInstructionFromJson(Map<String, dynamic> json) =>
    MessageInstruction(
      programIdIndex: json['programIdIndex'] as int,
      accounts: (json['accounts'] as List<dynamic>).map((e) => e as int),
      data: json['data'] as String,
    );

Map<String, dynamic> _$MessageInstructionToJson(MessageInstruction instance) =>
    <String, dynamic>{
      'programIdIndex': instance.programIdIndex,
      'accounts': instance.accounts.toList(),
      'data': instance.data,
    };
