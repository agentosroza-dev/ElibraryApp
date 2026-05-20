<template>
    <div class="content-wrapper book-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="d-flex flex-wrap justify-content-between align-items-center page-header">
                    <div class="mb-2 mb-md-0">
                        <h3 class="hero-title mb-1">List Books by Author</h3>
                    </div>

                    <ol class="breadcrumb mb-0 bg-transparent p-0">
                        <li class="breadcrumb-item">
                            <router-link :to="{ name: 'dashboard' }">Home</router-link>
                        </li>
                        <li class="breadcrumb-item active">Books</li>
                    </ol>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="card books-hero-card shadow-sm border-0">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4 mb-3 mb-md-0">
                                <label class="filter-label">Category</label>
                                <select v-model="filters.category_id" class="form-control filter-control">
                                    <option value="">All categories</option>
                                    <option
                                        v-for="category in categories"
                                        :key="category.id"
                                        :value="String(category.id)"
                                    >
                                        {{ category.name }}
                                    </option>
                                </select>
                            </div>

                            <div class="col-md-4 mb-3 mb-md-0">
                                <label class="filter-label">Search</label>
                                <div class="search-box">
                                    <i class="fas fa-search search-icon"></i>
                                    <input
                                        v-model.trim="filters.search"
                                        type="text"
                                        class="form-control filter-control search-input"
                                        placeholder="Search title, slug, author"
                                        @keyup.enter="applyFilters"
                                    />
                                </div>
                            </div>

                            <div class="col-md-2 d-flex align-items-end">
                                <button
                                    type="button"
                                    class="btn btn-outline-primary btn-block btn-filter"
                                    @click="applyFilters"
                                >
                                    <i class="fas fa-filter mr-1"></i>
                                    Apply
                                </button>
                            </div>

                            <div class="col-md-2 d-flex align-items-end">
                                <button
                                    v-if="canCreate"
                                    type="button"
                                    class="btn btn-primary btn-add-book btn-block"
                                    @click="openCreate"
                                >
                                    <i class="fas fa-plus mr-2"></i>
                                    Add Book
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm border-0 books-table-card">
                    <div class="card-header bg-transparent border-0">
                        <div class="d-flex flex-wrap justify-content-between align-items-center">
                            <small class="text-muted">
                                Total: {{ items.data.length }} item{{ items.data.length === 1 ? "" : "s" }} on this page
                            </small>
                        </div>
                    </div>

                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0 books-table">
                                <thead>
                                <tr>
                                    <th style="width: 70px">#</th>
                                    <th style="min-width: 220px">Book</th>
                                    <th style="min-width: 90px">Category</th>
                                    <th style="min-width: 90px">Author</th>
                                    <th style="width: 100px">Year</th>
                                    <th style="min-width: 120px">Tags</th>
                                    <th style="width: 80px">Language</th>
                                    <th style="width: 90px">Total Read</th>
                                    <th style="width: 90px">Status</th>
                                    <th style="width: 120px" class="text-right">Actions</th>
                                </tr>
                                </thead>

                                <tbody>
                                <tr v-if="loading">
                                    <td colspan="10" class="text-center py-5 text-muted">
                                        <i class="fas fa-spinner fa-spin mr-2"></i>
                                        Loading books...
                                    </td>
                                </tr>

                                <tr v-else-if="!items.data.length">
                                    <td colspan="10" class="text-center py-5 text-muted">
                                        <i class="far fa-folder-open mr-2"></i>
                                        No books found.
                                    </td>
                                </tr>

                                <tr v-for="(item, index) in items.data" :key="item.id">
                                    <td class="text-muted font-weight-bold">
                                        {{ index + 1 + (items.current_page - 1) * items.per_page }}
                                    </td>

                                    <td>
                                        <div class="book-cell">
                                            <div class="book-cover-wrap">
                                                <img
                                                    :src="getItemCover(item)"
                                                    alt="cover"
                                                    class="book-cover"
                                                    @error="onImageError"
                                                />
                                            </div>

                                            <div class="book-meta">
                                                <div class="book-title text-truncate">
                                                    {{ item.title || "Untitled" }}
                                                </div>
                                                <div class="book-slug text-truncate">
                                                    {{ item.slug || "—" }}
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                            <span v-if="item.category?.name" class="badge badge-category">
                                                <i class="fas fa-folder-open mr-1"></i>
                                                {{ item.category.name }}
                                            </span>
                                        <span v-else class="text-muted">—</span>
                                    </td>

                                    <td>
                                            <span class="author-name text-truncate d-inline-block">
                                                {{ getAuthorName(item) }}
                                            </span>
                                    </td>

                                    <td>{{ item.publish_year || "—" }}</td>

                                    <td>
                                        <div v-if="getTagList(item).length" class="table-tags">
                                                <span
                                                    v-for="tag in getTagList(item)"
                                                    :key="tag.id"
                                                    class="badge badge-tag"
                                                >
                                                    {{ tag.name }}
                                                </span>
                                        </div>
                                        <span v-else class="text-muted">—</span>
                                    </td>

                                    <td>
                                            <span class="badge badge-lang">
                                                {{ item.language || "—" }}
                                            </span>
                                    </td>

                                    <td>{{ getViewsCount(item.id) }}</td>

                                    <td>
                                            <span
                                                class="badge status-badge"
                                                :class="item.is_active ? 'status-active' : 'status-inactive'"
                                            >
                                                <i
                                                    class="fas"
                                                    :class="item.is_active ? 'fa-check-circle mr-1' : 'fa-pause-circle mr-1'"
                                                ></i>
                                                {{ item.is_active ? "Active" : "Inactive" }}
                                            </span>
                                    </td>

                                    <td class="text-right">
                                        <div class="action-buttons">
                                            <router-link
                                                class="btn btn-sm btn-action btn-view"
                                                :to="{ name: 'items.view', params: { id: item.id } }"
                                                title="View"
                                            >
                                                <i class="fas fa-eye"></i>
                                            </router-link>

                                            <button
                                                v-if="canEdit(item)"
                                                type="button"
                                                class="btn btn-sm btn-action btn-edit"
                                                title="Edit"
                                                @click="openEdit(item)"
                                            >
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div
                        v-if="items.last_page > 1"
                        class="card-footer bg-transparent border-0 d-flex flex-wrap justify-content-between align-items-center"
                    >
                        <small class="text-muted mb-2 mb-md-0">
                            Page {{ items.current_page }} of {{ items.last_page }}
                        </small>

                        <div class="pagination-actions">
                            <button
                                type="button"
                                class="btn btn-sm btn-outline-secondary mr-2"
                                :disabled="items.current_page === 1"
                                @click="changePage(items.current_page - 1)"
                            >
                                <i class="fas fa-angle-left mr-1"></i>
                                Prev
                            </button>

                            <button
                                type="button"
                                class="btn btn-sm btn-outline-secondary"
                                :disabled="items.current_page === items.last_page"
                                @click="changePage(items.current_page + 1)"
                            >
                                Next
                                <i class="fas fa-angle-right ml-1"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <div
                    v-if="showModal"
                    class="modal fade show custom-modal-overlay"
                    tabindex="-1"
                    role="dialog"
                    aria-modal="true"
                    style="display: block"
                    @click.self="closeModal"
                >
                    <div class="modal-dialog modal-xl custom-modal-dialog" role="document">
                        <div class="modal-content custom-modal">
                            <form class="custom-modal-form" @submit.prevent="saveItem">
                                <div class="modal-header custom-modal-header">
                                    <div>
                                        <h5 class="modal-title mb-1">
                                            <i class="fas fa-book mr-2"></i>
                                            {{ itemForm.id ? "Edit Book" : "Create Book" }}
                                        </h5>
                                        <small class="modal-subtitle">
                                            Fill in the book information and upload files if needed.
                                        </small>
                                    </div>

                                    <button type="button" class="close modal-close-btn" @click="closeModal">
                                        <span>&times;</span>
                                    </button>
                                </div>

                                <div class="modal-body custom-modal-body">
                                    <div class="form-row">
                                        <div class="form-group col-md-6">
                                            <label>Title <span class="text-danger">*</span></label>
                                            <input v-model.trim="itemForm.title" type="text" class="form-control" />
                                            <small v-if="errors.title" class="text-danger">{{ errors.title[0] }}</small>
                                        </div>

                                        <div class="form-group col-md-6">
                                            <label>Slug</label>
                                            <input v-model.trim="itemForm.slug" type="text" class="form-control" />
                                            <small v-if="errors.slug" class="text-danger">{{ errors.slug[0] }}</small>
                                        </div>

                                        <div class="form-group col-md-6">
                                            <label>Category <span class="text-danger">*</span></label>
                                            <select v-model="itemForm.category_id" class="form-control">
                                                <option value="">Select category</option>
                                                <option
                                                    v-for="category in categories"
                                                    :key="category.id"
                                                    :value="String(category.id)"
                                                >
                                                    {{ category.name }}
                                                </option>
                                            </select>
                                            <small v-if="errors.category_id" class="text-danger">
                                                {{ errors.category_id[0] }}
                                            </small>
                                        </div>

                                        <div class="form-group col-md-6 author-select-wrapper" ref="authorBoxRef">
                                            <label>Author</label>

                                            <div class="author-select">
                                                <template v-if="isAuthor">
                                                    <input
                                                        :value="currentUser.name || ''"
                                                        type="text"
                                                        class="form-control"
                                                        disabled
                                                    />
                                                    <small class="text-muted d-block mt-1">
                                                        Author is auto-selected from your account
                                                    </small>
                                                </template>

                                                <template v-else>
                                                    <div v-if="selectedAuthorName" class="selected-author-chip mb-2">
                                                        <span>{{ selectedAuthorName }}</span>
                                                        <button
                                                            type="button"
                                                            class="chip-remove"
                                                            title="Clear"
                                                            @click="clearAuthor"
                                                        >
                                                            ×
                                                        </button>
                                                    </div>

                                                    <input
                                                        v-model.trim="authorSearch"
                                                        type="text"
                                                        class="form-control"
                                                        placeholder="Type to search author..."
                                                        @focus="handleAuthorFocus"
                                                        @input="onAuthorSearchInput"
                                                        @keydown.down.prevent="moveHighlight(1)"
                                                        @keydown.up.prevent="moveHighlight(-1)"
                                                        @keydown.enter.prevent="selectHighlightedAuthor"
                                                        @keydown.esc="closeAuthorDropdown"
                                                    />

                                                    <div v-if="showAuthorDropdown" class="author-dropdown shadow-sm">
                                                        <div v-if="!authorSearch.trim()" class="p-2 text-muted small">
                                                            Type author name or email to search
                                                        </div>

                                                        <div v-else-if="authorLoading" class="p-2 text-muted small">
                                                            Loading...
                                                        </div>

                                                        <div v-else-if="!users.length" class="p-2 text-muted small">
                                                            No user found
                                                        </div>

                                                        <button
                                                            v-for="(user, index) in users"
                                                            :key="user.id"
                                                            type="button"
                                                            class="dropdown-item author-dropdown-item"
                                                            :class="{ active: highlightedAuthorIndex === index }"
                                                            @mousedown.prevent="selectAuthor(user)"
                                                        >
                                                            <div class="font-weight-bold">{{ user.name }}</div>
                                                            <small class="text-muted">{{ user.email }}</small>
                                                        </button>
                                                    </div>
                                                </template>
                                            </div>

                                            <small v-if="errors.author_id" class="text-danger d-block mt-1">
                                                {{ errors.author_id[0] }}
                                            </small>
                                        </div>
                                    </div>

                                    <div class="meta-section">
                                        <div class="meta-section-title">
                                            <i class="fas fa-info-circle mr-2"></i>
                                            Book Details
                                        </div>

                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label>Publish Year</label>
                                                <input
                                                    v-model="itemForm.publish_year"
                                                    type="number"
                                                    class="form-control"
                                                    min="1000"
                                                    :max="currentYear"
                                                />
                                                <small v-if="errors.publish_year" class="text-danger">
                                                    {{ errors.publish_year[0] }}
                                                </small>
                                            </div>

                                            <div class="form-group col-md-6">
                                                <label>Language</label>
                                                <select v-model="itemForm.language" class="form-control">
                                                    <option value="">Select language</option>
                                                    <option value="KH">Khmer</option>
                                                    <option value="EN">English</option>
                                                </select>
                                                <small v-if="errors.language" class="text-danger">
                                                    {{ errors.language[0] }}
                                                </small>
                                            </div>

                                            <div class="form-group col-md-12">
                                                <label>Description</label>
                                                <textarea
                                                    v-model.trim="itemForm.description"
                                                    class="form-control"
                                                    rows="4"
                                                    placeholder="Write short description..."
                                                ></textarea>
                                                <small v-if="errors.description" class="text-danger">
                                                    {{ errors.description[0] }}
                                                </small>
                                            </div>

                                            <div class="form-group col-md-12">
                                                <label>Tags</label>
                                                <select v-model="itemForm.tag_ids" class="form-control tag-multi-select" multiple>
                                                    <option
                                                        v-for="tag in tags"
                                                        :key="tag.id"
                                                        :value="Number(tag.id)"
                                                    >
                                                        {{ tag.name }}
                                                    </option>
                                                </select>

                                                <div v-if="selectedTags.length" class="selected-tags-preview mt-2">
                                                    <span v-for="tag in selectedTags" :key="tag.id" class="badge badge-tag">
                                                        {{ tag.name }}
                                                    </span>
                                                </div>

                                                <small v-if="errors.tag_ids" class="text-danger d-block mt-1">
                                                    {{ errors.tag_ids[0] }}
                                                </small>
                                            </div>

                                            <div class="form-group col-md-6">
                                                <label>Cover Image</label>
                                                <input
                                                    type="file"
                                                    class="form-control"
                                                    accept="image/*"
                                                    @change="onCoverChange"
                                                />
                                                <small v-if="errors.cover" class="text-danger d-block mt-1">
                                                    {{ errors.cover[0] }}
                                                </small>

                                                <div v-if="coverPreview || itemForm.cover_url" class="preview-box mt-3">
                                                    <img
                                                        :src="coverPreview || toAssetUrl(itemForm.cover_url, 'cover')"
                                                        alt="Cover Preview"
                                                        class="cover-preview-image"
                                                        @error="onImageError"
                                                    />
                                                </div>
                                            </div>

                                            <div class="form-group col-md-6">
                                                <label>Book File</label>
                                                <input
                                                    type="file"
                                                    class="form-control"
                                                    accept=".pdf,application/pdf"
                                                    @change="onFileChange"
                                                />
                                                <small v-if="errors.file" class="text-danger d-block mt-1">
                                                    {{ errors.file[0] }}
                                                </small>

                                                <div v-if="selectedFileName || existingFileName" class="mt-3">
                                                    <span class="file-pill">
                                                        <i class="fas fa-file-pdf mr-2"></i>
                                                        {{ selectedFileName || existingFileName }}
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="form-group col-md-12 mb-0">
                                                <div class="custom-control custom-switch">
                                                    <input
                                                        id="is-active-switch"
                                                        v-model="itemForm.is_active"
                                                        type="checkbox"
                                                        class="custom-control-input"
                                                    />
                                                    <label class="custom-control-label" for="is-active-switch">
                                                        Active
                                                    </label>
                                                </div>
                                                <small v-if="errors.is_active" class="text-danger d-block mt-1">
                                                    {{ errors.is_active[0] }}
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal-footer custom-modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" @click="closeModal">
                                        Cancel
                                    </button>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save mr-1"></i>
                                        {{ itemForm.id ? "Update Book" : "Create Book" }}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div v-if="showModal" class="modal-backdrop fade show"></div>
            </div>
        </section>
    </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import { useStore } from "vuex";
