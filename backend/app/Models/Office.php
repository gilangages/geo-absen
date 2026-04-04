<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;

#[Fillable(['name', 'latitude', 'longitude', 'radius', 'work_start', 'work_end'])]
class Office extends Model
{
    // Untuk saat ini belum perlu relasi karena lokasinya global untuk semua karyawan
}
