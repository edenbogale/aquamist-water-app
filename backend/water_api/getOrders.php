<?php
header('Content-Type: application/json');
require_once __DIR__.'/config.php';

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(['success' => false, 'error' => 'User ID is required']);
    http_response_code(400);
    exit;
}

try {
    $pdo = db();
    $stmt = $pdo->prepare("SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->execute([$user_id]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(['success' => true, 'orders' => $orders]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    http_response_code(500);
}
?>
