<?php

namespace App\Models;

//use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Item extends Model
{
    protected $fillable = [
        'title',
        'slug',
        'description',
        'cover_url',
        'file_url',
        'category_id',
        'author_id',
        'publish_year',
        'pages',
        'language',
        'view_count',
        'is_active',
        'user_id_created',
        'user_id_updated',
    ];
    protected $casts = [
        'is_active' => 'boolean',
        'view_count' => 'integer',
        'pages' => 'integer',
        'publish_year' => 'integer',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }


    public function author()
    {
        return $this->belongsTo(User::class,'author_id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'user_id_created');
    }

    public function updater()
    {
        return $this->belongsTo(User::class, 'user_id_updated');
    }


    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'book_tag', 'book_id', 'tag_id')
            ->withTimestamps();
    }

    public function favoriteUsers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_favorite_books', 'book_id', 'user_id')
            ->withPivot('created_at');
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(UserFavoriteBook::class);
    }

    public function views()
    {
        return $this->hasMany(BookView::class, 'book_id');
    }

    public function favoredByUsers()
    {
        return $this->belongsToMany(User::class, 'user_favorite_books', 'book_id', 'user_id')
            ->withPivot('created_at');
    }

}
