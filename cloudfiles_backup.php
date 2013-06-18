<?php

// Backup script called by make-backup.sh. 
// Requires the Rackspace php-opencloud library - https://github.com/rackspace/php-opencloud
// Based on documentation and examples at https://github.com/rackspace/php-opencloud/

$libPath = 'lib/'; // define path to php-opencloud library
$username = 'user_name'; // define username
$apiKey = 'api_key'; // define api key
$url = "https://identity.api.rackspacecloud.com/v2.0/"; // define endpoint
$target = 'container_name'; // define target container
#$expiration = 3600; // define object expiration in seconds. 3600 minimum value.
$filePath = $arg[1]; // define file path - supplied by bash script
$fileName = $arg[2]; // define file path - supplied by bash script


// include the autoloader
require_once $libPath . '/php-opencloud.php';

use OpenCloud\Rackspace;

// authenticate with rackspace
$endpoint = $url;
$credentials = array(
	'username' => $username,
    'apiKey' => $apiKey
);
$connection = new Rackspace($endpoint, $credentials);
$connection->SetDefaults('ObjectStore','cloudFiles','ORD','publicURL');


// progress callback function
function UploadProgress($len) {
	printf("[uploading %d bytes]", $len);
}

// set the callback function
$connection->SetUploadProgressCallback('UploadProgress');

// create a Cloud Files (ObjectStore) connection
$ostore = $connection->ObjectStore('cloudFiles','ORD');

 // select existing container
$container = $ostore->Container($target);

//create new object
$newObj = $container->DataObject();
$newObj->extra_headers['X-Delete-After'] = 3600;
$newObj->Create( array('name' => $fileName, 'content_type' => 'application/x-compressed'), $filePath); 

?>

