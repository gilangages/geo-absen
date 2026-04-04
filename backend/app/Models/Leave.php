<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;

#[Fillable([
    'user_id',
    'type',
    'start_date',
    'end_date',
    'reason',
    'image_proof',
    'status',
    'note_admin',
])]
class Leave extends Model
{
    use HasFactory;

    /**
     * Get the user that owns the leave.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
