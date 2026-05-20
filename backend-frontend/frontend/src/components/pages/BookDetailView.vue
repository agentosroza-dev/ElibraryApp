<template>
    <div class="content-wrapper pdf-reader-page">
        <section class="content-header reader-toolbar-section pt-0">
            <div class="container-fluid">
                <div class="reader-toolbar-inline">
                    <router-link
                        :to="{ name: 'book.details', params: { id: itemId } }"
                        class="btn btn-secondary btn-sm toolbar-back-btn"
                    >
                        <i class="fas fa-arrow-left mr-1"></i>
                        Back
                    </router-link>

                    <div class="reader-title" :title="displayTitle">
                        {{ displayTitle }}
                    </div>

                    <div class="toolbar-inline-group">
                        <span class="pill" title="Pages" style="font-size: 16px;">
                            <i class="fas fa-file-alt" style="font-size: 23px;"></i>
                            {{ page }}/{{ totalPages || "..." }}
                        </span>

                        <span class="pill" title="Progress" style="font-size: 16px;">
                            <i class="fas fa-chart-line" style="font-size: 23px;"></i>
                            {{ percent }}%
                        </span>

<!--                        <span class="pill" title="Rotation">-->
<!--                            <i class="fas fa-sync-alt"></i>-->
<!--                            {{ rotation }}°-->
<!--                        </span>-->
                    </div>

                    <div class="toolbar-inline-group">
                        <button type="button" @click="prevPage" :disabled="!canPrev" title="Previous page">
                            <i class="fas fa-chevron-left" style="font-size: 23px;"></i>
                        </button>

                        <button type="button" @click="nextPage" :disabled="!canNext" title="Next page">
                            <i class="fas fa-chevron-right" style="font-size: 23px;"></i>
                        </button>

                        <button type="button" @click="zoomOut" title="Zoom out">
                            <i class="fas fa-search-minus" style="font-size: 23px;"></i>
                        </button>

<!--                        <span class="value" title="Zoom scale">-->
<!--                            {{ scale.toFixed(2) }}-->
<!--                        </span>-->
<!--                        <span class="pill" title="Zoom">-->
<!--&lt;!&ndash;                            <i class="fas fa-search"></i>&ndash;&gt;-->
<!--                            {{ scale.toFixed(2) }}-->
<!--                        </span>-->

                        <button type="button" @click="zoomIn" title="Zoom in">
                            <i class="fas fa-search-plus" style="font-size: 23px;"></i>
                        </button>

                        <button type="button" @click="rotateLeft" title="Rotate left">
                            <i class="fas fa-undo" style="font-size: 23px;"></i>
                        </button>

