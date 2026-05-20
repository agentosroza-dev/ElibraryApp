<template>
    <div class="content-wrapper dashboard-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="dashboard-head">
                    <div>
                        <h1 class="dashboard-title">{{ $t("dashboard.text") }}</h1>
                        <div class="dashboard-subtitle">
                            {{ $t("dashboard.subtitle") }}
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="content pb-4">
            <div class="container-fluid">
                <div v-if="loading" class="card dashboard-card mb-4">
                    <div class="card-body text-center py-5">
                        <div class="spinner-border text-primary mb-3" role="status"></div>
                        <div class="font-weight-bold">{{ $t("dashboard.page_loading") }}</div>
                        <div class="text-muted small">{{ $t("dashboard.page_loading_sub") }}</div>
                    </div>
                </div>

                <div v-else-if="errorMessage" class="alert alert-danger">
                    {{ errorMessage }}
                </div>

                <template v-else>
                    <div
                        v-for="section in sliderSections"
                        :key="section.key"
                        v-show="section.items.length"
                        class="card dashboard-card mb-4"
                    >
                        <div class="card-header section-header" :class="section.headerClass">
                            <div class="section-header-left">
                                <div class="section-icon">
                                    <i :class="section.icon"></i>
                                </div>
                                <div>
<!--                                    <h5 class="section-title mb-0">{{ section.title }}</h5>-->
<!--                                    <small class="section-subtitle">{{ section.subtitle }}</small>-->
                                    <h5 class="section-title mb-0">{{ $t(section.titleKey) }}</h5>
                                    <small class="section-subtitle">{{ $t(section.subtitleKey) }}</small>

                                </div>
                            </div>
                        </div>

                        <div class="card-body">
                            <swiper
                                :modules="section.useNavigation ? swiperModulesAll : swiperModulesAutoplay"
                                :space-between="18"
                                :loop="section.items.length > 5"
                                :navigation="section.useNavigation && section.items.length > 5"
                                :autoplay="section.autoplay"
                                :breakpoints="swiperBreakpoints"
                            >
                                <swiper-slide
                                    v-for="book in section.items"
                                    :key="`${section.key}-${book.id}`"
                                >
                                    <router-link
                                        :to="section.routeType === 'read' ? buildReadRoute(book) : bookDetailsRoute(book.id)"
                                        class="book-slide-card text-decoration-none"
                                    >
                                        <div class="book-slide-card__image-wrap">
                                            <img
                                                :src="book.cover"
                                                :alt="book.title"
                                                class="book-slide-card__image"
                                                loading="lazy"
                                                @error="handleImageError"
                                            />

                                            <span
                                                v-if="section.badgeLabelKey"
                                                class="book-badge"
                                                :class="section.badgeClass"
                                            >
                                                {{ $t(section.badgeLabelKey) }}
                                            </span>
                                        </div>

                                        <div class="book-slide-card__body">
                                            <h6 class="book-slide-card__title" :title="book.title">
                                                {{ book.title }}
                                            </h6>

                                            <div class="book-slide-card__author" :title="book.author">
                                                {{ book.author }}
                                            </div>

                                            <template v-if="section.routeType === 'read'">
                                                <div class="continue-card__progress-wrap">
                                                    <div class="progress continue-card__progress">
                                                        <div
                                                            class="progress-bar bg-success"
                                                            role="progressbar"
                                                            :style="{ width: `${book.progress}%` }"
                                                            :aria-valuenow="book.progress"
                                                            aria-valuemin="0"
                                                            aria-valuemax="100"
                                                        ></div>
                                                    </div>
                                                    <div class="continue-card__percent">
                                                        {{ book.progress }}%
                                                    </div>
                                                </div>
                                            </template>

                                            <template v-else>
                                                <div v-if="book.tags.length" class="book-tag-list mt-2">
                                                    <span
                                                        v-for="tag in book.tags.slice(0, section.tagLimit || 3)"
                                                        :key="`${book.id}-${tag.id}-${tag.name}`"
                                                        class="book-tag"
                                                    >
                                                        {{ tag.name }}
                                                    </span>
                                                </div>

                                                <div class="book-slide-card__meta mt-2">
                                                    {{
                                                        section.metaType === "views"
                                                            ? `${book.views_count} reads`
                                                            : book.category_name
                                                    }}
                                                </div>
                                            </template>
                                        </div>
                                    </router-link>
                                </swiper-slide>
                            </swiper>
                        </div>
                    </div>

                    <div v-if="favoriteList.length" class="card dashboard-card mb-4">
                        <div class="card-header section-header section-header-warning">
                            <div class="section-header-left">
                                <div class="section-icon">
                                    <i class="fas fa-heart"></i>
                                </div>
                                <div>
                                    <h5 class="section-title mb-0">{{ $t("dashboard.sections.favorites.title") }}</h5>
                                    <small class="section-subtitle">{{ $t("dashboard.sections.favorites.subtitle") }}</small>
                                </div>
                            </div>
                        </div>

                        <div class="card-body">
                            <div class="favorite-list">
                                <router-link
                                    v-for="book in favoriteList"
                                    :key="`favorite-${book.id}`"
                                    :to="bookDetailsRoute(book.id)"
                                    class="favorite-row text-decoration-none"
                                >
                                    <img
                                        :src="book.cover"
                                        :alt="book.title"
                                        class="favorite-row__thumb"
                                        loading="lazy"
                                        @error="handleImageError"
                                    />

                                    <div class="favorite-row__content">
                                        <div class="favorite-row__title" :title="book.title">
                                            {{ book.title }}
                                        </div>

                                        <div class="favorite-row__author" :title="book.author">
                                            {{ book.author }}
                                        </div>

                                        <div
                                            v-if="book.tags.length"
                                            class="book-tag-list mt-2"
                                        >
                                            <span
                                                v-for="tag in book.tags.slice(0, 3)"
                                                :key="`${book.id}-${tag}`"
                                                class="book-tag"
                                            >
                                                {{ tag }}
                                            </span>
                                        </div>
                                    </div>

                                    <div class="favorite-row__action">
                                        <span class="btn btn-sm btn-primary favorite-row__btn">
                                            <i class="fas fa-book-open mr-1"></i>
                                            {{ $t("dashboard.sections.favorites.read") }}
                                        </span>
                                    </div>
                                </router-link>
                            </div>
                        </div>
                    </div>

                    <div v-if="showEmptyState" class="card dashboard-card">
                        <div class="card-body text-center py-5">
                            <i class="far fa-folder-open fa-2x text-muted mb-3"></i>
                            <h5 class="mb-2">No dashboard data</h5>
                            <div class="text-muted">
                                No books were returned from the current APIs.
                            </div>
                        </div>
                    </div>
                </template>
            </div>
        </section>
    </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { Swiper, SwiperSlide } from "swiper/vue";
