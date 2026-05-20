<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\BackupController;
use App\Http\Controllers\API\BookFavoriteController;
use App\Http\Controllers\API\BookTagController;
use App\Http\Controllers\API\BookViewController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\ChatController;
use App\Http\Controllers\API\ChatMemberController;
use App\Http\Controllers\API\ChatMessageController;
use App\Http\Controllers\API\ItemController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\PdfCommentHighlightController;
use App\Http\Controllers\API\PermissionController;
use App\Http\Controllers\API\SearchController;
use App\Http\Controllers\API\TagController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\UserPermissionController;
use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\PdfProgressController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\LoginHistoryController;

use Illuminate\Session\Middleware\StartSession;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;



//call controller with function
Route::post('/signup', [AuthController::class, 'signup']);
Route::post('/signin', [AuthController::class, 'signin']);


Route::get('/email/verify/{id}/{hash}', [AuthController::class, 'verifyEmail'])
    ->middleware('signed')
    ->name('verify.email');

Route::post('/email/verify/resend', [AuthController::class, 'resendVerificationMail'])
    ->middleware('throttle:3,1');
//throttle:3,1: 3 request in 1 mins

Route::post('/password/forgot', [AuthController::class, 'sendResetPasswordMail']);

Route::post('/password/reset', [AuthController::class, 'setNewPassword'])->name('reset.password');


// Google OAuth routes
Route::get('/auth/google', [GoogleAuthController::class, 'redirectToGoogle']);
Route::get('/auth/google/callback', [GoogleAuthController::class, 'handleGoogleCallback']);


//===tracking devices====
Route::middleware([
    EncryptCookies::class,
    AddQueuedCookiesToResponse::class,
    StartSession::class,
])->group(function () {
    Route::post('/signin', [AuthController::class, 'signin']);
    Route::post('/signout', [AuthController::class, 'signout']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/login-history', [LoginHistoryController::class, 'index']);
    Route::get('/login-history/current', [LoginHistoryController::class, 'current']);
});

Route::middleware('auth:sanctum')->group(function () {
    // Regular authenticated routes
    Route::post('/signout', [AuthController::class, 'signout']);
    Route::patch('/token/refresh', [AuthController::class, 'refreshToken']);
    Route::get('/verify/account', [AuthController::class, 'verifyAccount']);
    Route::patch('/password/change', [AuthController::class, 'changePassword']);
    Route::patch('/password/create', [AuthController::class, 'createPassword']);
    Route::patch('/update/photo', [AuthController::class, 'updateUserPhoto']);



    // Admin-only routes

    Route::middleware('admin')->group(function () {
        Route::prefix('backups')->group(function () {
            Route::get('/', [BackupController::class, 'getBackups']);
            Route::post('/create', [BackupController::class, 'createBackup']);
            Route::get('/download/{filename}', [BackupController::class, 'downloadBackup']);
            Route::delete('/delete/{filename}', [BackupController::class, 'deleteBackup']);
        });
        Route::prefix('manage')->group(function () {
            Route::prefix('users')->group(function () {
                Route::get('/', [UserController::class, 'getDetailUsers']);
                Route::get('/read/{id}', [UserController::class, 'readDetailUser']);
                Route::post('/create', [UserController::class, 'createUser']);
                Route::put('/update/{id}', [UserController::class, 'updateUser']);
                Route::delete('/delete/{id}', [UserController::class, 'deleteUser']);
            });
        });
    });


    // User API Routes
    Route::prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'getUsers']);

        //===user profile===
        Route::get('/profile', [UserController::class, 'profile']);
        Route::patch('/profile', [UserController::class, 'updateProfile']);
        Route::patch('/about', [UserController::class, 'updateAbout']);
        Route::get('/favorites', [UserController::class, 'favorites']);
        Route::get('/logs', [UserController::class, 'logs']);
        Route::get('/interests', [UserController::class, 'interests']);
        Route::get('/user-tag-interests', [UserController::class, 'getUserTagInterests']);

        Route::get('/recommended-books', [UserController::class, 'getRecommendedBooks']);
        Route::get('/recommended-overall-books', [UserController::class, 'getRecommendedOverallBooks']);
        Route::get('/books/{id}/similar-titles', [UserController::class, 'getSimilarTitleBooks']);

    });
    // Chat API Routes
    Route::prefix('chats')->group(function () {
        // Chat management
        Route::get('/', [ChatController::class, 'getChats']);
        Route::post('/create', [ChatController::class, 'createChat']);
        Route::get('/read/{chatId}', [ChatController::class, 'readChat']);
        Route::patch('/update/{chatId}', [ChatController::class, 'updateGroupChat']);
        Route::delete('/delete/{chatId}', [ChatController::class, 'deleteGroupChat']);
        Route::post('/leave/{chatId}', [ChatController::class, 'leaveGroupChat']);
        Route::get('/read/{chatId}/{folder}/{filename}', [ChatController::class, 'readChatFile']);


        // Chat messages
        Route::get('/{chatId}/messages', [ChatMessageController::class, 'getMessages']);
        Route::post('/{chatId}/messages/create', [ChatMessageController::class, 'createMessage']);
        Route::patch('/{chatId}/messages/update/{messageId}', [ChatMessageController::class, 'updateMessage']);
        Route::delete('/{chatId}/messages/delete/{messageId}', [ChatMessageController::class, 'deleteMessage']);
        Route::post('/{chatId}/messages/seen/{messageId}', [ChatMessageController::class, 'markMessageAsSeen']);
        Route::post('/{chatId}/messages/seen-all', [ChatMessageController::class, 'markAllMessagesAsSeen']);

        // Chat members
        Route::get('/{chatId}/members', [ChatMemberController::class, 'getMembers']);
        Route::post('/{chatId}/members/add', [ChatMemberController::class, 'addMember']);

        //assign permission to member but not use
        //Route::patch('/{chatId}/members/update/{memberId}', [ChatMemberController::class, 'updateMember']);
        Route::delete('/{chatId}/members/remove/{memberId}', [ChatMemberController::class, 'removeMember']);
    });


});

