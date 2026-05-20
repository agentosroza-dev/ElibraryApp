<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    /**
     * Auto delete notifications older than 14 days
     */
    private function autoDeleteOldNotifications(): void
    {
        Notification::query()
            ->where('created_at', '<', now()->subDays(14))
            ->delete();
    }

    public function index(Request $request)
    {
        $this->autoDeleteOldNotifications();

        $user = $request->user();

        $notifications = Notification::query()
            ->where(function ($query) use ($user) {
                $query->whereNull('user_id')
                    ->orWhere('user_id', $user->id);
            })
            ->with('item:id,title,slug,cover_url')
            ->latest()
            ->limit(15)
            ->get();

        $unreadCount = Notification::query()
            ->where(function ($query) use ($user) {
                $query->whereNull('user_id')
                    ->orWhere('user_id', $user->id);
            })
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'notifications' => $notifications,
            'unread_count' => $unreadCount,
        ]);
    }

    public function markAllRead(Request $request)
    {
        $this->autoDeleteOldNotifications();

        $user = $request->user();

        Notification::query()
            ->where(function ($query) use ($user) {
                $query->whereNull('user_id')
                    ->orWhere('user_id', $user->id);
            })
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'message' => 'All notifications marked as read.',
        ]);
    }

    public function clearAll(Request $request)
    {
        $this->autoDeleteOldNotifications();

        $user = $request->user();

        Notification::query()
            ->where(function ($query) use ($user) {
                $query->whereNull('user_id')
                    ->orWhere('user_id', $user->id);
            })
            ->delete();

        return response()->json([
            'message' => 'All notifications cleared.',
        ]);
    }

    public function markOneRead(Request $request, int $id)
    {
        $this->autoDeleteOldNotifications();

        $user = $request->user();

        $notification = Notification::query()
            ->where('id', $id)
            ->where(function ($query) use ($user) {
                $query->whereNull('user_id')
                    ->orWhere('user_id', $user->id);
            })
            ->firstOrFail();

        if (!$notification->read_at) {
            $notification->update([
                'read_at' => now(),
            ]);
        }

        return response()->json([
            'message' => 'Notification marked as read.',
            'notification' => $notification->fresh(),
        ]);
    }

}
