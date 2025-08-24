<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::query();

        // Filtres
        if ($request->has('role')) {
            $query->where('role', $request->role);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        // Recherche
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $users = $query->with('roles')
            ->orderBy('name')
            ->paginate($request->get('per_page', 15));

        return response()->json($users);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'role' => 'required|string|in:admin,manager,supervisor,commercial',
            'is_active' => 'boolean',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'is_active' => $validated['is_active'] ?? true,
        ]);

        // Assigner le rôle
        $user->assignRole($validated['role']);

        return response()->json($user->load('roles'), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user): JsonResponse
    {
        return response()->json($user->load('roles'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'password' => ['nullable', 'confirmed', Rules\Password::defaults()],
            'role' => 'sometimes|string|in:admin,manager,supervisor,commercial',
            'is_active' => 'boolean',
        ]);

        $updateData = array_filter($validated, function ($value) {
            return $value !== null;
        });

        if (isset($updateData['password'])) {
            $updateData['password'] = Hash::make($updateData['password']);
        }

        $user->update($updateData);

        // Mettre à jour le rôle si nécessaire
        if (isset($validated['role'])) {
            $user->syncRoles([$validated['role']]);
        }

        return response()->json($user->load('roles'));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user): JsonResponse
    {
        // Empêcher la suppression de l'utilisateur connecté
        if ($user->id === auth()->id()) {
            return response()->json(['message' => 'Vous ne pouvez pas supprimer votre propre compte'], 422);
        }

        $user->delete();

        return response()->json(null, 204);
    }

    /**
     * Get user statistics
     */
    public function statistics(User $user): JsonResponse
    {
        $stats = [
            'total_visites' => $user->visites()->count(),
            'visites_ce_mois' => $user->visites()->ceMois()->count(),
            'visites_cette_semaine' => $user->visites()->cetteSemaine()->count(),
            'visites_aujourd_hui' => $user->visites()->aujourdhui()->count(),
            'pdvs_assignes' => $user->pdvs()->count(),
            'derniere_visite' => $user->visites()->latest('date_visite')->first(),
            'performance_mensuelle' => $this->getPerformanceMensuelle($user),
        ];

        return response()->json($stats);
    }

    /**
     * Get monthly performance for a user
     */
    private function getPerformanceMensuelle(User $user): array
    {
        $months = collect();
        for ($i = 11; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $months->push([
                'month' => $date->format('Y-m'),
                'label' => $date->format('M Y'),
                'visites' => $user->visites()
                    ->whereYear('date_visite', $date->year)
                    ->whereMonth('date_visite', $date->month)
                    ->count(),
            ]);
        }

        return $months->toArray();
    }
} 