// Item Category/items
Route::middleware('auth:sanctum')->group(function () {
    //Route::apiResource('categories', CategoryController::class);
    Route::get('categories', [CategoryController::class, 'index']);
    Route::post('categories', [CategoryController::class, 'store']);
    Route::PUT('categories/{category}', [CategoryController::class, 'update']);
    Route::delete('categories/{category}', [CategoryController::class, 'destroy']);

    //===tag=====
    Route::prefix('tags')->group(function () {
        Route::get('/',[TagController::class, 'index']);
        Route::post('/', [TagController::class,'store']);
        Route::get('/{id}',[TagController::class, 'show']);
        Route::put('/{id}',[TagController::class, 'update']);
        Route::patch('/{id}',[TagController::class, 'update']);
        Route::delete('/{id}',[TagController::class, 'destroy']);
    });


    //===item===
    Route::prefix('items')->group(function () {
        Route::get('/',[ItemController::class, 'index']);
        Route::post('/', [ItemController::class,'store']);
        Route::get('/{id}',[ItemController::class, 'show']);
        Route::put('/{id}',[ItemController::class, 'update']);
        Route::patch('/{id}',[ItemController::class, 'update']);
        Route::delete('/{id}',[ItemController::class, 'destroy']);
    });

    //items notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::patch('/{id}/read', [NotificationController::class, 'markOneRead']);
        Route::patch('/read-all', [NotificationController::class, 'markAllRead']);
        Route::delete('/clear-all', [NotificationController::class, 'clearAll']);
    });

    Route::prefix('search')->group(function () {
        Route::get('/books', [SearchController::class, 'search']);
        Route::get('/trending', [SearchController::class, 'trending']);
        Route::get('/suggested', [SearchController::class, 'suggested']);
    });

    //==new Vue pdf
//    Route::get('/pdf-progress', [PdfProgressController::class, 'show']);   // ?book_id=1 OR ?doc_key=...
//    Route::post('/pdf-progress', [PdfProgressController::class, 'store']); // save progress
    Route::prefix('pdf-progress')->group(function () {
        Route::get('/pdf-progress-list', [PdfProgressController::class, 'index']); // list
        Route::get('/', [PdfProgressController::class, 'show']);
        Route::post('/', [PdfProgressController::class, 'store']);
    });

    //====pdf comment & highlight
    Route::prefix('pdf-comment-highlights')->group(function () {
        Route::get('/',[PdfCommentHighlightController::class, 'index']);
        Route::post('/', [PdfCommentHighlightController::class,'store']);
        Route::get('/{id}',[PdfCommentHighlightController::class, 'show']);
        Route::put('/{id}', [PdfCommentHighlightController::class,'update']);
        Route::delete('/{id}', [PdfCommentHighlightController::class,'destroy']);
    });

    //==view book
    Route::prefix('books')->group(function () {
        //Route::post('{book}/view', [BookViewController::class, 'store']);
        Route::get('{book}/views/count', [BookViewController::class, 'count']);
    });

    //===favorite & tag
    Route::prefix('books')->group(function () {
        Route::get('{book}/favorite/check', [BookFavoriteController::class, 'check']);
        Route::post('{book}/favorite', [BookFavoriteController::class, 'store']);
        Route::delete('{book}/favorite', [BookFavoriteController::class, 'destroy']);

        Route::get('{bookId}/tags', [BookTagController::class, 'index']);
        Route::put('{book}/tags', [BookTagController::class, 'update']);
        Route::post('{book}/tags/attach', [BookTagController::class, 'attach']);
        Route::delete('{book}/tags/{tag}', [BookTagController::class, 'detach']);
    });

    //==user favorites
    Route::get('my-favorite-books', [BookFavoriteController::class, 'index']);


    //===chat
    Route::delete('/chats/{chatId}', [ChatController::class, 'deleteChat']);


    //==== permission===
    Route::prefix('permissions')->group(function(){
        Route::get('/', [PermissionController::class, 'index']);
        Route::get('/simple', [PermissionController::class, 'listSimple']);
        Route::get('/{id}', [PermissionController::class, 'show'])
            ->whereNumber('id');
        Route::post('/', [PermissionController::class, 'store']);
        Route::put('/{id}', [PermissionController::class, 'update'])
            ->whereNumber('id');
        Route::delete('/{id}', [PermissionController::class, 'destroy'])
            ->whereNumber('id');
    });

    //====user permission===
    Route::prefix('user-permissions')->group(function () {
        Route::get('/', [UserPermissionController::class,'index']);
        Route::get('/{id}', [UserPermissionController::class,'show']);
        Route::post('/', [UserPermissionController::class,'store']);
        Route::put('/{id}', [UserPermissionController::class,'update']);
        Route::delete('/{id}', [UserPermissionController::class,'destroy']);
    });

});


//==user view pdf===
Route::get('/pdf-file/{path}', function ($path) {

    $path = urldecode($path);

    if (!Storage::disk('public')->exists($path)) {
        abort(404, 'File not found');
    }

    $fullPath = storage_path('app/public/' . $path);

    return response()->file($fullPath, [
        'Content-Type' => 'application/pdf',
        'Access-Control-Allow-Origin' => '*',
        'Cache-Control' => 'private, max-age=3600',
    ]);

})->where('path', '.*');