<!--                        <button type="button" @click="rotateReset" title="Reset rotation">-->
<!--                            Reset-->
<!--                        </button>-->

                        <button type="button" @click="rotateRight" title="Rotate right">
                            <i class="fas fa-redo" style="font-size: 23px;"></i>
                        </button>
                    </div>

                    <div class="annotation-switch">
                        <button
                            type="button"
                            :class="{ active: annotMode === 'highlight' }"
                            @click="setMode('highlight')"
                            title="Highlight"
                        >
                            <i class="fas fa-highlighter" style="font-size: 23px;"></i>
                        </button>

                        <button
                            type="button"
                            :class="{ active: annotMode === 'comment' }"
                            @click="setMode('comment')"
                            title="Comment"
                        >
                            <i class="fas fa-comment-dots" style="font-size: 23px;"></i>
                        </button>

                        <button
                            type="button"
                            :class="{ active: annotMode === 'none' }"
                            @click="setMode('none')"
                            title="Clear mode"
                        >
                            <i class="fas fa-eraser" style="font-size: 23px;"></i>
                        </button>
                    </div>

                    <div class="toolbar-inline-group">
                        <span class="pill" title="Annotations on this page" style="font-size: 16px;">
                            <i class="fas fa-clipboard" style="font-size: 23px;"></i>
                            {{ currentPageAnnotations.length }}
                        </span>

                        <button
                            type="button"
                            class="btn-fav"
                            :class="{ active: isFavorite }"
                            :disabled="loadingFavorite || !itemId"
                            @click="toggleFavorite"
                            title="Favorite"
                        >
                            <i class="fab fa-gratipay" style="font-size: 21px;"></i>
                        </button>
                    </div>
                </div>

                <div
                    v-if="annotMode !== 'none' && isTouchDevice"
                    class="reader-touch-hint"
                >
                    Select text, then release your finger to save {{ annotMode === "comment" ? "comment" : "highlight" }}.
                </div>
            </div>
        </section>

        <section class="content pb-4">
            <div class="container-fluid">
                <div class="card reader-card border-0 shadow-sm">
                    <div class="card-body p-0">
                        <div v-if="loadingBook" class="reader-alert-wrap">
                            <div class="alert alert-info m-0">Loading book...</div>
                        </div>

                        <div v-else-if="loadError" class="reader-alert-wrap">
                            <div class="alert alert-danger m-0">{{ loadError }}</div>
                        </div>

                        <div v-else-if="!resolvedPdfUrl" class="reader-alert-wrap">
                            <div class="alert alert-warning m-0">Missing PDF URL.</div>
                        </div>

                        <div v-else-if="pdfDownloading" class="reader-pdf-loading">
                            <div class="reader-pdf-loading__box">
                                <i class="fas fa-spinner fa-spin"></i>

                                <div class="reader-pdf-loading__title">
                                    Downloading PDF... {{ pdfDownloadPercent }}%
                                </div>

                                <div class="reader-pdf-loading__bar">
                                    <div
                                        class="reader-pdf-loading__bar-fill"
                                        :style="{ width: `${pdfDownloadPercent}%` }"
                                    ></div>
                                </div>

                                <div class="reader-pdf-loading__text">
                                    Please wait while the book is loading.
                                </div>
                            </div>
                        </div>

                        <div v-else class="reader-layout">
                            <div class="pdf-viewer" :class="{ 'pdf-viewer--dark': isDark }">

                                <div class="watermark-layer">
                                    <div
                                        v-for="n in 500"
                                        :key="n"
                                        class="watermark-item"
                                    >
                                        PAC E-Library
                                    </div>
                                </div>

                                <div
                                    ref="pdfPageRef"
                                    class="pdf-page-wrap"
                                    @mouseup="handleSelectionEnd"
                                    @touchend.passive="handleSelectionEnd"
                                >
                                    <VuePDF
                                        :pdf="pdf"
                                        :page="page"
                                        :scale="scale"
                                        :rotation="rotation"
                                        :text-layer="true"
                                        :annotation-layer="true"
                                    />

                                    <div class="annotation-overlay">
                                        <template
                                            v-for="annotation in currentPageAnnotations"
                                            :key="annotation.id"
                                        >
                                            <template
                                                v-for="(rect, idx) in annotation.rects"
                                                :key="`${annotation.id}_${idx}`"
                                            >
                                                <div
                                                    class="annotation-rect"
                                                    :class="{
                                                        'is-comment': !!annotation.comment,
                                                        'is-active': activeAnnotationId === annotation.id
                                                    }"
                                                    :style="{
                                                        left: `${rect.x * 100}%`,
                                                        top: `${rect.y * 100}%`,
                                                        width: `${rect.w * 100}%`,
                                                        height: `${rect.h * 100}%`,
                                                        background: getHighlightBackground(annotation)
                                                    }"
                                                    @click.stop="selectAnnotation(annotation.id)"
                                                >
                                                    <span
                                                        v-if="annotation.comment && idx === 0"
                                                        class="comment-badge"
                                                    >
                                                        💬
                                                    </span>

                                                    <div
                                                        v-if="annotation.comment && idx === 0"
                                                        class="comment-popup"
                                                        :class="{ 'comment-popup--show': activeAnnotationId === annotation.id }"
                                                    >
                                                        <div class="comment-popup__label">
                                                            Selected Text
                                                        </div>

                                                        <div class="comment-popup__text">
                                                            “{{ annotation.selected_text || "-" }}”
                                                        </div>

                                                        <div class="comment-popup__comment">
                                                            {{ annotation.comment }}
                                                        </div>
                                                    </div>
                                                </div>
                                            </template>
                                        </template>
                                    </div>
                                </div>
                            </div>

                            <aside class="annotation-sidebar">
                                <div class="sidebar-header">
                                    <div>
                                        <h5 class="sidebar-title mb-1">Annotations</h5>
                                        <div class="sidebar-subtitle">
                                            Page {{ page }} · {{ currentPageAnnotations.length }} item(s)
                                        </div>
                                    </div>
                                </div>

                                <div v-if="loadingAnnotations" class="empty-annotations">
                                    <div class="empty-annotations__icon">
                                        <i class="fas fa-spinner fa-spin"></i>
                                    </div>
                                    <div class="empty-annotations__title">Loading...</div>
                                    <div class="empty-annotations__text">
                                        Loading annotations for this document.
                                    </div>
                                </div>

                                <div v-else-if="!currentPageAnnotations.length" class="empty-annotations">
                                    <div class="empty-annotations__icon">
                                        <i class="far fa-sticky-note"></i>
                                    </div>
                                    <div class="empty-annotations__title">No annotations yet</div>
                                    <div class="empty-annotations__text">
                                        Add highlights or comments on this page.
                                    </div>
                                </div>

                                <div v-else class="annotation-list">
                                    <div
                                        v-for="annotation in currentPageAnnotations"
                                        :key="annotation.id"
                                        class="annotation-item"
                                        :class="{ active: activeAnnotationId === annotation.id }"
                                        @click="selectAnnotation(annotation.id)"
                                    >
                                        <div class="annotation-item__top">
                                            <span
                                                class="annotation-type-badge"
                                                :class="
                                                    annotation.comment
                                                        ? 'annotation-type-badge--comment'
                                                        : 'annotation-type-badge--highlight'
                                                "
                                            >
                                                <i
                                                    class="fas mr-1"
                                                    :class="
                                                        annotation.comment
                                                            ? 'fa-comment-dots'
                                                            : 'fa-highlighter'
                                                    "
                                                ></i>
                                                {{ annotation.comment ? "comment" : "highlight" }}
                                            </span>

                                            <button
                                                type="button"
                                                class="btn btn-delete-annotation"
                                                :disabled="deletingId === annotation.id"
                                                @click.stop="removeAnnotation(annotation.id)"
                                            >
                                                <i class="fas fa-trash-alt mr-1"></i>
                                                {{ deletingId === annotation.id ? "Deleting..." : "Delete" }}
                                            </button>
                                        </div>

                                        <div class="annotation-item__text">
                                            “{{ annotation.selected_text || "-" }}”
                                        </div>

                                        <div v-if="annotation.comment" class="annotation-item__comment">
                                            {{ annotation.comment }}
                                        </div>

                                        <div class="annotation-item__date">
                                            {{ formatDate(annotation.created_at) }}
                                        </div>
                                    </div>
                                </div>
                            </aside>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <div v-if="showCommentModal" class="modal-overlay" @click.self="closeModal">
            <div class="modal-box">
                <h5 class="mb-3">Add Comment</h5>

                <textarea
                    v-model="commentInput"
                    class="form-control mb-3"
                    rows="4"
                    placeholder="Enter comment..."
                />

                <div class="modal-footer-minimal">
                    <button
                        type="button"
                        class="btn btn-sm btn-secondary btn-modal btn-modal--secondary"
                        @click="closeModal"
                    >
                        Cancel
                    </button>

                    <button
                        type="button"
                        class="btn btn-sm btn-primary btn-modal btn-modal--primary"
                        :disabled="savingAnnotation"
                        @click="submitComment"
                    >
                        {{ savingAnnotation ? "Saving..." : "Save" }}
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import axios from "axios";
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { VuePDF, usePDF } from "@tato30/vue-pdf";
import "@tato30/vue-pdf/style.css";

import {
    apiAddFavorite,
    apiCheckFavorite,
    apiRemoveFavorite,
    apiShowItem,
} from "@func/api/item.js";

import {
    apiCreatePdfCommentHighlight,
    apiDeletePdfCommentHighlight,
    apiGetPdfCommentHighlights,
} from "@func/api/pdfCommentHighlight";

const props = defineProps({
    id: {
        type: [Number, String],
        required: true,
    },
});

