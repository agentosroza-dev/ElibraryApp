<?php
//
//namespace App\Http\Controllers\API;
//
//use App\Http\Controllers\Controller;
//use App\Models\PdfCommentHighlight;
//use Illuminate\Http\Request;
//
//class PdfCommentHighlightController extends Controller
//{
//    public function index(Request $request)
//    {
//        $request->validate([
//            'item_id' => ['nullable', 'integer'],
//            'doc_key' => ['nullable', 'string', 'size:64'],
//            'page'    => ['nullable', 'integer', 'min:1'],
//        ]);
//
//        $query = PdfCommentHighlight::query()
//            ->where('user_id', $request->user()->id)
//            ->latest();
//
//        if ($request->filled('item_id')) {
//            $query->where('item_id', $request->item_id);
//        }
//
//        if ($request->filled('doc_key')) {
//            $query->where('doc_key', $request->doc_key);
//        }
//
//        if ($request->filled('page')) {
//            $query->where('page', $request->page);
//        }
//
//        return response()->json([
//            'data' => $query->get(),
//        ]);
//    }
//
//    public function store(Request $request)
//    {
//        $data = $request->validate([
//            'item_id'         => ['nullable', 'integer'],
//            'doc_key'         => ['nullable', 'string', 'size:64'],
//            'page'            => ['required', 'integer', 'min:1'],
//            'selected_text'   => ['nullable', 'string'],
//            'comment'         => ['nullable', 'string'],
//            'highlight_color' => ['nullable', 'string', 'max:30'],
//            'rects'           => ['nullable', 'array'],
//            'meta'            => ['nullable', 'array'],
//        ]);
//
//        if (empty($data['item_id']) && empty($data['doc_key'])) {
//            return response()->json([
//                'message' => 'item_id or doc_key is required',
//            ], 422);
//        }
//
//        $record = PdfCommentHighlight::create([
//            'user_id'         => $request->user()->id,
//            'item_id'         => $data['item_id'] ?? null,
//            'doc_key'         => $data['doc_key'] ?? null,
//            'page'            => $data['page'],
//            'selected_text'   => $data['selected_text'] ?? null,
//            'comment'         => $data['comment'] ?? null,
//            'highlight_color' => $data['highlight_color'] ?? '#fff59d',
//            'rects'           => $data['rects'] ?? null,
//            'meta'            => $data['meta'] ?? null,
//        ]);
//
//        return response()->json([
//            'message' => 'Saved successfully.',
//            'data' => $record,
//        ]);
//    }
//
//    public function show($id)
//    {
//        $record = PdfCommentHighlight::findOrFail($id);
//
//        return response()->json([
//            'data' => $record,
//        ]);
//    }
//
//    public function update(Request $request, $id)
//    {
//        $record = PdfCommentHighlight::findOrFail($id);
//
//        $data = $request->validate([
//            'page'            => ['nullable', 'integer', 'min:1'],
//            'selected_text'   => ['nullable', 'string'],
//            'comment'         => ['nullable', 'string'],
//            'highlight_color' => ['nullable', 'string', 'max:30'],
//            'rects'           => ['nullable', 'array'],
//            'meta'            => ['nullable', 'array'],
//        ]);
//
//        $record->update([
//            'page'            => $data['page'] ?? $record->page,
//            'selected_text'   => array_key_exists('selected_text', $data) ? $data['selected_text'] : $record->selected_text,
//            'comment'         => array_key_exists('comment', $data) ? $data['comment'] : $record->comment,
//            'highlight_color' => $data['highlight_color'] ?? $record->highlight_color,
//            'rects'           => array_key_exists('rects', $data) ? $data['rects'] : $record->rects,
//            'meta'            => array_key_exists('meta', $data) ? $data['meta'] : $record->meta,
//        ]);
//
//        return response()->json([
//            'message' => 'Updated successfully.',
//            'data' => $record->fresh(),
//        ]);
//    }
//
//    public function destroy($id)
//    {
//        $record = PdfCommentHighlight::findOrFail($id);
//        $record->delete();
//
//        return response()->json([
//            'message' => 'Deleted successfully.',
//        ]);
//    }
//}


namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\PdfCommentHighlight;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PdfCommentHighlightController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $data = $request->validate([
            'item_id' => ['required', 'integer', 'min:1'],
            'page' => ['nullable', 'integer', 'min:1'],
        ]);

        $query = PdfCommentHighlight::query()
            ->where('user_id', $request->user()->id)
            ->where('item_id', $data['item_id'])
            ->orderBy('page')
            ->latest('updated_at');

        if ($request->filled('page')) {
            $query->where('page', $data['page']);
        }

        return response()->json([
            'data' => $query->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'item_id' => ['required', 'integer', 'min:1'],
            'page' => ['required', 'integer', 'min:1'],
            'selected_text' => ['nullable', 'string'],
            'comment' => ['nullable', 'string'],
            'highlight_color' => ['nullable', 'string', 'max:30'],
            'rects' => ['nullable', 'array'],
            'meta' => ['nullable', 'array'],
        ]);

        $record = PdfCommentHighlight::create([
            'user_id' => $request->user()->id,
            'item_id' => $data['item_id'],
            'page' => $data['page'],
            'selected_text' => $data['selected_text'] ?? null,
            'comment' => $data['comment'] ?? null,
            'highlight_color' => $data['highlight_color'] ?? '#fff59d',
            'rects' => $data['rects'] ?? null,
            'meta' => $data['meta'] ?? null,
        ]);

        return response()->json([
            'message' => 'Saved successfully.',
            'data' => $record,
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $record = PdfCommentHighlight::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'data' => $record,
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $record = PdfCommentHighlight::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        $data = $request->validate([
            'item_id' => ['nullable', 'integer', 'min:1'],
            'page' => ['nullable', 'integer', 'min:1'],
            'selected_text' => ['nullable', 'string'],
            'comment' => ['nullable', 'string'],
            'highlight_color' => ['nullable', 'string', 'max:30'],
            'rects' => ['nullable', 'array'],
            'meta' => ['nullable', 'array'],
        ]);

        $record->fill([
            'item_id' => $data['item_id'] ?? $record->item_id,
            'page' => $data['page'] ?? $record->page,
            'selected_text' => array_key_exists('selected_text', $data)
                ? $data['selected_text']
                : $record->selected_text,
            'comment' => array_key_exists('comment', $data)
                ? $data['comment']
                : $record->comment,
            'highlight_color' => $data['highlight_color'] ?? $record->highlight_color,
            'rects' => array_key_exists('rects', $data)
                ? $data['rects']
                : $record->rects,
            'meta' => array_key_exists('meta', $data)
                ? $data['meta']
                : $record->meta,
        ]);

        $record->save();

        return response()->json([
            'message' => 'Updated successfully.',
            'data' => $record->fresh(),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $record = PdfCommentHighlight::query()
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        $record->delete();

        return response()->json([
            'message' => 'Deleted successfully.',
        ]);
    }
}
