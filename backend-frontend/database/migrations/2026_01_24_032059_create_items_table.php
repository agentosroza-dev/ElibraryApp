<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
//    public function up(): void
//    {
//
//        Schema::create('items', function (Blueprint $table) {
//            $table->id();
//
//            $table->string('title');
//            $table->string('slug')->unique();
//            $table->text('description')->nullable();
//
//            $table->string('cover_url')->nullable();
//            $table->string('file_url')->nullable();
//
//            $table->foreignId('category_id')
//                ->constrained('categories')
//                ->cascadeOnUpdate()
//                ->restrictOnDelete();
//
//            $table->foreignId('author_id')
//                ->nullable()
//                ->constrained('users')
//                ->cascadeOnUpdate()
//                ->nullOnDelete();
//
//            $table->year('publish_year')->nullable();
//            $table->integer('pages')->nullable();
//            $table->string('language', 50)->nullable();
//
//            $table->unsignedBigInteger('view_count')->default(0);
//            $table->boolean('is_active')->default(true);
//
//            $table->unsignedBigInteger('user_id_created')->nullable();
//            $table->unsignedBigInteger('user_id_updated')->nullable();
//
//            $table->timestamps();
//
//            $table->index('title');
//            $table->index('category_id');
//            $table->index('author_id');
//            $table->index('is_active');
//        });
//
//    }
    public function up(): void
    {
        Schema::create('items', function (Blueprint $table) {
            $table->id();

            // Core
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description')->nullable();

            // Files
            $table->string('cover_url')->nullable();
            $table->string('file_url')->nullable();

            // Relations
            $table->foreignId('category_id')
                ->constrained('categories')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreignId('author_id')
                ->nullable()
                ->constrained('users')
                ->cascadeOnUpdate()
                ->nullOnDelete();

            // Metadata
            $table->year('publish_year')->nullable();
            $table->integer('pages')->nullable();
            $table->string('language', 50)->nullable();

            // Status
            $table->boolean('is_active')->default(true);

            // Audit
            $table->foreignId('user_id_created')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->foreignId('user_id_updated')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->timestamps();

            /*
            |--------------------------------------------------------------------------
            | INDEXES (IMPORTANT FOR SEARCH PERFORMANCE)
            |--------------------------------------------------------------------------
            */

            // Search indexes
            $table->index('title');
            $table->index('slug');
            $table->index('created_at');

            // Filtering indexes
            $table->index(['category_id', 'is_active']);
            $table->index(['author_id', 'is_active']);

            // Sorting
            $table->index(['is_active', 'created_at']);

            // Optional: faster LIKE search (MySQL 8+)
            // $table->fullText(['title', 'description']);

            // Audit indexes
            $table->index('user_id_created');
            $table->index('user_id_updated');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};
