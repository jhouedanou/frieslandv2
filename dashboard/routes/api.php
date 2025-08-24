<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Routes publiques pour la santé et l'authentification
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});

// Routes d'authentification
Route::post('/auth/login', [\App\Http\Controllers\Api\AuthController::class, 'login']);
Route::post('/auth/register', [\App\Http\Controllers\Api\AuthController::class, 'register']);
Route::post('/auth/logout', [\App\Http\Controllers\Api\AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::post('/auth/refresh', [\App\Http\Controllers\Api\AuthController::class, 'refresh'])->middleware('auth:sanctum');

// Routes protégées pour l'API Friesland
Route::middleware(['auth:sanctum'])->group(function () {
    Route::prefix('v1')->group(function () {
        // Routes pour les PDV
        Route::apiResource('pdvs', \App\Http\Controllers\Api\PDVController::class);
        Route::get('pdvs/nearby', [\App\Http\Controllers\Api\PDVController::class, 'nearby']);
        Route::get('pdvs/search', [\App\Http\Controllers\Api\PDVController::class, 'search']);
        Route::get('pdvs/statistics', [\App\Http\Controllers\Api\PDVController::class, 'statistics']);
        
        // Routes pour les visites
        Route::apiResource('visites', \App\Http\Controllers\Api\VisiteController::class);
        Route::get('visites/statistics', [\App\Http\Controllers\Api\VisiteController::class, 'statistics']);
        Route::post('visites/start', [\App\Http\Controllers\Api\VisiteController::class, 'startVisit']);
        Route::post('visites/end', [\App\Http\Controllers\Api\VisiteController::class, 'endVisit']);
        Route::post('visites/upload-photo', [\App\Http\Controllers\Api\VisiteController::class, 'uploadPhoto']);
        Route::post('visites/signature', [\App\Http\Controllers\Api\VisiteController::class, 'uploadSignature']);
        
        // Routes pour les utilisateurs
        Route::apiResource('users', \App\Http\Controllers\Api\UserController::class);
        Route::get('users/profile', [\App\Http\Controllers\Api\UserController::class, 'profile']);
        Route::put('users/profile', [\App\Http\Controllers\Api\UserController::class, 'updateProfile']);
        Route::get('users/statistics', [\App\Http\Controllers\Api\UserController::class, 'statistics']);
        
        // Routes pour les analytics
        Route::get('analytics/dashboard', [\App\Http\Controllers\Api\AnalyticsController::class, 'dashboard']);
        Route::get('analytics/visites', [\App\Http\Controllers\Api\AnalyticsController::class, 'visites']);
        Route::get('analytics/pdvs', [\App\Http\Controllers\Api\AnalyticsController::class, 'pdvs']);
        Route::get('analytics/commercials', [\App\Http\Controllers\Api\AnalyticsController::class, 'commercials']);
        Route::get('analytics/performance', [\App\Http\Controllers\Api\AnalyticsController::class, 'performance']);
        
        // Routes pour la synchronisation hors ligne
        Route::get('sync/check', [\App\Http\Controllers\Api\SyncController::class, 'check']);
        Route::post('sync/upload', [\App\Http\Controllers\Api\SyncController::class, 'upload']);
        Route::get('sync/download', [\App\Http\Controllers\Api\SyncController::class, 'download']);
        Route::post('sync/conflict-resolve', [\App\Http\Controllers\Api\SyncController::class, 'resolveConflict']);
        
        // Routes pour les géofences
        Route::get('geofences', [\App\Http\Controllers\Api\GeofenceController::class, 'index']);
        Route::post('geofences/check', [\App\Http\Controllers\Api\GeofenceController::class, 'checkLocation']);
        Route::post('geofences/enter', [\App\Http\Controllers\Api\GeofenceController::class, 'enterZone']);
        Route::post('geofences/exit', [\App\Http\Controllers\Api\GeofenceController::class, 'exitZone']);
        
        // Routes pour les produits et prix
        Route::get('products', [\App\Http\Controllers\Api\ProductController::class, 'index']);
        Route::get('products/categories', [\App\Http\Controllers\Api\ProductController::class, 'categories']);
        Route::post('products/verify', [\App\Http\Controllers\Api\ProductController::class, 'verify']);
        Route::get('products/visit/{visiteId}', [\App\Http\Controllers\Api\ProductController::class, 'getForVisit']);
        Route::post('prices/verify', [\App\Http\Controllers\Api\PriceController::class, 'verify']);
        Route::get('prices/reference', [\App\Http\Controllers\Api\PriceController::class, 'reference']);
        Route::get('prices/history', [\App\Http\Controllers\Api\PriceController::class, 'history']);
        
        // Routes pour les rapports
        Route::get('reports/visits', [\App\Http\Controllers\Api\ReportController::class, 'visits']);
        Route::get('reports/performance', [\App\Http\Controllers\Api\ReportController::class, 'performance']);
        Route::get('reports/export', [\App\Http\Controllers\Api\ReportController::class, 'export']);
    });
});

// Routes pour les webhooks (si nécessaire)
Route::post('webhooks/geofence', [\App\Http\Controllers\Api\WebhookController::class, 'geofence']);
Route::post('webhooks/visit-complete', [\App\Http\Controllers\Api\WebhookController::class, 'visitComplete']); 