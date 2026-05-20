<template>
    <div class="content-wrapper library-page">
        <section class="content-header">
            <div class="container-fluid d-flex justify-content-between align-items-center">
                <router-link :to="backLink" class="btn btn-secondary btn-sm">
                    <i class="fas fa-arrow-left mr-1"></i>
                    Back
                </router-link>
            </div>
        </section>

        <section class="content pt-3">
            <div class="container-fluid">
                <div v-if="loading" class="card book-card mb-4">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-spinner fa-spin fa-2x mb-3 text-primary"></i>
                        <h5 class="mb-2">Loading book details...</h5>
                        <p class="text-muted mb-0">Please wait while we fetch the data.</p>
                    </div>
                </div>

                <div v-else-if="errorMessage" class="card book-card mb-4">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-exclamation-circle fa-2x mb-3 text-danger"></i>
                        <h5 class="mb-2">Unable to load book</h5>
                        <p class="text-muted mb-0">{{ errorMessage }}</p>
                    </div>
                </div>

                <div v-else-if="!hasBook" class="card book-card mb-4">
                    <div class="card-body text-center py-5">
                        <i class="far fa-folder-open fa-2x mb-3 text-muted"></i>
                        <h5 class="mb-2">Book not found</h5>
                    </div>
                </div>

                <template v-else>
                    <div class="card book-card mb-4">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-3 col-md-4 mb-4">
                                    <div class="book-cover">
                                        <img
                                            :src="coverSrc"
                                            :alt="book.title || 'Book cover'"
                                            @error="handleImageError"
                                        />
                                    </div>
                                </div>

                                <div class="col-lg-9 col-md-8">
                                    <h2 class="book-title">
                                        {{ book.title || "Untitled Book" }}
                                    </h2>

                                    <div class="book-author">
                                        by {{ authorName }}
                                    </div>

                                    <div class="book-actions">
                                        <router-link
                                            v-if="readRoute"
                                            :to="readRoute"
                                            class="btn btn-primary btn-read"
                                        >
                                            <i class="fas fa-book-open mr-2"></i>
                                            Read Book
                                        </router-link>

                                        <button
                                            type="button"
                                            class="btn btn-outline-primary btn-library"
                                            :disabled="favoriteLoading || !hasBook"
                                            @click="toggleFavorite"
                                        >
                                            <i
                                                class="mr-2"
                                                :class="isFavorite ? 'fas fa-heart text-danger' : 'far fa-heart'"
                                            ></i>
                                            {{ isFavorite ? "Favorited" : "Add Favorite" }}
                                        </button>
                                    </div>

                                    <div v-if="bookTags.length" class="book-tags">
                                        <span
                                            v-for="tag in bookTags"
                                            :key="tag.id || tag.name"
                                            class="tag-chip"
                                        >
                                            <i class="fas fa-tag mr-1"></i>
                                            {{ tag.name }}
                                        </span>
                                    </div>

                                    <p class="book-description">
                                        {{ shortDescription }}
                                    </p>

                                    <div class="book-meta two-by-two-meta">
                                        <div class="meta-box">
                                            <div class="meta-label">Category</div>
                                            <div class="meta-value">
                                                {{ categoryName }}
                                            </div>
                                        </div>

                                        <div class="meta-box">
                                            <div class="meta-label">Year</div>
                                            <div class="meta-value">
                                                {{ book.publish_year || "—" }}
                                            </div>
                                        </div>

                                        <div class="meta-box">
                                            <div class="meta-label">Language</div>
                                            <div class="meta-value">
                                                {{ book.language || "—" }}
                                            </div>
                                        </div>

                                        <div class="meta-box">
                                            <div class="meta-label">Read</div>
                                            <div class="meta-value">
                                                {{ totalReads }}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div v-if="similarBooks.length" class="library-section">
                        <h3 class="section-title">Book Similar Titles</h3>

                        <div class="row">
                            <div
                                v-for="item in similarBooks"
                                :key="item.id"
                                class="col-xl-2 col-lg-3 col-md-4 col-sm-6 mb-4"
                            >
                                <router-link
                                    :to="bookDetailsRoute(item.id)"
                                    class="book-card-mini d-block text-decoration-none"
                                >
                                    <div class="book-card-img">
                                        <img
                                            :src="getCoverUrl(item.cover_url)"
                                            :alt="item.title || 'Book cover'"
                                            @error="handleImageError"
                                        />
                                    </div>

                                    <div class="book-card-body">
                                        <div class="book-card-title">
                                            {{ item.title || "Untitled Book" }}
                                        </div>

                                        <div class="book-card-subtitle">
                                            {{ getBookAuthorName(item) }}
                                        </div>

                                        <div v-if="item.tags?.length" class="book-card-tags">
                                            <span
                                                v-for="tag in item.tags.slice(0, 3)"
                                                :key="tag.id || tag.name"
                                                class="tag-mini"
                                            >
                                                {{ tag.name }}
                                            </span>
                                        </div>
                                    </div>
                                </router-link>
                            </div>
                        </div>
                    </div>

                    <div v-if="interestedBooks.length" class="library-section">
                        <h3 class="section-title">You may be interested</h3>

                        <div class="row">
                            <div
                                v-for="item in interestedBooks"
                                :key="item.id"
                                class="col-xl-2 col-lg-3 col-md-4 col-sm-6 mb-4"
                            >
                                <router-link
                                    :to="bookDetailsRoute(item.id)"
                                    class="book-card-mini d-block text-decoration-none"
                                >
                                    <div class="book-card-img">
                                        <img
                                            :src="getCoverUrl(item.cover_url)"
                                            :alt="item.title || 'Book cover'"
                                            @error="handleImageError"
                                        />
                                    </div>

                                    <div class="book-card-body">
                                        <div class="book-card-title">
                                            {{ item.title || "Untitled Book" }}
                                        </div>

                                        <div class="book-card-subtitle">
                                            {{ getBookAuthorName(item) }}
                                        </div>

                                        <div v-if="item.tags?.length" class="book-card-tags">
                                            <span
                                                v-for="tag in item.tags.slice(0, 3)"
                                                :key="tag.id || tag.name"
                                                class="tag-mini"
                                            >
                                                {{ tag.name }}
                                            </span>
                                        </div>
                                    </div>
                                </router-link>
                            </div>
                        </div>
                    </div>
                </template>
            </div>
        </section>
    </div>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { useRoute } from "vue-router";
