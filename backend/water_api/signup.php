<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

// Report all errors
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$host = "localhost";
$db = "water_delivery_db";
$user = "root";
$pass = "";
$conn = new mysqli($host, $user, $pass, $db);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed"]);
    exit();
}

// Get POST data
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$password = $_POST['password'] ?? '';

// Validate required fields
if (empty($name) || empty($email) || empty($phone) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit();
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Check if user exists
$checkUser = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkUser->bind_param("s", $email);
$checkUser->execute();
$result = $checkUser->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "User already exists"]);
} else {
    // Insert user
    $stmt = $conn->prepare("INSERT INTO users (name, email, phone, password) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $name, $email, $phone, $hashedPassword);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Account created"]);
    } else {
        echo json_encode(["success" => false, "message" => "Signup failed"]);
    }
}

$conn->close();
?>
