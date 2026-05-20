<template>
    <div class="content-wrapper library-page">
        <section class="content-header">
            <div class="container-fluid d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h1 class="library-page__title">
                        {{ $t("library-page.title") }}
                    </h1>
                    <div class="library-page__subtitle">
                        {{ $t("library-page.subtitle") }}
                    </div>
                </div>
            </div>
        </section>

        <section class="content pt-3">
            <div class="container-fluid">
                <div class="card library-shell">
                    <div class="card-body">
                        <div class="library-toolbar">
                            <div class="library-search">
                                <i class="fas fa-search library-search__icon"></i>

                                <input
                                    v-model.trim="searchQuery"
                                    type="text"
                                    class="form-control library-search__input"
                                    :placeholder="$t('library-page.search_placeholder')"
                                />

                                <button
                                    v-if="searchQuery"
                                    type="button"
                                    class="library-search__clear"
                                    @click="clearSearch"
                                >
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>

                            <div class="library-category">
                                <select
                                    v-model="selectedCategoryId"
                                    class="form-control library-category__select"
                                >
                                    <option value="">
                                        {{ $t("library-page.all_categories") }}
                                    </option>

                                    <option
                                        v-for="category in categoryOptions"
                                        :key="category.id"
                                        :value="String(category.id)"
                                    >
                                        {{ category.name }}
                                    </option>
                                </select>
                            </div>

                            <div class="library-view-switch btn-group">
                                <button
                                    type="button"
                                    class="btn btn-sm"
                                    :class="viewMode === 'grid' ? 'btn-primary' : 'btn-outline-secondary'"
                                    @click="viewMode = 'grid'"
                                >
                                    <i class="fas fa-th-large mr-1"></i>
                                    {{ $t("library-page.grid") }}
                                </button>

                                <button
                                    type="button"
                                    class="btn btn-sm"
                                    :class="viewMode === 'list' ? 'btn-primary' : 'btn-outline-secondary'"
                                    @click="viewMode = 'list'"
                                >
                                    <i class="fas fa-list mr-1"></i>
                                    {{ $t("library-page.list") }}
                                </button>
                            </div>
                        </div>

                        <div class="library-filters">
                            <button
                                v-for="filter in filterOptions"
                                :key="filter.value"
                                type="button"
                                class="btn btn-sm library-filter-btn"
                                :class="activeFilter === filter.value ? 'btn-primary' : 'btn-outline-secondary'"
                                @click="activeFilter = filter.value"
                            >
                                {{ filter.label }}
                            </button>
                        </div>

                        <div class="library-meta">
                            <div class="library-meta__left">
                                <span class="badge badge-light border px-3 py-2">
                                    {{ totalBooks }} {{ $t("library-page.books_found") }}
                                </span>

                                <span v-if="favoriteIds.size" class="badge badge-warning px-3 py-2">
                                    {{ favoriteIds.size }} {{ $t("library-page.favorites") }}
                                </span>
                            </div>

                            <div class="library-meta__right">
                                <select
                                    v-model.number="perPage"
                                    class="form-control form-control-sm library-per-page"
                                >
                                    <option :value="12">12 {{ $t("library-page.page") }}</option>
                                    <option :value="16">16 {{ $t("library-page.page") }}</option>
                                    <option :value="24">24 {{ $t("library-page.page") }}</option>
                                </select>

                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-sm"
                                    :disabled="loading"
                                    @click="loadLibraryData"
                                >
                                    <i class="fas fa-sync-alt mr-1"></i>
                                    {{ $t("library-page.refresh") }}
                                </button>
                            </div>
                        </div>

                        <div v-if="loading" class="library-loading">
                            <div class="spinner-border text-primary mr-2" role="status"></div>
                            <span>{{ $t("library-page.loading") }}</span>
                        </div>

                        <div v-else-if="errorMessage" class="alert alert-danger">
                            {{ errorMessage }}
                        </div>

                        <div v-else-if="!filteredBooks.length" class="library-empty">
                            <div class="library-empty__icon">
                                <i class="fas fa-book"></i>
                            </div>
                            <h5>{{ $t("library-page.empty_title") }}</h5>
                            <div class="text-muted">
                                {{ $t("library-page.empty_subtitle") }}
                            </div>
                        </div>

                        <template v-else>
                            <div v-if="viewMode === 'grid'" class="row">
                                <div
                                    v-for="book in filteredBooks"
                                    :key="book.id"
                                    class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2 mb-4"
                                >
                                    <router-link
                                        :to="bookRoute(book)"
                                        class="library-book text-decoration-none"
                                    >
                                        <div class="library-book__inner">
                                            <div class="library-book__cover-wrap">
                                                <img
                                                    :src="book.cover"
                                                    :alt="book.title"
                                                    class="library-book__cover"
                                                    loading="lazy"
                                                />

                                                <div class="library-book__overlay">
                                                    <span class="library-book__action">
                                                        <i class="fas fa-book-open mr-1"></i>
                                                        {{ $t("library-page.open") }}
                                                    </span>
                                                </div>

                                                <span
                                                    v-if="book.isFavorite"
                                                    class="library-badge library-badge--favorite"
                                                >
                                                    {{ $t("library-page.favorite") }}
                                                </span>

                                                <span
                                                    v-else-if="book.isNewRelease"
                                                    class="library-badge library-badge--new"
                                                >
                                                    {{ $t("library-page.new") }}
                                                </span>

                                                <span
                                                    v-else-if="book.isPopular"
                                                    class="library-badge library-badge--popular"
                                                >
                                                    {{ $t("library-page.popular") }}
                                                </span>
                                            </div>

                                            <div class="library-book__body">
                                                <h6 class="library-book__title" :title="book.title">
                                                    {{ book.title }}
                                                </h6>

                                                <div class="library-book__author" :title="book.author">
                                                    {{ book.author }}
                                                </div>

                                                <div v-if="book.tags.length" class="library-book__tags">
                                                    <span
                                                        v-for="tag in book.tags.slice(0, 2)"
                                                        :key="tag.id || tag.name"
                                                        class="library-tag"
                                                    >
                                                        {{ tag.name }}
                                                    </span>
                                                </div>

                                                <div class="library-book__footer">
                                                    <span class="library-book__category">
                                                        {{ book.category_name || $t("library-page.uncategorized") }}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </router-link>
                                </div>
                            </div>

                            <div v-else class="library-list">
                                <router-link
                                    v-for="book in filteredBooks"
                                    :key="book.id"
                                    :to="bookRoute(book)"
                                    class="library-list__item text-decoration-none"
                                >
                                    <div class="library-list__thumb-wrap">
                                        <img
                                            :src="book.cover"
                                            :alt="book.title"
                                            class="library-list__thumb"
                                            loading="lazy"
                                        />

                                        <span
                                            v-if="book.isFavorite"
                                            class="library-badge library-badge--favorite"
                                        >
                                            {{ $t("library-page.favorite") }}
                                        </span>

                                        <span
                                            v-else-if="book.isNewRelease"
                                            class="library-badge library-badge--new"
                                        >
                                            {{ $t("library-page.new") }}
                                        </span>
                                    </div>

                                    <div class="library-list__content">
                                        <div class="library-list__top">
                                            <h6 class="library-list__title mb-1">
                                                {{ book.title }}
                                            </h6>

                                            <div class="d-flex align-items-center" style="gap: 8px">
                                                <span
                                                    v-if="book.isFavorite"
                                                    class="badge badge-danger"
                                                >
                                                    {{ $t("library-page.favorite") }}
                                                </span>

                                                <span
                                                    v-else-if="book.isPopular"
                                                    class="badge badge-warning"
                                                >
                                                    {{ $t("library-page.popular") }}
                                                </span>
                                            </div>
                                        </div>

                                        <div class="library-list__author">
                                            {{ book.author }}
                                        </div>

                                        <div class="library-list__category">
                                            {{ book.category_name || $t("library-page.uncategorized") }}
                                        </div>

                                        <div v-if="book.tags.length" class="library-list__tags">
                                            <span
                                                v-for="tag in book.tags.slice(0, 3)"
                                                :key="tag.id || tag.name"
                                                class="library-tag"
                                            >
                                                {{ tag.name }}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="library-list__action">
                                        <span class="btn btn-sm btn-primary">
                                            <i class="fas fa-book-open mr-1"></i>
                                            {{ $t("library-page.open") }}
                                        </span>
                                    </div>
                                </router-link>
                            </div>

                            <div v-if="totalPages > 1" class="library-pagination">
                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-sm"
                                    :disabled="currentPage <= 1"
                                    @click="goToPage(currentPage - 1)"
                                >
                                    <i class="fas fa-chevron-left mr-1"></i>
                                    {{ $t("library-page.prev") }}
                                </button>

                                <button
                                    v-for="page in visiblePages"
                                    :key="page"
                                    type="button"
                                    class="btn btn-sm"
                                    :class="page === currentPage ? 'btn-primary' : 'btn-outline-secondary'"
                                    @click="goToPage(page)"
                                >
                                    {{ page }}
                                </button>

                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-sm"
                                    :disabled="currentPage >= totalPages"
                                    @click="goToPage(currentPage + 1)"
                                >
                                    {{ $t("library-page.next") }}
                                    <i class="fas fa-chevron-right ml-1"></i>
                                </button>
                            </div>
                        </template>
                    </div>
                </div>

                <div v-if="recommendedBooks.length" class="card library-shell library-similar-card mt-4">
                    <div class="card-body">
                        <div class="library-section-head">
                            <div>
                                <h4 class="library-section-head__title">
                                    {{ $t("library-page.recommended_for_you") }}
                                </h4>
                            </div>

                            <span class="library-section-head__count">
                                {{ recommendedBooks.length }} {{ $t("library-page.books") }}
                            </span>
                        </div>

                        <div class="row">
                            <div
                                v-for="book in recommendedBooks"
                                :key="`recommended-${book.id}`"
                                class="col-12 col-sm-6 col-lg-4 col-xl-3 mb-4"
                            >
                                <router-link :to="bookRoute(book)" class="similar-book text-decoration-none">
                                    <div class="similar-book__cover-wrap">
                                        <img
                                            :src="book.cover"
                                            :alt="book.title"
                                            class="similar-book__cover"
                                            loading="lazy"
                                        />
                                    </div>

                                    <div class="similar-book__content">
                                        <div class="similar-book__meta">
                                            <span class="similar-book__category">
                                                {{ book.category_name || $t("library-page.uncategorized") }}
                                            </span>

                                            <span
                                                v-if="book.isFavorite"
                                                class="similar-book__type similar-book__type--favorite"
                                            >
                                                {{ $t("library-page.favorite") }}
                                            </span>

                                            <span
                                                v-else-if="book.isPopular"
                                                class="similar-book__type similar-book__type--popular"
                                            >
                                                {{ $t("library-page.popular") }}
                                            </span>

                                            <span
                                                v-else-if="book.isNewRelease"
                                                class="similar-book__type similar-book__type--new"
                                            >
                                                {{ $t("library-page.new") }}
                                            </span>
                                        </div>

                                        <h6 class="similar-book__title">{{ book.title }}</h6>
                                        <div class="similar-book__author">{{ book.author }}</div>

                                        <div v-if="book.tags.length" class="similar-book__tags">
                                            <span
                                                v-for="tag in book.tags.slice(0, 2)"
                                                :key="tag.id || tag.name"
                                                class="library-tag"
                                            >
                                                {{ tag.name }}
                                            </span>
                                        </div>
                                    </div>
                                </router-link>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-if="popularBooks.length" class="card library-shell library-similar-card mt-4">
                    <div class="card-body">
                        <div class="library-section-head">
                            <div>
                                <h4 class="library-section-head__title">
                                    {{ $t("library-page.book_popular") }}
                                </h4>
                            </div>

                            <span class="library-section-head__count">
                                {{ popularBooks.length }} {{ $t("library-page.books") }}
                            </span>
                        </div>

                        <div class="row">
                            <div
                                v-for="book in popularBooks"
                                :key="`popular-${book.id}`"
                                class="col-12 col-sm-6 col-lg-4 col-xl-3 mb-4"
                            >
                                <router-link :to="bookRoute(book)" class="similar-book text-decoration-none">
                                    <div class="similar-book__cover-wrap">
                                        <img
                                            :src="book.cover"
                                            :alt="book.title"
                                            class="similar-book__cover"
                                            loading="lazy"
                                        />
                                    </div>

                                    <div class="similar-book__content">
                                        <div class="similar-book__meta">
                                            <span class="similar-book__category">
                                                {{ book.category_name || $t("library-page.uncategorized") }}
                                            </span>

                                            <span class="similar-book__type similar-book__type--popular">
                                                {{ $t("library-page.popular") }}
                                            </span>
                                        </div>

                                        <h6 class="similar-book__title">{{ book.title }}</h6>
                                        <div class="similar-book__author">{{ book.author }}</div>

                                        <div v-if="book.tags.length" class="similar-book__tags">
                                            <span
                                                v-for="tag in book.tags.slice(0, 2)"
                                                :key="tag.id || tag.name"
                                                class="library-tag"
                                            >
                                                {{ tag.name }}
                                            </span>
                                        </div>
                                    </div>
                                </router-link>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            &nbsp;
        </section>
    </div>
