<?php

//return [
////    'paths' => ['api/*', 'sanctum/csrf-cookie'],
////
////    'allowed_methods' => ['*'],
////
////    'allowed_origins' => [
////        'http://localhost:5173',
////        'http://127.0.0.1:5173',
////    ],
////
////    'allowed_headers' => ['*'],
////
////    'exposed_headers' => [],
////
////    'max_age' => 0,
////
////    'supports_credentials' => false,
//
//
////    'paths' => ['api/*', 'storage/*'],
////    'allowed_origins' => ['http://localhost:5173'],
////    'allowed_methods' => ['*'],
////    'allowed_headers' => ['*'],
////    'exposed_headers' => ['Content-Length', 'Content-Range', 'Accept-Ranges'],
//
//    'paths' => ['api/*', 'pdf-progress','pdf-file', 'storage/*'],
//    'allowed_origins' => ['http://localhost:5173', 'http://127.0.0.1:5173'],
//    'allowed_methods' => ['*'],
//    'allowed_headers' => ['*'],
//
//
//
//];


return [

    'paths' => [
        'api/*',
        'sanctum/csrf-cookie', 'pdf-progress','pdf-file', 'storage/*'
    ],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:5173'
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
