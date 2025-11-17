<?php
// test_callback.php - Simulates a successful M-Pesa callback
// Run this in your browser: http://localhost:8080/water_api/mpesa/test_callback.php

// Simulate M-Pesa callback data
$callbackData = [
    'Body' => [
        'stkCallback' => [
            'MerchantRequestID' => '29115-34620561-1',
            'CheckoutRequestID' => 'ws_CO_191220191020363925',
            'ResultCode' => 0,
            'ResultDesc' => 'The service request is processed successfully.',
            'CallbackMetadata' => [
                'Item' => [
                    ['Name' => 'Amount', 'Value' => 100],
                    ['Name' => 'MpesaReceiptNumber', 'Value' => 'NLJ7RT61SV'],
                    ['Name' => 'TransactionDate', 'Value' => 20191219102115],
                    ['Name' => 'PhoneNumber', 'Value' => 254708374149]
                ]
            ]
        ]
    ]
];

// Send to callback.php
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8080/water_api/mpesa/callback.php');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($callbackData));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
curl_close($ch);

echo "<h2>Test Callback Sent</h2>";
echo "<p>Response: " . $response . "</p>";
echo "<p>Check your database - mpesa_transactions table should have a new record!</p>";
echo "<p><a href='http://localhost/phpmyadmin'>Open phpMyAdmin</a></p>";
?>