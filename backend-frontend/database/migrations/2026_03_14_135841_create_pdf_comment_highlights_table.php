<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pdf_comment_highlights', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->unsignedBigInteger('item_id')->nullable();
            $table->string('doc_key', 64)->nullable();

            $table->unsignedInteger('page')->default(1);

            $table->text('selected_text')->nullable();
            $table->longText('comment')->nullable();
            $table->string('highlight_color', 30)->nullable()->default('#fff59d');

            $table->json('rects')->nullable();
            $table->json('meta')->nullable();

            $table->timestamps();

            $table->index(['user_id']);
            $table->index(['item_id']);
            $table->index(['doc_key']);
            $table->index(['page']);

            $table->foreign('item_id')
                ->references('id')
                ->on('items')
                ->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pdf_comment_highlights');
    }
};
