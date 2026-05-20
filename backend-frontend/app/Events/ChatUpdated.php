<?php

namespace App\Events;

use App\Http\Resources\ChatResource;
use App\Models\Chat;
use App\Models\User;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $chat;
    public $user;

    public function __construct(Chat $chat, int $userId)
    {
        $this->chat = $chat;
        $this->user = User::find($userId);
    }

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('ChatEvent.' . $this->user->id),
        ];
    }

    public function broadcastAs(): string
    {
        return 'ChatUpdated';
    }

    public function broadcastWith(): array
    {
        return [
            'chat' => new ChatResource($this->chat->loadDefault($this->user)),
        ];
    }
}