import defaultCover from "@assets/images/defaultCover.jpg";

import {
    apiShowItem,
    apiCheckFavorite,
    apiAddFavorite,
    apiRemoveFavorite,
    apiGetBookViewCount,
} from "@func/api/item.js";

import {
    apiGetRecommendedBooks,
    apiGetRecommendedOverallBooks,
    apiGetSimilarTitleBooks,
} from "@func/api/user.js";

const props = defineProps({
    id: {
        type: Number,
        default: 0,
    },
});

const route = useRoute();

const loading = ref(false);
const favoriteLoading = ref(false);
const errorMessage = ref("");

const book = ref(null);
const totalReads = ref(0);
const isFavorite = ref(false);
const similarBooks = ref([]);
const interestedBooks = ref([]);

const API_BASE = String(
    import.meta.env.VITE_API_URL ||
    import.meta.env.VITE_URL ||
    window.API_BASE_URL ||
    window.API_URL ||
    ""
).replace(/\/+$/, "");

function toNumber(value, fallback = 0) {
    const num = Number(value);
    return Number.isFinite(num) ? num : fallback;
}

function isAbsoluteUrl(value) {
    return /^(https?:\/\/|blob:|data:)/i.test(String(value || "").trim());
}

function removeApiSuffix(url) {
    return String(url || "").replace(/\/api$/i, "");
}

function normalizeStoragePath(path) {
    return String(path || "")
        .trim()
        .replace(/^https?:\/\/[^/]+/i, "")
        .replace(/^\/+/, "")
        .replace(/^storage\//i, "")
        .replace(/^public\//i, "");
}

function buildStorageUrl(path) {
    if (!path) return "";
    if (isAbsoluteUrl(path)) return path;

    const clean = normalizeStoragePath(path);
    if (!clean) return "";

    const base = removeApiSuffix(API_BASE);
    return base ? `${base}/storage/${clean}` : `/storage/${clean}`;
}

function getCoverUrl(path) {
    return buildStorageUrl(path) || defaultCover;
}

function handleImageError(event) {
    if (event?.target && event.target.src !== defaultCover) {
        event.target.src = defaultCover;
    }
}

function normalizeArray(payload) {
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload?.data)) return payload.data;
    if (Array.isArray(payload?.data?.data)) return payload.data.data;
    if (Array.isArray(payload?.items)) return payload.items;
    if (Array.isArray(payload?.data?.items)) return payload.data.items;
    if (Array.isArray(payload?.books)) return payload.books;
    if (Array.isArray(payload?.data?.books)) return payload.data.books;
    if (Array.isArray(payload?.results)) return payload.results;
    return [];
}

