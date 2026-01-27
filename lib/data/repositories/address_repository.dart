import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/features/shop/models/address_model.dart';
import 'package:get/get.dart';
// import '../authentication/authentication_repository.dart'; // Ensure you import your Auth Repo

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Fetch all addresses for the specific user
  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      // Replace with your actual method to get the User ID
      // final userId = AuthenticationRepository.instance.authUser!.uid;
      // For now, assuming you handle User ID retrieval in the controller or pass it
      // We will assume the collection is under Users -> UserID -> Addresses

      // NOTE: You need to pass the userId or retrieve it here.
      // Assuming a standard structure:
      // final userId = Get.find<AuthenticationRepository>().authUser?.uid;
      // if (userId == null || userId.isEmpty) throw 'Unable to find user information.';

      // Placeholder for userId retrieval logic:
      String userId = 'CURRENT_USER_ID_HERE';

      final result =
          await _db
              .collection('Users')
              .doc(userId)
              .collection('Addresses')
              .get();
      return result.docs
          .map((document) => AddressModel.fromDocumentSnapshot(document))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching Address Information. Try again later';
    }
  }

  // Clear the "selected" field for all addresses
  Future<void> updateSelectedField(String addressId, bool selected) async {
    try {
      String userId = 'CURRENT_USER_ID_HERE'; // Replace with actual Auth logic
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .update({'SelectedAddress': selected});
    } catch (e) {
      throw 'Unable to update your address selection. Try again later';
    }
  }

  // Update Address
  Future<void> updateAddress(AddressModel address) async {
    try {
      String userId = 'CURRENT_USER_ID_HERE'; // Replace with actual Auth logic
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .doc(address.id)
          .update(address.toJson());
    } catch (e) {
      throw 'Unable to update your address. Try again later';
    }
  }

  // Add new Address
  Future<String> addAddress(AddressModel address) async {
    try {
      String userId = 'CURRENT_USER_ID_HERE'; // Replace with actual Auth logic
      final currentAddress = await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .add(address.toJson());
      return currentAddress.id;
    } catch (e) {
      throw 'Something went wrong while saving Address Information. Try again later';
    }
  }

  // Delete Address
  Future<void> deleteAddress(String addressId) async {
    try {
      String userId = 'CURRENT_USER_ID_HERE'; // Replace with actual Auth logic
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw 'Something went wrong while deleting Address. Try again later';
    }
  }
}
