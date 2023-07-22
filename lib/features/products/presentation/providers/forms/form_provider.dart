import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

import '../../../../shared/infraestructure/inputs/inputs.dart';
import '../../../domain/domain.dart';

//* state
class ProductFormState {
  final bool isFormValid;
  final String? id;
  final Title title;
  final Slug slug;
  final Price price;
  final List<String> sizes;
  final String gender;
  final Stock inStock;
  final String description;
  final String tags;
  final List<String> images;

  ProductFormState({
    this.isFormValid = false,
    this.id,
    this.title = const Title.dirty(""),
    this.slug = const Slug.dirty(""),
    this.price = const Price.dirty(0),
    this.sizes = const [],
    this.gender = "kid",
    this.inStock = const Stock.dirty(0),
    this.description = "",
    this.tags = "",
    this.images = const [],
  });
  ProductFormState copyWith(
          {bool? isFormValid,
          String? id,
          Title? title,
          Slug? slug,
          Price? price,
          List<String>? sizes,
          String? gender,
          Stock? inStock,
          String? description,
          String? tags,
          List<String>? images}) =>
      ProductFormState(
        isFormValid: isFormValid ?? this.isFormValid,
        id: id ?? this.id,
        title: title ?? this.title,
        slug: slug ?? this.slug,
        price: price ?? this.price,
        sizes: sizes ?? this.sizes,
        gender: gender ?? this.gender,
        inStock: inStock ?? this.inStock,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        images: images ?? this.images,
      );
}

//! notifier
class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Future<bool> Function(Map<String, dynamic> productLike)?
      onSubmitCallBack;

  ProductFormNotifier({this.onSubmitCallBack, required Product product})
      : super(
          ProductFormState(
              id: product.id,
              title: Title.dirty(product.title),
              slug: Slug.dirty(product.slug),
              price: Price.dirty(product.price),
              inStock: Stock.dirty(product.stock),
              sizes: product.sizes,
              description: product.description,
              tags: product.tags.join(", "),
              images: product.images,
              gender: product.gender),
        );

  void onTitleChange(String value) {
    state = state.copyWith(
      title: Title.dirty(value),
      isFormValid: Formz.validate(
        [
          Title.dirty(value),
          Price.dirty(state.price.value),
          Slug.dirty(state.slug.value),
          Stock.dirty(state.inStock.value),
        ],
      ),
    );
  }

  void onPriceChange(double value) {
    state = state.copyWith(
      price: Price.dirty(value),
      isFormValid: Formz.validate(
        [
          Title.dirty(state.title.value),
          Price.dirty(value),
          Slug.dirty(state.slug.value),
          Stock.dirty(state.inStock.value),
        ],
      ),
    );
  }

  void onSlugChange(String value) {
    state = state.copyWith(
      slug: Slug.dirty(value),
      isFormValid: Formz.validate(
        [
          Title.dirty(state.title.value),
          Price.dirty(state.price.value),
          Slug.dirty(value),
          Stock.dirty(state.inStock.value),
        ],
      ),
    );
  }

  void onStockChange(int value) {
    state = state.copyWith(
      inStock: Stock.dirty(value),
      isFormValid: Formz.validate(
        [
          Title.dirty(state.title.value),
          Price.dirty(state.price.value),
          Slug.dirty(state.slug.value),
          Stock.dirty(value),
        ],
      ),
    );
  }

  void onSizedChanged(List<String> sizes) {
    state = state.copyWith(sizes: sizes);
  }

  void onGenderChanged(String gender) {
    state = state.copyWith(gender: gender);
  }

  void onDescriptionChange(String description) {
    state = state.copyWith(description: description);
  }

  void onTagsChange(String tags) {
    state = state.copyWith(tags: tags);
  }

  Future<bool> onFormSubmitted() async {
    _touchEverything();
    if (!state.isFormValid) return false;
    if (onSubmitCallBack == null) return false;
    final productLike = {
      "id": state.id,
      "title": state.title.value,
      "price": state.price.value,
      "description": state.description,
      "slug": state.slug.value,
      "stock": state.inStock.value,
      "sizes": state.sizes,
      "gender": state.gender,
      "tags": state.tags.replaceAll(" ", "").split(","),
      "images": state.images
          .map(
            (images) =>
                images.replaceAll("${Enviorment.apiUrl}/files/product/", ""),
          )
          .toList(),
    };
    try {
      return await onSubmitCallBack!(productLike);
    } catch (e) {
      return false;
    }
  }

  void _touchEverything() {
    state = state.copyWith(
        isFormValid: Formz.validate([
      Title.dirty(state.title.value),
      Price.dirty(state.price.value),
      Slug.dirty(state.slug.value),
      Stock.dirty(state.inStock.value),
    ]));
  }
}

//? provider
final productFormProvider = StateNotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, Product>(
        (ref, Product product) {
  // final createUpdateCallback =
  //     ref.watch(productsRepositoryProvider).createUpdateProduct;
  final createUpdateCallback =
      ref.watch(productsProvider.notifier).createUpdateProduct;
  return ProductFormNotifier(
      product: product, onSubmitCallBack: createUpdateCallback);
});
