<?php
// ✅ Must be first
header("ngrok-skip-browser-warning: true");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

function db() {
    $host = 'localhost';
    $db   = 'water_app';
    $user = 'root';
    $pass = '';
    $charset = 'utf8mb4';
    $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    try {
        return new PDO($dsn, $user, $pass, $options);
    } catch (PDOException $e) {
        file_put_contents(__DIR__.'/db_error.log', $e->getMessage() . "\n", FILE_APPEND);
        die(json_encode(['error' => 'Database connection failed']));
    }
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

file_put_contents(__DIR__.'/mpesa_callback.log',
    date('Y-m-d H:i:s') . " - " . $input . "\n\n",
    FILE_APPEND
);

if (isset($data['Body']['stkCallback']['CheckoutRequestID'])) {
    $result = $data['Body']['stkCallback'];
    $checkout_id = $result['CheckoutRequestID'];
    $status = $result['ResultCode'];

    $pdo = db();

    if ($status == 0) {
        $amount = $phone = $receipt = '';
        foreach ($result['CallbackMetadata']['Item'] as $item) {
            if ($item['Name'] == 'Amount') $amount = $item['Value'];
            if ($item['Name'] == 'PhoneNumber') $phone = $item['Value'];
            if ($item['Name'] == 'MpesaReceiptNumber') $receipt = $item['Value'];
        }

        $stmt = $pdo->prepare("UPDATE mpesa_transactions SET 
              status = 'success', 
              mpesa_receipt = ?, 
              updated_at = NOW() 
              WHERE checkout_request_id = ?");
        $stmt->execute([$receipt, $checkout_id]);

        $orderStmt = $pdo->prepare("SELECT order_id FROM mpesa_transactions WHERE checkout_request_id = ?");
        $orderStmt->execute([$checkout_id]);
        $order = $orderStmt->fetch();

        if ($order) {
            $pdo->prepare("UPDATE orders SET 
                  payment_status = 'paid', 
                  payment_method = 'mpesa' 
                  WHERE id = ?")->execute([$order['order_id']]);
        }
    } else {
        $pdo->prepare("UPDATE mpesa_transactions SET 
              status = 'failed', 
              response_desc = ? 
              WHERE checkout_request_id = ?")
            ->execute([$result['ResultDesc'], $checkout_id]);
    }
}

http_response_code(200);
echo json_encode([
    'ResultCode' => 0,
    'ResultDesc' => 'Accepted'
]);
?>