<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    require app_path('Features/Auth/routes/api.php');
    require app_path('Features/Assistant/routes/api.php');
    require app_path('Features/Directory/routes/api.php');
    require app_path('Features/Listings/routes/api.php');
    require app_path('Features/Registry/routes/api.php');
    require app_path('Features/Companies/routes/api.php');
    require app_path('Features/Seller/routes/api.php');
    require app_path('Features/Buyer/routes/api.php');
    require app_path('Features/Admin/routes/api.php');
});