import defaultCover from "@assets/images/defaultCover.jpg";

import { apiGetCategories } from "@func/api/category.js";
import { apiGetTags } from "@func/api/tag.js";
import { apiGetUsers_author } from "@func/api/user.js";
import {
    apiCreateItem,
    apiGetBookViewCount,
    apiGetItems,
    apiUpdateItem,
} from "@func/api/item.js";

const store = useStore();

const currentYear = computed(() => new Date().getFullYear());
const currentUser = computed(() => store.state.user || {});

const isAuthor = computed(() => String(currentUser.value?.level || "").toLowerCase() === "author");
const isAdmin = computed(() => {
    const level = String(currentUser.value?.level || "").toLowerCase();
    return Number(currentUser.value?.id) === 1 || level === "admin";
});
const canCreate = computed(() => Boolean(currentUser.value?.id) && (isAuthor.value || isAdmin.value));

const loading = ref(false);
const authorLoading = ref(false);
const showModal = ref(false);

const categories = ref([]);
const tags = ref([]);
const users = ref([]);
const userMap = ref({});
const viewsCountMap = ref({});

const errors = ref({});
const authorSearch = ref("");
const selectedAuthorName = ref("");
const highlightedAuthorIndex = ref(-1);
const showAuthorDropdown = ref(false);
const authorBoxRef = ref(null);

