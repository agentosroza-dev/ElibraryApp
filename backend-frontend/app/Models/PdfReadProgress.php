<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PdfReadProgress extends Model
{
    protected $table = 'pdf_read_progress';

    protected $fillable = [
        'user_id',
        'item_id',
        'doc_key',
        'last_page',
        'total_pages',
        'percent',
    ];

    public function item(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'item_id');
    }
}
