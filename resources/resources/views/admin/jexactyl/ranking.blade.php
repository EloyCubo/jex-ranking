@extends('layouts.admin')
@include('partials/admin.jexactyl.nav', ['activeTab' => 'ranking'])

@section('title')
    Ranking Settings
@endsection

@section('content-header')
    <h1>Ranking Settings<small>Configure ranking and rewards for users.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Jexactyl</li>
    </ol>
@endsection

@section('content')
    @yield('jexactyl::nav')
    <div class="row">
        <div class="col-xs-12">
            <form action="{{ route('admin.jexactyl.ranking') }}" method="POST">
                @method('PATCH')
                @csrf
                <div class="box box-info">
                    <div class="box-header with-border">
                        <i class="fa fa-trophy"></i> <h3 class="box-title">Ranking Settings</h3>
                    </div>
                    <div class="box-body">
                        <div class="row">
                            <div class="form-group col-md-12">
                                <label class="control-label">Monthly Rewards</label>
                                <textarea name="rewards" class="form-control" rows="5">{{ $rewards }}</textarea>
                                <p class="text-muted"><small>This text will appear in the Ranking section to motivate users. You can use HTML.</small></p>
                            </div>
                            <div class="form-group col-md-12">
                                <label class="control-label">Suggested Cron Command</label>
                                <input type="text" class="form-control" value="* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1" readonly>
                                <p class="text-muted"><small>Make sure you have this cron configured on your server so medals are delivered automatically every month.</small></p>
                            </div>
                        </div>
                    </div>
                    <div class="box-footer">
                        <button type="submit" class="btn btn-sm btn-primary pull-right">Save Changes</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
@endsection
