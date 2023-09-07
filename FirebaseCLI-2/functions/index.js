const fs = require("fs");
const functions = require("firebase-functions");

exports.hello = functions.https.onCall((data, context) => {
  try {
    const filePath = "/secret/SecretNewContents";
    const contents = fs.readFileSync(filePath, "utf8");
return {
      "data": {
        "ApiKey": contents
      }
    };
  } catch (error) {
    console.error("Error reading API key:", error);
    throw new functions.https.HttpsError("internal", "Error reading API key");
  }
});