const existingFileUrl = ref("");
const existingFileName = ref("");
const coverFile = ref(null);
const bookFile = ref(null);
const coverPreview = ref("");
const selectedFileName = ref("");

let authorSearchTimer = null;
const loadingViewIds = new Set();

const items = reactive({
    data: [],
    current_page: 1,
    last_page: 1,
    per_page: 10,
});

const filters = reactive({
    category_id: "",
    search: "",
    page: 1,
    per_page: 10,
});

const createDefaultItemForm = () => ({
    id: null,
    title: "",
    slug: "",
    description: "",
    cover_url: "",
    file_url: "",
    category_id: "",
    author_id: "",
    publish_year: "",
    language: "KH",
    is_active: true,
    tag_ids: [],
});

const itemForm = reactive(createDefaultItemForm());

const selectedTags = computed(() => {
    const selectedIds = new Set((itemForm.tag_ids || []).map(Number));
    return tags.value.filter((tag) => selectedIds.has(Number(tag.id)));
});

function normalizeSimpleList(payload) {
    if (!payload) return [];
    if (Array.isArray(payload)) return payload;
    if (Array.isArray(payload.data)) return payload.data;
    if (Array.isArray(payload.users)) return payload.users;
    if (Array.isArray(payload.tags)) return payload.tags;
    if (Array.isArray(payload.categories)) return payload.categories;
    return [];
}

