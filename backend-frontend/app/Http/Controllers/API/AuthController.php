<?php

namespace App\Http\Controllers\API;

use Exception;
use App\Models\User;
use Illuminate\Validation\ValidationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;

use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

use App\Traits\UploadMethod;

use App\Services\LoginHistoryService;

use Illuminate\Support\Facades\Auth;


class AuthController extends Controller
{
    use UploadMethod;
    //signIn
    function signup(Request $request)
    {
        //return 'Testing Sing in';
        $fields = $request->validate([
            'name' => 'required|string|max:55',
            'email' => 'required|email|unique:users,email|regex:/^[\w.+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/i',
            'password' => 'required|string|min:8|max:15|confirmed|regex:/^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).+$/'
            //pass|regex:/^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).+$/
        ]);

        try {
            //do something
            DB::beginTransaction();

            $user = User::create($fields);

            //===verify mail===
            $user->sendEmailVerificationNotification();

            DB::commit();
        } catch (Exception $e) {
            //database rollback
            DB::rollBack();
            //
            throw $e;
        }


        return response([
            'message' => 'User has created.',
            'user' => $user
        ], 201);
    }


    public function signin(Request $request, LoginHistoryService $loginHistoryService)
    {
        $request->validate([
            'email' => [
                'required',
                'email',
                'regex:/^[\w.+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/i',
            ],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['Email is not existing.'],
            ]);
        }

        if (!Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Password does not match.'],
            ]);
        }

        // Optional session login for database sessions
        Auth::guard('web')->login($user);

        if ($request->hasSession()) {
            $request->session()->regenerate();

            DB::table('sessions')->updateOrInsert(
                ['id' => $request->session()->getId()],
                [
                    'user_id' => $user->id,
                    'ip_address' => $request->input('ip_address') ?: $request->ip(),
                    'user_agent' => mb_substr((string) $request->userAgent(), 0, 500),
                    'payload' => base64_encode(serialize($request->session()->all())),
                    'last_activity' => now()->timestamp,
                ]
            );
        }

        // Sanctum token login
        $tokenResult = $user->createToken('auth_token');

        tap($tokenResult->accessToken)->update([
            'expires_at' => now()->addMinutes(300),
        ]);

        $accessToken = $tokenResult->accessToken->fresh();
        $plainTextToken = $tokenResult->plainTextToken;

