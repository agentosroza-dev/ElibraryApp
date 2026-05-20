<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('pdf_read_progress', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            // Choose ONE identity method in your app:
            // A) item_id (if you have books table)
            $table->foreignId('item_id')->nullable()->constrained()->nullOnDelete();

            // B) doc_key (sha256 of url/path)
            $table->string('doc_key', 64)->nullable();

            $table->unsignedInteger('last_page')->default(1);
            $table->unsignedInteger('total_pages')->default(0);

            // ✅ FIX: use decimal (no unsignedDecimal in Blueprint)
            $table->decimal('percent', 5, 2)->default(0); // 0.00 - 100.00

            $table->timestamps();

            // ✅ Uniques (work fine even with nullable columns on MySQL)
            $table->unique(['user_id', 'item_id'], 'uniq_user_book');
            $table->unique(['user_id', 'doc_key'], 'uniq_user_doc');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pdf_read_progress');
    }
};