function normalizeObject(payload) {
    if (!payload) return null;

    if (payload?.data?.data && !Array.isArray(payload.data.data)) return payload.data.data;
    if (payload?.data && !Array.isArray(payload.data)) return payload.data;
    if (payload?.item && typeof payload.item === "object") return payload.item;
    if (payload?.book && typeof payload.book === "object") return payload.book;
    if (typeof payload === "object" && !Array.isArray(payload)) return payload;

    return null;
}

function normalizeTag(tag) {
    if (!tag) return null;

    if (typeof tag === "string" || typeof tag === "number") {
        return {
            id: String(tag),
            name: String(tag),
        };
    }

    const name = String(tag.name || tag.title || tag.tag_name || "").trim();
    if (!name) return null;

    return {
        id: tag.id || tag.tag_id || name,
        name,
    };
}

function normalizeTags(item) {
    if (Array.isArray(item?.tags)) {
        return item.tags.map(normalizeTag).filter(Boolean);
    }

    if (Array.isArray(item?.book_tags)) {
        return item.book_tags.map(normalizeTag).filter(Boolean);
    }

    if (typeof item?.tags === "string") {
        return item.tags
            .split(",")
            .map((name) => normalizeTag(name.trim()))
            .filter(Boolean);
    }

    return [];
}

function normalizeBook(item) {
    if (!item || typeof item !== "object") return null;

    const id = toNumber(item.id);
    if (!id) return null;

    return {
        ...item,
        id,
        title: String(item.title || "").trim(),
        description: String(item.description || "").trim(),
        file_url: item.file_url || item.file || item.pdf_url || "",
        cover_url: item.cover_url || item.cover || item.image || "",
        publish_year: item.publish_year || item.year || "",
        language: item.language || "",
        author_id: item.author_id != null ? toNumber(item.author_id) : null,
        author_name:
            item.author_name ||
            item.author?.name ||
            item.user?.name ||
            "Unknown Author",
        category_id:
            item.category_id != null
                ? toNumber(item.category_id)
                : item.category?.id != null
                    ? toNumber(item.category.id)
                    : null,
        category_name: item.category_name || item.category?.name || "",
        category: item.category || null,
        author: item.author || null,
        tags: normalizeTags(item),
    };
}

function uniqueBooks(items = []) {
    const map = new Map();

    for (const raw of items) {
        const item = normalizeBook(raw);
        if (!item?.id || map.has(item.id)) continue;
        map.set(item.id, item);
    }

    return Array.from(map.values());
}

function excludeCurrentBook(items = []) {
    const currentId = toNumber(book.value?.id);
    return items.filter((item) => toNumber(item?.id) !== currentId);
}

function getBookAuthorName(item) {
    return (
        item?.author?.name ||
        item?.author_name ||
        item?.user?.name ||
        "Unknown Author"
    );
}

function bookDetailsRoute(id) {
    return {
        path: `/library/details/${toNumber(id)}`,
    };
}