//        // Save login history after auth/session/token are ready
//        $loginHistoryService->storeLogin(
//            $request,
//            (int) $user->id,
//            (int) $accessToken->id
//        );

        // Save login history after auth/session/token are ready
        try {
            $loginHistoryService->storeLogin(
                $request,
                (int) $user->id,
                (int) $accessToken->id
            );
        } catch (\Throwable $e) {
            report($e); // do not break login
        }

        return response()->json([
            'message' => 'User Sign In.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'level' => $user->level,
                'photo' => $user->photo,
            ],
            'token' => $plainTextToken,
            'expires_at' => $accessToken->expires_at,
        ], 200);
    }

    public function signout(Request $request, LoginHistoryService $loginHistoryService)
    {
        $user = $request->user();

        if (!$user) {
            return response([
                'message' => 'Unauthenticated.'
            ], 401);
        }

        $currentToken = $user->currentAccessToken();

        if ($currentToken) {
            $loginHistoryService->markLogoutByToken(
                $request,
                (int) $user->id,
                (int) $currentToken->id
            );

            $user->tokens()->where('id', $currentToken->id)->delete();
        }

        return response([
            'message' => 'User Signed Out'
        ], 200);
    }

    /**
     * Verify user email address.
     */
    function verifyEmail(Request $request)
    {
        $userID = $request->route('id');
        $user = User::findOrFail($userID);

        if (empty($user)) {
            return response([
                'message' => 'User not found.'
            ], 422);
        }

        if ($user->hasVerifiedEmail()) {
            return response([
                'message' => 'Email already verified.'
            ], 200);
        }

        $user->markEmailAsVerified();

        return response([
            'message' => 'Email verified successfully.'
        ], 200);
    }

    /**
     * Resend email verification notification.
     */
    function resendVerificationMail(Request $request)
    {
        $request->validate([
            'email' => 'required|email'
        ]);

        $user = User::where('email', $request->email)->first();

        if (empty($user)) {
            throw ValidationException::withMessages([
                'email' => 'Email does not exist.',
            ]);
        }

        if ($user->hasVerifiedEmail()) {
            return response([
                'message' => 'Email already verified.'
            ], 200);
        }

        $user->sendEmailVerificationNotification();

        return response([
            'message' => 'Verification email resent.'
        ], 200);
    }

    /**
     * Send password reset email.
     */
    function sendResetPasswordMail(Request $request)
    {
        $request->validate([
            'email' => 'required|email'
        ]);

        $user = User::where('email', $request->email)->first();

        if (empty($user)) {
            throw ValidationException::withMessages([
                'email' => 'Email does not exist.',
            ]);
        }

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response([
                'message' => 'Password reset link sent to your email'
            ], 200);
        }

        return response([
            'message' => 'Password reset link sent to your email'
        ], 200);
    }

    /**
     * Reset user password using Laravel's built-in system.
     */
    function setNewPassword(Request $request)
    {
        $request->validate([
            'token' => 'required|string',
            'email' => 'required|email',
            'password' => 'required|string|min:6|max:10|confirmed'
        ]);

        // Method 1: Using Password facade (recommended)
        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));

                $user->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response([
                'message' => 'Password has been reset successfully.'
            ], 200);
        }


        return response([
            'message' => 'Failed to reset password.'
        ], 500);
    }

    function refreshToken(Request $request)
    {
        $user = $request->user();
        $currentToken = $user->currentAccessToken();
        $user->tokens()->where('id', $currentToken->id)->delete();

        $token = $user->createToken('auth_token');
        return response([
            'message' => 'Token refreshed.',
            'token' => $token->plainTextToken
        ]);
    }

    function verifyAccount(Request $request)
    {
        $user = $request->user();

        return response([
            'message' => 'Account is valid.',
            'user' => $user
        ], 200);
    }

    function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:6|max:10|confirmed',
            'terminate_sessions' => 'required|boolean'
        ]);

        $user = $request->user();

        if (!Hash::check($request->old_password, $user->password)) {
            throw ValidationException::withMessages([
                'old_password' => 'Old password does not match.',
            ]);
        }

        try {
            DB::beginTransaction();
            $user->password = Hash::make($request->new_password);
            $user->save();

            if ($request->terminate_sessions) {
                // Delete all tokens
                $user->tokens()->delete();
            } else {
                // Delete current token only
                $currentToken = $user->currentAccessToken();
                $user->tokens()->where('id', $currentToken->id)->delete();
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }

        return response([
            'message' => 'Password changed successfully.'
        ], 200);
    }

    function createPassword(Request $request)
    {
        $request->validate([
            'new_password' => 'required|string|min:6|max:10|confirmed',
            'terminate_sessions' => 'required|boolean'
        ]);

        $user = $request->user();

        try {
            DB::beginTransaction();
            $user->password = Hash::make($request->new_password);
            $user->save();

            if ($request->terminate_sessions) {
                // delete all tokens
                $user->tokens()->delete();
            } else {
                // delete current token only
                $currentToken = $user->currentAccessToken();
                $user->tokens()->where('id', $currentToken->id)->delete();
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception($e->getMessage());
        }

        return response([
            'message' => 'Password created successfully.'
        ], 200);
    }

//    function updateUserPhoto(Request $request)
//    {
//        $request->validate([
//            'photo' => 'nullable|base64image|base64mimes:png,jpg,jpeg|base64dimensions:width=454,height=454'
//        ]);
//
//        $user = $request->user();
//
//        try {
//            DB::beginTransaction();
//            UploadMethod::discardImage($user->getRawOriginal('photo'), 'profile');
//            $user->photo = null;
//            if (!empty($request->photo)) {
//                $user->photo = UploadMethod::storeImage($request->photo, 'profile');
//            }
//            $user->save();
//            DB::commit();
//        } catch (\Exception $e) {
//            DB::rollBack();
//            throw new \Exception($e->getMessage());
//        }
//
//        return response([
//            'message' => 'User photo updated successfully.',
//            'photo' => $user->photo
//        ], 200);
//    }

    public function updateUserPhoto(Request $request)
    {
        $request->validate([
            'photo' => 'nullable|base64image|base64mimes:png,jpg,jpeg',
        ]);

        $user = $request->user();

        try {
            DB::beginTransaction();

            if (!empty($request->photo)) {
                UploadMethod::discardImage($user->getRawOriginal('photo'), 'profile');
                $user->photo = UploadMethod::storeImage($request->photo, 'profile');
            }

            $user->save();

            DB::commit();

            return response([
                'message' => 'User photo updated successfully.',
                'photo' => $user->photo,
            ], 200);
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'message' => $e->getMessage(),
            ], 500);
        }
    }

}
