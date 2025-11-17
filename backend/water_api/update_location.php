<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // allow local testing
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once __DIR__ . '/config.php';

$payload = json_decode(file_get_contents('php://input'), true);
$order_id = $payload['order_id'] ?? '';
$latitude = $payload['latitude'] ?? null;
$longitude = $payload['longitude'] ?? null;

if (empty($order_id)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Order ID is required']);
    exit;
}

if (!is_numeric($latitude) || !is_numeric($longitude)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Valid latitude and longitude are required']);
    exit;
}

try {
    $pdo = db();

    // Ensure table exists (safe for first-run)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS delivery_locations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id VARCHAR(100) NOT NULL UNIQUE,
            latitude DECIMAL(10,8) NOT NULL,
            longitude DECIMAL(11,8) NOT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (order_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ");

    $stmt = $pdo->prepare("
        INSERT INTO delivery_locations (order_id, latitude, longitude)
        VALUES (:order_id, :latitude, :longitude)
        ON DUPLICATE KEY UPDATE
            latitude = VALUES(latitude),
            longitude = VALUES(longitude),
            updated_at = CURRENT_TIMESTAMP
    ");

    $stmt->execute([
        ':order_id' => $order_id,
        ':latitude' => $latitude,
        ':longitude' => $longitude,
    ]);

    echo json_encode(['success' => true, 'message' => 'Location updated']);
} catch (Exception $e) {
    error_log('Update Location Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
