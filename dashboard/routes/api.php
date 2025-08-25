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

// Routes d'authentification selon CLAUDE.md
Route::post('/auth/login', [\App\Http\Controllers\Api\AuthController::class, 'login']);

// Routes API selon CLAUDE.md - Structure exacte demandée
Route::middleware(['auth:sanctum'])->prefix('api')->group(function () {
    
    // PDV endpoints selon CLAUDE.md
    Route::get('pdv', [\App\Http\Controllers\Api\PDVController::class, 'index']); // Liste PDV par zone
    Route::get('pdv/{id}', [\App\Http\Controllers\Api\PDVController::class, 'show']); // Détail PDV avec géofencing
    
    // Visites endpoints selon CLAUDE.md  
    Route::post('visites', [\App\Http\Controllers\Api\VisiteController::class, 'store']); // Création nouvelle visite
    Route::put('visites/{id}', [\App\Http\Controllers\Api\VisiteController::class, 'update']); // Mise à jour visite
    
    // Commercial/User endpoints selon CLAUDE.md
    Route::get('commerciaux/me', [\App\Http\Controllers\Api\UserController::class, 'me']); // Profil utilisateur connecté
    
    // Images upload selon CLAUDE.md
    Route::post('images/upload', [\App\Http\Controllers\Api\VisiteController::class, 'uploadImages']); // Upload photos
    
    // Dashboard stats selon CLAUDE.md
    Route::get('dashboard/stats', [\App\Http\Controllers\Api\AnalyticsController::class, 'stats']); // Métriques pour dashboard
    
    // Routes additionnelles pour synchronisation hors-ligne selon CLAUDE.md
    Route::get('sync/check', [\App\Http\Controllers\Api\SyncController::class, 'check']);
    Route::post('sync/upload', [\App\Http\Controllers\Api\SyncController::class, 'upload']);
    Route::get('sync/download', [\App\Http\Controllers\Api\SyncController::class, 'download']);
    
    // Routes géofencing selon CLAUDE.md - validation 300m obligatoire
    Route::post('geofences/validate', [\App\Http\Controllers\Api\GeofenceController::class, 'validate']);
}); 