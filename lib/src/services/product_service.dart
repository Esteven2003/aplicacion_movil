import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  Stream<List<Product>> watchProducts() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> addProduct(Product product) {
    return _collection.add(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _collection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) {
    return _collection.doc(id).delete();
  }
}
