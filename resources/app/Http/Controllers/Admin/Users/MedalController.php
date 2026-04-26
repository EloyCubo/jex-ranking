<?php

namespace Jexactyl\Http\Controllers\Admin\Users;

use Illuminate\View\View;
use Jexactyl\Models\User;
use Jexactyl\Models\UserMedal;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Jexactyl\Http\Controllers\Controller;

class MedalController extends Controller
{
    /**
     * MedalController constructor.
     */
    public function __construct(private AlertsMessageBag $alert)
    {
    }

    /**
     * Display user medals page.
     */
    public function index(User $user): View
    {
        return view('admin.users.medals', [
            'user' => $user,
            'medals' => $user->medals,
        ]);
    }

    /**
     * Store a new medal for a user.
     */
    public function store(Request $request, User $user): RedirectResponse
    {
        $request->validate([
            'type' => 'required|string|in:gold,silver,bronze,other',
            'name' => 'required|string|max:255',
        ]);

        UserMedal::create([
            'user_id' => $user->id,
            'type' => $request->input('type'),
            'name' => $request->input('name'),
        ]);

        $this->alert->success('Medal successfully added to user.')->flash();

        return redirect()->route('admin.users.medals', $user->id);
    }

    /**
     * Delete a medal from a user.
     */
    public function delete(User $user, UserMedal $medal): RedirectResponse
    {
        if ($medal->user_id !== $user->id) {
            abort(403);
        }

        $medal->delete();

        $this->alert->success('Medal successfully removed from user.')->flash();

        return redirect()->route('admin.users.medals', $user->id);
    }
}
