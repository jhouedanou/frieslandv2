<?php

namespace App\Filament\Resources\PDVResource\Pages;

use App\Filament\Resources\PDVResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPDV extends EditRecord
{
    protected static string $resource = PDVResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make()
                ->label('Supprimer')
                ->icon('heroicon-o-trash'),
        ];
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'PDV mis à jour avec succès';
    }
} 