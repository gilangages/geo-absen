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
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->date('date');

            // Check-in data
            $table->time('check_in_time');
            $table->string('check_in_latitude');
            $table->string('check_in_longitude');
            $table->string('check_in_foto');

            // Check-out data (Nullable)
            $table->time('check_out_time')->nullable();
            $table->string('check_out_latitude')->nullable();
            $table->string('check_out_longitude')->nullable();
            $table->string('check_out_foto')->nullable();

            $table->string('status'); // e.g., 'present', 'late'
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
