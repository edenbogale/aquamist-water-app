<?php
// callback.php - Handles M-Pesa response and saves to database

header('Content-Type: application/json');

// Database connection
$host = 'localhost';
$dbname = 'water_delivery_db';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    file_put_contents('callback_error.txt', date('Y-m-d H:i:s') . " - DB Error: " . $e->getMessage() . "\n", FILE_APPEND);
    http_response_code(200);
    echo json_encode(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
    exit;
}

// Get M-Pesa callback data
$callbackData = file_get_contents('php://input');
$data = json_decode($callbackData, true);

// Log the raw callback
file_put_contents('callback_log.txt', date('Y-m-d H:i:s') . " - " . $callbackData . "\n\n", FILE_APPEND);

// Extract callback data
$resultCode = $data['Body']['stkCallback']['ResultCode'] ?? null;
$resultDesc = $data['Body']['stkCallback']['ResultDesc'] ?? 'Unknown';
$checkoutRequestID = $data['Body']['stkCallback']['CheckoutRequestID'] ?? null;

// Default values
$amount = 0;
$phone = '';
$mpesaReceipt = null;

// If payment was successful
if ($resultCode == 0 && isset($data['Body']['stkCallback']['CallbackMetadata']['Item'])) {
    $items = $data['Body']['stkCallback']['CallbackMetadata']['Item'];
    
    foreach ($items as $item) {
        switch ($item['Name']) {
            case 'Amount':
                $amount = $item['Value'];
                break;
            case 'MpesaReceiptNumber':
                $mpesaReceipt = $item['Value'];
                break;
            case 'PhoneNumber':
                $phone = $item['Value'];
                break;
        }
    }
}

// Determine status
$status = ($resultCode == 0) ? 'completed' : 'failed';

// Save to database
try {
    $sql = "INSERT INTO mpesa_transactions 
            (checkout_request_id, amount, phone, status, response_code, response_desc, mpesa_receipt, created_at) 
            VALUES 
            (:checkout_id, :amount, :phone, :status, :response_code, :response_desc, :mpesa_receipt, NOW())
            ON DUPLICATE KEY UPDATE 
            status = :status2, 
            response_code = :response_code2, 
            response_desc = :response_desc2,
            mpesa_receipt = :mpesa_receipt2,
            updated_at = NOW()";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':checkout_id' => $checkoutRequestID,
        ':amount' => $amount,
        ':phone' => $phone,
        ':status' => $status,
        ':response_code' => $resultCode,
        ':response_desc' => $resultDesc,
        ':mpesa_receipt' => $mpesaReceipt,
        ':status2' => $status,
        ':response_code2' => $resultCode,
        ':response_desc2' => $resultDesc,
        ':mpesa_receipt2' => $mpesaReceipt
    ]);
    
    file_put_contents('callback_success.txt', date('Y-m-d H:i:s') . " - Saved: $checkoutRequestID\n", FILE_APPEND);
    
} catch (PDOException $e) {
    file_put_contents('callback_error.txt', date('Y-m-d H:i:s') . " - " . $e->getMessage() . "\n", FILE_APPEND);
}

// Always respond with success
http_response_code(200);
echo json_encode(['ResultCode' => 0, 'ResultDesc' => 'Accepted']);
?>