const API_BASE = (
    import.meta.env.VITE_API_URL ||
    window.API_URL ||
    window.API_BASE_URL ||
    ""
).replace(/\/$/, "");

const DARK_KEY = "dark-mode";
const DEFAULT_HIGHLIGHT = "#fff59d";
const DEFAULT_COMMENT_HIGHLIGHT = "#9ee7ff";
const INITIAL_SCALE = 1.18;
const MIN_SCALE = 0.5;
const MAX_SCALE = 2.5;
const SAVE_PROGRESS_DELAY = 600;
const SELECTION_DELAY = 180;

const itemId = computed(() => Number(props.id || 0));

const loadingBook = ref(false);
const loadError = ref("");
const book = ref({});

const isFavorite = ref(false);
const loadingFavorite = ref(false);
const isDark = ref(false);

const page = ref(1);
const totalPages = ref(0);
const scale = ref(INITIAL_SCALE);
const rotation = ref(0);

const annotMode = ref("none");
const annotations = ref([]);
const activeAnnotationId = ref(null);
const loadingAnnotations = ref(false);
const savingAnnotation = ref(false);
const deletingId = ref(null);

const showCommentModal = ref(false);
const commentInput = ref("");
const pendingPayload = ref(null);

const pdfPageRef = ref(null);
const docKey = ref("");

let saveProgressTimer = null;
let selectionTimer = null;
let selectionChangeTimer = null;
let initToken = 0;

const pdfDownloadPercent = ref(0);
const pdfBlobUrl = ref("");
const downloadingPdf = ref(false);

const pdfSourceUrl = computed(() => pdfBlobUrl.value || null);

const { pdf, pages: pdfPages } = usePDF(pdfSourceUrl);

const pdfDownloading = computed(() => {
    return downloadingPdf.value || (resolvedPdfUrl.value && !pdfPages.value);
});


function resetPdfBlobUrl() {
    if (pdfBlobUrl.value) {
        URL.revokeObjectURL(pdfBlobUrl.value);
    }

    pdfBlobUrl.value = "";
    pdfDownloadPercent.value = 0;
}

function downloadPdfWithProgress(url) {
    resetPdfBlobUrl();

    if (!url) return;

    downloadingPdf.value = true;
    pdfDownloadPercent.value = 0;

    const xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.responseType = "blob";

    xhr.onprogress = (event) => {
        if (event.lengthComputable) {
            pdfDownloadPercent.value = Math.round(
                (event.loaded / event.total) * 100
            );
        }
    };

    xhr.onload = () => {
        downloadingPdf.value = false;

        if (xhr.status >= 200 && xhr.status < 300) {
            pdfDownloadPercent.value = 100;
            pdfBlobUrl.value = URL.createObjectURL(xhr.response);
        } else {
            loadError.value = "Failed to download PDF.";
        }
    };

    xhr.onerror = () => {
        downloadingPdf.value = false;
        loadError.value = "Failed to download PDF.";
    };

    xhr.send();
}

const displayTitle = computed(() => book.value?.title || "PDF Preview");
const rawPdfUrl = computed(() => String(book.value?.file_url || "").trim());

