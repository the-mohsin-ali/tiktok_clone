import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();
    if (!messageData) return;

    const senderId = messageData.senderId;
    const receiverId = messageData.receiverId;
    const text = messageData.text || "New message";

    // Firestore se receiver ka FCM token lo
    const userDoc =
        await admin.firestore()
          .collection("users")
          .doc(receiverId)
          .get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token for user:", receiverId);
      return;
    }

    // Notification payload
    const payload = {
      notification: {
        title: "New Message",
        body: text,
      },
      data: {
        chatId: context.params.chatId,
        senderId: senderId,
      },
    };

    // Send notification
    await admin.messaging().sendToDevice(fcmToken, payload);
    console.log("Notification sent to:", receiverId);
  });
