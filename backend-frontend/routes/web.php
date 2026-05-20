<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});