import { Autoplay, Navigation } from "swiper/modules";

import "swiper/css";
import "swiper/css/navigation";

import defaultCover from "@/assets/images/defaultCover.jpg";

import {
    apiGetProfileFavorites,
    apiGetRecommendedOverallBooks,
    apiGetUserTagInterests,
} from "@func/api/user.js";
import {
    apiGetItems,
    apiGetPdfProgressList,
} from "@func/api/item.js";

const emptyPhoto = defaultCover;

const loading = ref(false);
const errorMessage = ref("");

const recommendedBooks = ref([]);
const popularBooks = ref([]);
const interestedBooks = ref([]);
const newReleaseBooks = ref([]);
const continueReadingBooks = ref([]);
const favoriteList = ref([]);

const favoriteIds = ref(new Set());
const userInterestTagMap = ref(new Map());

const swiperModulesAll = [Autoplay, Navigation];
const swiperModulesAutoplay = [Autoplay];

const swiperBreakpoints = {
    320: { slidesPerView: 1.2 },
    576: { slidesPerView: 2.1 },
    768: { slidesPerView: 3.1 },
    992: { slidesPerView: 4.1 },
    1200: { slidesPerView: 5.2 },
};

const API_BASE = String(
    import.meta.env.VITE_API_URL ||
    import.meta.env.VITE_URL ||
    window.API_BASE_URL ||
    window.API_URL ||
    ""
).replace(/\/+$/, "");

let currentLoadToken = 0;

// const sliderSections = computed(() => [
//     {
//         // key: "recommended",
//         // title: "Recommended Books",
//         // subtitle: "Picked for you",
//         key: "recommended",
//         title: "dashboard.sections.recommended.title",
//         subtitle: "dashboard.sections.recommended.subtitle",
//         badgeLabel: "dashboard.sections.recommended.badge",
//         icon: "fas fa-star",
//         headerClass: "section-header-danger",
//         // badgeLabel: "Recommended",
//         badgeClass: "book-badge--recommended",
//         items: recommendedBooks.value,
//         metaType: "category",
//         tagLimit: 3,
//         useNavigation: true,
//         autoplay: { delay: 1600, disableOnInteraction: false, pauseOnMouseEnter: true },
//         routeType: "details",
//     },
//     {
//         key: "popular",
//         title: "Popular Books",
//         subtitle: "Most loved by readers",
//         icon: "fas fa-fire",
//         headerClass: "section-header-info",
//         badgeLabel: "Popular",
//         badgeClass: "book-badge--popular",
//         items: popularBooks.value,
//         metaType: "views",
//         tagLimit: 2,
//         useNavigation: true,
//         autoplay: { delay: 2200, disableOnInteraction: false, pauseOnMouseEnter: true },
//         routeType: "details",
//     },
//     {
//         key: "interest",
//         title: "You may be interested",
//         subtitle: "Based on your interests",
//         icon: "fas fa-lightbulb",
//         headerClass: "section-header-gray",
//         badgeLabel: "Interest",
//         badgeClass: "book-badge--interest",
//         items: interestedBooks.value,
//         metaType: "category",
//         tagLimit: 3,
//         useNavigation: true,
//         autoplay: { delay: 3000, disableOnInteraction: false, pauseOnMouseEnter: true },
//         routeType: "details",
//     },
//     {
//         key: "new-release",
//         title: "New Releases",
//         subtitle: "Latest books",
//         icon: "fas fa-book-open",
//         headerClass: "section-header-primary",
//         badgeLabel: "NEW",
//         badgeClass: "book-badge--new",
//         items: newReleaseBooks.value,
//         metaType: "category",
//         tagLimit: 2,
//         useNavigation: false,
//         autoplay: { delay: 2800, disableOnInteraction: false, pauseOnMouseEnter: true },
//         routeType: "details",
//     },
//     {
//         key: "continue-reading",
//         title: "Continue Reading",
//         subtitle: "Pick up where you left off",
//         icon: "fas fa-book-reader",
//         headerClass: "section-header-success",
//         badgeLabel: "",
//         badgeClass: "",
//         items: continueReadingBooks.value,
//         metaType: "progress",
//         tagLimit: 0,
//         useNavigation: true,
//         autoplay: false,
//         routeType: "read",
//     },
// ]);

