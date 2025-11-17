<?php
header('Content-Type: application/json');
require_once __DIR__.'/config.php';

$payload = json_decode(file_get_contents('php://input'), true);
$order_id = $payload['order_id'] ?? '';
$status = $payload['status'] ?? '';

if (empty($order_id) || empty($status)) {
    echo json_encode(['success' => false, 'error' => 'Order ID and status are required']);
    http_response_code(400);
    exit;
}

$validStatuses = ['confirmed', 'preparing', 'delivering', 'delivered'];
if (!in_array(strtolower($status), $validStatuses)) {
    echo json_encode(['success' => false, 'error' => 'Invalid status']);
    http_response_code(400);
    exit;
}

try {
    $pdo = db();
    $stmt = $pdo->prepare("UPDATE orders SET status = ? WHERE id = ?");
    $stmt->execute([$status, $order_id]);

    echo json_encode(['success' => true, 'message' => 'Order status updated']);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    http_response_code(500);
}
?>