</template>


<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { apiGetCategories } from "@func/api/category.js";
import {
    apiGetProfileFavorites,
    apiGetUsers_author,
    apiGetUserTagInterests,
    apiGetRecommendedBooks,
    apiGetRecommendedOverallBooks,
    apiGetSimilarTitleBooks,
} from "@func/api/user.js";

import { apiGetItems } from "@func/api/item.js";

const DEFAULT_COVER = "https://via.placeholder.com/300x420?text=No+Cover";

import { useI18n } from "vue-i18n";

const { t } = useI18n();

const searchQuery = ref("");
const selectedCategoryId = ref("19");
const viewMode = ref("grid");
const activeFilter = ref("all");
const loading = ref(false);
const errorMessage = ref("");

const books = ref([]);
const newReleaseBooks = ref([]);
const popularBooks = ref([]);
const interestedBooks = ref([]);
const recommendedBooks = ref([]);
const similarTitles = ref([]);

const categories = ref([]);
const authors = ref([]);
const favoriteIds = ref(new Set());
const userInterestTagMap = ref(new Map());

const currentPage = ref(1);
const perPage = ref(12);
const totalBooks = ref(0);

const similarTitlesLoading = ref(false);

const filterOptions = computed(() => [
    { label: t("library-page.filters.all"), value: "all" },
    { label: t("library-page.filters.favorites"), value: "favorite" },
]);