function normalizeFilePath(path) {
    return String(path || "")
        .trim()
        .replace(/^https?:\/\/[^/]+/i, "")
        .replace(/^\/+/, "")
        .replace(/^public\//i, "")
        .replace(/^storage\//i, "storage/");
}

const bookId = computed(() =>
    toNumber(props.id || route.params.id || route.query.id || 0)
);

const hasBook = computed(() => toNumber(book.value?.id) > 0);

const coverSrc = computed(() => getCoverUrl(book.value?.cover_url));

const authorName = computed(() => getBookAuthorName(book.value));

const categoryName = computed(() => {
    return book.value?.category?.name || book.value?.category_name || "N/A";
});

const bookTags = computed(() => {
    return Array.isArray(book.value?.tags) ? book.value.tags : [];
});

const shortDescription = computed(() => {
    const text = String(book.value?.description || "").trim();

    if (!text) return "No description available.";
    if (text.length <= 1000) return text;

    return `${text.slice(0, 1000)}...`;
});

const backLink = computed(() => ({ path: "/library" }));

const readRoute = computed(() => {
    const id = Number(book.value?.id || 0);
    const filePath = normalizeFilePath(book.value?.file_url);

    if (!id || !filePath) return null;

    return {
        name: "book.details.view",
        params: { id },
        query: {
            file: `/${filePath}`,
            title: book.value?.title || "PDF Preview",
        },
    };
});

function resetState() {
    errorMessage.value = "";
    book.value = null;
    totalReads.value = 0;
    isFavorite.value = false;
    similarBooks.value = [];
    interestedBooks.value = [];
}

async function loadBook(id) {
    const response = await apiShowItem(id);
    const payload = response?.data ?? response;
    const normalized = normalizeBook(normalizeObject(payload));

    if (!normalized) {
        throw new Error("Book data is empty or invalid.");
    }

    book.value = normalized;
}

async function loadFavoriteStatus() {
    if (!hasBook.value) return;

    try {
        const response = await apiCheckFavorite(book.value.id);
        const data = response?.data ?? response ?? {};

        isFavorite.value = Boolean(
            data?.is_favorite ??
            data?.favorite ??
            data?.exists ??
            data?.data?.is_favorite ??
            false
        );
    } catch {
        isFavorite.value = false;
    }
}

async function loadViewCount() {
    if (!hasBook.value) return;

    try {
        const response = await apiGetBookViewCount(book.value.id);
        const data = response?.data ?? response ?? {};

        totalReads.value = toNumber(
            data?.views_count ??
            data?.total_reads ??
            data?.views ??
            data?.count ??
            data?.data?.views_count ??
            0
        );
    } catch {
        totalReads.value = 0;
    }
}

async function loadSimilarBooks() {
    if (!hasBook.value) return;

    try {
        const response = await apiGetSimilarTitleBooks(book.value.id, { limit: 6 });
        const rows = normalizeArray(response?.data ?? response ?? {});
        similarBooks.value = excludeCurrentBook(uniqueBooks(rows)).slice(0, 6);
    } catch {
        similarBooks.value = [];
    }
}

async function loadInterestedBooks() {
    if (!hasBook.value) return;

    try {
        const [recommendedRes, overallRes] = await Promise.allSettled([
            apiGetRecommendedBooks({ limit: 12 }),
            apiGetRecommendedOverallBooks({ limit: 12 }),
        ]);

        const recommendedRows =
            recommendedRes.status === "fulfilled"
                ? normalizeArray(recommendedRes.value?.data ?? recommendedRes.value ?? {})
                : [];

        const overallRows =
            overallRes.status === "fulfilled"
                ? normalizeArray(overallRes.value?.data ?? overallRes.value ?? {})
                : [];

        const similarIds = new Set(
            similarBooks.value.map((item) => toNumber(item.id))
        );

        interestedBooks.value = excludeCurrentBook(
            uniqueBooks([...recommendedRows, ...overallRows])
        )
            .filter((item) => !similarIds.has(toNumber(item.id)))
            .slice(0, 6);
    } catch {
        interestedBooks.value = [];
    }
}

async function toggleFavorite() {
    if (!hasBook.value || favoriteLoading.value) return;

    favoriteLoading.value = true;

    try {
        if (isFavorite.value) {
            await apiRemoveFavorite(book.value.id);
            isFavorite.value = false;
        } else {
            await apiAddFavorite(book.value.id);
            isFavorite.value = true;
        }
    } catch (error) {
        console.error("Failed to update favorite:", error);
    } finally {
        favoriteLoading.value = false;
    }
}

async function fetchData() {
    resetState();

    if (!bookId.value) {
        errorMessage.value = "Missing book ID in route.";
        return;
    }

    loading.value = true;

    try {
        await loadBook(bookId.value);

        await Promise.allSettled([
            loadFavoriteStatus(),
            loadViewCount(),
            loadSimilarBooks(),
            loadInterestedBooks(),
        ]);
    } catch (error) {
        console.error("Failed to load book detail:", error);

        errorMessage.value =
            error?.response?.data?.message ||
            error?.message ||
            "Unknown error while loading book details.";
    } finally {
        loading.value = false;
    }
}

watch(
    () => [props.id, route.params.id, route.query.id],
    () => {
        fetchData();
    },
    { immediate: true }
);
</script>

<style scoped>
.library-page {
    min-height: 100%;
    background: #f4f6f9;
    padding-bottom: 24px;
}

.book-card {
    background: #ffffff;
    border: 1px solid #e9ecef;
    border-radius: 16px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.04);
}

.book-card .card-body {
    padding: 1.5rem;
}

.book-cover {
    border-radius: 14px;
    overflow: hidden;
    background: #eef1f5;
    border: 1px solid #edf0f3;
}

.book-cover img {
    width: 100%;
    height: 420px;
    object-fit: cover;
    display: block;
}

.book-title {
    font-size: 28px;
    font-weight: 700;
    line-height: 1.3;
    color: #1f2937;
    margin-bottom: 8px;
}

.book-author {
    font-size: 15px;
    color: #6b7280;
    margin-bottom: 18px;
}

.book-description {
    font-size: 15px;
    line-height: 1.7;
    color: #4b5563;
    margin-bottom: 0;
    white-space: pre-line;
}

.book-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 18px;
}