function normalizeItemsResponse(payload) {
    if (payload && Array.isArray(payload.data)) {
        return {
            data: payload.data,
            current_page: Number(payload.current_page || 1),
            last_page: Number(payload.last_page || 1),
            per_page: Number(payload.per_page || 10),
        };
    }

    if (Array.isArray(payload)) {
        return {
            data: payload,
            current_page: 1,
            last_page: 1,
            per_page: payload.length || 10,
        };
    }

    return {
        data: [],
        current_page: 1,
        last_page: 1,
        per_page: 10,
    };
}

function rebuildUserMap(list = []) {
    const next = { ...userMap.value };

    for (const user of list) {
        if (user?.id != null) {
            next[String(user.id)] = user;
        }
    }

    userMap.value = next;
}

function getTagList(item) {
    return Array.isArray(item?.tags) ? item.tags : [];
}

function getAuthorName(item) {
    if (item?.author?.name) return item.author.name;
    if (item?.author_name) return item.author_name;

    const authorId = item?.author_id != null ? String(item.author_id) : "";
    if (authorId && userMap.value[authorId]?.name) {
        return userMap.value[authorId].name;
    }

    return "—";
}

function canEdit(item) {
    if (!currentUser.value?.id) return false;
    return isAdmin.value || Number(item?.author_id) === Number(currentUser.value.id);
}

function isAbsoluteUrl(value) {
    return /^https?:\/\//i.test(String(value || ""));
}

function isBlobUrl(value) {
    return /^blob:/i.test(String(value || ""));
}

function getOrigin() {
    return window.location.origin.replace(/\/+$/, "");
}

function getApiRoot() {
    const raw = window.API_BASE_URL || window.API_URL || window.location.origin;
    return String(raw).replace(/\/+$/, "");
}

function toAssetUrl(value, type = "generic") {
    if (!value) return "";

    let raw = String(value).trim();
    if (!raw) return "";

    if (isAbsoluteUrl(raw) || isBlobUrl(raw)) return raw;

    raw = raw.replace(/\\/g, "/");

    if (raw.startsWith("//")) return `${window.location.protocol}${raw}`;
    if (raw.startsWith("/")) return `${getOrigin()}${raw}`;
    if (raw.startsWith("storage/") || raw.startsWith("uploads/")) return `${getOrigin()}/${raw}`;
    if (raw.startsWith("public/")) return `${getOrigin()}/${raw.replace(/^public\//, "")}`;
    if (type === "cover" || type === "file") return `${getOrigin()}/storage/${raw.replace(/^\/+/, "")}`;

    return `${getApiRoot()}/${raw.replace(/^\/+/, "")}`;
}

function getRawCoverValue(item) {
    return item?.cover_url || item?.cover || item?.image_url || item?.image || "";
}

function getRawFileValue(item) {
    return item?.file_url || item?.file || item?.pdf_url || item?.pdf || "";
}

function getItemCover(item) {
    return toAssetUrl(getRawCoverValue(item), "cover") || defaultCover;
}

function getFileNameFromUrl(url) {
    if (!url) return "";

    try {
        return decodeURIComponent(url.split("?")[0].split("/").pop() || "");
    } catch {
        return "";
    }
}

function onImageError(event) {
    if (event?.target && event.target.src !== defaultCover) {
        event.target.src = defaultCover;
    }
}

function getViewsCount(itemId) {
    return viewsCountMap.value[itemId] ?? 0;
}

async function loadViewsForCurrentPage() {
    const missingIds = items.data
        .map((item) => item.id)
        .filter((id) => id != null && viewsCountMap.value[id] == null && !loadingViewIds.has(id));

    if (!missingIds.length) return;

    missingIds.forEach((id) => loadingViewIds.add(id));

    const results = await Promise.allSettled(missingIds.map((id) => apiGetBookViewCount(id)));
    const nextMap = { ...viewsCountMap.value };

    results.forEach((result, index) => {
        const itemId = missingIds[index];
        nextMap[itemId] =
            result.status === "fulfilled"
                ? Number(result.value?.data?.views_count ?? 0)
                : 0;
        loadingViewIds.delete(itemId);
    });

    viewsCountMap.value = nextMap;
}

function revokeCoverPreview() {
    if (coverPreview.value?.startsWith("blob:")) {
        URL.revokeObjectURL(coverPreview.value);
    }
}

function resetForm() {
    Object.assign(itemForm, createDefaultItemForm());
    errors.value = {};

    coverFile.value = null;
    bookFile.value = null;
    existingFileUrl.value = "";
    existingFileName.value = "";
    selectedFileName.value = "";

    selectedAuthorName.value = "";
    authorSearch.value = "";
    users.value = [];
    showAuthorDropdown.value = false;
    highlightedAuthorIndex.value = -1;

    revokeCoverPreview();
    coverPreview.value = "";
}

