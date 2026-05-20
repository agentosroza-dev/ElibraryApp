<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Permission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PermissionController extends Controller
{
    private function baseQuery()
    {
        return Permission::query()
            ->select([
                'permissions.id',
                'permissions.route_name',
                'permissions.title',
                'permissions.type',
                'permissions.list_icon',
                'permissions.menu_order',
                'permissions.created_at',
                'permissions.updated_at',
            ])
            ->whereNotNull('permissions.route_name')
            ->where('permissions.route_name', '!=', '');
    }

    private function isAdmin($user): bool
    {
        if (!$user) {
            return false;
        }

        return (int) $user->level === 1 || (string) $user->level === 'admin';
    }

    private function validatePermission(Request $request, ?int $permissionId = null): array
    {
        return $request->validate([
            'route_name' => [
                'required',
                'string',
                'max:255',
                Rule::unique('permissions', 'route_name')->ignore($permissionId),
            ],
            'title' => ['required', 'string', 'max:255'],
            'type' => ['required', 'integer', 'in:1,2,3'],
            'list_icon' => ['nullable', 'string', 'max:255'],
            'menu_order' => ['nullable', 'integer', 'min:0'],
        ]);
    }

    private function normalizePayload(array $data): array
    {
        return [
            'route_name' => trim($data['route_name']),
            'title' => trim($data['title']),
            'type' => (int) $data['type'],
            'list_icon' => filled($data['list_icon'] ?? null) ? trim($data['list_icon']) : null,
            'menu_order' => (int) ($data['menu_order'] ?? 0),
        ];
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $query = $this->baseQuery()
            ->orderBy('permissions.menu_order')
            ->orderBy('permissions.id');

        if ($this->isAdmin($user)) {
            return response()->json($query->get());
        }

        $permissions = $query
            ->whereExists(function ($subQuery) use ($user) {
                $subQuery->selectRaw('1')
                    ->from('user_permissions')
                    ->whereColumn('user_permissions.permission_id', 'permissions.id')
                    ->where('user_permissions.user_id', $user->id);
            })
            ->get();

        return response()->json($permissions);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $permission = $this->baseQuery()->findOrFail($id);

        if (!$this->isAdmin($user)) {
            $hasPermission = Permission::query()
                ->where('permissions.id', $id)
                ->whereExists(function ($subQuery) use ($user) {
                    $subQuery->selectRaw('1')
                        ->from('user_permissions')
                        ->whereColumn('user_permissions.permission_id', 'permissions.id')
                        ->where('user_permissions.user_id', $user->id);
                })
                ->exists();

            if (!$hasPermission) {
                return response()->json([
                    'message' => 'Forbidden',
                ], 403);
            }
        }

        return response()->json($permission);
    }

    public function listSimple(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $query = $this->baseQuery()
            ->orderBy('permissions.menu_order')
            ->orderBy('permissions.id');

        if ($this->isAdmin($user)) {
            return response()->json($query->get());
        }

        $permissions = $query
            ->whereExists(function ($subQuery) use ($user) {
                $subQuery->selectRaw('1')
                    ->from('user_permissions')
                    ->whereColumn('user_permissions.permission_id', 'permissions.id')
                    ->where('user_permissions.user_id', $user->id);
            })
            ->get();

        return response()->json($permissions);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        if (!$this->isAdmin($user)) {
            return response()->json([
                'message' => 'Forbidden',
            ], 403);
        }

        $data = $this->validatePermission($request);

        $permission = Permission::create(
            $this->normalizePayload($data)
        );

        return response()->json([
            'message' => 'Created successfully',
            'data' => $permission,
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        if (!$this->isAdmin($user)) {
            return response()->json([
                'message' => 'Forbidden',
            ], 403);
        }

        $permission = Permission::findOrFail($id);

        $data = $this->validatePermission($request, $permission->id);

        $permission->update(
            $this->normalizePayload($data)
        );

        return response()->json([
            'message' => 'Updated successfully',
            'data' => $permission->fresh(),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        if (!$this->isAdmin($user)) {
            return response()->json([
                'message' => 'Forbidden',
            ], 403);
        }

        $permission = Permission::findOrFail($id);

        $permission->delete();

        return response()->json([
            'message' => 'Permission deleted successfully',
        ]);
    }
}
