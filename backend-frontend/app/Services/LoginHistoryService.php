<?php

namespace App\Services;

use App\Models\LoginHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Jenssegers\Agent\Agent;

use Stevebauman\Location\Facades\Location;



class LoginHistoryService
{
    public function storeLogin(Request $request, int $userId, ?int $tokenId = null): LoginHistory
    {
        $agent = new Agent();
        $agent->setUserAgent((string) $request->userAgent());

        $ip = $this->resolveIp($request);

        $country = null;
        $city = null;
        $latitude = null;
        $longitude = null;

        try {
            $position = Location::get($ip);

            if ($position && is_object($position)) {
                $country = $position->countryName ?? null;
                $city = $position->cityName ?? null;
                $latitude = $position->latitude ?? null;
                $longitude = $position->longitude ?? null;
            }
        } catch (\Throwable $e) {
            report($e);
        }

        $location = collect([$city, $country])
            ->filter(fn ($value) => filled($value))
            ->implode(', ');

        LoginHistory::where('user_id', $userId)
            ->where('is_current', true)
            ->update(['is_current' => false]);

        return LoginHistory::create([
            'user_id' => $userId,
            'token_id' => $tokenId,
            'session_id' => $this->resolveSessionId($request),
            'ip_address' => $ip,

            'device_type' => $this->getDeviceType($agent),
            'device_name' => $this->getDeviceName($agent),
            'browser' => $agent->browser(),
            'platform' => $agent->platform(),
            'user_agent' => $request->userAgent(),

            'country' => $country,
            'city' => $city,
            'location' => $location ?: null,
            'latitude' => $latitude,
            'longitude' => $longitude,

            'login_at' => now(),
            'last_seen_at' => now(),
            'is_current' => true,
        ]);
    }

    protected function resolveIp(Request $request): string
    {
        $ip =
            $request->input('ip_address') ?:
                $request->header('CF-Connecting-IP') ?:
                    $request->header('X-Real-IP') ?:
                        $request->header('X-Forwarded-For') ?:
                            $request->ip();

        if (str_contains($ip, ',')) {
            $ip = trim(explode(',', $ip)[0]);
        }

        $ip = trim((string) $ip);

        if (
            !$ip ||
            in_array($ip, ['127.0.0.1', '::1'], true) ||
            !filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)
        ) {
            return '8.8.8.8'; // testing fallback
        }

        return $ip;
    }

    private function resolveLocation(string $ip): array
    {
        try {
            $position = Location::get($ip);

            if (!$position || !is_object($position)) {
                return [
                    'country' => null,
                    'city' => null,
                    'region' => null,
                    'latitude' => null,
                    'longitude' => null,
                ];
            }

            return [
                'country' => $position->countryName ?? null,
                'city' => $position->cityName ?? null,
                'region' => $position->regionName ?? null,
                'latitude' => $position->latitude ?? null,
                'longitude' => $position->longitude ?? null,
            ];
        } catch (\Throwable $e) {
            report($e);

            return [
                'country' => null,
                'city' => null,
                'region' => null,
                'latitude' => null,
                'longitude' => null,
            ];
        }
    }


    public function updateLastSeenByToken(Request $request, ?int $userId, ?int $tokenId = null): void
    {
        if (!$userId || !$tokenId) {
            return;
        }

        LoginHistory::where('user_id', $userId)
            ->where('token_id', $tokenId)
            ->where('is_current', true)
            ->update([
                'last_seen_at' => now(),
            ]);
    }

    public function markLogoutByToken(Request $request, ?int $userId, ?int $tokenId = null): void
    {
        if (!$userId || !$tokenId) {
            return;
        }

        LoginHistory::where('user_id', $userId)
            ->where('token_id', $tokenId)
            ->whereNull('logout_at')
            ->update([
                'logout_at' => now(),
                'last_seen_at' => now(),
                'is_current' => false,
            ]);
    }

    protected function resolveSessionId(Request $request): ?string
    {
        try {
            if (method_exists($request, 'hasSession') && $request->hasSession()) {
                return $request->session()->getId();
            }
        } catch (\Throwable $e) {
            return null;
        }

        return null;
    }



    protected function getDeviceType(Agent $agent): string
    {
        if ($agent->isDesktop()) {
            return 'Desktop';
        }

        if ($agent->isTablet()) {
            return 'Tablet';
        }

        if ($agent->isMobile()) {
            return 'Mobile';
        }

        if ($agent->isRobot()) {
            return 'Bot';
        }

        return 'Unknown';
    }

    protected function getDeviceName(Agent $agent): string
    {
        $device = trim((string) $agent->device());
        $platform = trim((string) $agent->platform());

        if ($device !== '') {
            return $device;
        }

        if ($platform !== '') {
            return $platform . ' Device';
        }

        return 'Unknown Device';
    }

    protected function resolveLocationFromIp(?string $ip): array
    {
        if (!$ip || in_array($ip, ['127.0.0.1', '::1'], true)) {
            return [
                'country' => 'Local',
                'city' => 'Local',
                'location' => 'Local Development',
                'latitude' => null,
                'longitude' => null,
            ];
        }

        try {
            $response = Http::timeout(5)->get("http://ip-api.com/json/{$ip}", [
                'fields' => 'status,message,country,city,lat,lon',
            ]);

            if (!$response->ok()) {
                return [];
            }

            $data = $response->json();

            if (($data['status'] ?? null) !== 'success') {
                return [];
            }

            $country = $data['country'] ?? null;
            $city = $data['city'] ?? null;

            return [
                'country' => $country,
                'city' => $city,
                'location' => collect([$city, $country])->filter()->implode(', '),
                'latitude' => $data['lat'] ?? null,
                'longitude' => $data['lon'] ?? null,
            ];
        } catch (\Throwable $e) {
            return [];
        }
    }
}
