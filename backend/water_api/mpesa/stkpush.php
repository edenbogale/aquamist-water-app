<?php
// ===== CORS HEADERS -  =====
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 🔑DARAJA CREDENTIALS
$consumerKey = 'eoGAeDtRz6xOcgm6Wh3gNiltJWEdszXAnYjxVEaxUvBWAO5J';
$consumerSecret = 'Vf10hKTlka1oxJaNDObkxtYsfPW3TbyXpR53afZjIXSREXp1qGEIZwtC2L9Jsqzg';

// 🧪 SANDBOX CONSTANTS
$shortCode = '174379';
$passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';

// Get input from Flutter
$input = json_decode(file_get_contents('php://input'), true);
$phone = trim($input['phone'] ?? '');
$amount = (int)($input['amount'] ?? 100);
$orderId = trim($input['orderId'] ?? 'WATER001');

// Validate phone
if (empty($phone)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Phone is required']);
    exit;
}

// Format phone to 2547XXXXXXXX
if (substr($phone, 0, 1) === '0') {
    $phone = '254' . substr($phone, 1);
} elseif (substr($phone, 0, 4) !== '2547') {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid phone format. Use 07XXXXXXXX']);
    exit;
}

// === STEP 1: Get Access Token ===
$authUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
$credentials = base64_encode($consumerKey . ':' . $consumerSecret);

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $authUrl);
curl_setopt($curl, CURLOPT_HTTPHEADER, ["Authorization: Basic $credentials"]);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
$authResponse = curl_exec($curl);

if (curl_errno($curl)) {
    echo json_encode(['success' => false, 'error' => 'cURL error: ' . curl_error($curl)]);
    curl_close($curl);
    exit;
}
curl_close($curl);

$tokenData = json_decode($authResponse, true);
if (!isset($tokenData['access_token'])) {
    echo json_encode(['success' => false, 'error' => 'Authentication failed', 'details' => $tokenData]);
    exit;
}
$accessToken = $tokenData['access_token'];

// === STEP 2: Initiate STK Push ===
$timestamp = date('YmdHis');
$password = base64_encode($shortCode . $passkey . $timestamp);

$stkUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
$postData = [
    'BusinessShortCode' => $shortCode,
    'Password' => $password,
    'Timestamp' => $timestamp,
    'TransactionType' => 'CustomerPayBillOnline',
    'Amount' => $amount,
    'PartyA' => $phone,
    'PartyB' => $shortCode,
    'PhoneNumber' => $phone,
    'CallBackURL' => 'https://4580acef1894.ngrok.io/water_api/mpesa/callback.php',
    'AccountReference' => 'WATER-' . $orderId,
    'TransactionDesc' => 'Water Delivery Payment'
];

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $stkUrl);
curl_setopt($curl, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Authorization: Bearer ' . $accessToken
]);
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($postData));
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($curl);

if (curl_errno($curl)) {
    echo json_encode(['success' => false, 'error' => 'STK Push cURL error: ' . curl_error($curl)]);
    curl_close($curl);
    exit;
}
curl_close($curl);

$result = json_decode($response, true);

if (isset($result['CheckoutRequestID'])) {
    echo json_encode([
        'success' => true,
        'checkoutId' => $result['CheckoutRequestID'],
        'message' => 'Check your phone and enter M-Pesa PIN'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'error' => $result['errorMessage'] ?? 'Unknown error',
        'details' => $result
    ]);
}
?>