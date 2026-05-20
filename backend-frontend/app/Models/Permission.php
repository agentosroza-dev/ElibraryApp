<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Permission extends Model
{
    protected $fillable = [
        'route_name',
        'title',
        'type',
        'list_icon',
        'menu_order',
    ];

    public function users()
    {
        return $this->belongsToMany(
            User::class,
            'user_permissions',
            'permission_id',
            'user_id'
        );
    }
}

