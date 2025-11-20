import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _featuredCollection =>
      _firestore.collection('featured_products');
  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firestore.collection('categories');

  Stream<List<Product>> watchProducts() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> addProduct(Product product) async {
    final data = product.toMap();
    final docRef = _collection.doc();
    await docRef.set(data);
    await _syncCategoryEntry(docRef.id, product.category, data);
    await _syncFeaturedEntry(docRef.id, product.isFeatured, data);
  }

  Future<void> updateProduct(
    Product product, {
    required String previousCategory,
    required bool previousFeatured,
  }) async {
    final data = product.toMap();
    await _collection.doc(product.id).update(data);

    if (previousCategory != product.category) {
      await _removeFromCategory(product.id, previousCategory);
    }
    await _syncCategoryEntry(product.id, product.category, data);

    if (previousFeatured != product.isFeatured && previousFeatured) {
      await _removeFromFeatured(product.id);
    }
    await _syncFeaturedEntry(product.id, product.isFeatured, data);
  }

  Future<void> deleteProduct(Product product) async {
    await _collection.doc(product.id).delete();
    await _removeFromCategory(product.id, product.category);
    if (product.isFeatured) {
      await _removeFromFeatured(product.id);
    }
  }

  Future<void> _syncCategoryEntry(
    String id,
    String category,
    Map<String, dynamic> data,
  ) async {
    await _categoriesCollection
        .doc(category)
        .collection('items')
        .doc(id)
        .set(data);
  }

  Future<void> _removeFromCategory(String id, String category) {
    return _categoriesCollection.doc(category).collection('items').doc(id).delete();
  }

  Future<void> _syncFeaturedEntry(
    String id,
    bool isFeatured,
    Map<String, dynamic> data,
  ) async {
    if (isFeatured) {
      await _featuredCollection.doc(id).set(data);
    } else {
      await _removeFromFeatured(id);
    }
  }

  Future<void> _removeFromFeatured(String id) {
    return _featuredCollection.doc(id).delete();
  }
}
