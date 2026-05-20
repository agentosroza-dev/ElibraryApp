<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PdfFileController extends Controller
{
    public function show(Request $request)
    {
        $request->validate([
            'path' => ['required', 'string'], // e.g. books/xxx.pdf
        ]);

        $path = $request->string('path')->toString();

        // protect: only allow inside "books/"
        abort_unless(str_starts_with($path, 'books/'), 403);

        abort_unless(Storage::disk('public')->exists($path), 404);

        $fullPath = Storage::disk('public')->path($path);

        return response()->file($fullPath, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'inline; filename="'.basename($fullPath).'"',
        ]);
    }
}
