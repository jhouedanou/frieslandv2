<?php

namespace App\Filament\Resources\PDVResource\Pages;

use App\Filament\Resources\PDVResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPDVs extends ListRecords
{
    protected static string $resource = PDVResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('Nouveau PDV')
                ->icon('heroicon-o-plus'),
        ];
    }
} 