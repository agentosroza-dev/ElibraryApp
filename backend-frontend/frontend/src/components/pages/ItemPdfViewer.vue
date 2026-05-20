<template>
    <div class="content-wrapper pdf-reader-page">
        <section class="content-header reader-toolbar-section pt-0">
            <div class="container-fluid">
                <div class="reader-topbar">
                    <div class="book-tags-wrap">
                        <button
                            type="button"
                            class="btn"
                            :class="isFavorite ? 'btn-danger' : 'btn-outline-danger'"
                            :disabled="loadingFavorite"
                            @click="toggleFavorite"
                        >
                            {{ loadingFavorite ? "Please wait..." : isFavorite ? "Favorited" : "Favorite" }}
                        </button>

                        <div class="book-tags-block">
                            <h5 class="book-tags-title mb-2">Tags</h5>

                            <div v-if="loadingBookTags" class="text-muted">Loading tags...</div>

                            <div v-else-if="bookTags.length" class="d-flex flex-wrap">
                                <span
                                    v-for="tag in bookTags"
                                    :key="tag.id"
                                    class="badge badge-tag mr-1 mb-1"
                                >
                                    {{ tag.name }}
                                </span>
                            </div>

                            <div v-else class="text-muted">No tags found</div>
                        </div>
                    </div>

                    <div class="reader-stats">
                        <div class="book-meta-item">
                            <span class="book-meta-label">Total Read</span>
                            <span class="book-meta-value">{{ views_count }}</span>
                        </div>

                        <div class="book-meta-item">
                            <span class="book-meta-label">My Read</span>
                            <span class="book-meta-value">{{ my_views_count }}</span>
                        </div>

                        <div class="book-meta-item">
                            <span class="book-meta-label">User Read</span>
                            <span class="book-meta-value">{{ unique_users_count }}</span>
                        </div>

                        <div class="book-meta-item">
                            <span class="book-meta-label">Favorite</span>
                            <span
                                class="book-meta-value"
                                :class="isFavorite ? 'text-danger font-weight-bold' : 'text-muted'"
                            >
                                {{ isFavorite ? "Yes" : "No" }}
                            </span>
                        </div>

                        <div class="book-meta-item">
                            <span class="book-meta-label">Annotations</span>
                            <span class="book-meta-value">{{ currentPageAnnotations.length }}</span>
                        </div>
                    </div>
                </div>

                <div class="reader-toolbar-card">
                    <div class="reader-toolbar-card__top">
                        <router-link
                            :to="{ name: 'items.view', params: { id: props.itemId } }"
                            class="btn btn-secondary btn-sm"
                        >
                            <i class="fas fa-arrow-left mr-1"></i>
                            Back
                        </router-link>

                        <div class="reader-progress">
                            <h2 class="reader-book-title mb-1">{{ title }}</h2>

                            <div class="reader-progress__meta">
                                <span class="reader-meta-pill">
                                    <i class="far fa-file-alt mr-1"></i>
                                    Page {{ page }} / {{ pages || "..." }}
                                </span>

                                <span class="reader-meta-pill">
                                    <i class="fas fa-chart-line mr-1"></i>
                                    {{ percent }}%
                                </span>

                                <span class="reader-meta-pill">
                                    <i class="fas fa-search-plus mr-1"></i>
                                    {{ scale.toFixed(2) }}x
                                </span>

                                <span class="reader-meta-pill">
                                    <i class="fas fa-sync-alt mr-1"></i>
                                    {{ rotation }}°
                                </span>
                            </div>
                        </div>

                        <div class="reader-toolbar-groups">
                            <div class="toolbar-group">
                                <button class="btn btn-toolbar" :disabled="page <= 1" @click="prevPage">
                                    <i class="fas fa-chevron-left mr-1"></i>
                                    Prev
                                </button>

                                <button class="btn btn-toolbar" :disabled="!pages || page >= pages" @click="nextPage">
                                    Next
                                    <i class="fas fa-chevron-right ml-1"></i>
                                </button>
                            </div>

                            <div class="toolbar-group">
                                <button class="btn btn-toolbar" @click="zoomOut">
                                    <i class="fas fa-search-minus"></i>
                                </button>

                                <button class="btn btn-toolbar btn-toolbar-static">
                                    {{ scale.toFixed(2) }}x
                                </button>

                                <button class="btn btn-toolbar" @click="zoomIn">
                                    <i class="fas fa-search-plus"></i>
                                </button>
                            </div>

                            <div class="toolbar-group">
                                <button class="btn btn-toolbar" @click="zoomReset">Reset Zoom</button>
                                <button class="btn btn-toolbar" @click="fitWidth">Fit</button>
                            </div>

                            <div class="toolbar-group">
                                <button class="btn btn-toolbar" @click="rotateLeft">
                                    <i class="fas fa-undo"></i>
                                </button>

                                <button class="btn btn-toolbar" @click="rotateReset">Reset</button>

                                <button class="btn btn-toolbar" @click="rotateRight">
                                    <i class="fas fa-redo"></i>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="reader-toolbar-card__bottom">
                        <div class="annotation-actions">
                            <button
                                class="btn btn-annot"
                                :class="annotMode === 'highlight' ? 'btn-annot--highlight-active' : 'btn-annot--highlight'"
                                @click="setMode('highlight')"
                            >
                                <i class="fas fa-highlighter mr-2"></i>
                                Highlight
                            </button>

                            <button
                                class="btn btn-annot"
                                :class="annotMode === 'comment' ? 'btn-annot--comment-active' : 'btn-annot--comment'"
                                @click="setMode('comment')"
                            >
                                <i class="fas fa-comment-dots mr-2"></i>
                                Comment
                            </button>

                            <button class="btn btn-annot btn-annot--clear" @click="setMode('none')">
                                <i class="fas fa-times mr-2"></i>
                                Clear Mode
                            </button>
                        </div>

                        <div class="annotation-help-box">
                            <template v-if="annotMode === 'none'">
                                <i class="fas fa-mouse-pointer mr-2"></i>
                                Mode: <b>None</b>
                            </template>

                            <template v-else-if="annotMode === 'highlight'">
                                <i class="fas fa-highlighter mr-2"></i>
                                Mode: <b>Select text to save highlight</b>
                            </template>

                            <template v-else>
                                <i class="fas fa-comment-dots mr-2"></i>
                                Mode: <b>Select text to save comment + highlight</b>
                            </template>
                        </div>


                        <div v-if="showCommentModal" class="modal-overlay">
                            <div class="modal-box">
                                <h5>Add Comment</h5>

                                <textarea
                                    v-model="commentInput"
                                    class="form-control mb-3"
                                    rows="3"
                                    placeholder="Enter comment..."
                                />

                                <div class="text-right">
                                    <button class="btn btn-sm btn-secondary mr-2" @click="closeModal">
                                        Cancel
                                    </button>
                                    <button
                                        class="btn btn-sm btn-primary"
                                        :disabled="savingAnnotation"
                                        @click="submitComment"
                                    >
                                        {{ savingAnnotation ? "Saving..." : "Save" }}
                                    </button>
                                </div>
                            </div>
                        </div>






                    </div>
                </div>
            </div>
        </section>

        <section class="content pb-4">
            <div class="container-fluid">
                <div class="card reader-card border-0 shadow-sm">
                    <div class="card-body p-0">
                        <div v-if="!resolvedPdfUrl" class="reader-alert-wrap">
                            <div class="alert alert-warning m-0">Missing PDF URL.</div>
                        </div>

                        <div v-else class="reader-layout">
                            <div class="pdf-viewer" :class="{ 'pdf-viewer--dark': isDark }">
                                <div
                                    ref="pdfPageRef"
                                    class="pdf-page-wrap"
                                    @mouseup="handlePdfMouseUp"
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
                                                    >
                                                        <div class="comment-popup__label">
                                                            Selected Text
                                                        </div>

                                                        <div class="comment-popup__text">
                                                            “{{ annotation.selected_text || '-' }}”
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
                                                :class="annotation.comment
                                                    ? 'annotation-type-badge--comment'
                                                    : 'annotation-type-badge--highlight'"
                                            >
                                                <i
                                                    class="fas mr-1"
                                                    :class="annotation.comment ? 'fa-comment-dots' : 'fa-highlighter'"
                                                ></i>
                                                {{ annotation.comment ? "comment" : "highlight" }}
                                            </span>

                                            <button
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
    </div>
