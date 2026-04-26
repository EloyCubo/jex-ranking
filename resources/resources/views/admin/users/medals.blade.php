@extends('layouts.admin')
@include('partials/admin.users.nav', ['activeTab' => 'medals', 'user' => $user])

@section('title')
    Medals: {{ $user->username }}
@endsection

@section('content-header')
    <h1>{{ $user->name_first }} {{ $user->name_last}}<small>{{ $user->username }}</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.users') }}">Users</a></li>
        <li><a href="{{ route('admin.users.view', $user->id) }}">{{ $user->username }}</a></li>
        <li class="active">Medals</li>
    </ol>
@endsection

@section('content')
    @yield('users::nav')
    <div class="row">
        <div class="col-md-6">
            <div class="box box-info">
                <div class="box-header with-border">
                    <h3 class="box-title">Current Medals</h3>
                </div>
                <div class="box-body table-responsive no-padding">
                    <table class="table table-hover">
                        <tr>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                        @foreach($medals as $medal)
                            <tr>
                                <td>{{ $medal->name }}</td>
                                <td>
                                    @if($medal->type === 'gold')
                                        <span class="label label-warning">Gold</span>
                                    @elseif($medal->type === 'silver')
                                        <span class="label label-default" style="background-color: #C0C0C0 !important;">Silver</span>
                                    @elseif($medal->type === 'bronze')
                                        <span class="label label-danger" style="background-color: #CD7F32 !important;">Bronze</span>
                                    @else
                                        <span class="label label-info">Other</span>
                                    @endif
                                </td>
                                <td>{{ $medal->created_at->format('d/m/Y') }}</td>
                                <td>
                                    <form action="{{ route('admin.users.medals.delete', [$user->id, $medal->id]) }}" method="POST">
                                        @method('DELETE')
                                        @csrf
                                        <button type="submit" class="btn btn-xs btn-danger"><i class="fa fa-trash"></i></button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                        @if($medals->isEmpty())
                            <tr>
                                <td colspan="4" class="text-center text-muted">This user has no medals.</td>
                            </tr>
                        @endif
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="box box-success">
                <div class="box-header with-border">
                    <h3 class="box-title">Add New Medal</h3>
                </div>
                <form action="{{ route('admin.users.medals', $user->id) }}" method="POST">
                    @csrf
                    <div class="box-body">
                        <div class="form-group">
                            <label class="control-label">Medal Name</label>
                            <input type="text" name="name" class="form-control" placeholder="Ex: #1 April 2026" required>
                            <p class="text-muted small">The name the user will see on their profile.</p>
                        </div>
                        <div class="form-group">
                            <label class="control-label">Medal Type</label>
                            <select name="type" class="form-control" required>
                                <option value="gold">Gold</option>
                                <option value="silver">Silver</option>
                                <option value="bronze">Bronze</option>
                                <option value="other">Other / Special</option>
                            </select>
                        </div>
                    </div>
                    <div class="box-footer">
                        <button type="submit" class="btn btn-sm btn-success pull-right">Add Medal</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
