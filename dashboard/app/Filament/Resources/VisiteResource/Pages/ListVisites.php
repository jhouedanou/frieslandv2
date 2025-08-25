<?php

namespace App\Filament\Resources\VisiteResource\Pages;

use App\Filament\Resources\VisiteResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListVisites extends ListRecords
{
    protected static string $resource = VisiteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [
            VisiteResource\Widgets\VisitesStatsWidget::class,
        ];
    }
}