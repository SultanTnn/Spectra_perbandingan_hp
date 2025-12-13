<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
// Handle Preflight Request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
$servername = "localhost";
$username = "bate2939_root";
$password = "kocak@123"; // Pastikan password ini sesuai dengan yang Anda set di cPanel
$dbname = "bate2939_perbandingan_hp";
// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);
// Cek koneksi
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "error" => "Koneksi database GAGAL.",
        "detail" => "Pastikan user dan password di db_config.php benar.",
        "db_error" => $conn->connect_error
    ]);
    exit;
}
// Set charset ke UTF-8
$conn->set_charset("utf8");
?>