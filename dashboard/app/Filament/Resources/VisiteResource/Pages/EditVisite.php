<?php

namespace App\Filament\Resources\VisiteResource\Pages;

use App\Filament\Resources\VisiteResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditVisite extends EditRecord
{
    protected static string $resource = VisiteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}