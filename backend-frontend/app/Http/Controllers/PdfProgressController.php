<?php

namespace App\Http\Controllers;

use App\Models\BookView;
use App\Models\PdfReadProgress;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Http\JsonResponse;


class PdfProgressController extends Controller
{

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated.',
                'data' => [],
            ], 401);
        }

        $rows = PdfReadProgress::query()
            ->select([
                'id',
                'user_id',
                'item_id',
                'doc_key',
                'last_page',
                'total_pages',
                'percent',
                'created_at',
                'updated_at',
            ])
            ->where('user_id', $user->id)
            ->whereNotNull('item_id')
            ->with([
                'item:id,title,cover_url,file_url,author_id,category_id',
                'item.author:id,name',
                'item.category:id,name',
                'item.tags:id,name',
            ])
            ->orderByDesc('updated_at')
            ->get()
            ->map(function (PdfReadProgress $row) {
                $item = $row->item;

                if (!$item || empty($item->file_url)) {
                    return null;
                }

                return [
                    'id' => (int)$row->id,
                    'item_id' => (int)$row->item_id,
                    'doc_key' => $row->doc_key,
                    'last_page' => (int)$row->last_page,
                    'total_pages' => (int)$row->total_pages,
                    'percent' => (float)$row->percent,
                    'created_at' => $row->created_at,
                    'updated_at' => $row->updated_at,

                    'title' => (string)($item->title ?? 'Untitled Book'),
                    'cover_url' => $item->cover_url,
                    'file_url' => $item->file_url,
                    'author_name' => $item->author->name ?? 'Unknown Author',
                    'category_name' => $item->category->name ?? 'Uncategorized',
                    'tags' => $item->tags
                        ? $item->tags->map(fn($tag) => [
                            'id' => (int)$tag->id,
                            'name' => (string)$tag->name,
                        ])->values()
                        : [],
                ];
            })
            ->filter()
            ->values();

        return response()->json([
            'message' => 'PDF progress list loaded successfully.',
            'data' => $rows,
        ]);
    }


    public function show(Request $request)
    {
        $data = $request->validate([
            'item_id' => ['nullable','integer'],
            'doc_key' => ['nullable','string','size:64'],
        ]);

        if (empty($data['item_id']) && empty($data['doc_key'])) {
            return response()->json(['message' => 'item_id or doc_key is required'], 422);
        }

        $q = PdfReadProgress::query()->where('user_id', $request->user()->id);

        if (!empty($data['item_id'])) $q->where('item_id', $data['item_id']);
        if (!empty($data['doc_key'])) $q->where('doc_key', $data['doc_key']);

        return response()->json($q->first());

    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'item_id'     => ['nullable', 'integer'],
            'doc_key'     => ['nullable', 'string', 'size:64'],
            'last_page'   => ['required', 'integer', 'min:1'],
            'total_pages' => ['required', 'integer', 'min:1'],
        ]);

        if (empty($data['item_id']) && empty($data['doc_key'])) {
            return response()->json([
                'message' => 'item_id or doc_key is required',
            ], 422);
        }

        $userId = $request->user()->id;
        $itemId = !empty($data['item_id']) ? (int) $data['item_id'] : null;
        $docKey = !empty($data['doc_key']) ? trim($data['doc_key']) : null;

        $last = (int) $data['last_page'];
        $total = max(1, (int) $data['total_pages']);

        if ($last > $total) {
            $last = $total;
        }

        $percent = round(($last / $total) * 100, 2);

//FIND EXISTING RECORD

        $progress = null;

        if ($itemId) {
            $progress = PdfReadProgress::where('user_id', $userId)
                ->where('item_id', $itemId)
                ->first();
        } elseif ($docKey) {
            $progress = PdfReadProgress::where('user_id', $userId)
                ->where('doc_key', $docKey)
                ->first();
        }

//CREATE NEW RECORD
//Save doc_key only when creating new row.

        if (!$progress) {
            $progress = PdfReadProgress::create([
                'user_id'     => $userId,
                'item_id'     => $itemId,
                'doc_key'     => $docKey,
                'last_page'   => $last,
                'total_pages' => $total,
                'percent'     => $percent,
            ]);
        } else {

//UPDATE EXISTING RECORD
//DO NOT update existing doc_key.

            $progress->update([
                'last_page'   => $last,
                'total_pages' => $total,
                'percent'     => $percent,
            ]);
        }

//COMPLETE READING

        if ($percent >= 100) {
            $bookView = null;

            if ($itemId) {
                $bookView = BookView::firstOrCreate([
                    'user_id' => $userId,
                    'book_id' => $itemId,
                ]);

                $bookView->touch();
            }

            $progress->delete();

            return response()->json([
                'message'   => 'Reading completed successfully.',
                'progress'  => null,
                'book_view' => $bookView,
                'percent'   => 100,
            ]);
        }

        return response()->json([
            'message'  => 'Progress saved successfully.',
            'progress' => $progress->fresh(),
            'percent'  => $percent,
        ]);
    }


}
