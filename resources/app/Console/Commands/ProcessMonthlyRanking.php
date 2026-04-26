<?php

namespace Jexactyl\Console\Commands;

use Carbon\Carbon;
use Jexactyl\Models\User;
use Jexactyl\Models\UserMedal;
use Illuminate\Console\Command;

class ProcessMonthlyRanking extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'p:ranking:process';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Processes the monthly ranking and awards medals to the top 3 users.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $lastMonth = Carbon::now()->subMonth();
        // Set locale to English for month names
        Carbon::setLocale('en');
        $monthName = ucfirst($lastMonth->translatedFormat('F'));
        $year = $lastMonth->year;

        $top3 = User::orderByDesc('store_balance')->limit(3)->get();

        $types = ['gold', 'silver', 'bronze'];
        $names = ['Gold Champion', 'Silver Runner-up', 'Bronze Third Place'];

        foreach ($top3 as $index => $user) {
            if (!isset($types[$index])) break;

            UserMedal::create([
                'user_id' => $user->id,
                'type' => $types[$index],
                'name' => "{$names[$index]} - {$monthName} {$year}",
            ]);

            $this->info("{$types[$index]} medal awarded to {$user->username} for {$monthName} {$year}");
        }

        $this->info('Monthly ranking process completed.');
    }
}