let searchTimer = null;
let similarRequestToken = 0;
let similarLastKey = "";

function getRows(response) {
    const payload = response?.data ?? {};

    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload.data)) return payload.data;
    if (Array.isArray(payload.items)) return payload.items;
    if (Array.isArray(payload.books)) return payload.books;
    if (Array.isArray(payload.categories)) return payload.categories;
    if (Array.isArray(payload.users)) return payload.users;
    if (Array.isArray(payload.favorites)) return payload.favorites;

    return [];
}

function toAbsoluteUrl(path) {
    if (!path) return DEFAULT_COVER;

    let value = String(path).trim();

    if (
        value.startsWith("http://") ||
        value.startsWith("https://") ||
        value.startsWith("//") ||
        value.startsWith("blob:") ||
        value.startsWith("data:")
    ) {
        return value;
    }

    value = value
        .replace(/^\/?api\//i, "")
        .replace(/^\/+/, "")
        .replace(/^public\//i, "storage/")
        .replace(/^storage\/storage\//i, "storage/");

    if (!value.startsWith("storage/")) {
        value = `storage/${value}`;
    }

    const base = String(
        import.meta.env.VITE_API_URL ||
        window.API_URL ||
        window.API_BASE_URL ||
        ""
    )
        .replace(/\/api$/i, "")
        .replace(/\/+$/, "");

    return base ? `${base}/${value}` : `/${value}`;
}

function normalizeCategories(rows = []) {
    return rows
        .map((row) => ({
            id: Number(row?.id || 0),
            name: String(row?.name || "Unnamed Category").trim(),
        }))
        .filter((row) => row.id);
}

function normalizeAuthors(rows = []) {
    return rows
        .map((row) => ({
            id: Number(row?.id || 0),
            name: String(row?.name || "Unknown Author").trim(),
        }))
        .filter((row) => row.id);
}

function getAuthorName(row) {
    if (row?.author?.name) return String(row.author.name).trim();
    if (row?.author_name) return String(row.author_name).trim();

    const authorId = Number(row?.author_id || 0);
    if (authorId) {
        const match = authors.value.find((item) => item.id === authorId);
        if (match?.name) return match.name;
    }

    return "Unknown Author";
}

function normalizeTags(row) {
    const source = Array.isArray(row?.tags) ? row.tags : [];

    return source
        .map((tag, index) => ({
            id: Number(tag?.id || tag?.tag_id || 0) || `${row?.id || "tag"}-${index}`,
            name: String(tag?.name || "").trim(),
        }))
        .filter((tag) => tag.name);
}

function normalizeBook(row, flags = {}) {
    const id = Number(row?.id || 0);
    const popularityScore = Number(
        row?.view_count ??
        row?.views_count ??
        row?.book_views_count ??
        row?.total_read ??
        0
    );

    return {
        id,
        title: String(row?.title || "Untitled").trim(),
        author_id: row?.author_id ? Number(row.author_id) : null,
        author: getAuthorName(row),
        cover_url: String(row?.cover_url || "").trim(),
        file_url: String(row?.file_url || "").trim(),
        cover: toAbsoluteUrl(row?.cover_url),
        category_id: row?.category_id ? Number(row.category_id) : null,
        category_name: String(
            row?.category?.name ||
            row?.category_name ||
            categories.value.find(
                (category) => category.id === Number(row?.category_id || 0)
            )?.name ||
            "Uncategorized"
        ).trim(),
        updated_at: row?.updated_at || null,
        created_at: row?.created_at || null,
        tags: normalizeTags(row),
        popularityScore: Number.isFinite(popularityScore) ? popularityScore : 0,
        final_score: Number(row?.final_score || 0),
        isFavorite: favoriteIds.value.has(id),
        isNewRelease:
            typeof flags.isNewRelease === "boolean"
                ? flags.isNewRelease
                : Boolean(row?.is_new_release ?? false),
        isPopular:
            typeof flags.isPopular === "boolean"
                ? flags.isPopular
                : Boolean(row?.is_popular ?? false),
    };
}

function normalizeBookList(rows = [], flags = {}) {
    return rows
        .map((row) => normalizeBook(row, flags))
        .filter((book) => book.id);
}

function syncFavoriteFlags(items = []) {
    return items.map((book) => ({
        ...book,
        isFavorite: favoriteIds.value.has(Number(book?.id || 0)),
    }));
}

function uniqueBooks(items = []) {
    const seen = new Set();

    return items.filter((book) => {
        const id = Number(book?.id || 0);
        if (!id || seen.has(id)) return false;
        seen.add(id);
        return true;
    });
}

const filteredBooks = computed(() => books.value);

const totalPages = computed(() =>
    Math.max(1, Math.ceil(totalBooks.value / perPage.value))
);

const visiblePages = computed(() => {
    const total = totalPages.value;
    const current = currentPage.value;

    if (total <= 7) {
        return Array.from({ length: total }, (_, index) => index + 1);
    }

    let start = Math.max(1, current - 2);
    let end = Math.min(total, current + 2);

    if (start === 1) end = 5;
    if (end === total) start = total - 4;

    return Array.from({ length: end - start + 1 }, (_, index) => start + index);
});

const categoryOptions = computed(() =>
    [...categories.value].sort((a, b) => a.name.localeCompare(b.name))
);

const similarBaseBook = computed(() => filteredBooks.value[0] || books.value[0] || null);

function computeSimilarLocal(base, limit = 4) {
    if (!base?.id) return [];

    const baseTitleWords = String(base.title || "")
        .toLowerCase()
        .split(/\s+/)
        .map((word) => word.replace(/[^\p{L}\p{N}]+/gu, ""))
        .filter((word) => word.length >= 2);

    const baseTagNames = new Set(
        (base.tags || []).map((tag) => String(tag.name || "").toLowerCase())
    );

    return books.value
        .filter((book) => Number(book.id) !== Number(base.id))
        .map((book) => {
            let score = 0;

            if (base.category_id && Number(book.category_id) === Number(base.category_id)) {
                score += 10;
            }

            const title = String(book.title || "").toLowerCase();
            for (const word of baseTitleWords) {
                if (word && title.includes(word)) {
                    score += 20;
                }
            }

            const matchedTags = (book.tags || []).filter((tag) =>
                baseTagNames.has(String(tag.name || "").toLowerCase())
            ).length;

            score += matchedTags * 8;

            if (book.isFavorite) {
                score += 15;
            }

            return {
                ...book,
                final_score: score,
            };
        })
        .filter((book) => book.final_score > 0)
        .sort((a, b) => {
            if (b.final_score !== a.final_score) {
                return b.final_score - a.final_score;
            }
            return a.title.localeCompare(b.title);
        })
        .slice(0, limit);
}

async function loadSimilarTitleBooks(options = {}) {
    const { force = false, limit = 4 } = options;
    const base = similarBaseBook.value;

    if (!base?.id) {
        similarTitles.value = [];
        similarLastKey = "";
        return;
    }

    const requestKey = `${base.id}:${limit}`;

    if (!force && similarLastKey === requestKey) {
        return;
    }

    similarLastKey = requestKey;
    const token = ++similarRequestToken;
    similarTitlesLoading.value = true;

    try {
        const response = await apiGetSimilarTitleBooks(base.id, { limit });
        const rows = getRows(response);

        if (token !== similarRequestToken) return;

        if (!rows.length) {
            similarTitles.value = computeSimilarLocal(base, limit);
            return;
        }

        similarTitles.value = syncFavoriteFlags(
            rows
                .map((row) =>
                    normalizeBook(row, {
                        isNewRelease: false,
                        isPopular: false,
                    })
                )
                .filter((book) => book.id && Number(book.id) !== Number(base.id))
                .slice(0, limit)
        );
    } catch (error) {
        if (token !== similarRequestToken) return;
        console.error("Failed to load similar title books:", error);
        similarTitles.value = computeSimilarLocal(base, limit);
    } finally {
        if (token === similarRequestToken) {
            similarTitlesLoading.value = false;
        }
    }
}

function bookRoute(book) {
    return {
        name: "book.details",
        params: { id: Number(book.id) },
    };
}

function clearSearch() {
    searchQuery.value = "";
}

async function fetchCategories() {
    try {
        categories.value = normalizeCategories(getRows(await apiGetCategories()));
    } catch (error) {
        console.error("Failed to load categories:", error);
        categories.value = [];
    }
}

async function fetchAuthors() {
    try {
        authors.value = normalizeAuthors(getRows(await apiGetUsers_author()));
    } catch (error) {
        console.error("Failed to load authors:", error);
        authors.value = [];
    }
}

async function fetchFavorites() {
    try {
        const rows = getRows(await apiGetProfileFavorites());
        favoriteIds.value = new Set(
            rows
                .map((row) => Number(row?.id || row?.book_id || row?.item_id || 0))
                .filter(Boolean)
        );
    } catch (error) {
        console.error("Failed to load favorites:", error);
        favoriteIds.value = new Set();
    }
}

async function fetchUserTagInterests() {
    try {
        const rows = getRows(await apiGetUserTagInterests());
        const interestMap = new Map();

        rows.forEach((row) => {
            const tagId = Number(row?.tag_id || row?.id || 0);
            if (!tagId) return;

            const score = Number(row?.total_score || row?.score || 1);
            interestMap.set(tagId, (interestMap.get(tagId) || 0) + score);
        });

        userInterestTagMap.value = interestMap;
    } catch (error) {
        console.error("Failed to load user tag interests:", error);
        userInterestTagMap.value = new Map();
    }
}

async function loadBooks(page = 1) {
    const params = {
        page,
        per_page: perPage.value,
        search: searchQuery.value.trim(),
        category_id: selectedCategoryId.value || "",
        filter: activeFilter.value || "all",
    };

    const response = await apiGetItems(params);
    const payload = response?.data ?? {};
    const rows = Array.isArray(payload?.data)
        ? payload.data
        : Array.isArray(payload)
            ? payload
            : [];

    books.value = syncFavoriteFlags(
        normalizeBookList(rows, {
            isNewRelease: activeFilter.value === "new",
            isPopular: activeFilter.value === "popular",
        })
    );

    currentPage.value = Number(payload?.current_page || page || 1);
    totalBooks.value = Number(payload?.total || rows.length || 0);
}

async function loadPopularBooks() {
    try {
        const response = await apiGetItems({
            per_page: 4,
            filter: "popular_section",
        });

        const payload = response?.data ?? {};
        const rows = Array.isArray(payload?.data)
            ? payload.data
            : Array.isArray(payload)
                ? payload
                : [];

        popularBooks.value = syncFavoriteFlags(
            normalizeBookList(rows, {
                isNewRelease: false,
                isPopular: true,
            })
        );
    } catch (error) {
        console.error("Failed to load popular books:", error);
        popularBooks.value = [];
    }
}

async function loadNewReleaseBooks() {
    try {
        const response = await apiGetItems({
            per_page: 4,
            filter: "new_release_section",
        });

        const payload = response?.data ?? {};
        const rows = Array.isArray(payload?.data)
            ? payload.data
            : Array.isArray(payload)
                ? payload
                : [];

        newReleaseBooks.value = syncFavoriteFlags(
            normalizeBookList(rows, {
                isNewRelease: true,
                isPopular: false,
            })
        );
    } catch (error) {
        console.error("Failed to load new release books:", error);
        newReleaseBooks.value = [];
    }
}

async function loadInterestedBooks() {
    try {
        const rows = getRows(await apiGetRecommendedBooks({ limit: 4 }));
        interestedBooks.value = syncFavoriteFlags(
            normalizeBookList(
                rows.map((row) => ({
                    ...row,
                    author_name: row?.author_name,
                    views_count: row?.views_count,
                })),
                {
                    isNewRelease: false,
                    isPopular: false,
                }
            )
        );
    } catch (error) {
        console.error("Failed to load interested books:", error);
        interestedBooks.value = [];
    }
}

async function loadRecommendedOverallBooks() {
    try {
        const response = await apiGetRecommendedOverallBooks({ limit: 4 });
        const rows = getRows(response);

        recommendedBooks.value = syncFavoriteFlags(
            normalizeBookList(
                rows.map((row) => ({
                    ...row,
                    author_name: row?.author_name,
                    views_count: row?.views_count,
                })),
                {
                    isNewRelease: false,
                    isPopular: false,
                }
            )
        );
    } catch (error) {
        console.error("Failed to load recommended overall books:", error);
        recommendedBooks.value = [];
    }
}

async function loadLibraryData() {
    loading.value = true;
    errorMessage.value = "";

    try {
        await Promise.all([
            fetchCategories(),
            fetchAuthors(),
            fetchFavorites(),
            fetchUserTagInterests(),
        ]);

        await Promise.all([
            loadBooks(1),
            loadNewReleaseBooks(),
            loadPopularBooks(),
            loadInterestedBooks(),
            loadRecommendedOverallBooks(),
        ]);
    } catch (error) {
        errorMessage.value =
            error?.response?.data?.message ||
            error?.message ||
            "Failed to load library data.";

        books.value = [];
        newReleaseBooks.value = [];
        popularBooks.value = [];
        interestedBooks.value = [];
        recommendedBooks.value = [];
        similarTitles.value = [];
        totalBooks.value = 0;
    } finally {
        loading.value = false;
    }
}

async function reloadBooksOnly() {
    loading.value = true;
    errorMessage.value = "";

    try {
        await loadBooks(1);
    } catch (error) {
        errorMessage.value =
            error?.response?.data?.message ||
            error?.message ||
            "Failed to load books.";
        books.value = [];
        similarTitles.value = [];
        totalBooks.value = 0;
    } finally {
        loading.value = false;
    }
}

async function reloadBooksPage(page) {
    loading.value = true;
    errorMessage.value = "";

    try {
        await loadBooks(page);
    } catch (error) {
        errorMessage.value =
            error?.response?.data?.message ||
            error?.message ||
            "Failed to load page.";
        books.value = [];
        similarTitles.value = [];
        totalBooks.value = 0;
    } finally {
        loading.value = false;
    }
}

function queueSearch() {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
        reloadBooksOnly();
    }, 400);
}

function goToPage(page) {
    if (page < 1 || page > totalPages.value || page === currentPage.value) return;
    currentPage.value = page;
    reloadBooksPage(page);
}

watch(searchQuery, queueSearch);
watch(selectedCategoryId, reloadBooksOnly);
watch(activeFilter, reloadBooksOnly);
watch(perPage, reloadBooksOnly);

watch(
    favoriteIds,
    () => {
        books.value = syncFavoriteFlags(books.value);
        newReleaseBooks.value = syncFavoriteFlags(newReleaseBooks.value);
        popularBooks.value = syncFavoriteFlags(popularBooks.value);
        interestedBooks.value = syncFavoriteFlags(interestedBooks.value);
        recommendedBooks.value = syncFavoriteFlags(recommendedBooks.value);
        similarTitles.value = syncFavoriteFlags(similarTitles.value);
    },
    { deep: false }
);

watch(
    () => similarBaseBook.value?.id || null,
    async (newId, oldId) => {
        if (!newId) {
            similarTitles.value = [];
            similarLastKey = "";
            return;
        }

        if (newId === oldId) return;

        await loadSimilarTitleBooks({ force: true, limit: 4 });
    },
    { immediate: true }
);

onMounted(loadLibraryData);

onBeforeUnmount(() => {
    clearTimeout(searchTimer);
});
</script>

<style scoped>
.library-page {
    --bg: #f4f6fb;
    --card: #ffffff;
    --border: rgba(0, 0, 0, 0.08);
    --text: #111827;
    --muted: #6b7280;
    --primary: #2563eb;
    --shadow: 0 12px 28px rgba(15, 23, 42, 0.08);
    --soft: #f9fafb;
    background: var(--bg);
    min-height: 100%;
    color: var(--text);
}

.library-page__title {
    color: var(--text);
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 4px;
}

.library-page__subtitle {
    color: var(--muted);
}

.library-shell {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
    overflow: hidden;
}

.library-toolbar {
    display: grid;
    grid-template-columns: minmax(260px, 1fr) 220px auto;
    gap: 14px;
    align-items: center;
    margin-bottom: 16px;
}

.library-search {
    position: relative;
    width: 100%;
}

.library-search__icon {
    position: absolute;
    top: 50%;
    left: 14px;
    transform: translateY(-50%);
    color: var(--muted);
    pointer-events: none;
}

.library-search__input {
    height: 46px;
    border-radius: 14px;
    padding-left: 42px;
    padding-right: 42px;
    border: 1px solid var(--border);
    background: var(--soft);
    color: var(--text);
    box-shadow: none !important;
}

.library-search__input:focus {
    border-color: rgba(37, 99, 235, 0.35);
    background: var(--card);
    color: var(--text);
}

.library-search__clear {
    position: absolute;
    top: 50%;
    right: 10px;
    transform: translateY(-50%);
    width: 28px;
    height: 28px;
    border: none;
    border-radius: 50%;
    background: transparent;
    color: var(--muted);
}

.library-search__clear:hover {
    background: rgba(0, 0, 0, 0.05);
}

.library-category__select {
    height: 46px;
    border-radius: 14px;
    border: 1px solid var(--border);
    background: var(--soft);
    color: var(--text);
    box-shadow: none !important;
}

.library-category__select:focus {
    border-color: rgba(37, 99, 235, 0.35);
    background: var(--card);
    color: var(--text);
}

.library-filters {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 16px;
}

.library-filter-btn {
    border-radius: 999px;
    padding-left: 14px;
    padding-right: 14px;
}

.library-meta {
    margin-bottom: 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}

.library-meta__left,
.library-meta__right {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.library-per-page {
    width: 110px;
    min-width: 110px;
}

.library-loading {
    min-height: 180px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--muted);
}

.library-empty {
    text-align: center;
    padding: 54px 20px;
    color: var(--muted);
}

.library-empty__icon {
    width: 72px;
    height: 72px;
    margin: 0 auto 14px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    background: #eef2ff;
    color: var(--primary);
    font-size: 28px;
}

.library-book {
    display: block;
    perspective: 1200px;
    color: inherit;
}

.library-book__inner {
    background: var(--card);
    border-radius: 18px;
    overflow: hidden;
    border: 1px solid var(--border);
    box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08);
    transform-style: preserve-3d;
    transition: transform 0.28s ease, box-shadow 0.28s ease;
    height: 100%;
}

