<?php
require_once __DIR__.'/config.php';
$payload = body_json();
try{
  $orderId = (int)($payload['order_id'] ?? 0);
  if ($orderId <= 0) json_response(['success'=>false,'error'=>'order_id required'],400);
  $fields = []; $params = [];
  if (isset($payload['status'])) { $fields[]='status=?'; $params[]=$payload['status']; }
  if (isset($payload['driver_lat'])) { $fields[]='driver_lat=?'; $params[]=$payload['driver_lat']; }
  if (isset($payload['driver_lng'])) { $fields[]='driver_lng=?'; $params[]=$payload['driver_lng']; }
  if (empty($fields)) json_response(['success'=>false,'error'=>'Nothing to update'],400);
  $params[] = $orderId;
  $sql = "UPDATE orders SET ".implode(", ",$fields)." WHERE id=?";
  $pdo = db();
  $stmt = $pdo->prepare($sql);
  $stmt->execute($params);
  json_response(['success'=>true]);
} catch(Exception $e){
  json_response(['success'=>false,'error'=>$e->getMessage()],500);
}
