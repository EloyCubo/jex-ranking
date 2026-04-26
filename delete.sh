#!/bin/bash

if (( $EUID != 0 )); then
    printf "\033[0;33m<jex-ranking> \033[0;31m[✕]\033[0m Please run this program as root \n"
    exit
fi

watermark="\033[0;33m<jex-ranking> \033[0;32m[✓]\033[0m"
target_dir=""

chooseDirectory() {
    echo -e "<jex-ranking> [1] /var/www/jexactyl"
    echo -e "<jex-ranking> [2] /var/www/pterodactyl"

    while true; do
        read -p "<jex-ranking> [?] Choose directory [1/2]: " choice
        case "$choice" in
            1) target_dir="/var/www/jexactyl"; break ;;
            2) target_dir="/var/www/pterodactyl"; break ;;
            *) echo -e "\033[0;33m<jex-ranking> \033[0;31m[✕]\033[0m Invalid choice.";;
        esac
    done
}

startPterodactyl(){
    printf "${watermark} Rebuilding panel assets... \n"
    cd "$target_dir"
    export NODE_OPTIONS=--openssl-legacy-provider
    yarn build:production
    php artisan optimize:clear
}

deleteModule(){
    chooseDirectory
    printf "${watermark} Deleting module... \n"

    # Restore backups if they exist
    [ -f "original-resources/SidePanel.tsx" ] && cp "original-resources/SidePanel.tsx" "$target_dir/resources/scripts/components/elements/"
    [ -f "original-resources/DashboardRouter.tsx" ] && cp "original-resources/DashboardRouter.tsx" "$target_dir/resources/scripts/routers/"
    [ -f "original-resources/api-client.php" ] && cp "original-resources/api-client.php" "$target_dir/routes/"
    [ -f "original-resources/admin.php" ] && cp "original-resources/admin.php" "$target_dir/routes/"
    [ -f "original-resources/Kernel.php" ] && cp "original-resources/Kernel.php" "$target_dir/app/Console/"
    [ -f "original-resources/User.php" ] && cp "original-resources/User.php" "$target_dir/app/Models/"
    [ -f "original-resources/user_nav.blade.php" ] && cp "original-resources/user_nav.blade.php" "$target_dir/resources/views/partials/admin/users/nav.blade.php"
    [ -f "original-resources/jex_nav.blade.php" ] && cp "original-resources/jex_nav.blade.php" "$target_dir/resources/views/partials/admin/jexactyl/nav.blade.php"

    # Remove files
    rm -f "$target_dir/resources/scripts/components/dashboard/RankingContainer.tsx"
    rm -f "$target_dir/app/Http/Controllers/Api/Client/RankingController.php"
    rm -f "$target_dir/app/Http/Controllers/Admin/Jexactyl/RankingController.php"
    rm -f "$target_dir/app/Http/Controllers/Admin/Users/MedalController.php"
    rm -f "$target_dir/app/Models/UserMedal.php"
    rm -f "$target_dir/app/Console/Commands/ProcessMonthlyRanking.php"
    rm -f "$target_dir/resources/views/admin/jexactyl/ranking.blade.php"
    rm -f "$target_dir/resources/views/admin/users/medals.blade.php"
    # Note: Migration is not removed automatically to avoid data loss.

    printf "${watermark} Module successfully deleted from your repository \n"

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
    read -p '<jex-ranking> [✓] Are you sure that you want to delete "jex-ranking" module [y/N]? ' yn
    case $yn in
        [Yy]* ) deleteModule; break;;
        [Nn]* ) printf "${watermark} Canceled \n"; exit;;
        * ) exit;;
    esac
done