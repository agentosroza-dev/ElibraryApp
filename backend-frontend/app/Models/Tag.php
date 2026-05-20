<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Tag extends Model
{
    protected $fillable = [
        'name',
        'slug',
    ];

    public function books(): BelongsToMany
    {
        return $this->belongsToMany(Item::class, 'book_tag', 'tag_id', 'book_id')
            ->withTimestamps();
    }

    public function interestedUsers()
    {
        return $this->belongsToMany(User::class, 'user_tag_interests', 'tag_id', 'user_id')
            ->withTimestamps();
    }


}
