<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // allow local testing
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once __DIR__ . '/config.php';

$order_id = $_GET['order_id'] ?? '';

if (empty($order_id)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Order ID required']);
    exit;
}

try {
    $pdo = db();

    $stmt = $pdo->prepare("
        SELECT latitude, longitude, updated_at
        FROM delivery_locations
        WHERE order_id = ?
        ORDER BY updated_at DESC
        LIMIT 1
    ");
    $stmt->execute([$order_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        echo json_encode([
            'success' => true,
            'location' => [
                'latitude' => (float)$row['latitude'],
                'longitude' => (float)$row['longitude'],
                'updated_at' => $row['updated_at'],
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'error' => 'No location found for this order']);
    }
} catch (Exception $e) {
    error_log('Get Location Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
