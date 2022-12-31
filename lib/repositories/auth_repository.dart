import 'package:collabworks/models/hackathon_model.dart';
import 'package:collabworks/models/hacker_model.dart';
import 'package:collabworks/models/organization_model.dart';
import 'package:collabworks/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class AuthRepository {
  //function to register the hacker

  void validate(HackerModel model, BuildContext context) async {
    print(model);
    if (model.name.length <= 3) {
      showSnackBar(context, 'The name must be of 3 characters atleast!');
    } else if (!model.email.toString().contains("@")) {
      showSnackBar(context, 'Invalid email address!');
    } else if (int.parse(model.age) < 12 || int.parse(model.age) > 60) {
      showSnackBar(context, 'Invalid age!');
    } else if (model.phoneNumber.length < 10) {
      showSnackBar(context, 'Invalid phone number');
    } else {
      //create account here
      firebaseAuth.createUserWithEmailAndPassword(
          email: model.email, password: model.password);

      //put the image in the storage

      Reference reference =
          firebaseStorage.ref('profilePictures/${model.name}');
      UploadTask uploadTask = reference.putFile(image!);
      final storageSnapshot = uploadTask.snapshot;
      final downloadUrl = await storageSnapshot.ref.getDownloadURL();

      HackerModel newModel = HackerModel(
          name: model.name,
          age: model.age,
          phoneNumber: model.phoneNumber,
          profilePicture: downloadUrl,
          email: model.email,
          password: model.password);

      firestore
          .collection('hackers')
          .doc(firebaseAuth.currentUser?.uid ?? '')
          .set(newModel.toMap());
    }
  }

  void loginHacker(String password, String email, BuildContext context) {
    if (!email.contains("@")) {
      showSnackBar(context, 'Invalid email address!');
    } else {
      try {
        firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } catch (e) {
        showSnackBar(context, e.toString());
      }
    }
  }

  void registerOrganization(
      OrganizationModel model, BuildContext context, image) async {
    if (!model.email.contains("@")) {
      showSnackBar(context, 'Invalid email');
    } else if (model.image == null) {
      showSnackBar(context, 'Pick an image');
    } else {
      firebaseAuth.createUserWithEmailAndPassword(
          email: model.email, password: model.password);

      Reference reference =
          firebaseStorage.ref('profilePictures/${model.name}');
      UploadTask uploadTask = reference.putFile(image!);
      final storageSnapshot = uploadTask.snapshot;
      final downloadUrl = await storageSnapshot.ref.getDownloadURL();

      OrganizationModel newModel = OrganizationModel(
          name: model.name,
          image: downloadUrl,
          email: model.email,
          password: model.password);

      firestore
          .collection('organizations')
          .doc(newModel.name)
          .set(newModel.toMap());
    }
  }

  void addHackathon(HackathonModel model) {}

  void registerHacker(HackerModel model, BuildContext context) async {
    //use firebase
    validate(model, context);
  }
}
