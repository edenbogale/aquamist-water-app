<?php
// ✅ Headers first
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("ngrok-skip-browser-warning: true");
header("Content-Type: application/json");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__.'/config.php';

// Log the raw input for debugging
$raw_input = file_get_contents('php://input');
error_log("Raw input received: " . $raw_input);

$input = json_decode($raw_input, true);
$amount = (int)($input['amount'] ?? 0);
$phone = $input['phone'] ?? '';
$order_id = $input['order_id'] ?? 'unknown';

error_log("Parsed data - Amount: $amount, Phone: $phone, Order ID: $order_id");

// Enhanced phone number formatting
function formatPhone($phone) {
    // Remove all non-digit characters
    $phone = preg_replace('/[^0-9]/', '', $phone);
    
    // Convert to 254 format
    if (strlen($phone) == 10 && substr($phone, 0, 1) == '0') {
        return '254' . substr($phone, 1);
    } elseif (strlen($phone) == 9) {
        return '254' . $phone;
    } elseif (strlen($phone) == 12 && substr($phone, 0, 3) == '254') {
        return $phone;
    }
    return $phone;
}

$phone = formatPhone($phone);

// Enhanced validation with better error messages
if ($amount <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => "Invalid amount: $amount. Amount must be greater than 0"]);
    exit;
}

if (!preg_match('/^2547[0-9]{8}$/', $phone)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => "Invalid phone number: $phone. Must be 2547XXXXXXXX"]);
    exit;
}

error_log("Validation passed - Proceeding with M-Pesa request");

function getAccessToken() {
    $consumerKey = 'AEhizNcq4hD4IrZGTREu0OhFnO99qbf3UTqEWHFYG6XOROsz';
    $consumerSecret = '7yyf1Hpa0zV63hty9Z3ejRk3ToY4yHk37QdtHpVU1XcrYGCJFqGorutSHdbStoVX';
    $url = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
    
    error_log("Getting access token from: $url");
    
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HEADER, false);
    curl_setopt($curl, CURLOPT_USERPWD, $consumerKey . ':' . $consumerSecret);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_TIMEOUT, 30);
    
    $response = curl_exec($curl);
    $http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $curl_error = curl_error($curl);
    curl_close($curl);
    
    error_log("Access Token Response - HTTP Code: $http_code, Response: $response");
    
    if ($curl_error) {
        error_log("cURL Error: " . $curl_error);
        return '';
    }
    
    $result = json_decode($response, true);
    return $result['access_token'] ?? '';
}

$access_token = getAccessToken();
if (!$access_token) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Failed to get access token from M-Pesa']);
    exit;
}

error_log("Access token obtained successfully");

$timestamp = date('YmdHis');
$passkey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
$shortcode = '174379';
$password = base64_encode($shortcode . $passkey . $timestamp);

// Make sure your callback URL is accessible
$callback_url = 'https://9780d6c3f9b0.ngrok-free.app/water_api/callback.php';

$request_data = [
    'BusinessShortCode' => $shortcode,
    'Password' => $password,
    'Timestamp' => $timestamp,
    'TransactionType' => 'CustomerPayBillOnline',
    'Amount' => $amount,
    'PartyA' => $phone,
    'PartyB' => $shortcode,
    'PhoneNumber' => $phone,
    'CallBackURL' => $callback_url,
    'AccountReference' => $order_id,
    'TransactionDesc' => 'Water delivery payment'
];

error_log("Sending STK Push request: " . json_encode($request_data));

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest');
curl_setopt($curl, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $access_token,
    'Content-Type: application/json'
]);
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($request_data));
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($curl, CURLOPT_TIMEOUT, 30);

$response = curl_exec($curl);
$http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
$curl_error = curl_error($curl);
curl_close($curl);

error_log("STK Push Response - HTTP Code: $http_code, Response: $response");

if ($curl_error) {
    error_log("STK Push cURL Error: " . $curl_error);
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Network error: ' . $curl_error]);
    exit;
}

$result = json_decode($response, true);

// Database operations
try {
    $pdo = db();
    $stmt = $pdo->prepare("INSERT INTO mpesa_transactions 
      (checkout_request_id, order_id, amount, phone, status, response_code, response_desc) 
      VALUES (?, ?, ?, ?, 'pending', ?, ?)");
    $stmt->execute([
        $result['CheckoutRequestID'] ?? null,
        $order_id,
        $amount,
        $phone,
        $result['ResponseCode'] ?? null,
        $result['ResponseDescription'] ?? null
    ]);
} catch (Exception $e) {
    error_log("Database error: " . $e->getMessage());
}

if (isset($result['CheckoutRequestID'])) {
    echo json_encode([
        'success' => true,
        'message' => 'Please enter your M-Pesa PIN.',
        'checkout_request_id' => $result['CheckoutRequestID']
    ]);
} else {
    $error_msg = $result['errorMessage'] ?? $result['ResponseDescription'] ?? 'Unknown payment failure';
    error_log("Payment failed: " . $error_msg);
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $error_msg]);
}
?>