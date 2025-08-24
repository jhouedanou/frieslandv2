<?php

namespace App\Filament\Resources\PDVResource\Pages;

use App\Filament\Resources\PDVResource;
use Filament\Resources\Pages\CreateRecord;

class CreatePDV extends CreateRecord
{
    protected static string $resource = PDVResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return 'PDV créé avec succès';
    }
} 