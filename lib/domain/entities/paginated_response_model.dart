class PaginatedResponseModel<T> {
  final List<T> items;
  final int pageSize;
  final int pageNumber;
  final bool hasNext;

  PaginatedResponseModel({
    required this.items,
    required this.pageSize,
    required this.pageNumber,
    required this.hasNext,
  });

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponseModel<T>(
      items: (json['value'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      pageSize: json['pageSize'],
      pageNumber: json['pageNumber'],
      hasNext: json['hasNext'],
    );
  }
}
