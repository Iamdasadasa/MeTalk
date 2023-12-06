/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.sendMessageNotification = functions.database.ref('/Chat/{RoomID}/{MessageID}').onCreate((snapshot, context) => {
    const newMessageData = snapshot.val(); // 新しいデータ
    console.log('New message created:', newMessageData);
    // ここに新しいデータに対する処理を追加
    return null;
});