.book-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 18px;
}

.tag-chip {
    display: inline-flex;
    align-items: center;
    padding: 6px 12px;
    border-radius: 999px;
    background: #eef2ff;
    color: #4338ca;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid #dbe4ff;
}

.book-meta.two-by-two-meta {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px;
    margin-top: 22px;
}

.meta-box {
    background: #f8fafc;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    padding: 14px;
}

.meta-label {
    font-size: 12px;
    font-weight: 600;
    color: #6b7280;
    margin-bottom: 6px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

.meta-value {
    font-size: 15px;
    font-weight: 700;
    color: #1f2937;
}

.library-section {
    margin-top: 36px;
}

.section-title {
    font-size: 22px;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 18px;
}

.book-card-mini {
    height: 100%;
    background: #ffffff;
    border-radius: 14px;
    overflow: hidden;
    border: 1px solid #e5e7eb;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.04);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.book-card-mini:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
}

.book-card-img img {
    width: 100%;
    height: 220px;
    object-fit: cover;
    display: block;
}

.book-card-body {
    padding: 12px;
}

.book-card-title {
    font-size: 14px;
    font-weight: 700;
    line-height: 1.45;
    color: #1f2937;
    margin-bottom: 6px;
    min-height: 40px;
}

.book-card-subtitle {
    font-size: 12px;
    color: #6b7280;
    margin-bottom: 8px;
}

.book-card-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}

.tag-mini {
    display: inline-flex;
    align-items: center;
    padding: 4px 8px;
    border-radius: 999px;
    background: #f1f5f9;
    color: #475569;
    font-size: 11px;
    font-weight: 600;
    border: 1px solid #e2e8f0;
}

@media (max-width: 767.98px) {
    .book-cover img {
        height: 320px;
    }

    .book-title {
        font-size: 22px;
    }

    .section-title {
        font-size: 20px;
    }

    .book-meta.two-by-two-meta {
        gap: 10px;
    }
}
</style>

<style>
body.dark-mode .library-page,
.dark-mode .library-page {
    background: #161a23 !important;
}

body.dark-mode .library-page .book-card,
body.dark-mode .library-page .book-card-mini,
.dark-mode .library-page .book-card,
.dark-mode .library-page .book-card-mini {
    background: #232834 !important;
    border-color: #3a4250 !important;
    color: #e9edf3 !important;
}

body.dark-mode .library-page .book-cover,
.dark-mode .library-page .book-cover {
    background: #1c212b !important;
    border-color: #394150 !important;
}

body.dark-mode .library-page .book-title,
body.dark-mode .library-page .section-title,
body.dark-mode .library-page .book-card-title,
body.dark-mode .library-page .meta-value,
.dark-mode .library-page .book-title,
.dark-mode .library-page .section-title,
.dark-mode .library-page .book-card-title,
.dark-mode .library-page .meta-value {
    color: #f8fafc !important;
}

body.dark-mode .library-page .book-author,
body.dark-mode .library-page .book-description,
body.dark-mode .library-page .meta-label,
body.dark-mode .library-page .book-card-subtitle,
.dark-mode .library-page .book-author,
.dark-mode .library-page .book-description,
.dark-mode .library-page .meta-label,
.dark-mode .library-page .book-card-subtitle {
    color: #b8c1cc !important;
}

body.dark-mode .library-page .meta-box,
.dark-mode .library-page .meta-box {
    background: #2b3240 !important;
    border-color: #404a5a !important;
}

body.dark-mode .library-page .tag-chip,
.dark-mode .library-page .tag-chip {
    background: #313a4a !important;
    color: #dbe7ff !important;
    border-color: #465166 !important;
}

body.dark-mode .library-page .tag-mini,
.dark-mode .library-page .tag-mini {
    background: #2f3746 !important;
    color: #d4dbe5 !important;
    border-color: #465166 !important;
}

body.dark-mode .library-page .btn-outline-primary,
.dark-mode .library-page .btn-outline-primary {
    color: #8ab4ff !important;
    border-color: #4f78c7 !important;
    background: transparent !important;
}

body.dark-mode .library-page .btn-outline-primary:hover,
.dark-mode .library-page .btn-outline-primary:hover {
    color: #fff !important;
    background: #2c4d87 !important;
    border-color: #2c4d87 !important;
}
</style>
