<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use App\Notifications\VerifyEmail;
use App\Notifications\ResetPassword;
use Illuminate\Auth\MustVerifyEmail;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Contracts\Auth\MustVerifyEmail as MustVerifyEmailContract;
use Illuminate\Database\Eloquent\ModelNotFoundException;


class User extends Authenticatable implements MustVerifyEmailContract
{

    use HasFactory, Notifiable;
    use HasApiTokens, MustVerifyEmail;

    protected $appends = [
        'password_null',
    ];

    protected $fillable = [
        'name',
        'email',
        'password',
        'level',
        'about_me',
        'interests',
        'email_verified_at',
        'photo'
    ];


    protected $hidden = [
        'password',
        'remember_token',
        'interests' => 'array',
    ];


    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    protected function Photo(): Attribute
    {
        return Attribute::make(
            get: fn(string|null $value) => $value ?
                asset('storage/profile/' . $value) :
                null,
        );
    }

    function getPasswordNullAttribute(): bool
    {
        return empty($this->password);
    }

    public function sendEmailVerificationNotification()
    {
        $this->notify(new VerifyEmail());
    }

    public function sendPasswordResetNotification($token)
    {
        $this->notify(new ResetPassword($token));
    }

    public function members()
    {
        return $this->hasMany(ChatMember::class);
    }

    public function chats()
    {
        return $this->belongsToMany(Chat::class, 'chat_members')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function messages()
    {
        return $this->hasMany(ChatMessage::class);
    }

    public function hasChatAsAdmin($chatId): Chat
    {
        $chat = $this->chats()
            ->where('chat_id', $chatId)
            ->wherePivot('role', 'admin')
            ->first();
        if (!$chat) {
            throw new ModelNotFoundException('Chat not found or user is not an admin.');
        }
        return $chat;
    }

    public function hasChat($chatId) : Chat
    {
        $chat = $this->chats()
            ->where('chat_id', $chatId)
            ->first();
        if (!$chat) {
            throw new ModelNotFoundException('Chat not found.');
        }
        return $chat;
    }

    public function isChatMember($chatId) : ChatMember
    {
        $member = $this->members()
            ->where('chat_id', $chatId)
            ->first();
        if (!$member) {
            throw new ModelNotFoundException('You are not a member of this chat.');
        }
        return $member;
    }

    public function hasMessageInChat($messageId, $chatId) : ChatMessage
    {
        $message = $this->messages()
            ->where('id', $messageId)
            ->where('chat_id', $chatId)
            ->first();
        if (!$message) {
            throw new ModelNotFoundException('Chat message not found.');
        }
        return $message;
    }

    public function permissions()
    {
        return $this->belongsToMany(
            Permission::class,
            'user_permissions',
            'user_id',
            'permission_id'
        );
    }

    public function hasPermission($route)
    {
        return $this->permissions()->where('route_name',$route)->exists();
    }

    // user as author
    public function authoredItems()
    {
        return $this->hasMany(Item::class, 'author_id');
    }

    // user who created item
    public function createdItems()
    {
        return $this->hasMany(Item::class, 'user_id_created');
    }

    // user who updated item
    public function updatedItems()
    {
        return $this->hasMany(Item::class, 'user_id_updated');
    }


    public function favoriteBooks()
    {
        return $this->belongsToMany(Item::class, 'user_favorite_books', 'user_id', 'book_id')
            ->withPivot('created_at');
    }

    public function favoriteBookRecords()
    {
        return $this->hasMany(UserFavoriteBook::class);
    }

    public function bookViews()
    {
        return $this->hasMany(BookView::class);
    }


    public function interestTags()
    {
        return $this->belongsToMany(Tag::class, 'user_tag_interests', 'user_id', 'tag_id')
            ->withPivot('created_at');
    }

    public function loginHistories()
    {
        return $this->hasMany(\App\Models\LoginHistory::class);
    }


}
