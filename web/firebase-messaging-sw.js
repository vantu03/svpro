// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/10.3.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.3.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyB6xlFgmxRgVD88A5cXIGYr84LxSjUBODk",
  authDomain: "svpro-26929.firebaseapp.com",
  projectId: "svpro-26929",
  storageBucket: "svpro-26929.appspot.com",
  messagingSenderId: "860440377687",
  appId: "1:860440377687:web:8646306443624721df2612",
  measurementId: "G-BKQNFP7KGJ"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notificationTitle = payload.notification?.title || 'Thông báo';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: 'icons/icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
