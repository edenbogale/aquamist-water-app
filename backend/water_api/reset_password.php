<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once __DIR__.'/config.php';

try {
    $input = json_decode(file_get_contents('php://input'), true);
    $email = trim($input['email'] ?? '');

    if (empty($email)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Email is required']);
        exit;
    }

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid email format']);
        exit;
    }

    // Check if user exists
    $pdo = db();
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    
    if ($stmt->rowCount() === 0) {
        // Still return success to avoid email enumeration
        echo json_encode([
            'success' => true,
            'message' => 'If your email is registered, you will receive a password reset link shortly.'
        ]);
        exit;
    }

    // 🔑 In a real app, you'd:
    // 1. Generate a secure token
    // 2. Store it in a `password_resets` table with expiry
    // 3. Send email via SMTP (PHPMailer, etc.)
    
    // For demo/final project, just simulate success
    echo json_encode([
        'success' => true,
        'message' => 'If your email is registered, you will receive a password reset link shortly.'
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error. Please try again later.']);
}
?>