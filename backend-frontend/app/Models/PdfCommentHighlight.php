<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PdfCommentHighlight extends Model
{
    protected $table = 'pdf_comment_highlights';

    protected $fillable = [
        'user_id',
        'item_id',
        'doc_key',
        'page',
        'selected_text',
        'comment',
        'highlight_color',
        'rects',
        'meta',
    ];

    protected $casts = [
        'rects' => 'array',
        'meta' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class, 'item_id');
    }
}
