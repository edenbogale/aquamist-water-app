<?php
require_once __DIR__.'/config.php';

// Allow CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Your Google Maps API Key
define('GOOGLE_MAPS_API_KEY', 'YOUR_GOOGLE_API_KEY_HERE');

/**
 * Geocode an address to get latitude and longitude
 */
function geocodeAddress($address) {
    $url = "https://maps.googleapis.com/maps/api/geocode/json?address=" . urlencode($address) . "&key=" . GOOGLE_MAPS_API_KEY;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $data = json_decode($response, true);
    
    if ($data['status'] == 'OK') {
        $location = $data['results'][0]['geometry']['location'];
        return [
            'success' => true,
            'lat' => $location['lat'],
            'lng' => $location['lng'],
            'formatted_address' => $data['results'][0]['formatted_address']
        ];
    } else {
        return [
            'success' => false,
            'error' => $data['error_message'] ?? 'Geocoding failed'
        ];
    }
}

/**
 * Calculate distance and time between two points
 */
function calculateDistance($origin, $destination) {
    $url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" . urlencode($origin) . 
           "&destinations=" . urlencode($destination) . "&key=" . GOOGLE_MAPS_API_KEY;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $data = json_decode($response, true);
    
    if ($data['status'] == 'OK') {
        if ($data['rows'][0]['elements'][0]['status'] == 'OK') {
            $distance = $data['rows'][0]['elements'][0]['distance']['text'];
            $duration = $data['rows'][0]['elements'][0]['duration']['text'];
            
            return [
                'success' => true,
                'distance' => $distance,
                'duration' => $duration
            ];
        } else {
            return [
                'success' => false,
                'error' => 'Could not calculate distance between points'
            ];
        }
    } else {
        return [
            'success' => false,
            'error' => $data['error_message'] ?? 'Distance calculation failed'
        ];
    }
}

/**
 * Handle incoming requests
 */
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $action = $_GET['action'] ?? '';
    
    if ($action === 'geocode') {
        $address = $_GET['address'] ?? '';
        if (!empty($address)) {
            $result = geocodeAddress($address);
            json_response($result);
        } else {
            json_response(['success' => false, 'error' => 'Address parameter is required'], 400);
        }
    } 
    elseif ($action === 'distance') {
        $origin = $_GET['origin'] ?? '';
        $destination = $_GET['destination'] ?? '';
        
        if (!empty($origin) && !empty($destination)) {
            $result = calculateDistance($origin, $destination);
            json_response($result);
        } else {
            json_response(['success' => false, 'error' => 'Origin and destination parameters are required'], 400);
        }
    }
    else {
        json_response(['success' => false, 'error' => 'Valid action parameter is required'], 400);
    }
} else {
    json_response(['success' => false, 'error' => 'Method not allowed'], 405);
}
?>