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


exports.PublicRoomUpdateTimeWatching = functions.database.ref('/Rooms/{RoomName}').onUpdate((change, context) => {
    const newMessageData = change.after.val(); // 新しいデータ  
    // 現在の時刻を取得
    const currentTime = new Date().getTime();

// オブジェクトのプロパティを操作する
for (var key in newMessageData) {
    // "UpdateDate"を含むプロパティであり、時間が5分以上経過しているかをチェック
    if (key.includes("UpdateDate") && newMessageData[key] && (currentTime - newMessageData[key]) > 5 * 60 * 1000) {
        console.log('５分経過しているために後述のIDを削除します');

        // UpdateData　Null
        newMessageData[key] = null;
        // 現在の入室数　減産
        if (newMessageData.currentParticipants != 0) {
            newMessageData.currentParticipants = newMessageData.currentParticipants -1
        }

    }
}
    // 新しいデータをデータベースに反映
    return change.after.ref.set(newMessageData);
});
