<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
require_once __DIR__.'/config.php';

try {
    $pdo = db();
    $stmt = $pdo->query("SELECT id, name, description, price, image_url, category, rating, comments, distance, delivery_time FROM products ORDER BY category, name");
    $rows = $stmt->fetchAll();

    // 👇 DO NOTHING — your image_url is already correct!
    // No need to replace or modify — it's already full URL

    // Allow Flutter to access this API
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json");

    echo json_encode(['success' => true, 'data' => $rows]);

} catch (Exception $e) {
    header("Content-Type: application/json");
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    http_response_code(500);
}
?>