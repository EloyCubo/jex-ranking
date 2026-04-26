#!/bin/bash

if (( $EUID != 0 )); then
    printf "\033[0;33m<jex-ranking> \033[0;31m[✕]\033[0m Please run this program as root \n"
    exit
fi

watermark="\033[0;33m<jex-ranking> \033[0;32m[✓]\033[0m"
target_dir=""

chooseDirectory() {
    echo -e "<jex-ranking> [1] /var/www/jexactyl   (choose this if you installed the panel using the official Jexactyl documentation)"
    echo -e "<jex-ranking> [2] /var/www/pterodactyl (choose this if you migrated from Pterodactyl to Jexactyl)"

    while true; do
        read -p "<jex-ranking> [?] Choose directory [1/2]: " choice
        case "$choice" in
            1) target_dir="/var/www/jexactyl"; break ;;
            2) target_dir="/var/www/pterodactyl"; break ;;
            *) echo -e "\033[0;33m<jex-ranking> \033[0;31m[✕]\033[0m Invalid choice. Please enter 1 or 2." ;;
        esac
    done
}

startPterodactyl(){
    printf "${watermark} Rebuilding panel assets... \n"
    cd "$target_dir"
    export NODE_OPTIONS=--openssl-legacy-provider
    yarn build:production || {
        printf "${watermark} node: --openssl-legacy-provider is not allowed in NODE_OPTIONS \n"
        export NODE_OPTIONS=
        yarn build:production
    }
    php artisan optimize:clear
}

patchSidePanel() {
    local file="$target_dir/resources/scripts/components/elements/SidePanel.tsx"
    if [ ! -f "$file" ]; then return; fi
    if grep -q "to={'/ranking'}" "$file"; then return; fi
    if ! grep -q "<NavLink to={'/store'} className={'navigation-link'}>" "$file"; then return; fi

    printf "${watermark} Patching SidePanel.tsx... \n"
    sed -i "/<NavLink to={'\/store'} className={'navigation-link'}>/i \                <NavLink to={'/ranking'} className={'navigation-link'}>\n                    <div>\n                        <Icon.Award size={20} />\n                        <span className={'ml-3'}>Ranking</span>\n                    </div>\n                </NavLink>" "$file"
}

patchDashboardRouter() {
    local file="$target_dir/resources/scripts/routers/DashboardRouter.tsx"
    if [ ! -f "$file" ]; then return; fi
    printf "${watermark} Patching DashboardRouter.tsx... \n"
    if ! grep -q "import RankingContainer" "$file"; then
        sed -i "/import DashboardContainer/i import RankingContainer from '@/components/dashboard/RankingContainer';" "$file"
    fi
    if ! grep -q "path={'/ranking'}" "$file"; then
        sed -i "/<Route path={'\/'} exact>/i \                        <Route path={'/ranking'} exact>\n                            <RankingContainer />\n                        </Route>" "$file"
    fi
}

patchRoutes() {
    # api-client.php
    local api_file="$target_dir/routes/api-client.php"
    if [ -f "$api_file" ] && ! grep -q "RankingController" "$api_file"; then
        printf "${watermark} Patching api-client.php routes... \n"
        echo "Route::get('/ranking', [Client\RankingController::class, 'index']);" >> "$api_file"
    fi

    # admin.php
    local admin_file="$target_dir/routes/admin.php"
    if [ -f "$admin_file" ]; then
        if ! grep -q "admin.jexactyl.ranking" "$admin_file"; then
            printf "${watermark} Patching admin.php (ranking) routes... \n"
            sed -i "/Route::group(\['prefix' => '\/'\], function () {/a \    Route::group(['prefix' => '/ranking'], function () {\n        Route::get('/', [Jexactyl\\\\RankingController::class, 'index'])->name('admin.jexactyl.ranking');\n        Route::patch('/', [Jexactyl\\\\RankingController::class, 'update']);\n    });" "$admin_file"
        fi
        if ! grep -q "admin.users.medals" "$admin_file"; then
            printf "${watermark} Patching admin.php (user medals) routes... \n"
            sed -i "/Route::group(\['prefix' => 'users'\], function () {/a \    Route::get('/view/{user:id}/medals', [Admin\\\\Users\\\\MedalController::class, 'index'])->name('admin.users.medals');\n    Route::post('/view/{user:id}/medals', [Admin\\\\Users\\\\MedalController::class, 'store']);\n    Route::delete('/view/{user:id}/medals/{medal}', [Admin\\\\Users\\\\MedalController::class, 'delete'])->name('admin.users.medals.delete');" "$admin_file"
        fi
    fi
}