.library-book:hover .library-book__inner {
    transform: rotateX(7deg) rotateY(-10deg) translateY(-8px) scale(1.02);
    box-shadow: 0 22px 38px rgba(15, 23, 42, 0.18);
}

.library-book__cover-wrap {
    position: relative;
    height: 250px;
    overflow: hidden;
    background: #f3f4f6;
}

.library-book__cover {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.35s ease;
}

.library-book:hover .library-book__cover {
    transform: scale(1.06);
}

.library-book__overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(15, 23, 42, 0.78), rgba(15, 23, 42, 0.08));
    opacity: 0;
    transition: opacity 0.28s ease;
    display: flex;
    align-items: flex-end;
    justify-content: center;
    padding: 14px;
}

.library-book:hover .library-book__overlay {
    opacity: 1;
}

.library-book__action {
    background: rgba(255, 255, 255, 0.96);
    color: #111827;
    font-weight: 600;
    font-size: 13px;
    padding: 8px 14px;
    border-radius: 999px;
    box-shadow: 0 8px 18px rgba(0, 0, 0, 0.18);
}

.library-book__body {
    padding: 14px;
}

.library-book__title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text);
    line-height: 1.35;
    min-height: 38px;
    margin-bottom: 4px;
    overflow: hidden;
}

.library-book__author {
    font-size: 12px;
    color: var(--muted);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin-bottom: 10px;
}

