<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('login_histories', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();
            $table->unsignedBigInteger('token_id')->nullable()->index();

            $table->string('session_id')->nullable()->index();
            $table->ipAddress('ip_address')->nullable();

            $table->string('device_type')->nullable(); // Desktop, Mobile, Tablet, Bot, Unknown
            $table->string('device_name')->nullable(); // iPhone, Windows PC, Mac, Android, etc
            $table->string('browser')->nullable();
            $table->string('platform')->nullable(); // Windows, macOS, Android, iOS, Linux
            $table->text('user_agent')->nullable();

            $table->string('country')->nullable();
            $table->string('city')->nullable();
            $table->string('location')->nullable(); // "Phnom Penh, Cambodia"
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();

            $table->timestamp('login_at')->nullable()->index();
            $table->timestamp('logout_at')->nullable();
            $table->timestamp('last_seen_at')->nullable();

            $table->boolean('is_current')->default(false)->index();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('login_histories');
    }
};