function openCreate() {
    resetForm();

    if (isAuthor.value && currentUser.value?.id) {
        itemForm.author_id = String(currentUser.value.id);
        selectedAuthorName.value = currentUser.value.name || "";
        authorSearch.value = currentUser.value.email
            ? `${currentUser.value.name} (${currentUser.value.email})`
            : currentUser.value.name || "";
        rebuildUserMap([currentUser.value]);
    }

    showModal.value = true;
    document.body.classList.add("modal-open");
}

function openEdit(item) {
    resetForm();

    const authorId =
        item?.author_id != null
            ? String(item.author_id)
            : item?.author?.id != null
                ? String(item.author.id)
                : "";

    Object.assign(itemForm, {
        id: item?.id ?? null,
        title: item?.title ?? "",
        slug: item?.slug ?? "",
        description: item?.description ?? "",
        cover_url: getRawCoverValue(item),
        file_url: getRawFileValue(item),
        category_id:
            item?.category_id != null
                ? String(item.category_id)
                : item?.category?.id != null
                    ? String(item.category.id)
                    : "",
        author_id: authorId,
        publish_year: item?.publish_year ?? "",
        language: item?.language ?? "KH",
        is_active: Boolean(item?.is_active),
        tag_ids: getTagList(item).map((tag) => Number(tag.id)),
    });

    if (item?.author) {
        rebuildUserMap([item.author]);
    }

    selectedAuthorName.value = getAuthorName(item) !== "—" ? getAuthorName(item) : "";
    authorSearch.value =
        item?.author?.email && selectedAuthorName.value
            ? `${selectedAuthorName.value} (${item.author.email})`
            : selectedAuthorName.value;

    coverPreview.value = toAssetUrl(itemForm.cover_url, "cover") || "";
    existingFileUrl.value = toAssetUrl(itemForm.file_url, "file") || "";
    existingFileName.value = getFileNameFromUrl(existingFileUrl.value) || "book-file.pdf";

    showModal.value = true;
    document.body.classList.add("modal-open");
}

function closeModal() {
    showModal.value = false;
    closeAuthorDropdown();
    document.body.classList.remove("modal-open");
}

async function loadCategories() {
    try {
        const res = await apiGetCategories();
        categories.value = normalizeSimpleList(res.data);
    } catch {
        categories.value = [];
    }
}

async function loadTags() {
    try {
        const res = await apiGetTags();
        tags.value = normalizeSimpleList(res.data);
    } catch {
        tags.value = [];
    }
}

async function loadUsers(search = "") {
    const keyword = String(search || "").trim();

    if (!keyword) {
        users.value = [];
        highlightedAuthorIndex.value = -1;
        authorLoading.value = false;
        return;
    }

    authorLoading.value = true;

    try {
        const res = await apiGetUsers_author({ search: keyword });
        const list = normalizeSimpleList(res.data);

        const authorList = list.filter((user) => {
            const level = String(user?.level ?? "").toLowerCase();
            return level === "author" || Number(user?.level) === 2;
        });

        users.value = authorList;
        rebuildUserMap(authorList);
        highlightedAuthorIndex.value = authorList.length ? 0 : -1;
    } catch {
        users.value = [];
        highlightedAuthorIndex.value = -1;
    } finally {
        authorLoading.value = false;
    }
}

async function loadItems() {
    loading.value = true;

    try {
        const res = await apiGetItems({ ...filters });
        const normalized = normalizeItemsResponse(res.data);

        Object.assign(items, normalized);

        const authors = normalized.data.map((item) => item.author).filter(Boolean);
        if (authors.length) rebuildUserMap(authors);
    } catch {
        Object.assign(items, {
            data: [],
            current_page: 1,
            last_page: 1,
            per_page: 10,
        });
    } finally {
        loading.value = false;
    }
}

async function applyFilters() {
    filters.page = 1;
    await loadItems();
}

async function changePage(page) {
    if (page < 1 || page > items.last_page || page === items.current_page) return;
    filters.page = page;
    await loadItems();
}

function onCoverChange(event) {
    const file = event.target.files?.[0] || null;
    coverFile.value = file;

    revokeCoverPreview();
    coverPreview.value = file ? URL.createObjectURL(file) : toAssetUrl(itemForm.cover_url, "cover") || "";
}

function onFileChange(event) {
    const file = event.target.files?.[0] || null;
    bookFile.value = file;
    selectedFileName.value = file?.name || "";
}

function handleAuthorFocus() {
    if (isAuthor.value) return;
    showAuthorDropdown.value = true;
    highlightedAuthorIndex.value = users.value.length ? 0 : -1;
}

function onAuthorSearchInput() {
    if (isAuthor.value) return;

    showAuthorDropdown.value = true;

    if (!authorSearch.value.trim()) {
        itemForm.author_id = "";
        selectedAuthorName.value = "";
        users.value = [];
        highlightedAuthorIndex.value = -1;

        if (authorSearchTimer) {
            clearTimeout(authorSearchTimer);
            authorSearchTimer = null;
        }
        return;
    }

    if (authorSearchTimer) clearTimeout(authorSearchTimer);

    authorSearchTimer = setTimeout(() => {
        loadUsers(authorSearch.value);
    }, 300);
}

function selectAuthor(user) {
    itemForm.author_id = String(user.id);
    selectedAuthorName.value = user.name || "";
    authorSearch.value = user.email ? `${user.name} (${user.email})` : user.name || "";
    users.value = [];
    showAuthorDropdown.value = false;
    highlightedAuthorIndex.value = -1;
    rebuildUserMap([user]);
}

