<?php

namespace App\Filament\Resources\PDVResource\Pages;

use App\Filament\Resources\PDVResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewPDV extends ViewRecord
{
    protected static string $resource = PDVResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->label('Modifier')
                ->icon('heroicon-o-pencil'),
        ];
    }
} 