const sliderSections = computed(() => [
    {
        key: "recommended",
        titleKey: "dashboard.sections.recommended.title",
        subtitleKey: "dashboard.sections.recommended.subtitle",
        badgeLabelKey: "dashboard.sections.recommended.badge",
        icon: "fas fa-star",
        headerClass: "section-header-danger",
        badgeClass: "book-badge--recommended",
        items: recommendedBooks.value,
        metaType: "category",
        tagLimit: 3,
        useNavigation: true,
        autoplay: { delay: 1600, disableOnInteraction: false, pauseOnMouseEnter: true },
        routeType: "details",
    },
    {
        key: "popular",
        titleKey: "dashboard.sections.popular.title",
        subtitleKey: "dashboard.sections.popular.subtitle",
        badgeLabelKey: "dashboard.sections.popular.badge",
        icon: "fas fa-fire",
        headerClass: "section-header-info",
        badgeClass: "book-badge--popular",
        items: popularBooks.value,
        metaType: "views",
        tagLimit: 2,
        useNavigation: true,
        autoplay: { delay: 2200, disableOnInteraction: false, pauseOnMouseEnter: true },
        routeType: "details",
    },
    {
        key: "interest",
        titleKey: "dashboard.sections.interest.title",
        subtitleKey: "dashboard.sections.interest.subtitle",
        badgeLabelKey: "dashboard.sections.interest.badge",
        icon: "fas fa-lightbulb",
        headerClass: "section-header-gray",
        badgeClass: "book-badge--interest",
        items: interestedBooks.value,
        metaType: "category",
        tagLimit: 3,
        useNavigation: true,
        autoplay: { delay: 3000, disableOnInteraction: false, pauseOnMouseEnter: true },
        routeType: "details",
    },
    {
        key: "new-release",
        titleKey: "dashboard.sections.new_release.title",
        subtitleKey: "dashboard.sections.new_release.subtitle",
        badgeLabelKey: "dashboard.sections.new_release.badge",
        icon: "fas fa-book-open",
        headerClass: "section-header-primary",
        badgeClass: "book-badge--new",
        items: newReleaseBooks.value,
        metaType: "category",
        tagLimit: 2,
        useNavigation: false,
        autoplay: { delay: 2800, disableOnInteraction: false, pauseOnMouseEnter: true },
        routeType: "details",
    },
    {
        key: "continue-reading",
        titleKey: "dashboard.sections.continue_reading.title",
        subtitleKey: "dashboard.sections.continue_reading.subtitle",
        badgeLabelKey: "",
        icon: "fas fa-book-reader",
        headerClass: "section-header-success",
        badgeClass: "",
        items: continueReadingBooks.value,
        metaType: "progress",
        tagLimit: 0,
        useNavigation: true,
        autoplay: false,
        routeType: "read",
    },
]);

const showEmptyState = computed(() => {
    return (
        !loading.value &&
        !recommendedBooks.value.length &&
        !popularBooks.value.length &&
        !interestedBooks.value.length &&
        !newReleaseBooks.value.length &&
        !continueReadingBooks.value.length &&
        !favoriteList.value.length
    );
});

function toNumber(value, fallback = 0) {
    const number = Number(value);
    return Number.isFinite(number) ? number : fallback;
}

function removeApiSuffix(url) {
    return String(url || "").replace(/\/api$/i, "");
}

function isAbsoluteUrl(value) {
    return /^(https?:\/\/|blob:|data:)/i.test(String(value || "").trim());
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
    const value = String(path || "").trim();
    if (!value) return emptyPhoto;
    if (isAbsoluteUrl(value)) return value;

    const cleanPath = normalizeStoragePath(value);
    if (!cleanPath) return emptyPhoto;

    const base = removeApiSuffix(API_BASE);
    return base ? `${base}/storage/${cleanPath}` : `/storage/${cleanPath}`;
}

// function normalizeFilePath(path) {
//     return String(path || "")
//         .trim()
//         .replace(/^https?:\/\/[^/]+/i, "")
//         .replace(/^\/+/, "")
//         .replace(/^public\//i, "")
//         .replace(/^storage\//i, "storage/");
// }
function normalizeFilePath(path) {
    return String(path || "")
        .trim()
        .replace(/^https?:\/\/[^/]+/i, "")
        .replace(/^\/+/, "")
        .replace(/^public\//i, "")
        .replace(/^storage\//i, "storage/");
}

function handleImageError(event) {
    const target = event?.target;
    if (!target || target.dataset.fallbackApplied === "1") return;
    target.dataset.fallbackApplied = "1";
    target.src = emptyPhoto;
}

function extractList(payload) {
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload?.data)) return payload.data;
    if (Array.isArray(payload?.data?.data)) return payload.data.data;
    if (Array.isArray(payload?.items)) return payload.items;
    if (Array.isArray(payload?.data?.items)) return payload.data.items;
    if (Array.isArray(payload?.books)) return payload.books;
    if (Array.isArray(payload?.data?.books)) return payload.data.books;
    if (Array.isArray(payload?.results)) return payload.results;
    if (Array.isArray(payload?.favorites)) return payload.favorites;
    return [];
}

function getRows(response) {
    return extractList(response?.data ?? response ?? []);
}

