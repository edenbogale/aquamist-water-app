<?php
$DB_HOST = "localhost";
$DB_NAME = "water_delivery_db";
$DB_USER = "root";
$DB_PASS = "";

// ✅ CORS headers - must be before any output
// header("Access-Control-Allow-Origin: *");
// header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
// header("Access-Control-Allow-Headers: Content-Type, Authorization");


if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

function db(){
  global $DB_HOST,$DB_NAME,$DB_USER,$DB_PASS;
  static $pdo;
  if (!$pdo) {
    $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4", $DB_USER, $DB_PASS, [
      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
      PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
  }
  return $pdo;
}

function json_response($data, $code = 200){
  http_response_code($code);
  header('Content-Type: application/json');
  echo json_encode($data);
  exit;
}

function body_json(){
  return json_decode(file_get_contents('php://input'), true) ?? [];
}
?>