.library-book__tags,
.library-list__tags,
.similar-book__tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 10px;
}

.library-tag {
    display: inline-flex;
    align-items: center;
    font-size: 11px;
    font-weight: 600;
    padding: 4px 8px;
    border-radius: 999px;
    background: #f3f4f6;
    color: #374151;
    border: 1px solid rgba(0, 0, 0, 0.06);
}

.library-book__footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.library-book__category {
    font-size: 11px;
    font-weight: 700;
    color: var(--primary);
    background: #eff6ff;
    padding: 5px 10px;
    border-radius: 999px;
}

.library-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    z-index: 2;
    font-size: 10px;
    font-weight: 800;
    padding: 4px 8px;
    border-radius: 999px;
    color: #fff;
}

.library-badge--new {
    background: #dc2626;
}

.library-badge--popular {
    background: #f59e0b;
    color: #111827;
}

.library-badge--favorite {
    background: #e11d48;
}

.library-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.library-list__item {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 12px;
    border: 1px solid var(--border);
    border-radius: 16px;
    background: var(--card);
    box-shadow: 0 8px 18px rgba(15, 23, 42, 0.06);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    color: inherit;
}

.library-list__item:hover {
    transform: translateY(-2px);
    box-shadow: 0 14px 24px rgba(15, 23, 42, 0.12);
}

