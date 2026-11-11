<?php

namespace App\Features\Registry\Filament\Resources\RegistrySubmissions\Pages;

use App\Features\Registry\Filament\Resources\RegistrySubmissions\RegistrySubmissionResource;
use Filament\Resources\Pages\ListRecords;

class ListRegistrySubmissions extends ListRecords
{
    protected static string $resource = RegistrySubmissionResource::class;
}
