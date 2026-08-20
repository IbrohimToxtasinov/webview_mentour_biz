part of 'coins_market_products_cubit.dart';

class CoinsMarketProductsState extends Equatable {
  final String errorMessage;
  final FormStatus status;
  final List<ProductModel> products;

  const CoinsMarketProductsState({
    required this.errorMessage,
    required this.status,
    required this.products,
  });

  CoinsMarketProductsState copyWith({
    String? errorMessage,
    FormStatus? status,
    List<ProductModel>? products,
  }) {
    return CoinsMarketProductsState(
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      products: products ?? this.products,
    );
  }

  @override
  List<Object> get props => [errorMessage, status, products];
}
