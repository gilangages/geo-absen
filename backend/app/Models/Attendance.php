<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'user_id',
    'date',
    'check_in_time',
    'check_in_latitude',
    'check_in_longitude',
    'check_in_foto',
    'check_out_time',
    'check_out_latitude',
    'check_out_longitude',
    'check_out_foto',
    'status',
])]
class Attendance extends Model
{
    /**
     * Get the user that owns the attendance.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