function normalizeTag(tag) {
    if (!tag) return null;

    if (typeof tag === "string" || typeof tag === "number") {
        const value = String(tag).trim();
        if (!value) return null;
        return { id: value, name: value };
    }

    const id = tag.id || tag.tag_id || tag.name || tag.title || tag.label;
    const name = String(tag.name || tag.title || tag.label || "").trim();

    if (!id || !name) return null;

    return { id, name };
}

// function normalizeBook(row, extra = {}) {
//     if (!row || typeof row !== "object") return null;
//
//     const id = toNumber(row.id || row.book_id || row.item_id);
//     if (!id) return null;
//
//     const tagsSource = Array.isArray(row.tags)
//         ? row.tags
//         : Array.isArray(row.item?.tags)
//             ? row.item.tags
//             : [];
//
//     return {
//         id,
//         title: String(row.title || row.item?.title || "Untitled Book").trim(),
//         author: String(
//             row.author_name ||
//             row.item?.author_name ||
//             row.author?.name ||
//             row.item?.author?.name ||
//             row.user?.name ||
//             "Unknown Author"
//         ).trim(),
//         category_name: String(
//             row.category_name ||
//             row.category?.name ||
//             row.item?.category_name ||
//             row.item?.category?.name ||
//             "Uncategorized"
//         ).trim(),
//         cover: buildStorageUrl(row.cover_url || row.item?.cover_url || row.cover || row.image || ""),
//         cover_url: String(row.cover_url || row.item?.cover_url || row.cover || row.image || "").trim(),
//         file_url: String(row.file_url || row.item?.file_url || "").trim(),
//         tags: tagsSource.map(normalizeTag).filter(Boolean),
//         views_count: toNumber(
//             row.views_count ||
//             row.total_reads ||
//             row.read_count ||
//             row.item?.views_count ||
//             0
//         ),
//         progress: Math.max(0, Math.min(100, toNumber(row.percent || row.progress || 0))),
//         updated_at: row.updated_at || row.item?.updated_at || null,
//         isFavorite: Boolean(extra.isFavorite ?? row.isFavorite ?? false),
//         isPopular: Boolean(extra.isPopular ?? row.isPopular ?? false),
//         isNewRelease: Boolean(extra.isNewRelease ?? row.isNewRelease ?? false),
//     };
// }
function normalizeBook(row, extra = {}) {
    if (!row || typeof row !== "object") return null;

    const id = toNumber(row.id || row.book_id || row.item_id || row.item?.id);
    if (!id) return null;

    const tagsSource = Array.isArray(row.tags)
        ? row.tags
        : Array.isArray(row.item?.tags)
            ? row.item.tags
            : Array.isArray(row.book?.tags)
                ? row.book.tags
                : [];

    return {
        id,
        title: String(
            row.title ||
            row.item?.title ||
            row.book?.title ||
            "Untitled Book"
        ).trim(),
        author: String(
            row.author_name ||
            row.author?.name ||
            row.item?.author_name ||
            row.item?.author?.name ||
            row.book?.author_name ||
            row.book?.author?.name ||
            row.user?.name ||
            "Unknown Author"
        ).trim(),
        category_name: String(
            row.category_name ||
            row.category?.name ||
            row.item?.category_name ||
            row.item?.category?.name ||
            row.book?.category_name ||
            row.book?.category?.name ||
            "Uncategorized"
        ).trim(),
        cover: buildStorageUrl(
            row.cover_url ||
            row.item?.cover_url ||
            row.book?.cover_url ||
            row.cover ||
            row.image ||
            ""
        ),
        cover_url: String(
            row.cover_url ||
            row.item?.cover_url ||
            row.book?.cover_url ||
            row.cover ||
            row.image ||
            ""
        ).trim(),
        file_url: String(
            row.file_url ||
            row.item?.file_url ||
            row.book?.file_url ||
            ""
        ).trim(),
        tags: tagsSource.map(normalizeTag).filter(Boolean),
        views_count: toNumber(
            row.views_count ||
            row.total_reads ||
            row.read_count ||
            row.item?.views_count ||
            row.book?.views_count ||
            0
        ),
        progress: Math.max(0, Math.min(100, toNumber(row.percent || row.progress || 0))),
        updated_at: row.updated_at || row.item?.updated_at || row.book?.updated_at || null,
        isFavorite: Boolean(extra.isFavorite ?? row.isFavorite ?? false),
        isPopular: Boolean(extra.isPopular ?? row.isPopular ?? false),
        isNewRelease: Boolean(extra.isNewRelease ?? row.isNewRelease ?? false),
    };
}

function normalizeBookList(rows = [], extra = {}) {
    return rows.map((row) => normalizeBook(row, extra)).filter(Boolean);
}

function uniqueBooks(rows = []) {
    const map = new Map();

    for (const row of rows) {
        if (!row?.id || map.has(row.id)) continue;
        map.set(row.id, row);
    }

    return Array.from(map.values());
}

function syncFavoriteFlags(rows = []) {
    return rows.map((book) => ({
        ...book,
        isFavorite: favoriteIds.value.has(Number(book.id)),
    }));
}

function normalizeFavoriteTag(tag) {
    if (typeof tag === "string" || typeof tag === "number") {
        const value = String(tag).trim();
        return value || null;
    }

    const value = String(tag?.name || tag?.title || tag?.label || "").trim();
    return value || null;
}

