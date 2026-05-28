class Table {
  final int id;
  final int restaurant;
  final int tableNumber;
  final int capacity;

  const Table({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    required this.capacity,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      restaurant: json['restaurant'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
    );
  }
}