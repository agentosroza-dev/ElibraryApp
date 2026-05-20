<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoginHistory extends Model
{
    protected $fillable = [
        'user_id',
        'token_id',
        'session_id',
        'ip_address',
        'device_type',
        'device_name',
        'browser',
        'platform',
        'user_agent',
        'country',
        'city',
        'location',
        'latitude',
        'longitude',
        'login_at',
        'logout_at',
        'last_seen_at',
        'is_current',
    ];

    protected $casts = [
        'login_at' => 'datetime',
        'logout_at' => 'datetime',
        'last_seen_at' => 'datetime',
        'is_current' => 'boolean',
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