// function normalizeFavorites(rows = []) {
//     if (!Array.isArray(rows)) return [];
//
//     return rows
//         .map((item) => {
//             const normalized = normalizeBook(item);
//             if (!normalized?.id) return null;
//
//             const tagsSource = Array.isArray(item?.tags)
//                 ? item.tags
//                 : Array.isArray(item?.item?.tags)
//                     ? item.item.tags
//                     : [];
//
//             return {
//                 id: normalized.id,
//                 title: normalized.title,
//                 author: normalized.author,
//                 cover: normalized.cover,
//                 tags: tagsSource.map(normalizeFavoriteTag).filter(Boolean),
//             };
//         })
//         .filter(Boolean);
// }

function normalizeFavorites(rows = []) {
    if (!Array.isArray(rows)) return [];

    return rows
        .map((item) => {
            const id = toNumber(item?.id || item?.book_id || item?.item_id || item?.item?.id || 0);
            if (!id) return null;

            const title = String(
                item?.title ||
                item?.item?.title ||
                item?.book?.title ||
                "Untitled Book"
            ).trim();

            const author = String(
                item?.author ||
                item?.author_name ||
                item?.author?.name ||
                item?.item?.author_name ||
                item?.item?.author?.name ||
                item?.book?.author_name ||
                item?.book?.author?.name ||
                "Unknown Author"
            ).trim();

            const coverSource =
                item?.image ||
                item?.cover ||
                item?.cover_url ||
                item?.item?.image ||
                item?.item?.cover ||
                item?.item?.cover_url ||
                item?.book?.image ||
                item?.book?.cover ||
                item?.book?.cover_url ||
                "";

            const tagsSource = Array.isArray(item?.tags)
                ? item.tags
                : Array.isArray(item?.item?.tags)
                    ? item.item.tags
                    : Array.isArray(item?.book?.tags)
                        ? item.book.tags
                        : [];

            return {
                id,
                title,
                author,
                cover: buildStorageUrl(coverSource),
                tags: tagsSource.map(normalizeFavoriteTag).filter(Boolean),
            };
        })
        .filter(Boolean);
}

// function normalizeProgressRow(row) {
//     const book = normalizeBook(row);
//     if (!book?.id) return null;
//     if (!book.file_url) return null;
//     if (book.progress <= 0 || book.progress >= 100) return null;
//
//     return book;
// }
function normalizeProgressRow(row) {
    if (!row || typeof row !== "object") return null;

    const id = toNumber(row?.item_id || row?.id || row?.item?.id || 0);
    if (!id) return null;

    const tagsSource = Array.isArray(row?.tags)
        ? row.tags
        : Array.isArray(row?.item?.tags)
            ? row.item.tags
            : [];

    const fileUrl = String(
        row?.file_url ||
        row?.file ||
        row?.item?.file_url ||
        row?.item?.file ||
        ""
    ).trim();

    return {
        id,
        item_id: id,
        title: String(row?.title || row?.item?.title || "Untitled Book").trim(),
        author: String(
            row?.author_name ||
            row?.author?.name ||
            row?.item?.author_name ||
            row?.item?.author?.name ||
            "Unknown Author"
        ).trim(),
        category_name: String(
            row?.category_name ||
            row?.category?.name ||
            row?.item?.category_name ||
            row?.item?.category?.name ||
            "Uncategorized"
        ).trim(),
        cover: buildStorageUrl(
            row?.cover_url ||
            row?.cover ||
            row?.item?.cover_url ||
            row?.item?.cover ||
            row?.image ||
            ""
        ),
        cover_url: String(
            row?.cover_url ||
            row?.cover ||
            row?.item?.cover_url ||
            row?.item?.cover ||
            row?.image ||
            ""
        ).trim(),
        file_url: fileUrl,
        tags: tagsSource.map(normalizeTag).filter(Boolean),
        progress: Math.max(0, Math.min(100, toNumber(row?.percent ?? row?.progress ?? 0))),
        updated_at: row?.updated_at || row?.item?.updated_at || null,
    };
}

// function bookDetailsRoute(id) {
//     return {
//         name: "book.details",
//         params: { id: Number(id) },
//     };
// }

// function buildReadRoute(book) {
//     if (!book?.id || !book?.file_url) return bookDetailsRoute(book?.id || 0);
//
//     return {
//         name: "book.details.view",
//         params: { id: Number(book.id) },
//         query: {
//             file: `/storage/${normalizeFilePath(book.file_url)}`,
//             title: book.title || "PDF Preview",
//         },
//     };
// }

function bookDetailsRoute(id) {
    return {
        name: "book.details",
        params: { id: Number(id) || 0 },
    };
}

function buildReadRoute(book) {
    const id = toNumber(book?.id || book?.item_id || book?.item?.id || 0);
    const fileUrl = String(
        book?.file_url ||
        book?.file ||
        book?.item?.file_url ||
        book?.item?.file ||
        ""
    ).trim();

    if (!id) {
        return { name: "book.details" };
    }

    if (!fileUrl) {
        return bookDetailsRoute(id);
    }

    return {
        name: "book.details.view",
        params: { id },
        query: {
            file: `/${normalizeFilePath(fileUrl)}`,
            title: String(book?.title || "Book Preview"),
        },
    };
}

function resetDashboardSections() {
    recommendedBooks.value = [];
    popularBooks.value = [];
    interestedBooks.value = [];
    newReleaseBooks.value = [];
    continueReadingBooks.value = [];
    favoriteList.value = [];
    favoriteIds.value = new Set();
    userInterestTagMap.value = new Map();
}