function clearAuthor() {
    itemForm.author_id = "";
    selectedAuthorName.value = "";
    authorSearch.value = "";
    users.value = [];
    showAuthorDropdown.value = false;
    highlightedAuthorIndex.value = -1;
}

function moveHighlight(direction) {
    if (!showAuthorDropdown.value || !users.value.length) return;

    const lastIndex = users.value.length - 1;
    let nextIndex = highlightedAuthorIndex.value + direction;

    if (nextIndex < 0) nextIndex = lastIndex;
    if (nextIndex > lastIndex) nextIndex = 0;

    highlightedAuthorIndex.value = nextIndex;
}

function selectHighlightedAuthor() {
    if (highlightedAuthorIndex.value >= 0 && highlightedAuthorIndex.value < users.value.length) {
        selectAuthor(users.value[highlightedAuthorIndex.value]);
    }
}

function closeAuthorDropdown() {
    showAuthorDropdown.value = false;
    highlightedAuthorIndex.value = -1;
}

async function saveItem() {
    errors.value = {};

    if (isAuthor.value && currentUser.value?.id) {
        itemForm.author_id = String(currentUser.value.id);
    }

    if (!itemForm.title.trim()) {
        errors.value.title = ["Title is required"];
        return;
    }

    if (!itemForm.category_id) {
        errors.value.category_id = ["Category is required"];
        return;
    }

    try {
        const formData = new FormData();

        formData.append("title", itemForm.title.trim());
        formData.append("slug", itemForm.slug || "");
        formData.append("description", itemForm.description || "");
        formData.append("category_id", itemForm.category_id || "");
        formData.append("author_id", itemForm.author_id || "");
        formData.append("publish_year", itemForm.publish_year ? String(itemForm.publish_year) : "");
        formData.append("language", itemForm.language || "");
        formData.append("is_active", itemForm.is_active ? "1" : "0");

        for (const tagId of itemForm.tag_ids || []) {
            formData.append("tag_ids[]", String(tagId));
        }

        if (coverFile.value) formData.append("cover", coverFile.value);
        if (bookFile.value) formData.append("file", bookFile.value);

        if (itemForm.id) {
            formData.append("_method", "PUT");
            await apiUpdateItem(itemForm.id, formData);
        } else {
            await apiCreateItem(formData);
        }

        await loadItems();
        closeModal();
        resetForm();
    } catch (error) {
        if (error?.response?.status === 422) {
            errors.value = error.response.data.errors || {};
            return;
        }

        alert(error?.response?.data?.message || "Failed to save item");
    }
}

function handleClickOutside(event) {
    if (authorBoxRef.value && !authorBoxRef.value.contains(event.target)) {
        closeAuthorDropdown();
    }
}

watch(
    () => items.data.map((item) => item.id).join(","),
    async () => {
        await loadViewsForCurrentPage();
    },
    { immediate: true }
);

onMounted(async () => {
    document.addEventListener("click", handleClickOutside);
    await Promise.all([loadCategories(), loadTags(), loadItems()]);
});

onBeforeUnmount(() => {
    revokeCoverPreview();
    document.body.classList.remove("modal-open");
    document.removeEventListener("click", handleClickOutside);

    if (authorSearchTimer) {
        clearTimeout(authorSearchTimer);
        authorSearchTimer = null;
    }
});
</script>

<style scoped>
.book-page {
    background: #f4f6f9;
    min-height: 100vh;
}

.page-header {
    padding: 0.25rem 0 0.75rem;
}

.hero-title {
    font-size: 1.45rem;
    font-weight: 700;
    color: #1f2d3d;
}

.books-hero-card,
.books-table-card {
    border-radius: 18px;
    overflow: hidden;
    margin-bottom: 1.5rem;
}

