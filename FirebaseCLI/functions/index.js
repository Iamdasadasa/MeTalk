const fs = require("fs");
const functions = require("firebase-functions");

exports.generateSecuredApi = functions.https.onCall((data, context) => {
  try {
    const filePath = "/APIKey/AlgoliaSearchOnlyAPIKey";
    const contents = fs.readFileSync(filePath, "utf8");
    
    console.log(contents);
    
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