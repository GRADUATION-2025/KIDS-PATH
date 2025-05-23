// const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

const ONESIGNAL_APP_ID = "6445d2e4-c795-47ef-8810-80ee242dc83c";
// Replace this with your actual REST API Key from OneSignal Dashboard
const ONESIGNAL_REST_API_KEY = "os_v2_app_mrc5fzghsvd67caqqdxciloihr5hcdpracluuj5akx56mt63senrrjcyer4r6kpzew66ypfroradaft5ybongjqqdd2m4jyb5t57piy";

exports.sendNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
    try {
        const snap = event.data;
        const notificationData = snap.data();
        console.log("Function triggered for document:", event.params.notificationId);
        console.log("Notification data:", notificationData);

        // Validate required fields
        if (!notificationData.userId || !notificationData.title || !notificationData.message) {
            const error = new Error("Missing required fields: userId, title, or message");
            console.error("Error sending notification:", error);
            throw error;
        }

        // Get the user's OneSignal player ID from Firestore
        const userDoc = await admin.firestore().collection("users").doc(notificationData.userId).get();
        const userData = userDoc.data();
        
        if (!userData || !userData.oneSignalPlayerId) {
            throw new Error("User's OneSignal player ID not found");
        }

        // Create notification payload
        const notificationPayload = {
            app_id: ONESIGNAL_APP_ID,
            include_player_ids: [userData.oneSignalPlayerId],
            contents: {
                en: notificationData.message
            },
            headings: {
                en: notificationData.title
            },
            data: {
                ...notificationData,
                notificationId: event.params.notificationId
            }
        };

        console.log("Sending notification with payload:", JSON.stringify(notificationPayload, null, 2));

        // Send notification using OneSignal API
        const response = await axios.post(
            "https://onesignal.com/api/v1/notifications",
            notificationPayload,
            {
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Basic ${ONESIGNAL_REST_API_KEY}`
                }
            }
        );

        console.log("Notification sent successfully:", response.data);

        // Update the Firestore document with the OneSignal response
        await snap.ref.update({
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            oneSignalResponse: response.data,
            status: "sent"
        });

        return { success: true, data: response.data };

    } catch (error) {
        console.error("Error sending notification:", error);
        console.error("Error details:", {
            message: error.message,
            code: error.code,
            response: error.response ? error.response.data : null
        });

        // Update the Firestore document with the error
        if (event.data && event.data.ref) {
            await event.data.ref.update({
                error: {
                    message: error.message,
                    code: error.code || "UNKNOWN",
                    details: error.response ? error.response.data : null,
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                },
                status: "failed"
            });
        }

        throw new Error("Failed to send notification");
    }
}); 