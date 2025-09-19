import 'package:flutter/material.dart';

class FollowersFollowingView extends StatelessWidget {
  final String uid;
  final String type;

  const FollowersFollowingView({Key? key, required this.uid, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type == 'followers' ? "Followers" : "Following")),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(uid)
      //       .collection(type) // followers OR following
      //       .snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData) {
      //       return Center(child: CircularProgressIndicator());
      //     }

      //     final docs = snapshot.data!.docs;

      //     if (docs.isEmpty) {
      //       return Center(
      //         child: Text(
      //           type == 'followers'
      //               ? "No followers yet"
      //               : "Not following anyone",
      //         ),
      //       );
      //     }

      //     return ListView.builder(
      //       itemCount: docs.length,
      //       itemBuilder: (context, index) {
      //         final data = docs[index].data() as Map<String, dynamic>;

      //         final userId = docs[index].id; // follower/following UID
      //         final userName = data['userName'] ?? "User";
      //         final photoUrl = data['profilePhoto'] ?? "";

      //         return ListTile(
      //           leading: CircleAvatar(
      //             backgroundImage: photoUrl.isNotEmpty
      //                 ? NetworkImage(photoUrl)
      //                 : AssetImage("assets/images/default_profile.jpg")
      //                     as ImageProvider,
      //           ),
      //           title: Text(userName),
      //           trailing: type == 'followers'
      //               ? ElevatedButton(
      //                   onPressed: () {
      //                     // follow back logic yaha likhna
      //                   },
      //                   child: Text("Follow back"),
      //                 )
      //               : null,
      //           onTap: () {
      //             // Navigate to user profile
      //             // Get.to(() => OtherProfileView(uid: userId));
      //           },
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