.books-hero-card .card-body {
    padding: 1.5rem;
    background: linear-gradient(135deg, #ffffff 0%, #f8fbff 100%);
}

.btn-add-book {
    border-radius: 12px;
    padding: 0.7rem 1.1rem;
    font-weight: 600;
    box-shadow: 0 8px 20px rgba(13, 110, 253, 0.16);
}

.filter-label {
    display: block;
    margin-bottom: 0.45rem;
    font-size: 0.85rem;
    font-weight: 600;
    color: #495057;
}

.filter-control {
    height: 44px;
    border-radius: 12px;
    border: 1px solid #dee2e6;
    box-shadow: none;
}

.filter-control:focus,
.form-control:focus,
textarea.form-control:focus,
select.form-control:focus {
    border-color: #86b7fe;
    box-shadow: 0 0 0 0.16rem rgba(13, 110, 253, 0.12);
}

.search-box {
    position: relative;
}

.search-input {
    padding-left: 2.5rem;
}

.search-icon {
    position: absolute;
    top: 50%;
    left: 14px;
    transform: translateY(-50%);
    color: #6c757d;
    z-index: 2;
}

.btn-filter {
    height: 44px;
    border-radius: 12px;
    font-weight: 600;
}

.books-table-card .card-header {
    padding: 1.1rem 1.25rem 0.75rem;
}

.books-table thead th {
    border-top: 0;
    border-bottom: 1px solid #edf0f3;
    background: #f8fafc;
    color: #6c757d;
    font-size: 0.78rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    padding: 1rem;
    white-space: nowrap;
}

.books-table tbody td {
    vertical-align: middle;
    padding: 1rem;
    border-top: 1px solid #f1f3f5;
}

.books-table tbody tr:hover {
    background: #fbfdff;
}

.book-cell {
    display: flex;
    align-items: center;
    gap: 0.9rem;
    min-width: 0;
}

.book-cover-wrap {
    flex: 0 0 62px;
}

.book-cover {
    width: 62px;
    height: 80px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 6px 16px rgba(31, 45, 61, 0.14);
    border: 1px solid #eef2f7;
    background: #fff;
}

.book-meta {
    min-width: 0;
}

.book-title {
    font-weight: 700;
    color: #212529;
    font-size: 0.98rem;
    margin-bottom: 0.2rem;
}

.book-slug {
    color: #6c757d;
    font-size: 0.84rem;
}

.badge-category {
    background: rgba(23, 162, 184, 0.12);
    color: #138496;
    font-weight: 600;
    padding: 0.5rem 0.7rem;
    border-radius: 999px;
}

.badge-lang {
    background: #f8f9fa;
    color: #495057;
    border: 1px solid #dee2e6;
    font-weight: 600;
    padding: 0.45rem 0.65rem;
    border-radius: 999px;
}

.badge-tag {
    background: rgba(13, 110, 253, 0.1);
    color: #0d6efd;
    font-weight: 600;
    padding: 0.42rem 0.65rem;
    border-radius: 999px;
    margin-right: 0.35rem;
    margin-bottom: 0.35rem;
}

.table-tags,
.selected-tags-preview {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
}

.author-name {
    max-width: 150px;
}

.status-badge {
    border-radius: 999px;
    padding: 0.45rem 0.7rem;
    font-weight: 600;
}

.status-active {
    background: rgba(40, 167, 69, 0.12);
    color: #1e7e34;
}

.status-inactive {
    background: rgba(108, 117, 125, 0.14);
    color: #495057;
}

.action-buttons {
    display: inline-flex;
    gap: 0.45rem;
}

.btn-action {
    width: 34px;
    height: 34px;
    padding: 0;
    border-radius: 10px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 1px solid transparent;
    transition: all 0.2s ease;
}

.btn-view {
    color: #17a2b8;
    background: rgba(23, 162, 184, 0.1);
}

.btn-view:hover {
    color: #fff;
    background: #17a2b8;
}

.btn-edit {
    color: #0d6efd;
    background: rgba(13, 110, 253, 0.1);
}

.btn-edit:hover {
    color: #fff;
    background: #0d6efd;
}

.btn-delete {
    color: #dc3545;
    background: rgba(220, 53, 69, 0.1);
}

.btn-delete:hover {
    color: #fff;
    background: #dc3545;
}

.custom-modal-overlay {
    position: fixed;
    inset: 0;
    z-index: 1050;
    overflow-y: auto;
    background: rgba(15, 23, 42, 0.55);
    padding: 1.5rem 0;
}

.custom-modal-dialog {
    margin: 0 auto;
    max-width: 1140px;
    min-height: calc(100vh - 3rem);
    display: flex;
    align-items: center;
}

.custom-modal {
    width: 100%;
    border: 0;
    border-radius: 18px;
    box-shadow: 0 20px 45px rgba(15, 23, 42, 0.2);
    background: #ffffff;
    max-height: calc(100vh - 3rem);
    overflow: visible;
}

.custom-modal-form {
    display: flex;
    flex-direction: column;
    max-height: calc(100vh - 3rem);
}

.custom-modal-header {
    border-bottom: 1px solid #edf0f3;
    background: linear-gradient(135deg, #ffffff 0%, #f8fbff 100%);
    padding: 1rem 1.25rem;
    flex: 0 0 auto;
}

.modal-subtitle {
    color: #6c757d;
}

.custom-modal-body {
    padding: 1.25rem;
    flex: 1 1 auto;
    overflow-y: auto;
    overflow-x: visible;
    min-height: 0;
}

.custom-modal-footer {
    border-top: 1px solid #edf0f3;
    background: #f8f9fa;
    padding: 1rem 1.25rem;
    flex: 0 0 auto;
}

.modal-close-btn {
    opacity: 1;
    color: inherit;
    text-shadow: none;
}

.meta-section {
    margin: 0.25rem 0 1rem;
    padding: 1rem;
    border: 1px solid #e9eef5;
    border-radius: 16px;
    background: linear-gradient(180deg, #fbfdff 0%, #f8fafc 100%);
}

.meta-section-title {
    display: flex;
    align-items: center;
    font-weight: 700;
    color: #334155;
    margin-bottom: 1rem;
    font-size: 0.95rem;
}

.preview-box {
    background: #f8fafc;
    border: 1px solid #e9ecef;
    border-radius: 14px;
    padding: 0.9rem;
    display: inline-block;
}

.cover-preview-image {
    width: 130px;
    height: 150px;
    object-fit: cover;
    border-radius: 12px;
    border: 1px solid #e9ecef;
    background: #fff;
}

.file-pill {
    display: inline-flex;
    align-items: center;
    background: #f1f5f9;
    color: #334155;
    border-radius: 999px;
    padding: 0.55rem 0.85rem;
    font-size: 0.9rem;
}

.author-select-wrapper {
    position: relative;
}

.author-select {
    position: relative;
    overflow: visible;
}

.selected-author-chip {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: rgba(13, 110, 253, 0.09);
    color: #0d6efd;
    border: 1px solid rgba(13, 110, 253, 0.16);
    padding: 6px 12px;
    border-radius: 999px;
    font-size: 13px;
    line-height: 1;
    font-weight: 600;
}

.chip-remove {
    border: 0;
    background: transparent;
    font-size: 16px;
    line-height: 1;
    cursor: pointer;
    color: inherit;
    padding: 0;
}

.author-dropdown {
    position: absolute;
    top: calc(100% + 6px);
    left: 0;
    right: 0;
    z-index: 99999;
    max-height: 240px;
    overflow-y: auto;
    background: #ffffff;
    border: 1px solid #dbe2ea;
    border-radius: 12px;
    box-shadow: 0 12px 30px rgba(15, 23, 42, 0.14);
}

.author-dropdown-item {
    width: 100%;
    text-align: left;
    border: 0;
    background: #ffffff;
    padding: 0.75rem 0.85rem;
    color: #212529;
}

.author-dropdown-item:hover,
.author-dropdown-item.active {
    background: #eff6ff;
    color: #0f172a;
}

.author-dropdown-item .text-muted {
    color: #6b7280 !important;
}

.tag-multi-select {
    min-height: 120px;
    padding: 0.5rem;
}

body.dark-mode .book-page {
    background: #0f172a;
}

body.dark-mode .hero-title,
body.dark-mode .book-title,
body.dark-mode .modal-title,
body.dark-mode .filter-label,
body.dark-mode label,
body.dark-mode .custom-control-label,
body.dark-mode .file-pill,
body.dark-mode .selected-author-chip,
body.dark-mode .modal-close-btn,
body.dark-mode .author-dropdown-item,
body.dark-mode .meta-section-title {
    color: #e5e7eb !important;
}

body.dark-mode .book-slug,
body.dark-mode .modal-subtitle,
body.dark-mode .text-muted,
body.dark-mode small.text-muted,
body.dark-mode .breadcrumb-item,
body.dark-mode .breadcrumb-item a {
    color: #94a3b8 !important;
}

body.dark-mode .books-hero-card,
body.dark-mode .books-table-card,
body.dark-mode .custom-modal {
    background: #111827 !important;
    color: #e5e7eb;
    box-shadow: 0 18px 40px rgba(0, 0, 0, 0.35);
}

body.dark-mode .books-hero-card .card-body,
body.dark-mode .custom-modal-header {
    background: linear-gradient(135deg, #111827 0%, #172033 100%);
}

body.dark-mode .books-table-card .card-header,
body.dark-mode .card-footer,
body.dark-mode .custom-modal-footer {
    background: #111827 !important;
}

body.dark-mode .books-table thead th {
    background: #1f2937;
    color: #cbd5e1;
    border-bottom-color: #334155;
}

body.dark-mode .books-table tbody td {
    color: #e5e7eb;
    border-top-color: #243244;
}

body.dark-mode .books-table tbody tr:hover {
    background: #172033;
}

body.dark-mode .book-cover {
    border-color: #334155;
    background: #0f172a;
}

body.dark-mode .filter-control,
body.dark-mode .form-control,
body.dark-mode textarea.form-control,
body.dark-mode select.form-control {
    background: #0f172a !important;
    border-color: #334155 !important;
    color: #e5e7eb !important;
}

body.dark-mode .filter-control::placeholder,
body.dark-mode .form-control::placeholder,
body.dark-mode textarea.form-control::placeholder {
    color: #94a3b8 !important;
}

body.dark-mode .filter-control:focus,
body.dark-mode .form-control:focus,
body.dark-mode textarea.form-control:focus,
body.dark-mode select.form-control:focus {
    background: #0f172a !important;
    border-color: #3b82f6 !important;
    box-shadow: 0 0 0 0.16rem rgba(59, 130, 246, 0.16) !important;
    color: #fff !important;
}

body.dark-mode .search-icon {
    color: #94a3b8;
}

body.dark-mode .badge-lang {
    background: #1f2937;
    border-color: #334155;
    color: #e5e7eb;
}

body.dark-mode .badge-category {
    background: rgba(34, 211, 238, 0.14);
    color: #67e8f9;
}

body.dark-mode .badge-tag {
    background: rgba(59, 130, 246, 0.16);
    color: #bfdbfe;
}

body.dark-mode .status-active {
    background: rgba(34, 197, 94, 0.16);
    color: #86efac;
}

body.dark-mode .status-inactive {
    background: rgba(148, 163, 184, 0.16);
    color: #cbd5e1;
}

body.dark-mode .meta-section {
    background: linear-gradient(180deg, #0f172a 0%, #111827 100%);
    border-color: #253247;
}

body.dark-mode .preview-box {
    background: #0f172a;
    border-color: #334155;
}

body.dark-mode .cover-preview-image {
    border-color: #334155;
    background: #0f172a;
}

body.dark-mode .file-pill {
    background: #1f2937;
    color: #e5e7eb;
}

body.dark-mode .selected-author-chip {
    background: rgba(59, 130, 246, 0.16);
    border-color: rgba(59, 130, 246, 0.3);
    color: #bfdbfe !important;
}

body.dark-mode .author-dropdown {
    background: #111827;
    border-color: #334155;
    box-shadow: 0 16px 32px rgba(0, 0, 0, 0.45);
}

body.dark-mode .author-dropdown-item {
    background: #111827;
    color: #e5e7eb !important;
}

body.dark-mode .author-dropdown-item:hover,
body.dark-mode .author-dropdown-item.active {
    background: #1f2937;
    color: #ffffff !important;
}

body.dark-mode .author-dropdown-item .text-muted,
body.dark-mode .author-dropdown-item small {
    color: #94a3b8 !important;
}

body.dark-mode .btn-outline-secondary {
    color: #cbd5e1;
    border-color: #475569;
}

body.dark-mode .btn-outline-secondary:hover {
    background: #334155;
    color: #fff;
    border-color: #475569;
}

body.dark-mode .breadcrumb-item.active {
    color: #cbd5e1;
}

@media (max-width: 767.98px) {
    .books-hero-card .card-body,
    .books-table-card .card-header,
    .custom-modal-header,
    .custom-modal-body,
    .custom-modal-footer {
        padding: 1rem;
    }

    .books-table tbody td,
    .books-table thead th {
        padding: 0.85rem 0.75rem;
    }

    .book-cover {
        width: 54px;
        height: 72px;
    }

    .custom-modal-overlay {
        padding: 0.75rem 0;
    }

    .custom-modal-dialog {
        min-height: calc(100vh - 1.5rem);
        align-items: flex-start;
    }

    .custom-modal,
    .custom-modal-form {
        max-height: calc(100vh - 1.5rem);
    }

    .meta-section {
        padding: 0.9rem;
    }
}
</style>