.library-list__thumb-wrap {
    position: relative;
    flex: 0 0 auto;
}

.library-list__thumb {
    width: 70px;
    height: 96px;
    border-radius: 12px;
    object-fit: cover;
    border: 1px solid var(--border);
}

.library-list__content {
    flex: 1;
    min-width: 0;
}

.library-list__top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
}

.library-list__title {
    font-size: 15px;
    font-weight: 700;
    color: var(--text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.library-list__author {
    font-size: 13px;
    color: var(--muted);
    margin-bottom: 6px;
}

.library-list__category {
    font-size: 12px;
    font-weight: 600;
    color: var(--primary);
    margin-bottom: 8px;
}

.library-list__action {
    flex: 0 0 auto;
}

.library-pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 20px;
}

.library-similar-card {
    margin-bottom: 24px;
}

.library-section-head {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 18px;
}

.library-section-head__title {
    font-size: 20px;
    font-weight: 700;
    color: var(--text);
    margin-bottom: 4px;
}

.library-section-head__subtitle {
    font-size: 13px;
    color: var(--muted);
}

.library-section-head__count {
    display: inline-flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    background: var(--soft);
    color: var(--text);
    border: 1px solid var(--border);
    white-space: nowrap;
}

.similar-book {
    display: flex;
    gap: 12px;
    align-items: stretch;
    height: 100%;
    padding: 12px;
    border-radius: 16px;
    border: 1px solid var(--border);
    background: var(--card);
    color: inherit;
    box-shadow: 0 8px 20px rgba(15, 23, 42, 0.06);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.similar-book:hover {
    transform: translateY(-3px);
    box-shadow: 0 16px 28px rgba(15, 23, 42, 0.12);
}

.similar-book__cover-wrap {
    flex: 0 0 76px;
}

.similar-book__cover {
    width: 76px;
    height: 108px;
    object-fit: cover;
    border-radius: 12px;
    border: 1px solid var(--border);
    background: #f3f4f6;
}

.similar-book__content {
    min-width: 0;
    flex: 1;
}

.similar-book__meta {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 8px;
}

.similar-book__category,
.similar-book__type {
    font-size: 10px;
    font-weight: 800;
    border-radius: 999px;
    padding: 4px 8px;
}

.similar-book__category {
    color: var(--primary);
    background: #eff6ff;
}

.similar-book__type--new {
    background: #fee2e2;
    color: #b91c1c;
}

.similar-book__type--popular {
    background: #fef3c7;
    color: #92400e;
}

.similar-book__type--favorite {
    background: #ffe4e6;
    color: #be123c;
}

.similar-book__title {
    font-size: 14px;
    font-weight: 700;
    color: var(--text);
    line-height: 1.4;
    margin-bottom: 4px;
}

.similar-book__author {
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 10px;
}

@media (max-width: 991.98px) {
    .library-toolbar {
        grid-template-columns: 1fr;
    }

    .library-view-switch {
        width: 100%;
    }

    .library-view-switch .btn {
        flex: 1;
    }
}

@media (max-width: 767.98px) {
    .library-list__item {
        align-items: flex-start;
    }

    .library-list__action {
        display: none;
    }

    .library-section-head {
        flex-direction: column;
    }

    .similar-book {
        align-items: flex-start;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.library-page,
html.dark-mode .content-wrapper.library-page,
.dark-mode .content-wrapper.library-page {
    background: #0f172a !important;
}

body.dark-mode .library-page,
html.dark-mode .library-page,
.dark-mode .library-page {
    --bg: #0f172a;
    --card: #111827;
    --border: rgba(255, 255, 255, 0.08);
    --text: #e5e7eb;
    --muted: #9ca3af;
    --primary: #60a5fa;
    --shadow: 0 12px 28px rgba(0, 0, 0, 0.35);
    --soft: #0b1220;
    color: var(--text) !important;
}

body.dark-mode .library-page .card,
html.dark-mode .library-page .card,
.dark-mode .library-page .card,
body.dark-mode .library-page .library-shell,
html.dark-mode .library-page .library-shell,
.dark-mode .library-page .library-shell {
    background: var(--card) !important;
    border-color: var(--border) !important;
    color: var(--text) !important;
}

body.dark-mode .library-page .library-search__input,
body.dark-mode .library-page .library-category__select,
html.dark-mode .library-page .library-search__input,
html.dark-mode .library-page .library-category__select,
.dark-mode .library-page .library-search__input,
.dark-mode .library-page .library-category__select {
    background: var(--soft) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .library-page .library-book__inner,
body.dark-mode .library-page .library-list__item,
body.dark-mode .library-page .similar-book,
html.dark-mode .library-page .library-book__inner,
html.dark-mode .library-page .library-list__item,
html.dark-mode .library-page .similar-book,
.dark-mode .library-page .library-book__inner,
.dark-mode .library-page .library-list__item,
.dark-mode .library-page .similar-book {
    background: var(--card) !important;
    border-color: var(--border) !important;
}

body.dark-mode .library-page .library-tag,
body.dark-mode .library-page .library-section-head__count,
html.dark-mode .library-page .library-tag,
html.dark-mode .library-page .library-section-head__count,
.dark-mode .library-page .library-tag,
.dark-mode .library-page .library-section-head__count {
    background: #1f2937 !important;
    color: #d1d5db !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
}
</style>