patchKernel() {
    local file="$target_dir/app/Console/Kernel.php"
    if [ -f "$file" ] && ! grep -q "p:ranking:process" "$file"; then
        printf "${watermark} Patching Console/Kernel.php... \n"
        sed -i "/protected function schedule/a \        \$schedule->command('p:ranking:process')->monthlyOn(1, '00:00');" "$file"
    fi
}

patchUserModel() {
    local file="$target_dir/app/Models/User.php"
    if [ -f "$file" ] && ! grep -q "public function medals()" "$file"; then
        printf "${watermark} Patching Models/User.php... \n"
        sed -i "/class User extends Model/a \    public function medals(): \\\\Illuminate\\\\Database\\\\Eloquent\\\\Relations\\\\HasMany { return \$this->hasMany(UserMedal::class); }" "$file"
    fi
}

patchUserNav() {
    local file="$target_dir/resources/views/partials/admin/users/nav.blade.php"
    if [ -f "$file" ] && ! grep -q "admin.users.medals" "$file"; then
        printf "${watermark} Patching partials/admin/users/nav.blade.php... \n"
        sed -i "/admin.users.resources/a \                    <li @if(\$activeTab === 'medals')class=\"active\"@endif><a href=\"{{ route('admin.users.medals', ['user' => \$user]) }}\">Medals</a></li>" "$file"
    fi
}

patchJexactylNav() {
    local file="$target_dir/resources/views/partials/admin/jexactyl/nav.blade.php"
    if [ -f "$file" ] && ! grep -q "admin.jexactyl.ranking" "$file"; then
        printf "${watermark} Patching partials/admin/jexactyl/nav.blade.php... \n"
        sed -i "/admin.jexactyl.coupons/ { n; n; a \                    <li @if(\$activeTab === 'ranking') class=\"active\" @endif>\n                        <a href=\"{{ route('admin.jexactyl.ranking') }}\">Ranking</a>\n                    </li>" "$file"
    fi
}

installModule(){
    chooseDirectory
    printf "${watermark} Installing module... \n"
    
    # Backup
    mkdir -p "original-resources"
    cp "$target_dir/resources/scripts/components/elements/SidePanel.tsx" "original-resources/" 2>/dev/null
    cp "$target_dir/resources/scripts/routers/DashboardRouter.tsx" "original-resources/" 2>/dev/null
    cp "$target_dir/routes/api-client.php" "original-resources/" 2>/dev/null
    cp "$target_dir/routes/admin.php" "original-resources/" 2>/dev/null
    cp "$target_dir/app/Console/Kernel.php" "original-resources/" 2>/dev/null
    cp "$target_dir/app/Models/User.php" "original-resources/" 2>/dev/null
    cp "$target_dir/resources/views/partials/admin/users/nav.blade.php" "original-resources/user_nav.blade.php" 2>/dev/null
    cp "$target_dir/resources/views/partials/admin/jexactyl/nav.blade.php" "original-resources/jex_nav.blade.php" 2>/dev/null

    # Copy files
    cp -rv resources/* "$target_dir/"

    # Patch
    patchSidePanel
    patchDashboardRouter
    patchRoutes
    patchKernel
    patchUserModel
    patchUserNav
    patchJexactylNav

    # Migrations
    printf "${watermark} Running migrations... \n"
    cd "$target_dir"
    php artisan migrate --force

    printf "${watermark} Module successfully installed. \n"

    while true; do
        read -p '<jex-ranking> [?] Do you want to rebuild panel assets [y/N]? ' yn
        case $yn in
            [Yy]* ) startPterodactyl; break;;
            [Nn]* ) exit;;
            * ) exit;;
        esac
    done
}

while true; do
    read -p '<jex-ranking> [✓] Are you sure that you want to install "jex-ranking" module [y/N]? ' yn
    case $yn in
        [Yy]* ) installModule; break;;
        [Nn]* ) printf "${watermark} Canceled \n"; exit;;
        * ) exit;;
    esac
done