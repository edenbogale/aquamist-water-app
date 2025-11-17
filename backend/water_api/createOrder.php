<?php
require_once __DIR__.'/config.php';

$payload = json_decode(file_get_contents('php://input'), true);

if (!$payload || !isset($payload['user_name'], $payload['user_phone'], $payload['address'], $payload['items'])) {
    json_response(['success' => false, 'error' => 'Missing required fields'], 400);
}

$totalAmount = $payload['total_amount'] ?? 0;

try {
    $pdo = db();
    $pdo->beginTransaction();

    $stmt = $pdo->prepare("INSERT INTO orders (user_name, user_email, user_phone, address, total_amount, status) VALUES (?, ?, ?, ?, ?, 'pending')");
    $stmt->execute([
        $payload['user_name'],
        $payload['user_email'] ?? null,
        $payload['user_phone'],
        $payload['address'],
        $totalAmount
    ]);

    $orderId = (int)$pdo->lastInsertId();

    $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)");
    foreach ($payload['items'] as $item) {
        if (!isset($item['product_id'], $item['quantity'], $item['price'])) {
            continue;
        }
        $itemStmt->execute([
            $orderId,
            $item['product_id'],
            (int)$item['quantity'],
            (float)$item['price']
        ]);
    }

    $pdo->commit();
    json_response(['success' => true, 'order_id' => $orderId]);
} catch (Exception $e) {
    if ($pdo?->inTransaction()) $pdo->rollBack();
    json_response(['success' => false, 'error' => $e->getMessage()], 500);
}
?>