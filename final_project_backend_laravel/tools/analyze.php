<?php
$str = file_get_contents('e2e_stdout.txt');
$str = mb_convert_encoding($str, 'UTF-8', 'UTF-16LE');
// Remove BOM if present
if (substr($str, 0, 3) === "\xEF\xBB\xBF") {
    $str = substr($str, 3);
}

$data = json_decode($str, true);

if ($data === null) {
    echo "JSON decode error: " . json_last_error_msg() . "\n";
    echo "First 500 chars:\n" . substr($str, 0, 500) . "\n";
    exit;
}

if (isset($data['error'])) {
    echo "Workflow failed at: " . ($data['error'] ?? 'Unknown step') . "\n";
    if (isset($data['create']['body'])) {
        $body = $data['create']['body'];
        if (strpos($body, '<title>') !== false) {
            preg_match('/<title>(.*?)<\/title>/', $body, $matches);
            echo "Exception Title: " . ($matches[1] ?? 'None') . "\n";
        }
        $bdata = json_decode($body, true);
        if ($bdata) {
            echo "Body JSON: " . print_r($bdata, true) . "\n";
        } else {
            // It's html, let's extract the exception message
            preg_match('/"message": "(.*?)"/', $body, $matches);
            if ($matches) echo "Exception Message: " . $matches[1] . "\n";
            preg_match('/"exception": "(.*?)"/', $body, $matches2);
            if ($matches2) echo "Exception Class: " . $matches2[1] . "\n";
            preg_match('/"file": "(.*?)"/', $body, $matches3);
            if ($matches3) echo "File: " . $matches3[1] . "\n";
        }
    }
}

// Check phase 1
if (isset($data['phase1'])) {
    echo "Phase 1 keys: " . implode(', ', array_keys($data['phase1'])) . "\n";
}

// Check phase 2
if (isset($data['phase2'])) {
    echo "Phase 2 keys: " . implode(', ', array_keys($data['phase2'])) . "\n";
}