async function loadFavorites() {
    const { data } = await apiGetProfileFavorites();

    const rows = Array.isArray(data?.favorites)
        ? data.favorites
        : Array.isArray(data?.data)
            ? data.data
            : Array.isArray(data)
                ? data
                : [];

    const normalized = normalizeFavorites(rows).slice(0, 8);

    favoriteList.value = normalized;
    favoriteIds.value = new Set(normalized.map((book) => Number(book.id)));
}

async function fetchUserTagInterests() {
    const rows = getRows(await apiGetUserTagInterests());
    const map = new Map();

    for (const row of rows) {
        const tagId = toNumber(row?.tag_id || row?.id || 0);
        if (!tagId) continue;

        const score = toNumber(row?.total_score || row?.score || 1, 1);
        map.set(tagId, (map.get(tagId) || 0) + score);
    }

    userInterestTagMap.value = map;
}

async function loadRecommendedOverallBooks() {
    const rows = getRows(await apiGetRecommendedOverallBooks({ limit: 8 }));

    recommendedBooks.value = uniqueBooks(
        syncFavoriteFlags(normalizeBookList(rows))
    ).slice(0, 8);
}

async function loadPopularBooks() {
    const rows = getRows(
        await apiGetItems({
            per_page: 8,
            filter: "popular_section",
        })
    );

    popularBooks.value = uniqueBooks(
        syncFavoriteFlags(
            normalizeBookList(rows, { isPopular: true })
        )
    ).slice(0, 8);
}

async function loadNewReleaseBooks() {
    const rows = getRows(
        await apiGetItems({
            per_page: 8,
            filter: "new_release_section",
        })
    );

    newReleaseBooks.value = uniqueBooks(
        syncFavoriteFlags(
            normalizeBookList(rows, { isNewRelease: true })
        )
    ).slice(0, 8);
}

async function loadContinueReadingBooks() {
    const rows = getRows(await apiGetPdfProgressList());

    continueReadingBooks.value = uniqueBooks(
        rows
            .map(normalizeProgressRow)
            .filter(Boolean)
            .sort((a, b) => {
                const progressDiff = Number(b.progress || 0) - Number(a.progress || 0);
                if (progressDiff !== 0) return progressDiff;

                const aTime = new Date(a.updated_at || 0).getTime();
                const bTime = new Date(b.updated_at || 0).getTime();
                return bTime - aTime;
            })
    ).slice(0, 8);
}

async function loadInterestedBooks() {
    if (!userInterestTagMap.value.size) {
        interestedBooks.value = [];
        return;
    }

    const rows = getRows(
        await apiGetItems({
            per_page: 30,
            filter: "all",
        })
    );

    const excludedIds = new Set(recommendedBooks.value.map((book) => Number(book.id)));

    const scoredBooks = normalizeBookList(rows)
        .map((book) => {
            const matchedTagScore = book.tags.reduce((sum, tag) => {
                const tagId = toNumber(tag.id || 0);
                return sum + (userInterestTagMap.value.get(tagId) || 0);
            }, 0);

            const score = matchedTagScore * 10 + Math.min(book.views_count || 0, 20);

            return {
                ...book,
                _score: score,
            };
        })
        .filter((book) => book._score > 0 && !excludedIds.has(Number(book.id)))
        .sort((a, b) => b._score - a._score || b.id - a.id);

    interestedBooks.value = uniqueBooks(syncFavoriteFlags(scoredBooks)).slice(0, 8);
}

async function loadDashboardData(force = false) {
    const loadToken = ++currentLoadToken;

    loading.value = true;
    errorMessage.value = "";

    try {
        if (force) {
            resetDashboardSections();
        }

        await Promise.all([
            loadFavorites(),
            fetchUserTagInterests(),
        ]);

        await Promise.all([
            loadRecommendedOverallBooks(),
            loadPopularBooks(),
            loadNewReleaseBooks(),
            loadContinueReadingBooks(),
        ]);

        await loadInterestedBooks();

        if (loadToken !== currentLoadToken) return;
    } catch (error) {
        if (loadToken !== currentLoadToken) return;

        console.error("Failed to load dashboard:", error);

        errorMessage.value =
            error?.response?.data?.message ||
            error?.message ||
            "Failed to load dashboard data.";

        resetDashboardSections();
    } finally {
        if (loadToken === currentLoadToken) {
            loading.value = false;
        }
    }
}

onMounted(() => {
    loadDashboardData();
});

</script>

<style scoped>
.dashboard-page {
    min-height: 100%;
    background: #f4f6f9;
}

.dashboard-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    flex-wrap: wrap;
}

.dashboard-title {
    margin: 0;
    font-size: 1.8rem;
    font-weight: 700;
    color: #111827;
}

.dashboard-subtitle {
    margin-top: 4px;
    color: #6b7280;
    font-size: 0.95rem;
}

.dashboard-card {
    border: 0;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
}

.section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 14px 18px;
    border-bottom: 0;
}

.section-header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}

.section-icon {
    width: 42px;
    height: 42px;
    border-radius: 12px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    background: rgba(255, 255, 255, 0.22);
    color: #fff;
}

.section-title {
    color: #fff;
    font-weight: 700;
}

.section-subtitle {
    color: rgba(255, 255, 255, 0.88);
}

