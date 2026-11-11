<?php

namespace App\Support;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Slugger
{
    public static function unique(string $modelClass, string $value, ?string $ignoreId = null): string
    {
        /** @var class-string<Model> $modelClass */
        $base = Str::slug($value);
        $base = $base !== '' ? $base : 'listing';
        $slug = $base;
        $suffix = 2;

        while ($modelClass::query()
            ->when($ignoreId, fn ($query) => $query->whereKeyNot($ignoreId))
            ->where('slug', $slug)
            ->exists()) {
            $slug = $base.'-'.$suffix;
            $suffix++;
        }

        return $slug;
    }
}
