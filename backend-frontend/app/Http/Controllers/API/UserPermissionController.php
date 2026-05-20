<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UserPermissionController extends Controller
{

    public function index()
    {
        $users = User::whereHas('permissions')
            ->with(['permissions:id,route_name,title'])
            ->select('id','name','email','photo','level')
            ->orderBy('name')
            ->get();

        return response()->json($users);
    }

    public function show($id)
    {
        $user = User::with(['permissions:id,route_name,title'])->findOrFail($id);

        return response()->json([
            'user_id' => $user->id,
            'permissions' => $user->permissions->map(function ($permission) {
                return [
                    'id' => $permission->id,
                    'route_name' => $permission->route_name,
                    'title' => $permission->title,
                ];
            })->values(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => ['required', 'integer', Rule::exists('users', 'id')],
            'permissions' => ['nullable', 'array'],
            'permissions.*' => ['integer', Rule::exists('permissions', 'id')],
        ]);

        $user = User::findOrFail($data['user_id']);

        $permissionIds = $data['permissions'] ?? [];

        $user->permissions()->sync($permissionIds);

        $user->load(['permissions:id,route_name,title']);

        return response()->json([
            'message' => 'User permissions saved successfully.',
            'data' => [
                'user_id' => $user->id,
                'name' => $user->name,
                'permissions' => $user->permissions,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'permissions' => ['nullable', 'array'],
            'permissions.*' => ['integer', Rule::exists('permissions', 'id')],
        ]);

        $user = User::findOrFail($id);

        $permissionIds = $data['permissions'] ?? [];

        $user->permissions()->sync($permissionIds);

        $user->load(['permissions:id,route_name,title']);

        return response()->json([
            'message' => 'User permissions updated successfully.',
            'data' => [
                'user_id' => $user->id,
                'name' => $user->name,
                'permissions' => $user->permissions,
            ]
        ]);
    }

    public function destroy($id)
    {
        $user = User::findOrFail($id);

        $user->permissions()->detach();

        return response()->json([
            'message' => 'All permissions removed from user successfully.'
        ]);
    }
}

