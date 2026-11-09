/// Fare family model with allowances and fee rules
enum FareFamilyType { saver, flex, business }

class FareOption {
  final FareFamilyType type;
  final String name;
  final double price;
  final String cabinBaggage;
  final String checkInBaggage;
  final String seatSelection;
  final String meal;
  final double cancellationFee;
  final double changeFee;
  final String refundRule;
  final List<String> benefits;

  const FareOption({
    required this.type,
    required this.name,
    required this.price,
    required this.cabinBaggage,
    required this.checkInBaggage,
    required this.seatSelection,
    required this.meal,
    required this.cancellationFee,
    required this.changeFee,
    required this.refundRule,
    required this.benefits,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'price': price,
        'cabinBaggage': cabinBaggage,
        'checkInBaggage': checkInBaggage,
        'seatSelection': seatSelection,
        'meal': meal,
        'cancellationFee': cancellationFee,
        'changeFee': changeFee,
        'refundRule': refundRule,
        'benefits': benefits,
      };

  factory FareOption.fromJson(Map<String, dynamic> json) => FareOption(
        type: FareFamilyType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => FareFamilyType.saver,
        ),
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        cabinBaggage: json['cabinBaggage'] as String? ?? '7 kg',
        checkInBaggage: json['checkInBaggage'] as String? ?? '15 kg',
        seatSelection: json['seatSelection'] as String? ?? 'Chargeable',
        meal: json['meal'] as String? ?? 'Chargeable',
        cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 3000.0,
        changeFee: (json['changeFee'] as num?)?.toDouble() ?? 2500.0,
        refundRule: json['refundRule'] as String? ?? 'Standard refund rules apply',
        benefits: (json['benefits'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  FareOption copyWith({
    FareFamilyType? type,
    String? name,
    double? price,
    String? cabinBaggage,
    String? checkInBaggage,
    String? seatSelection,
    String? meal,
    double? cancellationFee,
    double? changeFee,
    String? refundRule,
    List<String>? benefits,
  }) {
    return FareOption(
      type: type ?? this.type,
      name: name ?? this.name,
      price: price ?? this.price,
      cabinBaggage: cabinBaggage ?? this.cabinBaggage,
      checkInBaggage: checkInBaggage ?? this.checkInBaggage,
      seatSelection: seatSelection ?? this.seatSelection,
      meal: meal ?? this.meal,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      changeFee: changeFee ?? this.changeFee,
      refundRule: refundRule ?? this.refundRule,
      benefits: benefits ?? this.benefits,
    );
  }
}
