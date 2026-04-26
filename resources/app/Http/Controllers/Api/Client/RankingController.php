<?php

namespace Jexactyl\Http\Controllers\Api\Client;

use Carbon\Carbon;
use Jexactyl\Models\User;
use Illuminate\Http\JsonResponse;
use Jexactyl\Http\Controllers\Api\Client\ClientApiController;
use Jexactyl\Contracts\Repository\SettingsRepositoryInterface;

class RankingController extends ClientApiController
{
    /**
     * Return the ranking data.
     */
    public function index(): JsonResponse
    {
        $user = $this->request->user();

        $top10 = User::query()
            ->select('id', 'username', 'store_balance')
            ->where('email', 'NOT LIKE', '%@eknodes.es')
            ->with('medals')
            ->orderByDesc('store_balance')
            ->limit(10)
            ->get()
            ->map(function (User $u, $index) {
                return [
                    'rank' => $index + 1,
                    'username' => $u->username,
                    'balance' => $u->store_balance,
                    'medals' => $u->medals->map(fn($m) => [
                        'type' => $m->type,
                        'name' => $m->name,
                    ]),
                ];
            });

        // Find current user rank
        $userRank = User::query()
            ->where('email', 'NOT LIKE', '%@eknodes.es')
            ->where('store_balance', '>', $user->store_balance)
            ->count() + 1;

        $rewards = $this->settings->get('jexactyl::ranking:rewards', 'No rewards configured.');
        $nextMonth = Carbon::now()->addMonth()->startOfMonth()->toIso8601String();

        return new JsonResponse([
            'top10' => $top10,
            'user' => [
                'rank' => $userRank,
                'balance' => $user->store_balance,
            ],
            'rewards' => $rewards,
            'next_month' => $nextMonth,
        ]);
    }
}