</template>

<script setup>
import axios from "axios";
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import { VuePDF, usePDF } from "@tato30/vue-pdf";
import "@tato30/vue-pdf/style.css";

import {
    apiAddFavorite,
    apiCheckFavorite,
    apiGetBookViewCount,
    apiRecordBookView,
    apiRemoveFavorite
} from "@func/api/item.js";

import { apiGetBookTags } from "@func/api/bookTag.js";

import {
    apiCreatePdfCommentHighlight,
    apiDeletePdfCommentHighlight,
    apiGetPdfCommentHighlights
} from "@func/api/pdfCommentHighlight";

const props = defineProps({
    pdfUrl: { type: String, default: "" },
    itemId: { type: [Number, String], default: null },
    title: { type: String, default: "PDF Preview" },
    book: { type: Object, default: () => ({}) }
});

const form = reactive({
    selected_text: "",
    comment: "",
    highlight_color: "#fff59d"
});

const bookTags = ref([]);
const loadingBookTags = ref(false);

const views_count = ref(0);
const my_views_count = ref(0);
const unique_users_count = ref(0);
const isFavorite = ref(false);
const loadingFavorite = ref(false);

const DARK_KEY = "dark-mode";
const isDark = ref(false);

const page = ref(1);
const pages = ref(0);
const scale = ref(1.5);
const rotation = ref(0);

