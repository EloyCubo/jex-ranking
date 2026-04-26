<?php

namespace Jexactyl\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserMedal extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user_medals';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'user_id',
        'type',
        'name',
    ];

    /**
     * Gets the user that owns the medal.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
