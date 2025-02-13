<?php



if (isset($_GET['url'])) {
    $url = urldecode($_GET['url']);
} else {
    die("No URL provided. Usage: FF");
}


if (!filter_var($url, FILTER_VALIDATE_URL)) {
    die("Invalid URL provided.");
}





$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); 
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); 


$response = curl_exec($ch);


if (curl_errno($ch)) {
    die("Error fetching URL: " . curl_error($ch));
}


$contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);


curl_close($ch);


header("Content-Type: $contentType");


echo $response;
?>