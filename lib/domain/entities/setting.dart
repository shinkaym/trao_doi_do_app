import 'package:equatable/equatable.dart';

class Setting extends Equatable {
  final int id;
  final String key;
  final String value;

  const Setting({required this.id, required this.key, required this.value});

  @override
  List<Object?> get props => [id, key, value];
}