const resolvedPdfUrl = computed(() => {
    const fileUrl = rawPdfUrl.value;
    if (!fileUrl) return null;

    if (/^https?:\/\//i.test(fileUrl) && /\/api\/pdf-file\//i.test(fileUrl)) {
        return fileUrl;
    }

    let relativePath = fileUrl
        .replace(/^https?:\/\/[^/]+/i, "")
        .replace(/^\/+/, "");

    if (relativePath.startsWith("storage/")) {
        relativePath = relativePath.replace(/^storage\//, "");
    }

    if (relativePath.startsWith("api/pdf-file/")) {
        relativePath = relativePath.replace(/^api\/pdf-file\//, "");
    }

    return `${API_BASE}/pdf-file/${relativePath}`;
});

const isTouchDevice = computed(() => {
    if (typeof window === "undefined") return false;

    return (
        window.matchMedia?.("(pointer: coarse)")?.matches ||
        "ontouchstart" in window ||
        navigator.maxTouchPoints > 0
    );
});

// const { pdf, pages: pdfPages } = usePDF(resolvedPdfUrl);

const percent = computed(() => {
    if (!totalPages.value) return 0;
    return Math.round((page.value / totalPages.value) * 10000) / 100;
});

const sourceParams = computed(() => ({
    item_id: itemId.value || null,
    doc_key: docKey.value || null,
}));

const currentPageAnnotations = computed(() =>
    annotations.value.filter((item) => Number(item.page) === Number(page.value))
);

const canPrev = computed(() => page.value > 1);
const canNext = computed(() => totalPages.value > 0 && page.value < totalPages.value);

function normalizeBook(row = {}) {
    return {
        id: Number(row.id || itemId.value || 0),
        title: String(row.title || "Untitled"),
        file_url: String(row.file_url || ""),
    };
}

function parseItemResponse(payload) {
    if (!payload) return {};
    if (payload.data && typeof payload.data === "object" && !Array.isArray(payload.data)) {
        return payload.data;
    }
    return payload;
}

function cleanObject(obj = {}) {
    return Object.fromEntries(
        Object.entries(obj).filter(([, value]) => value !== null && value !== undefined && value !== "")
    );
}

function readDark() {
    const value = localStorage.getItem(DARK_KEY);
    return value === "true" || value === "1";
}

function applyDark(value) {
    document.body.classList.toggle("dark-mode", !!value);
}

function syncDark() {
    isDark.value = readDark();
    applyDark(isDark.value);
}

function onStorage(event) {
    if (event.key === DARK_KEY) {
        syncDark();
    }
}

function onThemeChanged() {
    syncDark();
}

async function sha256Hex(str) {
    const encoded = new TextEncoder().encode(str || "");
    const buffer = await crypto.subtle.digest("SHA-256", encoded);

    return Array.from(new Uint8Array(buffer))
        .map((byte) => byte.toString(16).padStart(2, "0"))
        .join("");
}

function debounceSaveProgress() {
    clearTimeout(saveProgressTimer);
    saveProgressTimer = setTimeout(() => {
        void saveProgress();
    }, SAVE_PROGRESS_DELAY);
}

async function loadBookDetail() {
    if (!itemId.value) {
        book.value = {};
        loadError.value = "Invalid book ID.";
        return;
    }

    loadingBook.value = true;
    loadError.value = "";

    try {
        const res = await apiShowItem(itemId.value);
        book.value = normalizeBook(parseItemResponse(res?.data));
    } catch (error) {
        console.error("Failed to load book detail:", error);
        book.value = {};
        loadError.value = "Failed to load book detail.";
    } finally {
        loadingBook.value = false;
    }
}

async function loadFavoriteStatus() {
    if (!itemId.value) {
        isFavorite.value = false;
        return;
    }

    try {
        const res = await apiCheckFavorite(itemId.value);
        isFavorite.value = Boolean(
            res?.data?.is_favorite ??
            res?.data?.favorite ??
            res?.data?.exists ??
            false
        );
    } catch (error) {
        console.error("Failed to load favorite:", error);
        isFavorite.value = false;
    }
}

async function toggleFavorite() {
    if (!itemId.value || loadingFavorite.value) return;

    loadingFavorite.value = true;

    try {
        if (isFavorite.value) {
            await apiRemoveFavorite(itemId.value);
            isFavorite.value = false;
        } else {
            await apiAddFavorite(itemId.value);
            isFavorite.value = true;
        }
    } catch (error) {
        console.error("Failed to toggle favorite:", error);
    } finally {
        loadingFavorite.value = false;
    }
}

// async function loadProgress() {
//     const params = cleanObject(sourceParams.value);
//     if (!params.item_id) return;
//
//     try {
//         const res = await axios.get(`${API_BASE}/pdf-progress`, { params });
//         const data = res?.data || {};
//
//         if (data.last_page != null) {
//             page.value = Math.max(1, Number(data.last_page));
//         }
//
//         if (data.total_pages != null) {
//             totalPages.value = Math.max(0, Number(data.total_pages));
//         }
//     } catch (error) {
//         console.warn("Load progress failed:", error?.response?.data || error?.message);
//     }
// }
async function loadProgress() {
    const itemId = Number(sourceParams.value?.item_id);

    if (!itemId || itemId <= 0) return;

    try {
        const res = await axios.get(`${API_BASE}/pdf-progress`, {
            params: {
                item_id: itemId,
            },
            headers: {
                Accept: "application/json",
                "Cache-Control": "no-cache",
                Pragma: "no-cache",
            },
        });

        const data = res?.data || {};

        const lastPage = Number(data.last_page ?? 1);
        const total = Number(data.total_pages ?? 0);

        page.value = Number.isFinite(lastPage) && lastPage > 0 ? lastPage : 1;
        totalPages.value = Number.isFinite(total) && total > 0 ? total : 0;

        console.log("RESUME PAGE:", page.value);
    } catch (error) {
        console.warn(
            "Load progress failed:",
            error?.response?.data || error?.message
        );

        page.value = 1;
    }
}

async function saveProgress() {
    if (!totalPages.value) return;

    const payload = cleanObject({
        item_id: sourceParams.value.item_id,
        doc_key: sourceParams.value.doc_key,
        last_page: page.value,
        total_pages: totalPages.value,
    });

    if (!payload.item_id && !payload.doc_key) return;

    try {
        await axios.post(`${API_BASE}/pdf-progress`, payload);
    } catch (error) {
        console.warn("Save progress failed:", error?.response?.data || error?.message);
    }
}

function normalizeRects(raw) {
    if (Array.isArray(raw)) return raw;

    if (typeof raw === "string") {
        try {
            const parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed : [];
        } catch {
            return [];
        }
    }

    return [];
}

function normalizeAnnotation(row = {}) {
    return {
        id: row.id,
        page: Number(row.page || 1),
        selected_text: String(row.selected_text || ""),
        comment: String(row.comment || ""),
        highlight_color: String(row.highlight_color || DEFAULT_HIGHLIGHT),
        created_at: row.created_at || null,
        rects: normalizeRects(row.rects || row.position_json || row.rect_json),
    };
}

async function loadAnnotations() {
    const params = cleanObject(sourceParams.value);

    if (!params.item_id && !params.doc_key) {
        annotations.value = [];
        return;
    }

    loadingAnnotations.value = true;

    try {
        const res = await apiGetPdfCommentHighlights(params);
        const rows = Array.isArray(res?.data?.data)
            ? res.data.data
            : Array.isArray(res?.data)
                ? res.data
                : [];

        annotations.value = rows.map(normalizeAnnotation);
    } catch (error) {
        console.error("Failed to load annotations:", error);
        annotations.value = [];
    } finally {
        loadingAnnotations.value = false;
    }
}

function selectAnnotation(id) {
    activeAnnotationId.value = activeAnnotationId.value === id ? null : id;
}

async function removeAnnotation(id) {
    if (!id || deletingId.value) return;

    deletingId.value = id;

    try {
        await apiDeletePdfCommentHighlight(id);
        annotations.value = annotations.value.filter((item) => item.id !== id);

        if (activeAnnotationId.value === id) {
            activeAnnotationId.value = null;
        }
    } catch (error) {
        console.error("Failed to delete annotation:", error);
    } finally {
        deletingId.value = null;
    }
}

function formatDate(value) {
    if (!value) return "-";

    try {
        return new Date(value).toLocaleString();
    } catch {
        return value;
    }
}

function prevPage() {
    if (canPrev.value) {
        page.value -= 1;
    }
}

function nextPage() {
    if (canNext.value) {
        page.value += 1;
    }
}

function zoomIn() {
    scale.value = Math.min(MAX_SCALE, +(scale.value + 0.25).toFixed(2));
}

function zoomOut() {
    scale.value = Math.max(MIN_SCALE, +(scale.value - 0.25).toFixed(2));
}

function rotateRight() {
    rotation.value = (rotation.value + 90) % 360;
}

function rotateLeft() {
    rotation.value = (rotation.value + 270) % 360;
}

function rotateReset() {
    rotation.value = 0;
}

function setMode(mode) {
    annotMode.value = annotMode.value === mode ? "none" : mode;
    closeAnnotationPopup();
    clearSelection();
}

function clearSelection() {
    const selection = window.getSelection?.();
    if (selection) {
        selection.removeAllRanges();
    }
}

function closeAnnotationPopup() {
    activeAnnotationId.value = null;
}

function selectionBelongsToPdf() {
    const selection = window.getSelection?.();
    const host = pdfPageRef.value;

    if (!selection || !host || selection.rangeCount === 0 || selection.isCollapsed) {
        return false;
    }

    const range = selection.getRangeAt(0);
    const node =
        range.commonAncestorContainer.nodeType === 1
            ? range.commonAncestorContainer
            : range.commonAncestorContainer.parentNode;

    return !!node && host.contains(node);
}

function getSelectionText() {
    const selection = window.getSelection?.();
    return String(selection?.toString() || "").trim();
}

function getSelectionRectsNormalized() {
    const selection = window.getSelection?.();
    const host = pdfPageRef.value;

    if (!selection || !host || selection.rangeCount === 0) {
        return [];
    }

    const range = selection.getRangeAt(0);
    const hostRect = host.getBoundingClientRect();
    const rects = Array.from(range.getClientRects());

    return rects
        .map((rect) => {
            if (
                rect.width <= 0 ||
                rect.height <= 0 ||
                hostRect.width <= 0 ||
                hostRect.height <= 0
            ) {
                return null;
            }

            const left = Math.max(0, rect.left - hostRect.left);
            const top = Math.max(0, rect.top - hostRect.top);
            const width = Math.min(rect.width, hostRect.width);
            const height = Math.min(rect.height, hostRect.height);

            return {
                x: left / hostRect.width,
                y: top / hostRect.height,
                w: width / hostRect.width,
                h: height / hostRect.height,
            };
        })
        .filter(Boolean);
}

function scheduleSelectionSave(delay = SELECTION_DELAY) {
    if (annotMode.value === "none" || rotation.value !== 0) return;

    clearTimeout(selectionTimer);
    selectionTimer = setTimeout(() => {
        void saveSelectionAsAnnotation();
    }, delay);
}

async function saveSelectionAsAnnotation() {
    if (savingAnnotation.value || annotMode.value === "none") return;
    if (!selectionBelongsToPdf()) return;

    const text = getSelectionText();
    if (!text) {
        clearSelection();
        return;
    }

    const rects = getSelectionRectsNormalized();
    if (!rects.length) {
        clearSelection();
        return;
    }

    const basePayload = {
        item_id: sourceParams.value.item_id,
        doc_key: sourceParams.value.doc_key,
        page: page.value,
        selected_text: text,
        rects,
    };

    if (annotMode.value === "comment") {
        pendingPayload.value = basePayload;
        commentInput.value = "";
        showCommentModal.value = true;
        return;
    }

    await submitAnnotation({
        ...basePayload,
        comment: null,
        highlight_color: DEFAULT_HIGHLIGHT,
    });
}

async function submitComment() {
    if (!pendingPayload.value) return;

    await submitAnnotation({
        ...pendingPayload.value,
        comment: commentInput.value.trim() || null,
        highlight_color: DEFAULT_COMMENT_HIGHLIGHT,
    });

    closeModal();
}

async function submitAnnotation(payload) {
    const cleanedPayload = cleanObject(payload);
    savingAnnotation.value = true;

    try {
        const res = await apiCreatePdfCommentHighlight(cleanedPayload);
        const saved = normalizeAnnotation(res?.data?.data || res?.data || cleanedPayload);

        if (!saved.id) {
            await loadAnnotations();
        } else {
            annotations.value = [saved, ...annotations.value];
            activeAnnotationId.value = saved.id;
        }
    } catch (error) {
        console.error("Save annotation failed:", error);
        await loadAnnotations();
    } finally {
        savingAnnotation.value = false;
        clearSelection();
    }
}

function closeModal() {
    showCommentModal.value = false;
    commentInput.value = "";
    pendingPayload.value = null;
    clearSelection();
}

function handleSelectionEnd() {
    scheduleSelectionSave();
}

function handleSelectionChange() {
    if (!isTouchDevice.value || annotMode.value === "none" || showCommentModal.value) return;

    clearTimeout(selectionChangeTimer);
    selectionChangeTimer = setTimeout(() => {
        const text = getSelectionText();
        if (text && selectionBelongsToPdf()) {
            scheduleSelectionSave(220);
        }
    }, 120);
}

function getHighlightBackground(annotation) {
    const color = annotation.highlight_color || DEFAULT_HIGHLIGHT;

    if (color.startsWith("rgba")) return color;
    if (color.startsWith("rgb")) return color;
    if (color.startsWith("#")) return `${color}88`;

    return "rgba(255, 235, 59, 0.45)";
}

function handleBeforeUnload() {
    void saveProgress();
}

function resetReaderState() {
    page.value = 1;
    totalPages.value = 0;
    scale.value = INITIAL_SCALE;
    rotation.value = 0;
    annotations.value = [];
    activeAnnotationId.value = null;
    showCommentModal.value = false;
    commentInput.value = "";
    pendingPayload.value = null;
}

async function initializePage() {
    const currentToken = ++initToken;
    resetReaderState();

    await loadBookDetail();
    if (currentToken !== initToken) return;

    docKey.value = await sha256Hex(rawPdfUrl.value || "");
    if (currentToken !== initToken) return;

    await Promise.all([
        loadFavoriteStatus(),
        loadAnnotations(),
    ]);

    if (currentToken !== initToken) return;
    await loadProgress();
}

watch(pdfPages, (value) => {
    if (!value) return;

    totalPages.value = Number(value) || 0;

    if (totalPages.value > 0 && page.value > totalPages.value) {
        page.value = totalPages.value;
    }

    if (page.value < 1) {
        page.value = 1;
    }

    debounceSaveProgress();
});

watch(page, async (value) => {
    if (value < 1) {
        page.value = 1;
        return;
    }

    if (totalPages.value && value > totalPages.value) {
        page.value = totalPages.value;
        return;
    }

    if (totalPages.value) {
        debounceSaveProgress();
    }

    activeAnnotationId.value = null;
    await nextTick();
    clearSelection();
});

watch(
    () => props.id,
    async () => {
        await initializePage();
    }
);

watch(
    () => rawPdfUrl.value,
    async (newUrl, oldUrl) => {
        if (newUrl === oldUrl) return;

        docKey.value = await sha256Hex(newUrl || "");
        await Promise.all([loadAnnotations(), loadProgress()]);
    }
);

watch(
    () => resolvedPdfUrl.value,
    (url) => {
        downloadPdfWithProgress(url);
    },
    { immediate: true }
);
onBeforeUnmount(() => {
    resetPdfBlobUrl();
});

onMounted(async () => {
    syncDark();

    window.addEventListener("storage", onStorage);
    window.addEventListener("theme-changed", onThemeChanged);
    window.addEventListener("beforeunload", handleBeforeUnload);
    document.addEventListener("selectionchange", handleSelectionChange);

    await initializePage();
});

onBeforeUnmount(() => {
    window.removeEventListener("storage", onStorage);
    window.removeEventListener("theme-changed", onThemeChanged);
    window.removeEventListener("beforeunload", handleBeforeUnload);
    document.removeEventListener("selectionchange", handleSelectionChange);

    clearTimeout(saveProgressTimer);
    clearTimeout(selectionTimer);
    clearTimeout(selectionChangeTimer);

    void saveProgress();
});
</script>

<style scoped>
.pdf-reader-page {
    min-height: 100vh;
    background: var(--reader-page-bg, #f4f6f9);
}

.reader-toolbar-section {
    padding-bottom: 0.55rem;
}

.reader-toolbar-inline {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: nowrap;
    overflow-x: auto;
    padding: 8px 10px;
}

.reader-touch-hint {
    margin-top: 8px;
    padding: 8px 12px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    color: var(--reader-text, #334155);
    background: var(--reader-soft-bg, #f8fafc);
    border: 1px solid var(--reader-border, #e5e7eb);
}

.reader-title {
    max-width: 320px;
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--reader-heading, #111827);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.toolbar-inline-group {
    display: flex;
    align-items: center;
    gap: 8px;
}

.toolbar-back-btn {
    white-space: nowrap;
}

.pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 8px;
    font-size: 13px;
    color: var(--reader-text, #334155);
    background: var(--reader-soft-bg, #f8fafc);
    border: 1px solid var(--reader-border, #e5e7eb);
    border-radius: 999px;
    white-space: nowrap;
}

.value {
    font-size: 14px;
    font-weight: 600;
    color: var(--reader-heading, #111827);
    padding: 0 6px;
    white-space: nowrap;
}

.reader-toolbar-inline button {
    height: 30px;
    min-width: 30px;
    border-radius: 8px;
    border: 1px solid var(--reader-border, #e5e7eb);
    background: var(--reader-card-bg, #fff);
    color: var(--reader-text, #334155);
    font-size: 13px;
    transition: all 0.2s ease;
}

.reader-toolbar-inline button:hover:not(:disabled) {
    background: var(--reader-soft-bg, #f1f5f9);
}

.reader-toolbar-inline button:disabled {
    opacity: 0.55;
    cursor: not-allowed;
}

.annotation-switch {
    display: flex;
    gap: 4px;
    padding: 2px;
    background: var(--reader-soft-bg, #f1f5f9);
    border: 1px solid var(--reader-border, #e5e7eb);
    border-radius: 10px;
}

.annotation-switch button {
    border: none;
    background: transparent;
}

.annotation-switch button.active {
    background: var(--reader-card-bg, #fff);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.08);
}

.btn-fav {
    background: #fee2e2 !important;
    border: 1px solid #fecaca !important;
    color: #b91c1c !important;
}

.btn-fav.active {
    background: #dc2626 !important;
    border-color: #dc2626 !important;
    color: #fff !important;
}

.reader-card {
    border-radius: 14px;
    overflow: hidden;
    background: var(--reader-card-bg, #ffffff);
    border: 1px solid var(--reader-border, #e5e7eb);
    box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
}

.reader-alert-wrap {
    padding: 0.8rem;
}

.reader-layout {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 280px;
    min-height: calc(100vh - 200px);
}

.pdf-viewer {
    background: var(--reader-viewer-bg, #eef2f7);
    min-height: 100vh;
    max-height: calc(100vh - 200px);
    overflow: auto;
    padding: 0.9rem;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    border-right: 1px solid var(--reader-border, #e9ecef);
    -webkit-overflow-scrolling: touch;
    touch-action: pan-y pan-x;
}

.pdf-page-wrap {
    position: relative;
    display: inline-block;
    padding: 0.12rem;
    border-radius: 12px;
}

.watermark-layer {
    position: absolute;
    inset: 0;
    z-index: 45;

    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 50px;

    padding: 30px;
    overflow: hidden;

    pointer-events: none;
    user-select: none;
}

.watermark-item {
    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 28px;
    font-weight: 900;
    color: rgba(120, 120, 120, 0.16);

    transform: rotate(-30deg);
    white-space: nowrap;
}

.annotation-overlay {
    position: absolute;
    inset: 0;
    z-index: 50;
    pointer-events: none;
}

.watermark-layer {
    position: fixed;
    inset: 0;
    z-index: 1;

    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 60px;

    padding: 20px;

    pointer-events: none;
    overflow: hidden;
}

.watermark-item {
    font-size: 26px;
    font-weight: 800;

    color: rgba(120,120,120,0.10);

    transform: rotate(-30deg);

    white-space: nowrap;

    user-select: none;
}

.pdf-viewer--dark .watermark-item {
    color: rgba(255,255,255,0.06);
}








.pdf-page-wrap {
    position: relative;
    display: inline-block;
    padding: 0.12rem;
    border-radius: 12px;
}

.annotation-overlay {
    position: absolute;
    inset: 0;
    z-index: 50;
    pointer-events: none;
}

.annotation-rect {
    position: absolute;
    border-radius: 4px;
    box-sizing: border-box;
    pointer-events: auto;
    cursor: pointer;
}

.annotation-rect.is-comment {
    border: 1px solid rgba(13, 202, 240, 0.5);
}

.annotation-rect.is-active {
    outline: 2px solid #343a40;
    outline-offset: 1px;
}

.comment-badge {
    position: absolute;
    top: -10px;
    right: -8px;
    font-size: 12px;
    line-height: 1;
    background: #fff;
    border-radius: 999px;
    padding: 3px 5px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.16);
    pointer-events: none;
}

.comment-popup {
    position: absolute;
    top: calc(100% + 8px);
    left: 0;
    min-width: 180px;
    max-width: 260px;
    padding: 0.55rem 0.65rem;
    border-radius: 10px;
    background: rgba(17, 24, 39, 0.96);
    color: #fff;
    box-shadow: 0 10px 28px rgba(0, 0, 0, 0.22);
    opacity: 0;
    visibility: hidden;
    transform: translateY(4px);
    transition: all 0.16s ease;
    pointer-events: none;
    z-index: 120;
}

.annotation-rect.is-comment:hover .comment-popup,
.annotation-rect.is-comment.is-active .comment-popup,
.comment-popup--show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.comment-popup__label {
    font-size: 0.62rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: #93c5fd;
    margin-bottom: 0.28rem;
}

.comment-popup__text {
    font-size: 0.74rem;
    line-height: 1.4;
    font-weight: 600;
    margin-bottom: 0.38rem;
    word-break: break-word;
}

.comment-popup__comment {
    font-size: 0.72rem;
    line-height: 1.4;
    color: #e5e7eb;
    word-break: break-word;
    padding-top: 0.38rem;
    border-top: 1px solid rgba(255, 255, 255, 0.12);
}

.annotation-sidebar {
    background: var(--reader-card-bg, #ffffff);
    padding: 0.8rem;
    min-height: 72vh;
    max-height: calc(100vh - 200px);
    overflow: auto;
}

.sidebar-header {
    padding-bottom: 0.75rem;
    margin-bottom: 0.8rem;
    border-bottom: 1px solid var(--reader-border, #e9ecef);
}

.sidebar-title {
    font-size: 0.95rem;
    font-weight: 800;
    color: var(--reader-heading, #1f2937);
}

.sidebar-subtitle {
    color: var(--reader-muted, #6b7280);
    font-size: 0.78rem;
}

.empty-annotations {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 220px;
    text-align: center;
    border: 1px dashed var(--reader-border, #d7dde5);
    border-radius: 14px;
    background: var(--reader-soft-bg, #f8fafc);
    padding: 1rem 0.8rem;
}

.empty-annotations__icon {
    width: 56px;
    height: 56px;
    display: grid;
    place-items: center;
    border-radius: 50%;
    margin-bottom: 0.7rem;
    font-size: 1.2rem;
    background: rgba(13, 110, 253, 0.08);
    color: #0d6efd;
}

.empty-annotations__title {
    font-size: 0.92rem;
    font-weight: 800;
    color: var(--reader-heading, #1f2937);
    margin-bottom: 0.25rem;
}

.empty-annotations__text {
    color: var(--reader-muted, #6b7280);
    font-size: 0.8rem;
}

.annotation-list {
    display: flex;
    flex-direction: column;
    gap: 0.65rem;
}

.annotation-item {
    border: 1px solid var(--reader-border, #e9ecef);
    border-radius: 12px;
    padding: 0.72rem;
    background: var(--reader-soft-bg, #fafbfc);
    cursor: pointer;
    transition: all 0.18s ease;
}

.annotation-item:hover {
    transform: translateY(-1px);
    box-shadow: 0 8px 18px rgba(15, 23, 42, 0.05);
}

.annotation-item.active {
    border-color: #0d6efd;
    background: rgba(13, 110, 253, 0.08);
}

.annotation-item__top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 0.55rem;
    margin-bottom: 0.55rem;
    flex-wrap: wrap;
}

.annotation-type-badge {
    display: inline-flex;
    align-items: center;
    border-radius: 999px;
    padding: 0.28rem 0.58rem;
    font-size: 0.68rem;
    font-weight: 800;
    text-transform: capitalize;
}

.annotation-type-badge--highlight {
    background: rgba(255, 193, 7, 0.14);
    color: #9a6a00;
}

.annotation-type-badge--comment {
    background: rgba(13, 202, 240, 0.14);
    color: #0b7285;
}

.btn-delete-annotation {
    border-radius: 8px;
    padding: 0.28rem 0.5rem;
    font-size: 0.68rem;
    font-weight: 700;
    background: rgba(220, 53, 69, 0.08);
    color: #dc3545;
    border: 1px solid rgba(220, 53, 69, 0.18);
}

.btn-delete-annotation:hover:not(:disabled) {
    background: #dc3545;
    border-color: #dc3545;
    color: #fff;
}

.annotation-item__text {
    font-size: 0.82rem;
    color: var(--reader-heading, #212529);
    line-height: 1.5;
    margin-bottom: 0.55rem;
    word-break: break-word;
    font-weight: 500;
}

.annotation-item__comment {
    font-size: 0.77rem;
    color: var(--reader-text, #495057);
    background: var(--reader-card-bg, #ffffff);
    border-radius: 10px;
    padding: 0.58rem 0.65rem;
    border: 1px solid var(--reader-border, #e9ecef);
    margin-bottom: 0.55rem;
    word-break: break-word;
}

.annotation-item__date {
    font-size: 0.7rem;
    color: var(--reader-muted, #6c757d);
}

.pdf-viewer :deep(canvas) {
    display: block;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 12px 28px rgba(15, 23, 42, 0.12);
}

.pdf-viewer :deep(.textLayer) {
    user-select: text;
    -webkit-user-select: text;
    cursor: text;
    z-index: 20;
    -webkit-touch-callout: text;
}

.pdf-viewer :deep(.textLayer span),
.pdf-viewer :deep(.textLayer br) {
    user-select: text;
    -webkit-user-select: text;
}

.pdf-viewer :deep(.annotationLayer) {
    z-index: 10;
}

:global(body.dark-mode) .pdf-reader-page,
:global(.dark-mode) .pdf-reader-page {
    --reader-page-bg: #0f172a;
    --reader-card-bg: #111827;
    --reader-soft-bg: #182235;
    --reader-viewer-bg: #16202a;
    --reader-border: rgba(255, 255, 255, 0.08);
    --reader-heading: #f8fafc;
    --reader-text: #dbe4f0;
    --reader-muted: #94a3b8;
}

:global(body.dark-mode) .comment-badge,
:global(.dark-mode) .comment-badge {
    background: #1f2937;
    color: #fff;
}

:global(body.dark-mode) .comment-popup,
:global(.dark-mode) .comment-popup {
    background: rgba(15, 23, 42, 0.96);
    color: #f8fafc;
}

.pdf-viewer--dark :deep(canvas) {
    filter: invert(1) hue-rotate(180deg) contrast(0.92) brightness(0.9);
    background: #0f172a;
}

.pdf-viewer--dark :deep(.textLayer) {
    filter: invert(1) hue-rotate(180deg);
}

.pdf-viewer--dark :deep(.annotationLayer) {
    filter: invert(1) hue-rotate(180deg);
}

.pdf-viewer--dark .annotation-overlay {
    filter: none !important;
}

.pdf-viewer--dark .comment-badge {
    filter: invert(1) hue-rotate(180deg);
}

:root {
    --modal-overlay-bg: rgba(15, 23, 42, 0.45);
    --modal-bg: #ffffff;
    --modal-border: #e5e7eb;
    --modal-text: #111827;
    --modal-shadow: 0 20px 50px rgba(15, 23, 42, 0.18);
    --modal-btn-secondary-bg: #f8fafc;
    --modal-btn-secondary-border: #dbe2ea;
    --modal-btn-secondary-text: #334155;
    --modal-btn-secondary-hover: #eef2f7;
    --modal-btn-primary-bg: #2563eb;
    --modal-btn-primary-border: #2563eb;
    --modal-btn-primary-text: #ffffff;
    --modal-btn-primary-hover: #1d4ed8;
}

body.dark-mode,
html.dark-mode body,
[data-theme="dark"] {
    --modal-overlay-bg: rgba(2, 6, 23, 0.72);
    --modal-bg: #0f172a;
    --modal-border: rgba(255, 255, 255, 0.12);
    --modal-text: #f8fafc;
    --modal-shadow: 0 24px 60px rgba(0, 0, 0, 0.45);
    --modal-btn-secondary-bg: rgba(255, 255, 255, 0.08);
    --modal-btn-secondary-border: rgba(255, 255, 255, 0.14);
    --modal-btn-secondary-text: #e2e8f0;
    --modal-btn-secondary-hover: rgba(255, 255, 255, 0.14);
    --modal-btn-primary-bg: #3b82f6;
    --modal-btn-primary-border: #3b82f6;
    --modal-btn-primary-text: #ffffff;
    --modal-btn-primary-hover: #2563eb;
}

.modal-overlay {
    position: fixed;
    inset: 0;
    background: var(--modal-overlay-bg);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    padding: 1rem;
    backdrop-filter: blur(4px);
}

.modal-box {
    width: 100%;
    max-width: 400px;
    background: var(--modal-bg);
    color: var(--modal-text);
    border: 1px solid var(--modal-border);
    border-radius: 16px;
    padding: 18px;
    box-shadow: var(--modal-shadow);
}

.modal-footer-minimal {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 16px;
}

.btn-modal {
    height: 36px !important;
    min-width: 88px !important;
    padding: 0 14px !important;
    border-radius: 10px !important;
    border: 1px solid transparent !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    transition: all 0.2s ease;
}

.btn-modal:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-modal--secondary {
    background: var(--modal-btn-secondary-bg) !important;
    border-color: var(--modal-btn-secondary-border) !important;
    color: var(--modal-btn-secondary-text) !important;
}

.btn-modal--secondary:hover:not(:disabled) {
    background: var(--modal-btn-secondary-hover) !important;
}

.btn-modal--primary {
    background: var(--modal-btn-primary-bg) !important;
    border-color: var(--modal-btn-primary-border) !important;
    color: var(--modal-btn-primary-text) !important;
}

.btn-modal--primary:hover:not(:disabled) {
    background: var(--modal-btn-primary-hover) !important;
    border-color: var(--modal-btn-primary-hover) !important;
}

@media (max-width: 1199.98px) {
    .reader-layout {
        grid-template-columns: minmax(0, 1fr) 250px;
    }
}

@media (max-width: 991.98px) {
    .reader-layout {
        grid-template-columns: 1fr;
    }

    .pdf-viewer {
        border-right: 0;
        border-bottom: 1px solid var(--reader-border, #e9ecef);
        max-height: none;
        min-height: 58vh;
    }

    .annotation-sidebar {
        min-height: auto;
        max-height: none;
    }
}

@media (max-width: 767.98px) {
    .reader-toolbar-inline {
        gap: 8px;
        padding: 8px;
    }

    .reader-title {
        max-width: 220px;
        font-size: 0.88rem;
    }

    .pill {
        font-size: 12px;
    }

    .value {
        font-size: 13px;
    }

    .pdf-viewer {
        padding: 0.7rem;
    }

    .annotation-sidebar {
        padding: 0.7rem;
    }

    .comment-popup {
        min-width: 160px;
        max-width: 220px;
    }
}

@media (max-width: 576px) {
    .modal-box {
        max-width: 100%;
        padding: 16px;
        border-radius: 14px;
    }

    .modal-footer-minimal {
        flex-direction: column-reverse;
    }

    .btn-modal {
        width: 100%;
    }
}

.reader-pdf-loading {
    min-height: calc(100vh - 200px);
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--reader-viewer-bg, #eef2f7);
    padding: 2rem;
}

.reader-pdf-loading__box {
    width: 100%;
    max-width: 320px;
    padding: 1.5rem;
    text-align: center;
    border-radius: 16px;
    background: var(--reader-card-bg, #ffffff);
    border: 1px solid var(--reader-border, #e5e7eb);
    box-shadow: 0 12px 28px rgba(15, 23, 42, 0.08);
}

.reader-pdf-loading__box i {
    font-size: 34px;
    color: #2563eb;
    margin-bottom: 14px;
}

.reader-pdf-loading__title {
    font-size: 1rem;
    font-weight: 800;
    color: var(--reader-heading, #111827);
    margin-bottom: 6px;
}

.reader-pdf-loading__text {
    font-size: 0.82rem;
    color: var(--reader-muted, #6b7280);
}

.reader-pdf-loading__bar {
    width: 100%;
    height: 10px;
    overflow: hidden;
    border-radius: 999px;
    background: #e5e7eb;
    margin: 14px 0 10px;
}

.reader-pdf-loading__bar-fill {
    height: 100%;
    width: 0;
    border-radius: 999px;
    background: #2563eb;
    transition: width 0.2s ease;
}

</style>
