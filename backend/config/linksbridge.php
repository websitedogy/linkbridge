<?php

return [
    'media_disk' => env('AWS_BUCKET') ? 's3' : env('LISTING_MEDIA_DISK', 'public'),
];
