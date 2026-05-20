<template>
    <div class="content-wrapper book-detail-page">
        <!-- Header -->
        <section class="content-header">
            <div class="container-fluid">
                <div class="detail-header">
                    <div class="detail-header__left">

                        <h1 class="detail-header__title mb-1">Book Details</h1>
<!--                        if user level = admin set name ='items' and author or user go to items.author-->
<!--                        <router-link :to="{ name: 'items' }" class="btn btn-secondary btn-sm" active-class="active">-->
<!--                            <i-->
<!--                                class="fas fa-arrow-left mr-1"></i> Back-->
<!--                        </router-link>-->
                        <router-link
                            :to="{ name: backRoute }"
                            class="btn btn-secondary btn-sm"
                        >
                            <i class="fas fa-arrow-left mr-1"></i> Back
                        </router-link>
<!--                        <button class="btn btn-secondary btn-sm" @click="goBack">-->
<!--                            <i class="fas fa-arrow-left mr-1"></i> Back-->
<!--                        </button>-->
                    </div>


                </div>
            </div>
        </section>

        <!-- Content -->
        <section class="content pb-4">
            <div class="container-fluid">
                <!-- Loading -->
                <div v-if="loading" class="state-card text-center py-5">
                    <div class="state-icon loading-icon mb-3">
                        <i class="fas fa-spinner fa-spin"></i>
                    </div>
                    <h5 class="mb-2">Loading book details...</h5>
                    <p class="text-muted-custom mb-0">
                        Please wait while we fetch the data.
                    </p>
                </div>

                <!-- Not found -->
                <div v-else-if="!item || !item.id" class="state-card text-center py-5">
                    <div class="state-icon empty-icon mb-3">
                        <i class="far fa-folder-open"></i>
                    </div>
                    <h5 class="mb-2">Book not found</h5>
                    <p class="text-muted-custom mb-0">
                        The requested book does not exist or could not be loaded.
                    </p>
                </div>

                <!-- Detail -->
                <div v-else class="row">
                    <!-- Left -->
                    <div class="col-lg-4 col-md-5 mb-4">
                        <div class="card detail-card cover-card h-100">
                            <div class="cover-card__image-wrap">
                                <img
                                    :src="coverSrc(item.cover_url)"
                                    :alt="item.title || 'Book cover'"
                                    class="cover-card__image"
                                    @error="onImageError"
                                />
                            </div>

                            <div class="card-body text-center">
                                <h5 class="cover-card__title mb-2">
                                    {{ item.title || "Untitled Book" }}
                                </h5>

                                <p class="cover-card__author mb-3">
                                    <i class="fas fa-user-edit mr-2"></i>
                                    {{ authorName }}
                                </p>

                                <div class="status-wrap mb-3">
                                    <span
                                        class="status-badge"
                                        :class="item.is_active ? 'status-badge--active' : 'status-badge--inactive'"
                                    >
                                        <i
                                            class="fas mr-1"
                                            :class="item.is_active ? 'fa-check-circle' : 'fa-pause-circle'"
                                        ></i>
                                        {{ item.is_active ? "Active" : "Inactive" }}
                                    </span>
                                </div>

                                <div class="quick-meta">
                                    <div class="quick-meta__item">
                                        <span class="quick-meta__label">Pages</span>
                                        <span class="quick-meta__value">{{ item.pages || "—" }}</span>
                                    </div>
                                    <div class="quick-meta__item">
                                        <span class="quick-meta__label">Language</span>
                                        <span class="quick-meta__value">{{ item.language || "—" }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right -->
                    <div class="col-lg-8 col-md-7 mb-4">
                        <div class="card detail-card info-card">
                            <div class="card-header info-card__header border-0">
                                <div>
                                    <h3 class="card-title mb-0">Book Information</h3>
                                </div>
                            </div>

                            <div class="card-body">
                                <div class="info-grid">
                                    <div class="info-row">
                                        <div class="info-label">
                                            <i class="fas fa-heading mr-2"></i>Title
                                        </div>
                                        <div class="info-value">{{ item.title || "—" }}</div>
                                    </div>

                                    <div class="info-row">
                                        <div class="info-label">
                                            <i class="fas fa-user mr-2"></i>Author
                                        </div>
                                        <div class="info-value">{{ authorName }}</div>
                                    </div>

                                    <div class="info-row">
                                        <div class="info-label">
                                            <i class="fas fa-language mr-2"></i>Language
                                        </div>
                                        <div class="info-value">{{ item.language || "—" }}</div>
                                    </div>

<!--                                    <div class="info-row">-->
<!--                                        <div class="info-label">-->
<!--                                            <i class="fas fa-copy mr-2"></i>Pages-->
<!--                                        </div>-->
<!--                                        <div class="info-value">{{ item.pages || "—" }}</div>-->
<!--                                    </div>-->

                                    <div class="info-row">
                                        <div class="info-label">
                                            <i class="fas fa-layer-group mr-2"></i>Category
                                        </div>
                                        <div class="info-value">{{ item.category?.name || "N/A" }}</div>
                                    </div>

                                    <div class="info-row info-row--block">
                                        <div class="info-label">
                                            <i class="fas fa-align-left mr-2"></i>Description
                                        </div>
                                        <div class="info-value info-value--description">
                                            {{ item.description || "No description available." }}
                                        </div>
                                    </div>
                                </div>

                                <div class="action-section mt-4">
                                    <router-link
                                        v-if="item?.id && item?.file_url"
                                        :to="{
                                            name: 'items.pdf-progress',
                                            params: { itemId: item.id },
                                            query: {
                                                file: fileSrc(item.file_url),
                                                title: item.title
                                            }
                                        }"
                                        class="btn btn-read"
                                    >
                                        <i class="fas fa-file-pdf mr-2"></i>
                                        Read PDF
                                    </router-link>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /row -->
            </div>
        </section>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { apiShowItem } from "@func/api/item.js";