.section-header-danger {
    background: linear-gradient(135deg, #ef4444, #dc2626);
}

.section-header-info {
    background: linear-gradient(135deg, #0ea5e9, #2563eb);
}

.section-header-primary {
    background: linear-gradient(135deg, #6366f1, #4f46e5);
}

.section-header-success {
    background: linear-gradient(135deg, #10b981, #059669);
}

.section-header-warning {
    background: linear-gradient(135deg, #f59e0b, #d97706);
}

.section-header-gray {
    background: linear-gradient(135deg, #9ca3af, #6b7280);
}

.book-slide-card {
    display: block;
    height: 100%;
    color: inherit;
    background: #fff;
    border: 1px solid #eef2f7;
    border-radius: 16px;
    overflow: hidden;
    transition: transform 0.18s ease, box-shadow 0.18s ease;
}

.book-slide-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 14px 28px rgba(15, 23, 42, 0.08);
}

.book-slide-card__image-wrap {
    position: relative;
    aspect-ratio: 3 / 4;
    background: #f8fafc;
    overflow: hidden;
}

.book-slide-card__image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.book-slide-card__body {
    padding: 14px;
}

.book-slide-card__title {
    margin: 0;
    font-size: 0.95rem;
    font-weight: 700;
    color: #111827;
    line-height: 1.4;
    min-height: 2.7em;
    overflow: hidden;
}

.book-slide-card__author {
    margin-top: 6px;
    font-size: 0.86rem;
    color: #6b7280;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.book-slide-card__meta {
    font-size: 0.8rem;
    color: #94a3b8;
}

.book-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    z-index: 1;
    padding: 5px 10px;
    border-radius: 999px;
    font-size: 0.72rem;
    font-weight: 700;
    color: #fff;
}

.book-badge--recommended {
    background: #dc2626;
}

.book-badge--popular {
    background: #f59e0b;
}

.book-badge--interest {
    background: #7c3aed;
}

.book-badge--new {
    background: #2563eb;
}

.book-tag-list {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 6px;
}

.book-tag {
    display: inline-flex;
    align-items: center;
    padding: 4px 8px;
    border-radius: 999px;
    background: #f8fafc;
    border: 1px solid #e5e7eb;
    color: #475569;
    font-size: 0.74rem;
    font-weight: 600;
    max-width: 100%;
}

.continue-card__progress-wrap {
    margin-top: 12px;
}

.continue-card__progress {
    height: 8px;
    border-radius: 999px;
    overflow: hidden;
    background: #e5e7eb;
}

.continue-card__percent {
    margin-top: 8px;
    font-size: 0.82rem;
    color: #059669;
    font-weight: 700;
    text-align: right;
}

.favorite-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.favorite-row {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 12px;
    background: #fff;
    border: 1px solid #eef2f7;
    border-radius: 14px;
    color: inherit;
    transition: transform 0.18s ease, box-shadow 0.18s ease;
}

.favorite-row:hover {
    transform: translateY(-3px);
    box-shadow: 0 14px 28px rgba(15, 23, 42, 0.08);
}

.favorite-row__thumb {
    width: 64px;
    height: 84px;
    object-fit: cover;
    border-radius: 10px;
    flex-shrink: 0;
    background: #f8fafc;
}

.favorite-row__content {
    min-width: 0;
    flex: 1 1 auto;
}

.favorite-row__title {
    font-size: 1rem;
    font-weight: 700;
    color: #111827;
    line-height: 1.4;
}

.favorite-row__author {
    margin-top: 6px;
    font-size: 0.88rem;
    color: #6b7280;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.favorite-row__action {
    flex-shrink: 0;
}

.favorite-row__btn {
    white-space: nowrap;
    pointer-events: none;
}

:deep(.swiper-button-next),
:deep(.swiper-button-prev) {
    color: #2563eb;
}

:deep(.swiper-button-next::after),
:deep(.swiper-button-prev::after) {
    font-size: 18px;
    font-weight: 700;
}

@media (max-width: 768px) {
    .dashboard-title {
        font-size: 1.45rem;
    }

    .favorite-row {
        align-items: flex-start;
    }

    .favorite-row__action {
        align-self: center;
    }
}

@media (max-width: 575.98px) {
    .favorite-row {
        gap: 10px;
    }

    .favorite-row__thumb {
        width: 56px;
        height: 76px;
    }

    .favorite-row__btn {
        padding-left: 10px;
        padding-right: 10px;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.dashboard-page,
html.dark-mode .content-wrapper.dashboard-page,
.dark-mode .content-wrapper.dashboard-page {
    background: #0f172a !important;
}

body.dark-mode .dashboard-page,
html.dark-mode .dashboard-page,
.dark-mode .dashboard-page {
    background: #0f172a !important;
    color: #e5e7eb !important;
}

body.dark-mode .dashboard-page .dashboard-title,
html.dark-mode .dashboard-page .dashboard-title,
.dark-mode .dashboard-page .dashboard-title {
    color: #f8fafc !important;
}

body.dark-mode .dashboard-page .dashboard-subtitle,
html.dark-mode .dashboard-page .dashboard-subtitle,
.dark-mode .dashboard-page .dashboard-subtitle {
    color: #9ca3af !important;
}

body.dark-mode .dashboard-page .card,
body.dark-mode .dashboard-page .dashboard-card,
html.dark-mode .dashboard-page .card,
html.dark-mode .dashboard-page .dashboard-card,
.dark-mode .dashboard-page .card,
.dark-mode .dashboard-page .dashboard-card {
    background: #111827 !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
    color: #e5e7eb !important;
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.35) !important;
}

body.dark-mode .dashboard-page .card-body,
html.dark-mode .dashboard-page .card-body,
.dark-mode .dashboard-page .card-body {
    background: #111827 !important;
    color: #e5e7eb !important;
}

body.dark-mode .dashboard-page .book-slide-card,
body.dark-mode .dashboard-page .favorite-row,
html.dark-mode .dashboard-page .book-slide-card,
html.dark-mode .dashboard-page .favorite-row,
.dark-mode .dashboard-page .book-slide-card,
.dark-mode .dashboard-page .favorite-row {
    background: #1f2937 !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
    color: #e5e7eb !important;
    box-shadow: none !important;
}

body.dark-mode .dashboard-page .book-slide-card:hover,
body.dark-mode .dashboard-page .favorite-row:hover,
html.dark-mode .dashboard-page .book-slide-card:hover,
html.dark-mode .dashboard-page .favorite-row:hover,
.dark-mode .dashboard-page .book-slide-card:hover,
.dark-mode .dashboard-page .favorite-row:hover {
    box-shadow: 0 14px 28px rgba(0, 0, 0, 0.35) !important;
    border-color: rgba(255, 255, 255, 0.12) !important;
}

body.dark-mode .dashboard-page .book-slide-card__image-wrap,
body.dark-mode .dashboard-page .favorite-row__thumb,
html.dark-mode .dashboard-page .book-slide-card__image-wrap,
html.dark-mode .dashboard-page .favorite-row__thumb,
.dark-mode .dashboard-page .book-slide-card__image-wrap,
.dark-mode .dashboard-page .favorite-row__thumb {
    background: #0b1220 !important;
}

body.dark-mode .dashboard-page .book-slide-card__title,
body.dark-mode .dashboard-page .favorite-row__title,
html.dark-mode .dashboard-page .book-slide-card__title,
html.dark-mode .dashboard-page .favorite-row__title,
.dark-mode .dashboard-page .book-slide-card__title,
.dark-mode .dashboard-page .favorite-row__title {
    color: #f3f4f6 !important;
}

body.dark-mode .dashboard-page .book-slide-card__author,
body.dark-mode .dashboard-page .favorite-row__author,
html.dark-mode .dashboard-page .book-slide-card__author,
html.dark-mode .dashboard-page .favorite-row__author,
.dark-mode .dashboard-page .book-slide-card__author,
.dark-mode .dashboard-page .favorite-row__author {
    color: #cbd5e1 !important;
}

body.dark-mode .dashboard-page .book-slide-card__meta,
html.dark-mode .dashboard-page .book-slide-card__meta,
.dark-mode .dashboard-page .book-slide-card__meta {
    color: #94a3b8 !important;
}

body.dark-mode .dashboard-page .book-tag,
html.dark-mode .dashboard-page .book-tag,
.dark-mode .dashboard-page .book-tag {
    background: #243244 !important;
    color: #dbe4ec !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
}

body.dark-mode .dashboard-page .continue-card__progress,
html.dark-mode .dashboard-page .continue-card__progress,
.dark-mode .dashboard-page .continue-card__progress {
    background: #334155 !important;
}

body.dark-mode .dashboard-page .continue-card__percent,
html.dark-mode .dashboard-page .continue-card__percent,
.dark-mode .dashboard-page .continue-card__percent {
    color: #6ee7b7 !important;
}

body.dark-mode .dashboard-page .text-muted,
body.dark-mode .dashboard-page .small.text-muted,
html.dark-mode .dashboard-page .text-muted,
html.dark-mode .dashboard-page .small.text-muted,
.dark-mode .dashboard-page .text-muted,
.dark-mode .dashboard-page .small.text-muted {
    color: #9ca3af !important;
}

body.dark-mode .dashboard-page .alert-danger,
html.dark-mode .dashboard-page .alert-danger,
.dark-mode .dashboard-page .alert-danger {
    background: #44262a !important;
    border-color: #7f1d1d !important;
    color: #fecaca !important;
}

body.dark-mode .dashboard-page .btn-outline-primary,
html.dark-mode .dashboard-page .btn-outline-primary,
.dark-mode .dashboard-page .btn-outline-primary {
    color: #93c5fd !important;
    border-color: #3b82f6 !important;
    background: transparent !important;
}

body.dark-mode .dashboard-page .btn-outline-primary:hover,
html.dark-mode .dashboard-page .btn-outline-primary:hover,
.dark-mode .dashboard-page .btn-outline-primary:hover {
    background: #1d4ed8 !important;
    color: #ffffff !important;
    border-color: #1d4ed8 !important;
}

body.dark-mode .dashboard-page .favorite-row__btn,
html.dark-mode .dashboard-page .favorite-row__btn,
.dark-mode .dashboard-page .favorite-row__btn {
    color: #fff !important;
}

body.dark-mode .dashboard-page .spinner-border.text-primary,
html.dark-mode .dashboard-page .spinner-border.text-primary,
.dark-mode .dashboard-page .spinner-border.text-primary {
    color: #93c5fd !important;
}

body.dark-mode .dashboard-page .far.fa-folder-open,
html.dark-mode .dashboard-page .far.fa-folder-open,
.dark-mode .dashboard-page .far.fa-folder-open {
    color: #94a3b8 !important;
}

body.dark-mode .dashboard-page .swiper-button-next,
body.dark-mode .dashboard-page .swiper-button-prev,
html.dark-mode .dashboard-page .swiper-button-next,
html.dark-mode .dashboard-page .swiper-button-prev,
.dark-mode .dashboard-page .swiper-button-next,
.dark-mode .dashboard-page .swiper-button-prev {
    color: #93c5fd !important;
}
</style>
