<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BookView extends Model
{
    protected $table = 'book_views';

//    public const UPDATED_AT = null;

    protected $fillable = [
        'user_id',
        'book_id',
        'created_at',
        'updated_at',
    ];

    public $timestamps = true;

//    protected $casts = [
//        'created_at' => 'datetime',
//    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }
}
