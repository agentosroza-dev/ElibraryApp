<template>
    <div class="content-wrapper search-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="d-flex justify-content-between align-items-center flex-wrap">
                    <div>
                        <h1 class="search-page__title">{{ $t("search-page.title") }}</h1>
                        <div class="search-page__subtitle">
                            {{ $t("search-page.subtitle") }}
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="content pt-3">
            <div class="container-fluid">
                <div class="search-hero mb-4">
                    <div class="search-hero__content">
                        <div class="search-hero__badge">
                            <i class="fas fa-search mr-2"></i>
                            {{ $t("search-page.smart_search") }}
                        </div>

                        <h3 class="search-hero__title">
                            {{ $t("search-page.hero_title") }}
                        </h3>

                        <p class="search-hero__text">
                            {{ $t("search-page.hero_text") }}
                        </p>

                        <div class="search-box">
                            <i class="fas fa-search search-box__icon"></i>

                            <input
                                v-model.trim="searchQuery"
                                type="text"
                                class="form-control search-box__input"
                                :placeholder="$t('search-page.search_placeholder')"
                                @input="onSearchInput"
                                @keyup.enter="submitSearch"
                            />

                            <button
                                v-if="searchQuery"
                                type="button"
                                class="search-box__clear"
                                @click="clearSearch"
                            >
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="search-filters mb-4">
                    <button
                        v-for="chip in filterChips"
                        :key="chip.value"
                        type="button"
                        class="btn btn-sm search-filter-btn"
                        :class="sortMode === chip.value ? 'btn-primary' : 'btn-outline-secondary'"
                        @click="changeSort(chip.value)"
                    >
                        {{ chip.label }}
                    </button>
                </div>

                <div v-if="!hasSearchQuery" class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card search-card h-100">
                            <div class="card-header search-card__header">
                                <h5 class="mb-0">
                                    {{ $t("search-page.recent_searches") }}
                                </h5>

                                <button
                                    v-if="recentSearches.length"
                                    type="button"
                                    class="btn btn-xs btn-outline-danger"
                                    @click="clearHistory"
                                >
                                    {{ $t("search-page.clear") }}
                                </button>
                            </div>

                            <div class="card-body">
                                <div v-if="recentSearches.length" class="search-chip-list">
                                    <button
                                        v-for="item in recentSearches"
                                        :key="item"
                                        type="button"
                                        class="btn btn-sm btn-outline-primary rounded-pill"
                                        @click="applyQuickSearch(item)"
                                    >
                                        <i class="fas fa-history mr-1"></i>
                                        {{ item }}
                                    </button>
                                </div>

                                <div v-else class="search-empty-mini">
                                    <div class="search-empty-mini__icon">
                                        <i class="fas fa-history"></i>
                                    </div>
                                    <div class="search-empty-mini__text">
                                        {{ $t("search-page.recent_empty") }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-6 mb-4">
                        <div class="card search-card h-100">
                            <div class="card-header search-card__header">
                                <h5 class="mb-0">
                                    {{ $t("search-page.trending_searches") }}
                                </h5>
                            </div>

                            <div class="card-body">
                                <div v-if="trendingSearches.length" class="search-chip-list">
                                    <button
                                        v-for="item in trendingSearches"
                                        :key="item.id || item.name || item"
                                        type="button"
                                        class="btn btn-sm btn-outline-secondary rounded-pill"
                                        @click="applyQuickSearch(getTrendLabel(item))"
                                    >
                                        <i class="fas fa-fire mr-1 text-warning"></i>
                                        {{ getTrendLabel(item) }}
                                    </button>
                                </div>

                                <div v-else class="search-empty-mini">
                                    <div class="search-empty-mini__icon">
                                        <i class="fas fa-fire"></i>
                                    </div>
                                    <div class="search-empty-mini__text">
                                        {{ $t("search-page.trending_empty") }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12">
                        <div class="card search-card">
                            <div class="card-header search-card__header">
                                <h5 class="mb-0">
                                    {{ $t("search-page.suggested_books") }}
                                </h5>
                            </div>

                            <div class="card-body">
                                <div v-if="suggestedBooks.length" class="row">
                                    <div
                                        v-for="book in suggestedBooks"
                                        :key="book.id"
                                        class="col-12 col-sm-6 col-md-4 col-lg-3 mb-4"
                                    >
                                        <router-link
                                            :to="{ name: 'book.details', params: { id: book.id } }"
                                            class="suggested-book text-decoration-none"
                                        >
                                            <div class="suggested-book__cover">
                                                <img :src="book.image" :alt="book.title" />
                                            </div>

                                            <div class="suggested-book__body">
                                                <div class="suggested-book__title" :title="book.title">
                                                    {{ book.title }}
                                                </div>

                                                <div class="suggested-book__author">
                                                    {{ book.author.name }}
                                                </div>

                                                <div class="suggested-book__stats">
                                                    <span class="search-stat">
                                                        <i class="fas fa-eye mr-1"></i>
                                                        {{ formatViews(book.views_count) }}
                                                    </span>
                                                </div>

                                                <div v-if="book.tags.length" class="suggested-book__tags">
                                                    <span
                                                        v-for="tag in book.tags.slice(0, 2)"
                                                        :key="`${book.id}-${tag}`"
                                                        class="search-tag"
                                                    >
                                                        {{ tag }}
                                                    </span>
                                                </div>
                                            </div>
                                        </router-link>
                                    </div>
                                </div>

                                <div v-else class="search-empty-mini">
                                    <div class="search-empty-mini__icon">
                                        <i class="fas fa-book"></i>
                                    </div>
                                    <div class="search-empty-mini__text">
                                        {{ $t("search-page.suggested_empty") }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <template v-else>
                    <div class="search-results-top mb-3">
                        <div>
                            <h5 class="mb-1">
                                {{ $t("search-page.results_for") }}
                                <span class="search-highlight">"{{ searchQuery }}"</span>
                            </h5>
                            <div class="search-results-top__meta">
                                {{ pagination.total }} {{ $t("search-page.results_found") }}
                            </div>
                        </div>
                    </div>

                    <div v-if="searchLoading" class="card search-card">
                        <div class="card-body search-empty">
                            <div class="search-empty__icon">
                                <i class="fas fa-spinner fa-spin"></i>
                            </div>
                            <div class="search-empty__text">
                                {{ $t("search-page.searching") }}
                            </div>
                        </div>
                    </div>

                    <div v-else-if="results.length">
                        <div v-if="bestResult" class="card search-card featured-card mb-4">
                            <div class="row no-gutters">
                                <div class="col-md-3">
                                    <div class="featured-card__image-wrap">
                                        <img
                                            :src="bestResult.image"
                                            :alt="bestResult.title"
                                            class="featured-card__image"
                                        />
                                        <span class="featured-card__badge">
                                            {{ $t("search-page.best_match") }}
                                        </span>
                                    </div>
                                </div>

                                <div class="col-md-9">
                                    <div class="card-body featured-card__body">
                                        <div class="featured-card__category">
                                            {{ bestResult.category.name }}
                                        </div>

                                        <h4 class="featured-card__title">
                                            {{ bestResult.title }}
                                        </h4>

                                        <div class="featured-card__author">
                                            {{ $t("search-page.by") }} {{ bestResult.author.name }}
                                        </div>

                                        <div class="featured-card__stats">
                                            <span class="search-stat mr-3">
                                                <i class="fas fa-eye mr-1"></i>
                                                {{ formatViews(bestResult.views_count) }}
                                            </span>
                                        </div>

                                        <p class="featured-card__desc">
                                            {{ bestResult.description }}
                                        </p>

                                        <div v-if="bestResult.tags.length" class="featured-card__tags">
                                            <button
                                                v-for="tag in bestResult.tags"
                                                :key="`${bestResult.id}-${tag}`"
                                                type="button"
                                                class="search-tag search-tag--button"
                                                @click="applyQuickSearch(tag)"
                                            >
                                                <i class="fas fa-tag mr-1"></i>
                                                {{ tag }}
                                            </button>
                                        </div>

                                        <div class="featured-card__actions">
                                            <router-link
                                                v-if="readRoute"
                                                :to="readRoute"
                                                class="btn btn-primary btn-sm"
                                            >
                                                <i class="fas fa-book-open mr-1"></i>
                                                {{ $t("search-page.read_book") }}
                                            </router-link>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="search-list">
                            <router-link
                                v-for="book in otherResults"
                                :key="book.id"
                                :to="{ name: 'book.details', params: { id: book.id } }"
                                class="search-item text-decoration-none"
                            >
                                <img :src="book.image" :alt="book.title" class="search-item__thumb" />

                                <div class="search-item__body">
                                    <div class="search-item__top">
                                        <div class="search-item__title">
                                            {{ book.title }}
                                        </div>

                                        <span class="search-item__badge">
                                            {{ book.category.name }}
                                        </span>
                                    </div>

                                    <div class="search-item__author">
                                        {{ $t("search-page.by") }} {{ book.author.name }}
                                    </div>

                                    <div class="search-item__stats">
                                        <span class="search-stat mr-3">
                                            <i class="fas fa-eye mr-1"></i>
                                            {{ formatViews(book.views_count) }}
                                        </span>
                                    </div>

                                    <div class="search-item__desc">
                                        {{ book.description }}
                                    </div>

                                    <div v-if="book.tags.length" class="search-item__tags">
                                        <span
                                            v-for="tag in book.tags.slice(0, 3)"
                                            :key="`${book.id}-${tag}`"
                                            class="search-tag"
                                        >
                                            {{ tag }}
                                        </span>
                                    </div>
                                </div>
                            </router-link>
                        </div>

                        <div
                            v-if="pagination.last_page > 1"
                            class="d-flex justify-content-center mt-4"
                        >
                            <button
                                type="button"
                                class="btn btn-outline-secondary mr-2"
                                :disabled="pagination.current_page <= 1 || searchLoading"
                                @click="goToPage(pagination.current_page - 1)"
                            >
                                {{ $t("search-page.previous") }}
                            </button>

                            <button
                                type="button"
                                class="btn btn-outline-secondary"
                                :disabled="pagination.current_page >= pagination.last_page || searchLoading"
                                @click="goToPage(pagination.current_page + 1)"
                            >
                                {{ $t("search-page.next") }}
                            </button>
                        </div>
                    </div>

                    <div v-else class="card search-card">
                        <div class="card-body search-empty">
                            <div class="search-empty__icon">
                                <i class="fas fa-search"></i>
                            </div>

                            <h4 class="mb-2">
                                {{ $t("search-page.no_results") }}
                            </h4>

                            <div class="search-empty__text mb-3">
                                {{ $t("search-page.try_another") }}
                            </div>

                            <div class="search-chip-list justify-content-center">
                                <button
                                    v-for="item in quickSearches"
                                    :key="item"
                                    type="button"
                                    class="btn btn-sm btn-outline-secondary rounded-pill"
                                    @click="applyQuickSearch(item)"
                                >
                                    {{ item }}
                                </button>
                            </div>
                        </div>
                    </div>
                </template>
            </div>
        </section>
    </div>
</template>


<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import {
    apiGetItems,
    apiGetSuggestedBooks,
    apiGetTrendingSearches,
    apiSearchBooks,
    apiGetBookViewCount,
} from "@func/api/item.js";
import { apiGetUserTagInterests } from "@func/api/user.js";

const STORAGE_KEY = "library-search-history";
const SEARCH_DELAY = 350;
const SUGGESTION_LIMIT = 8;
const SEARCH_PER_PAGE = 12;
const DEFAULT_COVER = "https://via.placeholder.com/300x420?text=No+Cover";

const searchQuery = ref("");
const sortMode = ref("best");
const bootstrapLoading = ref(false);
const searchLoading = ref(false);

const allBooks = ref([]);
const results = ref([]);
const recentSearches = ref([]);
const trendingSearches = ref([]);
const suggestedFromApi = ref([]);
const userInterestTagIds = ref(new Set());

const bookViewCountMap = ref({});
const bookViewPendingMap = ref({});

import { useI18n } from "vue-i18n";

const { t } = useI18n();

const pagination = ref({
    current_page: 1,
    last_page: 1,
    per_page: SEARCH_PER_PAGE,
    total: 0,
});

const filterChips = computed(() => [
    { label: t("search-page.filters.best_match"), value: "best" },
    { label: t("search-page.filters.most_popular"), value: "popular" },
    { label: t("search-page.filters.newest"), value: "newest" },
]);

let searchTimer = null;

const hasSearchQuery = computed(() => searchQuery.value.trim().length > 0);
const bestResult = computed(() => results.value[0] || null);
const otherResults = computed(() => results.value.slice(1));

const quickSearches = computed(() => {
    const trendNames = trendingSearches.value.map((item) => getTrendLabel(item));
    return [...new Set([...trendNames, ...recentSearches.value])]
        .filter(Boolean)
        .slice(0, 8);
});

const suggestedBooks = computed(() => {
    if (suggestedFromApi.value.length) {
        return suggestedFromApi.value.slice(0, SUGGESTION_LIMIT);
    }

    const preferred = allBooks.value;
    if (!preferred.length) return [];

    const interestIds = userInterestTagIds.value;

    return [...preferred]
        .map((book) => {
            const matchedInterestTags = book.tag_ids.filter((id) => interestIds.has(id)).length;

            return {
                ...book,
                suggested_score:
                    matchedInterestTags * 100 +
                    Math.min(book.views_count, 1000) +
                    Math.min(book.created_at_ts / 100000000, 100),
            };
        })
        .sort((a, b) => {
            if (b.suggested_score !== a.suggested_score) {
                return b.suggested_score - a.suggested_score;
            }
            if (b.views_count !== a.views_count) {
                return b.views_count - a.views_count;
            }
            return b.created_at_ts - a.created_at_ts;
        })
        .slice(0, SUGGESTION_LIMIT);
});

function normalizeFilePath(path) {
    return String(path || "")
        .replace(/^https?:\/\/[^/]+/i, "")
        .replace(/^\/+/, "");
}

const readRoute = computed(() => {
    const bookId = Number(bestResult.value?.id || 0);
    const filePath = normalizeFilePath(bestResult.value?.file_url);

    if (!bookId || !filePath) return null;

    return {
        name: "book.details.view",
        params: { id: bookId },
        query: {
            file: `/${filePath}`,
            title: bestResult.value?.title || "PDF Preview",
        },
    };
});

function toNumber(value, fallback = 0) {
    const num = Number(value);
    return Number.isFinite(num) ? num : fallback;
}

function normalizeRows(data) {
    if (Array.isArray(data)) return data;
    if (Array.isArray(data?.data)) return data.data;
    if (Array.isArray(data?.items)) return data.items;
    return [];
}

function normalizeBook(row) {
    const authorName =
        row?.author?.name ||
        row?.author_name ||
        row?.author ||
        "Unknown Author";

    const categoryName =
        row?.category?.name ||
        row?.category_name ||
        row?.category ||
        "Uncategorized";

    const image =
        row?.image ||
        row?.cover_url ||
        row?.cover ||
        row?.thumbnail ||
        DEFAULT_COVER;

    const rawTags = Array.isArray(row?.tags) ? row.tags : [];
    const tags = rawTags
        .map((tag) =>
            typeof tag === "string"
                ? tag.trim()
                : String(tag?.name || tag?.title || "").trim()
        )
        .filter(Boolean);

    const tagIds = rawTags
        .map((tag) => Number(tag?.id || tag?.tag_id || 0))
        .filter(Boolean);

    const createdAt = row?.created_at || row?.updated_at || null;

    return {
        id: Number(row?.id || 0),
        title: String(row?.title || "Untitled"),
        slug: String(row?.slug || ""),
        description: String(row?.description || "No description available."),
        image: String(image || DEFAULT_COVER),
        file_url: String(row?.file_url || ""),
        author: {
            id: Number(row?.author?.id || row?.author_id || 0),
            name: String(authorName || "Unknown Author"),
        },
        category: {
            id: Number(row?.category?.id || row?.category_id || 0),
            name: String(categoryName || "Uncategorized"),
        },
        tags,
        tag_ids: tagIds,
        views_count: toNumber(
            row?.views_count ??
            row?.view_count ??
            row?.total_read ??
            row?.total_reads ??
            row?.views ??
            row?.count ??
            0
        ),
        suggested_score: toNumber(row?.suggested_score, 0),
        search_score: toNumber(row?.search_score, 0),
        created_at: createdAt,
        created_at_ts: createdAt ? new Date(createdAt).getTime() || 0 : 0,
    };
}

function normalizeInterestTagIds(data) {
    const rows = normalizeRows(data);

    return new Set(
        rows
            .map((row) => Number(row?.tag_id || row?.id || 0))
            .filter(Boolean)
    );
}

function normalizeText(value) {
    return String(value || "").trim().toLowerCase();
}

function splitTerms(value) {
    return normalizeText(value)
        .split(/\s+/)
        .map((item) => item.trim())
        .filter(Boolean);
}

function getTrendLabel(item) {
    if (typeof item === "string") return item.trim();
    return String(item?.name || item?.title || item?.keyword || "").trim();
}

function calculateLocalSearchScore(book, query, terms) {
    const title = normalizeText(book.title);
    const author = normalizeText(book.author.name);
    const category = normalizeText(book.category.name);
    const description = normalizeText(book.description);
    const tags = book.tags.map((tag) => normalizeText(tag));
    const tagsText = tags.join(" ");

    let score = 0;

    if (title === query) score += 1000;
    if (title.startsWith(query)) score += 650;
    if (title.includes(query)) score += 350;

    if (tags.includes(query)) score += 320;
    else if (tags.some((tag) => tag.includes(query))) score += 220;

    if (author.includes(query)) score += 120;
    if (category.includes(query)) score += 70;
    if (description.includes(query)) score += 40;

    for (const term of terms) {
        if (!term) continue;

        if (title === term) score += 160;
        if (title.startsWith(term)) score += 90;
        if (title.includes(term)) score += 55;

        if (tags.includes(term)) score += 70;
        else if (tagsText.includes(term)) score += 35;

        if (author.includes(term)) score += 24;
        if (category.includes(term)) score += 12;
        if (description.includes(term)) score += 8;
    }

    if (terms.length > 1) {
        const matchedTitleTerms = terms.filter((term) => title.includes(term)).length;
        const matchedTagTerms = terms.filter((term) => tagsText.includes(term)).length;

        score += matchedTitleTerms * 35;
        score += matchedTagTerms * 22;
    }

    score += Math.min(book.views_count, 500) * 0.3;

    return Math.round(score);
}

function buildLocalSearchFallback(q) {
    const query = normalizeText(q);
    if (!query) return [];

    const terms = splitTerms(query);

    const rows = allBooks.value
        .map((book) => ({
            ...book,
            search_score: calculateLocalSearchScore(book, query, terms),
        }))
        .filter((book) => book.search_score > 0);

    if (sortMode.value === "popular") {
        return rows.sort((a, b) => {
            if (b.views_count !== a.views_count) return b.views_count - a.views_count;
            if (b.search_score !== a.search_score) return b.search_score - a.search_score;
            return b.created_at_ts - a.created_at_ts;
        });
    }

    if (sortMode.value === "newest") {
        return rows.sort((a, b) => {
            if (b.created_at_ts !== a.created_at_ts) return b.created_at_ts - a.created_at_ts;
            if (b.search_score !== a.search_score) return b.search_score - a.search_score;
            return b.views_count - a.views_count;
        });
    }

    return rows.sort((a, b) => {
        if (b.search_score !== a.search_score) return b.search_score - a.search_score;
        if (b.views_count !== a.views_count) return b.views_count - a.views_count;
        return b.created_at_ts - a.created_at_ts;
    });
}

function saveSearch(value) {
    const q = String(value || "").trim();
    if (!q) return;

    const normalized = q.toLowerCase();
    const next = [
        q,
        ...recentSearches.value.filter((item) => item.toLowerCase() !== normalized),
    ].slice(0, 10);

    recentSearches.value = next;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
}

function loadRecentSearches() {
    try {
        const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
        recentSearches.value = Array.isArray(saved) ? saved : [];
    } catch {
        recentSearches.value = [];
    }
}

function clearHistory() {
    recentSearches.value = [];
    localStorage.removeItem(STORAGE_KEY);
}

function clearSearch() {
    searchQuery.value = "";
    results.value = [];
    pagination.value = {
        current_page: 1,
        last_page: 1,
        per_page: SEARCH_PER_PAGE,
        total: 0,
    };
    clearTimeout(searchTimer);
}

function formatViews(value) {
    const count = Number(value || 0);

    if (count >= 1000000) return `${(count / 1000000).toFixed(1)}M`;
    if (count >= 1000) return `${(count / 1000).toFixed(1)}K`;
    return String(count);
}

function applyQuickSearch(value) {
    const q = String(value || "").trim();
    if (!q) return;

    searchQuery.value = q;
    submitSearch();
}

function changeSort(value) {
    if (sortMode.value === value) return;
    sortMode.value = value;

    if (hasSearchQuery.value) {
        fetchSearchResults(1);
    }
}

function onSearchInput() {
    clearTimeout(searchTimer);

    if (!hasSearchQuery.value) {
        results.value = [];
        pagination.value = {
            current_page: 1,
            last_page: 1,
            per_page: SEARCH_PER_PAGE,
            total: 0,
        };
        return;
    }

    searchTimer = setTimeout(() => {
        fetchSearchResults(1);
    }, SEARCH_DELAY);
}

function submitSearch() {
    if (!hasSearchQuery.value) return;

    saveSearch(searchQuery.value);
    fetchSearchResults(1);
}

function goToPage(page) {
    fetchSearchResults(page);
}

async function loadBookViewCount(book) {
    const bookId = Number(book?.id || 0);
    if (!bookId) return 0;

    if (bookViewCountMap.value[bookId] !== undefined) {
        book.views_count = toNumber(bookViewCountMap.value[bookId], book.views_count || 0);
        return book.views_count;
    }

    if (bookViewPendingMap.value[bookId]) {
        return bookViewPendingMap.value[bookId];
    }

    bookViewPendingMap.value[bookId] = apiGetBookViewCount(bookId)
        .then((response) => {
            const data = response?.data ?? response ?? {};

            const count = toNumber(
                data?.views_count ??
                data?.total_reads ??
                data?.views ??
                data?.count ??
                data?.data?.views_count ??
                0
            );

            bookViewCountMap.value[bookId] = count;
            book.views_count = count;

            return count;
        })
        .catch(() => {
            const fallback = toNumber(book?.views_count, 0);
            bookViewCountMap.value[bookId] = fallback;
            book.views_count = fallback;
            return fallback;
        })
        .finally(() => {
            delete bookViewPendingMap.value[bookId];
        });

    return bookViewPendingMap.value[bookId];
}

async function loadBooksViewCounts(books = []) {
    const validBooks = books.filter((book) => Number(book?.id || 0) > 0);
    if (!validBooks.length) return;

    await Promise.allSettled(validBooks.map((book) => loadBookViewCount(book)));
}

async function fetchItems() {
    try {
        const { data } = await apiGetItems({ per_page: 200 });

        allBooks.value = normalizeRows(data)
            .map(normalizeBook)
            .filter((book) => book.id > 0);

        await loadBooksViewCounts(allBooks.value);
    } catch (error) {
        console.error("Failed to load items:", error);
        allBooks.value = [];
    }
}

async function fetchTrending() {
    try {
        const { data } = await apiGetTrendingSearches({ limit: 10 });
        trendingSearches.value = normalizeRows(data).filter((item) => getTrendLabel(item));
    } catch (error) {
        console.error("Failed to load trending searches:", error);
        trendingSearches.value = [];
    }
}

async function fetchUserInterests() {
    try {
        const { data } = await apiGetUserTagInterests();
        userInterestTagIds.value = normalizeInterestTagIds(data);
    } catch (error) {
        console.error("Failed to load user tag interests:", error);
        userInterestTagIds.value = new Set();
    }
}

async function fetchSuggested() {
    try {
        const { data } = await apiGetSuggestedBooks({ limit: SUGGESTION_LIMIT });
        suggestedFromApi.value = normalizeRows(data)
            .map(normalizeBook)
            .filter((book) => book.id > 0);

        await loadBooksViewCounts(suggestedFromApi.value);
    } catch (error) {
        console.error("Failed to load suggested books:", error);
        suggestedFromApi.value = [];
    }
}

async function fetchSearchResults(page = 1) {
    const q = searchQuery.value.trim();
    if (!q) return;

    searchLoading.value = true;

    try {
        saveSearch(q);

        const { data } = await apiSearchBooks({
            q,
            sort: sortMode.value,
            page,
            per_page: SEARCH_PER_PAGE,
        });

        const normalized = normalizeRows(data)
            .map(normalizeBook)
            .filter((book) => book.id > 0);

        if (normalized.length) {
            await loadBooksViewCounts(normalized);

            results.value = normalized;
            pagination.value = {
                current_page: Number(data?.meta?.current_page || 1),
                last_page: Number(data?.meta?.last_page || 1),
                per_page: Number(data?.meta?.per_page || SEARCH_PER_PAGE),
                total: Number(data?.meta?.total || normalized.length),
            };
            return;
        }

        const fallback = buildLocalSearchFallback(q);
        const paged = fallback.slice((page - 1) * SEARCH_PER_PAGE, page * SEARCH_PER_PAGE);

        await loadBooksViewCounts(paged);

        results.value = paged;
        pagination.value = {
            current_page: page,
            last_page: Math.max(1, Math.ceil(fallback.length / SEARCH_PER_PAGE)),
            per_page: SEARCH_PER_PAGE,
            total: fallback.length,
        };
    } catch (error) {
        console.error("Failed to search books:", error);

        const fallback = buildLocalSearchFallback(q);
        const paged = fallback.slice((page - 1) * SEARCH_PER_PAGE, page * SEARCH_PER_PAGE);

        await loadBooksViewCounts(paged);

        results.value = paged;
        pagination.value = {
            current_page: page,
            last_page: Math.max(1, Math.ceil(fallback.length / SEARCH_PER_PAGE)),
            per_page: SEARCH_PER_PAGE,
            total: fallback.length,
        };
    } finally {
        searchLoading.value = false;
    }
}

onMounted(async () => {
    loadRecentSearches();
    bootstrapLoading.value = true;

    try {
        await Promise.all([
            fetchItems(),
            fetchTrending(),
            fetchUserInterests(),
            fetchSuggested(),
        ]);
    } finally {
        bootstrapLoading.value = false;
    }
});

onBeforeUnmount(() => {
    clearTimeout(searchTimer);
});
</script>

<style scoped>
.search-page {
    --page-bg: #f4f6fb;
    --card: #ffffff;
    --card-2: #ffffff;
    --border: rgba(15, 23, 42, 0.08);
    --text: #111827;
    --muted: #6b7280;
    --primary: #2563eb;
    --primary-soft: #eff6ff;
    --input-bg: #ffffff;
    --input-text: #111827;
    --input-placeholder: #94a3b8;
    --list-hover: #f8fafc;
    --shadow: 0 10px 28px rgba(15, 23, 42, 0.08);

    min-height: 100%;
    background: var(--page-bg);
    color: var(--text);
    padding-bottom: 1.5rem;
}

.search-page__title {
    margin-bottom: 4px;
    color: var(--text);
    font-size: 28px;
    font-weight: 700;
}

.search-page__subtitle {
    color: var(--muted);
    font-size: 14px;
}

.search-hero {
    overflow: hidden;
    border-radius: 22px;
    background: linear-gradient(95deg, #2563eb, #1d4ed8);
    box-shadow: 0 18px 40px rgba(37, 99, 235, 0.22);
}

.search-hero__content {
    padding: 28px 24px;
}

.search-hero__badge {
    display: inline-flex;
    align-items: center;
    margin-bottom: 14px;
    padding: 7px 12px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.14);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
}

.search-hero__title {
    margin-bottom: 8px;
    color: #ffffff;
    font-size: 28px;
    font-weight: 800;
}

.search-hero__text {
    max-width: 680px;
    margin-bottom: 20px;
    color: rgba(255, 255, 255, 0.9);
}

.search-box {
    position: relative;
    max-width: 760px;
}

.search-box__icon {
    position: absolute;
    top: 50%;
    left: 16px;
    z-index: 2;
    transform: translateY(-50%);
    color: var(--input-placeholder);
}

.search-box__input {
    height: 54px;
    padding-right: 46px;
    padding-left: 46px;
    border: 1px solid transparent;
    border-radius: 999px;
    background: var(--input-bg);
    color: var(--input-text);
    font-size: 15px;
    box-shadow: none !important;
}

.search-box__input::placeholder {
    color: var(--input-placeholder);
}

.search-box__clear {
    position: absolute;
    top: 50%;
    right: 10px;
    width: 34px;
    height: 34px;
    border: none;
    border-radius: 50%;
    background: transparent;
    color: var(--muted);
    transform: translateY(-50%);
}

.search-box__clear:hover {
    background: rgba(0, 0, 0, 0.06);
}

.search-quick,
.search-filters,
.search-chip-list,
.suggested-book__tags,
.featured-card__tags,
.search-item__tags,
.featured-card__stats,
.search-item__stats,
.suggested-book__stats {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.search-filter-btn {
    border-radius: 999px;
}

.search-card {
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 18px;
    background: var(--card);
    box-shadow: var(--shadow);
}

.search-card__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid var(--border);
    background: transparent;
}

.search-card__header h5 {
    margin: 0;
    color: var(--text);
    font-size: 18px;
    font-weight: 700;
}

.search-empty-mini,
.search-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: var(--muted);
    text-align: center;
}

.search-empty-mini {
    min-height: 120px;
}

.search-empty {
    padding: 48px 20px;
}

.search-empty-mini__icon,
.search-empty__icon {
    display: grid;
    place-items: center;
    border-radius: 50%;
    background: var(--primary-soft);
    color: var(--primary);
}

.search-empty-mini__icon {
    width: 52px;
    height: 52px;
    margin-bottom: 10px;
}

.search-empty__icon {
    width: 72px;
    height: 72px;
    margin: 0 auto 16px;
    font-size: 28px;
}

.suggested-book {
    display: block;
    height: 100%;
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: 16px;
    background: var(--card-2);
    color: inherit;
    transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.suggested-book:hover {
    border-color: rgba(37, 99, 235, 0.2);
    box-shadow: 0 14px 30px rgba(15, 23, 42, 0.12);
    transform: translateY(-4px);
}

.suggested-book__cover {
    height: 190px;
    overflow: hidden;
    background: #f3f4f6;
}

.suggested-book__cover img,
.featured-card__image,
.search-item__thumb {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.suggested-book__body {
    padding: 12px;
}

.suggested-book__title {
    min-height: 38px;
    overflow: hidden;
    color: var(--text);
    font-size: 14px;
    font-weight: 700;
    line-height: 1.35;
}

.suggested-book__author,
.search-item__author,
.featured-card__author {
    color: var(--muted);
    font-size: 13px;
    margin-top: 4px;
}

.suggested-book__stats,
.search-item__stats,
.featured-card__stats {
    margin-top: 8px;
    color: var(--muted);
    font-size: 12px;
    align-items: center;
}

.search-stat {
    display: inline-flex;
    align-items: center;
}

.search-tag {
    display: inline-flex;
    align-items: center;
    padding: 5px 10px;
    border: 1px solid rgba(37, 99, 235, 0.12);
    border-radius: 999px;
    background: var(--primary-soft);
    color: var(--primary);
    font-size: 11px;
    font-weight: 700;
}

.search-tag--button {
    border: none;
    cursor: pointer;
}

.search-results-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    flex-wrap: wrap;
}

.search-results-top__meta {
    color: var(--muted);
    font-size: 14px;
}

.search-highlight {
    color: var(--primary);
}

.featured-card__image-wrap {
    position: relative;
    height: 100%;
    min-height: 280px;
    background: #f3f4f6;
}

.featured-card__badge {
    position: absolute;
    top: 14px;
    left: 14px;
    padding: 6px 12px;
    border-radius: 999px;
    background: #f59e0b;
    color: #111827;
    font-size: 11px;
    font-weight: 800;
}

.featured-card__body {
    padding: 1.5rem;
}

.featured-card__category {
    margin-bottom: 10px;
    color: var(--primary);
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
}

.featured-card__title {
    margin-bottom: 0;
    color: var(--text);
    font-size: 28px;
    font-weight: 800;
}

.featured-card__desc,
.search-item__desc {
    margin-top: 10px;
    color: var(--text);
    line-height: 1.65;
}

.featured-card__actions {
    margin-top: 16px;
}

.search-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.search-item {
    display: flex;
    gap: 14px;
    padding: 14px;
    border: 1px solid var(--border);
    border-radius: 18px;
    background: var(--card);
    color: inherit;
    overflow: hidden;
    transition: transform 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
}

.search-item:hover {
    background: var(--list-hover);
    box-shadow: 0 14px 30px rgba(15, 23, 42, 0.1);
    transform: translateY(-2px);
}

.search-item__thumb {
    width: 76px;
    height: 104px;
    flex: 0 0 auto;
    border-radius: 12px;
    background: #f3f4f6;
    border: 1px solid var(--border);
}

.search-item__body {
    flex: 1;
    min-width: 0;
}

.search-item__top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
}

.search-item__title {
    color: var(--text);
    font-size: 17px;
    font-weight: 700;
    line-height: 1.35;
}

.search-item__badge {
    display: inline-flex;
    align-items: center;
    padding: 5px 10px;
    border: 1px solid var(--border);
    border-radius: 999px;
    font-size: 11px;
    font-weight: 700;
    color: var(--muted);
    background: #ffffff;
}

@media (max-width: 991.98px) {
    .featured-card__title {
        font-size: 24px;
    }
}

@media (max-width: 767.98px) {
    .search-item {
        flex-direction: column;
    }

    .search-hero__content {
        padding: 22px 18px;
    }

    .search-hero__title {
        font-size: 24px;
    }

    .featured-card__image-wrap {
        min-height: 220px;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.search-page,
html.dark-mode .content-wrapper.search-page,
.dark-mode .content-wrapper.search-page {
    background: #0f172a !important;
}

body.dark-mode .search-page,
html.dark-mode .search-page,
.dark-mode .search-page {
    --page-bg: #0f172a;
    --card: #111827;
    --card-2: #111827;
    --border: rgba(255, 255, 255, 0.08);
    --text: #e5e7eb;
    --muted: #9ca3af;
    --primary: #60a5fa;
    --primary-soft: rgba(96, 165, 250, 0.14);
    --input-bg: #ffffff;
    --input-text: #111827;
    --input-placeholder: #94a3b8;
    --list-hover: #182132;
    --shadow: 0 12px 30px rgba(0, 0, 0, 0.28);

    background: var(--page-bg) !important;
    color: var(--text) !important;
}

body.dark-mode .search-hero,
html.dark-mode .search-hero,
.dark-mode .search-hero {
    background: linear-gradient(135deg, #1e293b, #0f172a) !important;
}

body.dark-mode .search-page .card,
body.dark-mode .search-page .search-card,
html.dark-mode .search-page .card,
html.dark-mode .search-page .search-card,
.dark-mode .search-page .card,
.dark-mode .search-page .search-card {
    background: var(--card) !important;
    border-color: var(--border) !important;
    color: var(--text) !important;
}

body.dark-mode .search-page .search-page__title,
body.dark-mode .search-page .featured-card__title,
body.dark-mode .search-page .search-item__title,
body.dark-mode .search-page .suggested-book__title,
body.dark-mode .search-page .search-card__header h5,
html.dark-mode .search-page .search-page__title,
html.dark-mode .search-page .featured-card__title,
html.dark-mode .search-page .search-item__title,
html.dark-mode .search-page .suggested-book__title,
html.dark-mode .search-page .search-card__header h5,
.dark-mode .search-page .search-page__title,
.dark-mode .search-page .featured-card__title,
.dark-mode .search-page .search-item__title,
.dark-mode .search-page .suggested-book__title,
.dark-mode .search-page .search-card__header h5 {
    color: var(--text) !important;
}

body.dark-mode .search-page .search-page__subtitle,
body.dark-mode .search-page .search-results-top__meta,
body.dark-mode .search-page .search-item__author,
body.dark-mode .search-page .suggested-book__author,
body.dark-mode .search-page .featured-card__author,
body.dark-mode .search-page .search-empty__text,
body.dark-mode .search-page .search-empty-mini__text,
body.dark-mode .search-page .search-item__stats,
body.dark-mode .search-page .suggested-book__stats,
body.dark-mode .search-page .featured-card__stats,
html.dark-mode .search-page .search-page__subtitle,
html.dark-mode .search-page .search-results-top__meta,
html.dark-mode .search-page .search-item__author,
html.dark-mode .search-page .suggested-book__author,
html.dark-mode .search-page .featured-card__author,
html.dark-mode .search-page .search-empty__text,
html.dark-mode .search-page .search-empty-mini__text,
html.dark-mode .search-page .search-item__stats,
html.dark-mode .search-page .suggested-book__stats,
html.dark-mode .search-page .featured-card__stats,
.dark-mode .search-page .search-page__subtitle,
.dark-mode .search-page .search-results-top__meta,
.dark-mode .search-page .search-item__author,
.dark-mode .search-page .suggested-book__author,
.dark-mode .search-page .featured-card__author,
.dark-mode .search-page .search-empty__text,
.dark-mode .search-page .search-empty-mini__text,
.dark-mode .search-page .search-item__stats,
.dark-mode .search-page .suggested-book__stats,
.dark-mode .search-page .featured-card__stats {
    color: var(--muted) !important;
}

body.dark-mode .search-page .suggested-book,
body.dark-mode .search-page .search-item,
html.dark-mode .search-page .suggested-book,
html.dark-mode .search-page .search-item,
.dark-mode .search-page .suggested-book,
.dark-mode .search-page .search-item {
    background: var(--card) !important;
    border-color: var(--border) !important;
    color: var(--text) !important;
}

body.dark-mode .search-page .suggested-book:hover,
body.dark-mode .search-page .search-item:hover,
html.dark-mode .search-page .suggested-book:hover,
html.dark-mode .search-page .search-item:hover,
.dark-mode .search-page .suggested-book:hover,
.dark-mode .search-page .search-item:hover {
    background: var(--list-hover) !important;
}

body.dark-mode .search-page .search-tag,
html.dark-mode .search-page .search-tag,
.dark-mode .search-page .search-tag {
    background: var(--primary-soft) !important;
    color: #93c5fd !important;
    border-color: rgba(96, 165, 250, 0.18) !important;
}

body.dark-mode .search-page .search-item__badge,
html.dark-mode .search-page .search-item__badge,
.dark-mode .search-page .search-item__badge {
    background: #1f2937 !important;
    color: #d1d5db !important;
    border-color: var(--border) !important;
}
</style>
