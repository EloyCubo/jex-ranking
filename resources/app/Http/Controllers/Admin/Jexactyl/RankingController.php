<?php

namespace Jexactyl\Http\Controllers\Admin\Jexactyl;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Jexactyl\Http\Controllers\Controller;
use Jexactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Http\Request;

class RankingController extends Controller
{
    /**
     * RankingController constructor.
     */
    public function __construct(
        private AlertsMessageBag $alert,
        private SettingsRepositoryInterface $settings
    ) {
    }

    /**
     * Render the Jexactyl ranking settings interface.
     */
    public function index(): View
    {
        return view('admin.jexactyl.ranking', [
            'rewards' => $this->settings->get('jexactyl::ranking:rewards', 'No rewards configured.'),
        ]);
    }

    /**
     * Handle settings update.
     */
    public function update(Request $request): RedirectResponse
    {
        $this->settings->set('jexactyl::ranking:rewards', $request->input('rewards'));

        $this->alert->success('Ranking settings have been successfully updated.')->flash();

        return redirect()->route('admin.jexactyl.ranking');
    }
}
