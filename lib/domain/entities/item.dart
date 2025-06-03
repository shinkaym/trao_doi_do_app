import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int id;
  final int categoryID;
  final String name;
  final String description;
  final String? image;
  
  const Item({
    required this.id,
    required this.categoryID,
    required this.name,
    required this.description,
    this.image,
  });
  
  @override
  List<Object?> get props => [id, categoryID, name, description, image];
}