const minScale = 0.5;
const maxScale = 2.5;

const annotMode = ref("none");
const annotations = ref([]);
const activeAnnotationId = ref(null);
const loadingAnnotations = ref(false);
const savingAnnotation = ref(false);
const deletingId = ref(null);

const docKey = ref("");
const pdfPageRef = ref(null);

let saveProgressTimer = null;
let selectionTimer = null;

const showCommentModal = ref(false);
const commentInput = ref("");
const pendingPayload = ref(null);

const API_BASE = (import.meta.env.VITE_API_URL || "").replace(/\/$/, "");

const resolvedPdfUrl = computed(() => {
    if (!props.pdfUrl) return null;
    if (/^https?:\/\//i.test(props.pdfUrl)) return props.pdfUrl;

    let relativePath = props.pdfUrl.replace(/^\/+/, "");
    if (relativePath.startsWith("storage/")) {
        relativePath = relativePath.replace(/^storage\//, "");
    }

    return `${API_BASE}/pdf-file/${relativePath}`;
});

const { pdf, pages: pdfPages } = usePDF(resolvedPdfUrl);

const percent = computed(() => {
    if (!pages.value) return 0;
    return Math.round((page.value / pages.value) * 10000) / 100;
});

const title = computed(() => props.title || props.book?.title || "PDF Preview");

const sourceParams = computed(() => ({
    item_id: props.itemId || null,
    doc_key: docKey.value || null
}));

const currentPageAnnotations = computed(() => {
    return annotations.value.filter((item) => Number(item.page) === Number(page.value));
});

function applyDark(value) {
    document.body.classList.toggle("dark-mode", !!value);
}

function readDark() {
    const value = localStorage.getItem(DARK_KEY);
    return value === "true" || value === "1";
}

function syncDark() {
    const value = readDark();
    isDark.value = value;
    applyDark(value);
}

function onStorage(e) {
    if (e.key === DARK_KEY) syncDark();
}

function onThemeChanged() {
    syncDark();
}

async function sha256Hex(str) {
    const enc = new TextEncoder().encode(str || "");
    const buf = await crypto.subtle.digest("SHA-256", enc);
    return [...new Uint8Array(buf)]
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");
}

function debounceSaveProgress() {
    clearTimeout(saveProgressTimer);
    saveProgressTimer = setTimeout(() => {
        saveProgress();
    }, 500);
}

async function loadBookTags() {
    if (!props.itemId) {
        bookTags.value = [];
        return;
    }

    loadingBookTags.value = true;

    try {
        const res = await apiGetBookTags(props.itemId);
        bookTags.value = Array.isArray(res.data?.tags) ? res.data.tags : [];
    } catch (error) {
        console.error("Failed to load book tags:", error);
        bookTags.value = [];
    } finally {
        loadingBookTags.value = false;
    }
}

async function loadViews() {
    if (!props.itemId) return;

    try {
        const { data } = await apiGetBookViewCount(props.itemId);

        views_count.value = Number(data?.views_count ?? 0);
        unique_users_count.value = Number(data?.unique_users_count ?? 0);
        my_views_count.value = Number(data?.my_views_count ?? 0);

    } catch (error) {
        console.error("Failed to load views count:", error);
    }
}





async function recordView() {
    if (!props.itemId) return;

    try {
        await apiRecordBookView(props.itemId);
    } catch (error) {
        console.error("Failed to record view:", error);
    }
}

async function loadFavoriteStatus() {
    if (!props.itemId) return;

    try {
        const res = await apiCheckFavorite(props.itemId);
        isFavorite.value = !!res?.data?.is_favorite;
    } catch (error) {
        console.error("Failed to load favorite status:", error);
    }
}

async function toggleFavorite() {
    if (!props.itemId || loadingFavorite.value) return;

    loadingFavorite.value = true;

    try {
        if (isFavorite.value) {
            await apiRemoveFavorite(props.itemId);
            isFavorite.value = false;
        } else {
            await apiAddFavorite(props.itemId);
            isFavorite.value = true;
        }
    } catch (error) {
        console.error("Failed to toggle favorite:", error);
    } finally {
        loadingFavorite.value = false;
    }
}

async function loadProgress() {
    const params = { ...sourceParams.value };

    Object.keys(params).forEach((key) => {
        if (!params[key]) delete params[key];
    });

    if (!params.item_id && !params.doc_key) return;

    try {
        const res = await axios.get(`${API_BASE}/pdf-progress`, { params });
        const data = res?.data;

        if (data?.last_page != null) {
            page.value = Math.max(1, Number(data.last_page));
        }

        if (data?.total_pages != null) {
            pages.value = Math.max(0, Number(data.total_pages));
        }
    } catch (error) {
        console.warn("Load progress failed:", error?.response?.data || error?.message);
    }
}

async function saveProgress() {
    if (!pages.value) return;

    const payload = {
        last_page: page.value,
        total_pages: pages.value,
        ...sourceParams.value
    };

    Object.keys(payload).forEach((key) => {
        if (!payload[key]) delete payload[key];
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

function normalizeAnnotation(row) {
    return {
        id: row.id,
        page: Number(row.page || 1),
        selected_text: row.selected_text || "",
        comment: row.comment || "",
        highlight_color: row.highlight_color || "#fff59d",
        created_at: row.created_at || null,
        rects: normalizeRects(row.rects || row.position_json || row.rect_json)
    };
}

async function loadAnnotations() {
    const params = { ...sourceParams.value };

    Object.keys(params).forEach((key) => {
        if (!params[key]) delete params[key];
    });

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
        console.error("Load annotations failed:", error);
        annotations.value = [];
    } finally {
        loadingAnnotations.value = false;
    }
}

function selectAnnotation(id) {
    activeAnnotationId.value = id;
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
        console.error("Delete annotation failed:", error);
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
    if (page.value > 1) page.value--;
}

function nextPage() {
    if (pages.value && page.value < pages.value) page.value++;
}

function zoomIn() {
    scale.value = Math.min(maxScale, +(scale.value + 0.25).toFixed(2));
}

function zoomOut() {
    scale.value = Math.max(minScale, +(scale.value - 0.25).toFixed(2));
}

function zoomReset() {
    scale.value = 1.5;
}

function fitWidth() {
    scale.value = 1.25;
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
    clearSelection();
}

function clearSelection() {
    const sel = window.getSelection();
    if (sel) sel.removeAllRanges();
}

function selectionBelongsToPdf() {
    const sel = window.getSelection();
    const host = pdfPageRef.value;

    if (!sel || !host || sel.rangeCount === 0 || sel.isCollapsed) return false;

    const range = sel.getRangeAt(0);
    const node =
        range.commonAncestorContainer.nodeType === 1
            ? range.commonAncestorContainer
            : range.commonAncestorContainer.parentNode;

    return !!node && host.contains(node);
}

function getSelectionRectsNormalized() {
    const sel = window.getSelection();
    const host = pdfPageRef.value;

    if (!sel || !host || sel.rangeCount === 0) return [];

    const range = sel.getRangeAt(0);
    const hostRect = host.getBoundingClientRect();
    const rects = Array.from(range.getClientRects());

    return rects
        .map((r) => {
            if (r.width <= 0 || r.height <= 0 || hostRect.width <= 0 || hostRect.height <= 0) {
                return null;
            }

            const left = Math.max(0, r.left - hostRect.left);
            const top = Math.max(0, r.top - hostRect.top);

            return {
                x: left / hostRect.width,
                y: top / hostRect.height,
                w: Math.min(r.width, hostRect.width) / hostRect.width,
                h: Math.min(r.height, hostRect.height) / hostRect.height
            };
        })
        .filter(Boolean);
}

// async function saveSelectionAsAnnotation() {
//     if (savingAnnotation.value) return;
//
//     const sel = window.getSelection();
//
//     if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return;
//     if (!selectionBelongsToPdf()) return;
//
//     const text = sel.toString().trim();
//     if (!text) {
//         clearSelection();
//         return;
//     }
//
//     const rects = getSelectionRectsNormalized();
//     if (!rects.length) {
//         clearSelection();
//         return;
//     }
//
//     let comment = "";
//     let highlightColor = "#fff59d";
//
//     if (annotMode.value === "comment") {
//         const promptValue = window.prompt("Add comment", "");
//         if (promptValue === null) {
//             clearSelection();
//             return;
//         }
//         comment = promptValue.trim();
//         highlightColor = "#9ee7ff";
//     }
//
//     form.selected_text = text;
//     form.comment = comment;
//     form.highlight_color = highlightColor;
//
//     const payload = {
//         item_id: sourceParams.value.item_id,
//         doc_key: sourceParams.value.doc_key,
//         page: page.value,
//         selected_text: form.selected_text,
//         comment: form.comment || null,
//         highlight_color: form.highlight_color,
//         rects
//     };
//
//     Object.keys(payload).forEach((key) => {
//         if (payload[key] === null || payload[key] === undefined || payload[key] === "") {
//             if (key !== "comment") delete payload[key];
//         }
//     });
//
//     savingAnnotation.value = true;
//
//     try {
//         const res = await apiCreatePdfCommentHighlight(payload);
//
//         const saved = normalizeAnnotation(res?.data?.data || res?.data || payload);
//         if (!saved.id) {
//             await loadAnnotations();
//         } else {
//             annotations.value.unshift(saved);
//         }
//
//         activeAnnotationId.value = saved.id || null;
//     } catch (error) {
//         console.error("Save annotation failed:", error);
//         await loadAnnotations();
//     } finally {
//         form.selected_text = "";
//         form.comment = "";
//         form.highlight_color = "#fff59d";
//         savingAnnotation.value = false;
//         clearSelection();
//     }
// }

async function saveSelectionAsAnnotation() {
    if (savingAnnotation.value) return;

    const sel = window.getSelection();

    if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return;
    if (!selectionBelongsToPdf()) return;

    const text = sel.toString().trim();
    if (!text) {
        clearSelection();
        return;
    }

    const rects = getSelectionRectsNormalized();
    if (!rects.length) {
        clearSelection();
        return;
    }

    // 👇 base payload (store first)
    const basePayload = {
        item_id: sourceParams.value.item_id,
        doc_key: sourceParams.value.doc_key,
        page: page.value,
        selected_text: text,
        rects,
    };

    // ✅ COMMENT MODE → open modal instead of prompt
    if (annotMode.value === "comment") {
        pendingPayload.value = basePayload;
        commentInput.value = "";
        showCommentModal.value = true;
        return;
    }

    // ✅ NORMAL HIGHLIGHT
    await submitAnnotation({
        ...basePayload,
        comment: null,
        highlight_color: "#fff59d",
    });
}

async function submitComment() {
    if (!pendingPayload.value) return;

    const comment = commentInput.value.trim();

    await submitAnnotation({
        ...pendingPayload.value,
        comment: comment || null,
        highlight_color: "#9ee7ff",
    });

    closeModal();
}

async function submitAnnotation(payload) {
    form.selected_text = payload.selected_text || "";
    form.comment = payload.comment || "";
    form.highlight_color = payload.highlight_color || "#fff59d";

    const cleanedPayload = { ...payload };

    Object.keys(cleanedPayload).forEach((key) => {
        if (
            cleanedPayload[key] === null ||
            cleanedPayload[key] === undefined ||
            cleanedPayload[key] === ""
        ) {
            if (key !== "comment") delete cleanedPayload[key];
        }
    });

    savingAnnotation.value = true;

    try {
        const res = await apiCreatePdfCommentHighlight(cleanedPayload);

        const saved = normalizeAnnotation(res?.data?.data || res?.data || cleanedPayload);

        if (!saved.id) {
            await loadAnnotations();
        } else {
            annotations.value.unshift(saved);
        }

        activeAnnotationId.value = saved.id || null;
    } catch (error) {
        console.error("Save annotation failed:", error);
        await loadAnnotations();
    } finally {
        form.selected_text = "";
        form.comment = "";
        form.highlight_color = "#fff59d";
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

function handlePdfMouseUp() {
    if (annotMode.value === "none") return;
    if (rotation.value !== 0) return;

    clearTimeout(selectionTimer);
    selectionTimer = setTimeout(() => {
        saveSelectionAsAnnotation();
    }, 80);
}

function getHighlightBackground(annotation) {
    const color = annotation.highlight_color || "#fff59d";

    if (color.startsWith("rgba")) return color;
    if (color.startsWith("rgb")) return color;
    if (color.startsWith("#")) return `${color}88`;

    return "rgba(255, 235, 59, 0.45)";
}

function handleBeforeUnload() {
    saveProgress();
}

watch(pdfPages, (val) => {
    if (!val) return;

    pages.value = Number(val) || 0;

    if (page.value > pages.value && pages.value > 0) {
        page.value = pages.value;
    }

    if (page.value < 1) {
        page.value = 1;
    }

    debounceSaveProgress();
});

watch(page, async (val) => {
    if (val < 1) page.value = 1;
    if (pages.value && val > pages.value) page.value = pages.value;

    if (pages.value) debounceSaveProgress();

    activeAnnotationId.value = null;
    await nextTick();
    clearSelection();
});

watch(
    () => [props.itemId, props.pdfUrl],
    async () => {
        docKey.value = await sha256Hex(props.pdfUrl || "");
        page.value = 1;
        pages.value = 0;
        activeAnnotationId.value = null;

        await Promise.all([
            loadProgress(),
            loadViews(),
            loadFavoriteStatus(),
            loadBookTags(),
            loadAnnotations()
        ]);
    }
);

onMounted(async () => {
    syncDark();

    window.addEventListener("storage", onStorage);
    window.addEventListener("theme-changed", onThemeChanged);
    window.addEventListener("beforeunload", handleBeforeUnload);

    docKey.value = await sha256Hex(props.pdfUrl || "");

    await Promise.all([
        recordView(),
        loadViews(),
        loadFavoriteStatus(),
        loadBookTags(),
        loadAnnotations()
    ]);

    await loadProgress();
});

onBeforeUnmount(() => {
    window.removeEventListener("storage", onStorage);
    window.removeEventListener("theme-changed", onThemeChanged);
    window.removeEventListener("beforeunload", handleBeforeUnload);

    clearTimeout(saveProgressTimer);
    clearTimeout(selectionTimer);
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

.reader-topbar {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    flex-wrap: wrap;
    margin-bottom: 0.75rem;
}

.book-tags-wrap {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    flex-wrap: wrap;
}

.book-tags-block {
    min-width: 220px;
}

.book-tags-title {
    font-size: 0.95rem;
    font-weight: 800;
    color: var(--reader-heading, #1f2937);
}

.badge-tag {
    font-size: 0.72rem;
    padding: 0.42rem 0.62rem;
    border-radius: 999px;
    font-weight: 700;
    background: rgba(13, 110, 253, 0.1);
    color: #0d6efd;
}

.reader-stats {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
}

.book-meta-item {
    min-width: 92px;
    padding: 0.65rem 0.8rem;
    border-radius: 12px;
    background: var(--reader-card-bg, #ffffff);
    border: 1px solid var(--reader-border, #e5e7eb);
    box-shadow: 0 8px 20px rgba(15, 23, 42, 0.04);
    display: flex;
    flex-direction: column;
    gap: 0.18rem;
}

.book-meta-label {
    font-size: 0.72rem;
    font-weight: 700;
    color: var(--reader-muted, #6b7280);
}

.book-meta-value {
    font-size: 0.95rem;
    font-weight: 800;
    color: var(--reader-heading, #111827);
}

.reader-toolbar-card {
    background: var(--reader-card-bg, #ffffff);
    border: 1px solid var(--reader-border, #e5e7eb);
    border-radius: 12px;
    padding: 0.55rem 0.65rem;
    box-shadow: 0 8px 20px rgba(15, 23, 42, 0.045);
}

.reader-toolbar-card__top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 0.55rem;
    flex-wrap: wrap;
    margin-bottom: 0.5rem;
}

.reader-book-title {
    font-size: 0.88rem;
    font-weight: 800;
    color: var(--reader-heading, #1f2937);
    line-height: 1.35;
    word-break: break-word;
    max-width: 420px;
}

.reader-progress__meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
    margin-top: 0.2rem;
}

.reader-meta-pill {
    display: inline-flex;
    align-items: center;
    border-radius: 999px;
    padding: 0.24rem 0.52rem;
    background: var(--reader-soft-bg, #f8fafc);
    border: 1px solid var(--reader-border, #e5e7eb);
    color: var(--reader-text, #334155);
    font-size: 0.68rem;
    font-weight: 700;
    line-height: 1;
}

.reader-toolbar-groups,
.annotation-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
}

.toolbar-group {
    display: inline-flex;
    flex-wrap: wrap;
    gap: 0.28rem;
}

.reader-toolbar-card__bottom {
    display: flex;
    justify-content: space-between;
    gap: 0.55rem;
    flex-wrap: wrap;
    align-items: center;
    border-top: 1px solid var(--reader-border, #e5e7eb);
    padding-top: 0.5rem;
}

.btn-toolbar,
.btn-annot {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 30px;
    border-radius: 8px;
    padding: 0.35rem 0.58rem;
    border: 1px solid var(--reader-border-strong, #ced4da);
    background: var(--reader-btn-bg, #ffffff);
    color: var(--reader-text, #495057);
    font-weight: 700;
    font-size: 0.7rem;
    line-height: 1;
    transition: all 0.18s ease;
}

.btn-toolbar:hover:not(:disabled),
.btn-annot:hover {
    background: var(--reader-btn-hover, #f8f9fa);
    transform: translateY(-1px);
}

.btn-toolbar:disabled,
.btn-annot:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.btn-toolbar-static {
    pointer-events: none;
    min-width: 52px;
}

.btn-annot--highlight {
    background: rgba(255, 193, 7, 0.08);
    border-color: rgba(255, 193, 7, 0.3);
    color: #a16d00;
}

.btn-annot--highlight-active {
    background: #ffc107;
    border-color: #ffc107;
    color: #2d2200;
}

.btn-annot--comment {
    background: rgba(13, 202, 240, 0.08);
    border-color: rgba(13, 202, 240, 0.35);
    color: #0b7285;
}

.btn-annot--comment-active {
    background: #0dcaf0;
    border-color: #0dcaf0;
    color: #042a31;
}

.btn-annot--clear {
    background: rgba(108, 117, 125, 0.08);
    border-color: rgba(108, 117, 125, 0.25);
    color: #495057;
}

.annotation-help-box {
    border-radius: 10px;
    padding: 0.4rem 0.62rem;
    background: var(--reader-soft-bg, #f8fafc);
    border: 1px solid var(--reader-border, #e5e7eb);
    color: var(--reader-muted, #6b7280);
    font-size: 0.72rem;
    font-weight: 500;
    line-height: 1.2;
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
    min-height: 72vh;
    max-height: calc(100vh - 200px);
    overflow: auto;
    padding: 0.9rem;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    border-right: 1px solid var(--reader-border, #e9ecef);
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
.annotation-rect.is-comment.is-active .comment-popup {
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
    --reader-border-strong: rgba(255, 255, 255, 0.14);
    --reader-heading: #f8fafc;
    --reader-text: #dbe4f0;
    --reader-muted: #94a3b8;
    --reader-btn-bg: #1c2738;
    --reader-btn-hover: #243246;
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

:global(body.dark-mode) .comment-popup__label,
:global(.dark-mode) .comment-popup__label {
    color: #93c5fd;
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

    .annotation-help-box {
        width: 100%;
    }
}

@media (max-width: 767.98px) {
    .reader-toolbar-card {
        padding: 0.55rem;
        border-radius: 12px;
    }

    .reader-topbar {
        flex-direction: column;
    }

    .book-tags-wrap,
    .reader-stats {
        width: 100%;
    }

    .pdf-viewer {
        padding: 0.7rem;
    }

    .annotation-sidebar {
        padding: 0.7rem;
    }

    .toolbar-group,
    .annotation-actions,
    .reader-toolbar-groups {
        width: 100%;
    }

    .toolbar-group .btn,
    .annotation-actions .btn {
        flex: 1 1 auto;
    }

    .btn-toolbar-static {
        min-width: 48px;
    }
}

.modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.modal-box {
    background: #fff;
    padding: 16px;
    border-radius: 10px;
    width: 360px;
}
</style>
