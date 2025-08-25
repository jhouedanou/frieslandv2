<?php

namespace App\Filament\Resources\VisiteResource\Pages;

use App\Filament\Resources\VisiteResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewVisite extends ViewRecord
{
    protected static string $resource = VisiteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}