import defaultCover from "@assets/images/defaultCover.jpg";
import {useStore} from "vuex";

const route = useRoute();
const store = useStore();

const item = ref({});
const loading = ref(true);

const currentUser = computed(() => store.state.user || {});

const backRoute = computed(() => {
    return currentUser.level === 'admin' ? 'items' : 'items.author';
});

const API_BASE = (import.meta.env.VITE_URL || "").replace(/\/+$/, "");


const normalizeItem = (payload) => {
    if (payload?.data) return payload.data;
    return payload || {};
};

const authorName = computed(() => {
    return (
        item.value?.author?.name ||
        item.value?.author_name ||
        item.value?.author?.full_name ||
        item.value?.user?.name ||
        item.value?.created_by?.name ||
        item.value?.author ||
        "Unknown Author"
    );
});

const coverSrc = (url) => {
    if (!url) return defaultCover;
    if (url.startsWith("blob:")) return url;
    if (/^https?:\/\//i.test(url)) return url;

    if (url.startsWith("/storage/")) {
        return `${API_BASE}${url}`;
    }

    return `${API_BASE}/storage/${url.replace(/^\/+/, "")}`;
};

const fileSrc = (url) => {
    if (!url) return "";

    if (url.startsWith("blob:")) return url;

    const cleanUrl = url.replace(/^https?:\/\/[^/]+/i, "");

    if (cleanUrl.startsWith("/storage/")) return cleanUrl;

    return `/storage/${cleanUrl.replace(/^\/+/, "")}`;
};

const onImageError = (event) => {
    event.target.src = defaultCover;
};

const fetchItem = async () => {
    loading.value = true;

    try {
        const id = route.params.id;

        if (!id) {
            console.error("No item id found in route params.");
            item.value = {};
            return;
        }

        const res = await apiShowItem(id);
        item.value = normalizeItem(res.data);
    } catch (error) {
        console.error("Failed to load item:", error?.response || error);
        item.value = {};
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    fetchItem();
});
</script>

<style scoped>
.book-detail-page {
    background: var(--page-bg, #f4f6f9);
    min-height: 100vh;
}

/* Header */
.detail-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    flex-wrap: wrap;
    padding: 0.35rem 0 0.75rem;
}

.detail-header__badge {
    display: inline-flex;
    align-items: center;
    padding: 0.45rem 0.85rem;
    border-radius: 999px;
    font-size: 0.8rem;
    font-weight: 700;
    margin-bottom: 0.85rem;
    background: rgba(13, 110, 253, 0.1);
    color: #0d6efd;
}

.detail-header__title {
    font-size: 1.9rem;
    font-weight: 800;
    color: var(--heading-color, #1f2937);
}

.detail-header__subtitle {
    color: var(--text-muted-2, #6b7280);
    font-size: 0.95rem;
}

.btn-back {
    border: 1px solid var(--border-soft, #d7dce3);
    background: var(--card-bg, #ffffff);
    color: var(--heading-color, #1f2937);
    border-radius: 12px;
    padding: 0.65rem 1rem;
    font-weight: 600;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
    transition: all 0.2s ease;
}

.btn-back:hover {
    transform: translateY(-1px);
    color: #fff;
    background: #343a40;
    border-color: #343a40;
}

/* Shared cards */
.detail-card,
.state-card {
    border: 1px solid var(--border-soft, #e5e7eb);
    border-radius: 20px;
    background: var(--card-bg, #ffffff);
    box-shadow: 0 14px 35px rgba(15, 23, 42, 0.07);
    overflow: hidden;
}

.state-card {
    padding: 2rem 1rem;
}

.state-icon {
    width: 74px;
    height: 74px;
    margin: 0 auto;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 1.7rem;
}

.loading-icon {
    background: rgba(13, 110, 253, 0.12);
    color: #0d6efd;
}

.empty-icon {
    background: rgba(108, 117, 125, 0.15);
    color: #6c757d;
}

/* Cover card */
.cover-card__image-wrap {
    background: linear-gradient(135deg, rgba(13, 110, 253, 0.06), rgba(111, 66, 193, 0.08));
    padding: 1.2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 420px;
}

.cover-card__image {
    width: 100%;
    max-height: 520px;
    object-fit: contain;
    border-radius: 16px;
    box-shadow: 0 12px 30px rgba(15, 23, 42, 0.16);
    background: #fff;
}

.cover-card__title {
    font-size: 1.2rem;
    font-weight: 800;
    color: var(--heading-color, #1f2937);
    line-height: 1.5;
}

.cover-card__author {
    color: var(--text-muted-2, #6b7280);
    font-size: 0.95rem;
}

.status-wrap {
    display: flex;
    justify-content: center;
}

.status-badge {
    display: inline-flex;
    align-items: center;
    border-radius: 999px;
    padding: 0.55rem 0.95rem;
    font-weight: 700;
    font-size: 0.85rem;
}

.status-badge--active {
    background: rgba(40, 167, 69, 0.14);
    color: #28a745;
}

.status-badge--inactive {
    background: rgba(108, 117, 125, 0.15);
    color: #6c757d;
}

.quick-meta {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
}

.quick-meta__item {
    border-radius: 14px;
    padding: 0.9rem 0.75rem;
    background: var(--soft-bg, #f8fafc);
    border: 1px solid var(--border-soft, #e5e7eb);
}

.quick-meta__label {
    display: block;
    font-size: 0.76rem;
    font-weight: 700;
    letter-spacing: 0.03em;
    text-transform: uppercase;
    color: var(--text-muted-2, #6b7280);
    margin-bottom: 0.35rem;
}

.quick-meta__value {
    display: block;
    font-size: 0.98rem;
    font-weight: 700;
    color: var(--heading-color, #1f2937);
    word-break: break-word;
}

/* Info card */
.info-card__header {
    padding: 1.35rem 1.5rem 0.6rem;
    background: transparent;
}

.info-card .card-title {
    font-size: 1.2rem;
    font-weight: 800;
    color: var(--heading-color, #1f2937);
}

.info-grid {
    display: flex;
    flex-direction: column;
    gap: 0.9rem;
}

.info-row {
    display: grid;
    grid-template-columns: 180px 1fr;
    gap: 1rem;
    align-items: start;
    padding: 1rem 1.05rem;
    border-radius: 16px;
    background: var(--soft-bg, #f8fafc);
    border: 1px solid var(--border-soft, #e5e7eb);
}

.info-row--block {
    align-items: stretch;
}

.info-label {
    font-weight: 700;
    color: var(--heading-color, #1f2937);
    display: flex;
    align-items: center;
    min-height: 24px;
}

.info-value {
    color: var(--body-color, #374151);
    line-height: 1.7;
    word-break: break-word;
}

.info-value--description {
    white-space: pre-line;
}

.action-section {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
}

.btn-read {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: none;
    border-radius: 14px;
    padding: 0.8rem 1.2rem;
    font-weight: 700;
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: #fff;
    box-shadow: 0 12px 24px rgba(220, 53, 69, 0.25);
    transition: all 0.2s ease;
    text-decoration: none;
}

.btn-read:hover {
    color: #fff;
    transform: translateY(-1px);
    box-shadow: 0 16px 28px rgba(220, 53, 69, 0.32);
}

.text-muted-custom {
    color: var(--text-muted-2, #6b7280) !important;
}

/* Dark mode support */
:global(body.dark-mode) .book-detail-page,
:global(.dark-mode) .book-detail-page {
    --page-bg: #0f172a;
    --card-bg: #111827;
    --soft-bg: #182235;
    --border-soft: rgba(255, 255, 255, 0.08);
    --heading-color: #f8fafc;
    --body-color: #dbe4f0;
    --text-muted-2: #94a3b8;
}

:global(body.dark-mode) .detail-header__badge,
:global(.dark-mode) .detail-header__badge {
    background: rgba(96, 165, 250, 0.15);
    color: #93c5fd;
}

:global(body.dark-mode) .detail-card,
:global(body.dark-mode) .state-card,
:global(.dark-mode) .detail-card,
:global(.dark-mode) .state-card {
    box-shadow: 0 18px 40px rgba(0, 0, 0, 0.35);
}

:global(body.dark-mode) .btn-back,
:global(.dark-mode) .btn-back {
    background: #182235;
    color: #f8fafc;
    border-color: rgba(255, 255, 255, 0.08);
}

:global(body.dark-mode) .btn-back:hover,
:global(.dark-mode) .btn-back:hover {
    background: #2563eb;
    border-color: #2563eb;
    color: #fff;
}

:global(body.dark-mode) .cover-card__image,
:global(.dark-mode) .cover-card__image {
    background: #0f172a;
}

:global(body.dark-mode) .cover-card__image-wrap,
:global(.dark-mode) .cover-card__image-wrap {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.09), rgba(168, 85, 247, 0.08));
}

:global(body.dark-mode) .status-badge--active,
:global(.dark-mode) .status-badge--active {
    background: rgba(34, 197, 94, 0.18);
    color: #86efac;
}

:global(body.dark-mode) .status-badge--inactive,
:global(.dark-mode) .status-badge--inactive {
    background: rgba(148, 163, 184, 0.18);
    color: #cbd5e1;
}

:global(body.dark-mode) .loading-icon,
:global(.dark-mode) .loading-icon {
    background: rgba(59, 130, 246, 0.18);
    color: #93c5fd;
}

:global(body.dark-mode) .empty-icon,
:global(.dark-mode) .empty-icon {
    background: rgba(148, 163, 184, 0.14);
    color: #cbd5e1;
}

/* Responsive */
@media (max-width: 991.98px) {
    .cover-card__image-wrap {
        min-height: 360px;
    }

    .info-row {
        grid-template-columns: 1fr;
        gap: 0.5rem;
    }

    .info-label {
        margin-bottom: 0.15rem;
    }
}

@media (max-width: 767.98px) {
    .detail-header {
        align-items: flex-start;
    }

    .detail-header__title {
        font-size: 1.55rem;
    }

    .quick-meta {
        grid-template-columns: 1fr;
    }

    .cover-card__image-wrap {
        min-height: 300px;
        padding: 1rem;
    }

    .info-card__header,
    .info-card .card-body {
        padding-left: 1rem;
        padding-right: 1rem;
    }
}
</style>
