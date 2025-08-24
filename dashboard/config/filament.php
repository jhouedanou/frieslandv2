<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Filament Path
    |--------------------------------------------------------------------------
    |
    | The default is `admin` but you can change it to whatever works best and
    | doesn't conflict with the routing in your application.
    |
    */

    'path' => env('FILAMENT_PATH', 'admin'),

    /*
    |--------------------------------------------------------------------------
    | Filament Core Path
    |--------------------------------------------------------------------------
    |
    | This is the path which Filament will use to load its core routes and assets.
    | You may change it if it conflicts with your other routes.
    |
    */

    'core_path' => env('FILAMENT_CORE_PATH', 'filament'),

    /*
    |--------------------------------------------------------------------------
    | Filament Domain
    |--------------------------------------------------------------------------
    |
    | You may change the domain where Filament should be active. If the domain
    | is empty, all domains will be valid.
    |
    */

    'domain' => env('FILAMENT_DOMAIN'),

    /*
    |--------------------------------------------------------------------------
    | Homepage URL
    |--------------------------------------------------------------------------
    |
    | This is the URL that Filament will redirect the user to when they click
    | on the sidebar's "Home" button.
    |
    */

    'home_url' => '/',

    /*
    |--------------------------------------------------------------------------
    | Brand Name
    |--------------------------------------------------------------------------
    |
    | This is the name that will be displayed in the page title and header.
    |
    */

    'brand' => env('FILAMENT_BRAND', 'Friesland Dashboard'),

    /*
    |--------------------------------------------------------------------------
    | Auth
    |--------------------------------------------------------------------------
    |
    | This is the configuration that Filament will use to handle authentication
    | into the admin panel.
    |
    */

    'auth' => [
        'guard' => env('FILAMENT_AUTH_GUARD', 'web'),
        'pages' => [
            'login' => \Filament\Pages\Auth\Login::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Pages
    |--------------------------------------------------------------------------
    |
    | This is the namespace and directory that Filament will automatically
    | register pages from. You may also register pages here.
    |
    */

    'pages' => [
        'namespace' => 'App\\Filament\\Pages',
        'path' => app_path('Filament/Pages'),
        'register' => [
            //
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Resources
    |--------------------------------------------------------------------------
    |
    | This is the namespace and directory that Filament will automatically
    | register resources from. You may also register resources here.
    |
    */

    'resources' => [
        'namespace' => 'App\\Filament\\Resources',
        'path' => app_path('Filament/Resources'),
        'register' => [
            //
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Widgets
    |--------------------------------------------------------------------------
    |
    | This is the namespace and directory that Filament will automatically
    | register dashboard widgets from. You may also register widgets here.
    |
    */

    'widgets' => [
        'namespace' => 'App\\Filament\\Widgets',
        'path' => app_path('Filament/Widgets'),
        'register' => [
            //
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Livewire
    |--------------------------------------------------------------------------
    |
    | This is the namespace and directory that Filament will automatically
    | register Livewire components from. You may also register components here.
    |
    */

    'livewire' => [
        'namespace' => 'App\\Filament',
        'path' => app_path('Filament'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Layout
    |--------------------------------------------------------------------------
    |
    | This is the configuration for the general layout of the admin panel.
    | You may configure the max content width from `xl` to `7xl`, or `full`
    | for no max width.
    |
    */

    'layout' => [
        'actions' => [
            'modal' => [
                'actions' => [
                    'alignment' => 'left',
                ],
            ],
        ],
        'forms' => [
            'actions' => [
                'alignment' => 'left',
                'are_sticky' => false,
            ],
            'have_inline_labels' => false,
        ],
        'footer' => [
            'should_show_logo' => false,
        ],
        'max_content_width' => 'full',
        'notifications' => [
            'vertical_alignment' => 'top',
        ],
        'sidebar' => [
            'is_collapsible_on_desktop' => true,
            'groups' => [
                'are_collapsible' => true,
            ],
            'width' => null,
            'collapsed_width' => null,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Default Theme
    |--------------------------------------------------------------------------
    |
    | This is the default theme that Filament will use. You may view the
    | available themes in the `app/filament/themes` directory, or switch
    | between them at runtime.
    |
    */

    'default_theme' => 'filament',

    /*
    |--------------------------------------------------------------------------
    | Dark mode
    |--------------------------------------------------------------------------
    |
    | By enabling this feature, your users are able to select between a light
    | and dark appearance for the admin panel, or let it automatically
    | adjust based on their system's preferences.
    |
    | You may enable dark mode for the entire admin panel by setting this
    | to `true`, or enable it per-user by setting the `dark_mode` setting
    | in the user's settings.
    |
    */

    'dark_mode' => [
        'enabled' => true,
        'toggle_enabled' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Database notifications
    |--------------------------------------------------------------------------
    |
    | You can enable database notifications in Filament by setting this to
    | `true`. This will create a table in your database to store the
    | notifications.
    |
    */

    'database_notifications' => [
        'enabled' => false,
        'polling_interval' => '30s',
    ],

    /*
    |--------------------------------------------------------------------------
    | Layout components
    |--------------------------------------------------------------------------
    |
    | These are the layout components that Filament will use to display
    | the admin panel. You may customize the layout components here.
    |
    */

    'layout_components' => [
        'actions' => [
            'modal' => [
                'actions' => [
                    'alignment' => 'left',
                ],
            ],
        ],
        'forms' => [
            'actions' => [
                'alignment' => 'left',
                'are_sticky' => false,
            ],
            'have_inline_labels' => false,
        ],
        'footer' => [
            'should_show_logo' => false,
        ],
        'header' => [
            'should_show_logo' => true,
        ],
        'sidebar' => [
            'is_collapsible_on_desktop' => true,
            'groups' => [
                'are_collapsible' => true,
            ],
            'width' => null,
            'collapsed_width' => null,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Available themes
    |--------------------------------------------------------------------------
    |
    | This is the list of themes that Filament will use. You may disable
    | themes by removing them from this list.
    |
    */

    'themes' => [
        'filament' => [
            'id' => 'filament',
            'name' => 'Filament',
            'class' => \Filament\Themes\Filament::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Global search
    |--------------------------------------------------------------------------
    |
    | You can enable global search in Filament by setting this to `true`.
    | This will create a search bar in the header of the admin panel.
    |
    */

    'global_search' => [
        'enabled' => true,
        'include_models' => [
            \App\Models\PDV::class,
            \App\Models\Visite::class,
            \App\Models\User::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Middleware
    |--------------------------------------------------------------------------
    |
    | You may customize the middleware stack that Filament uses to handle
    | requests.
    |
    */

    'middleware' => [
        'base' => [
            \Illuminate\Cookie\Middleware\EncryptCookies::class,
            \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\Session\Middleware\AuthenticateSession::class,
            \Illuminate\View\Middleware\ShareErrorsFromSession::class,
            \Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class,
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
        ],
        'auth' => [
            \Filament\Http\Middleware\Authenticate::class,
        ],
        'base_auth' => [
            \Illuminate\Auth\Middleware\Authenticate::class,
        ],
    ],

]; 