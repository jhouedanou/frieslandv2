<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    /**
     * Authentifier un utilisateur
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'nullable|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Les identifiants fournis sont incorrects.'],
            ]);
        }

        if (!$user->is_active) {
            return response()->json([
                'message' => 'Compte désactivé'
            ], 403);
        }

        // Révoquer les anciens tokens
        $user->tokens()->delete();

        // Créer un nouveau token
        $token = $user->createToken($request->device_name ?? 'mobile-app');

        return response()->json([
            'user' => $user->load('roles'),
            'token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'expires_at' => now()->addDays(30),
        ]);
    }

    /**
     * Enregistrer un nouvel utilisateur
     */
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|string|in:commercial,supervisor',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'is_active' => true,
        ]);

        // Assigner le rôle
        $user->assignRole($request->role);

        // Créer un token
        $token = $user->createToken('mobile-app');

        return response()->json([
            'user' => $user->load('roles'),
            'token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'expires_at' => now()->addDays(30),
        ], 201);
    }

    /**
     * Déconnecter l'utilisateur
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie'
        ]);
    }

    /**
     * Rafraîchir le token
     */
    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();
        
        // Révoquer l'ancien token
        $user->currentAccessToken()->delete();
        
        // Créer un nouveau token
        $token = $user->createToken('mobile-app');

        return response()->json([
            'token' => $token->plainTextToken,
            'token_type' => 'Bearer',
            'expires_at' => now()->addDays(30),
        ]);
    }

    /**
     * Vérifier la validité du token
     */
    public function check(Request $request): JsonResponse
    {
        $user = $request->user();
        
        return response()->json([
            'valid' => true,
            'user' => $user->load('roles'),
            'expires_at' => $user->currentAccessToken()->created_at->addDays(30),
        ]);
    }
} 