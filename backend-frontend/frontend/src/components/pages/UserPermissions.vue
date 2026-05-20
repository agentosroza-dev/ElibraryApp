<template>
    <div class="content-wrapper permission-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="page-header d-flex justify-content-between align-items-center flex-wrap">
                    <div>
                        <h1 class="page-title mb-1">Permission Management</h1>
                        <p class="page-subtitle mb-0">
                            Create permissions, assign them to users, and manage user access.
                        </p>
                    </div>

                    <ol class="breadcrumb float-sm-right mb-0">
                        <li class="breadcrumb-item">
                            <router-link :to="{ name: 'dashboard' }">Home</router-link>
                        </li>
                        <li class="breadcrumb-item active">Permissions</li>
                    </ol>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-lg-4 col-md-5">
                        <div class="card card-primary permission-card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title mb-0">
                                    {{ isEdit ? "Edit Permission" : "Create Permission" }}
                                </h3>
                            </div>

                            <div class="card-body">
                                <div class="form-group">
                                    <label>Route Name</label>
                                    <input
                                        v-model.trim="form.route_name"
                                        class="form-control"
                                        placeholder="books.index"
                                    />
                                </div>

                                <div class="form-group">
                                    <label>Permission Title</label>
                                    <input
                                        v-model.trim="form.title"
                                        class="form-control"
                                        placeholder="View Books"
                                    />
                                </div>

                                <div class="form-group">
                                    <label>User Type</label>
                                    <select v-model.number="form.type" class="form-control">
                                        <option :value="1">Admin</option>
                                        <option :value="2">Author</option>
                                        <option :value="3">User</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>List Icon</label>
                                    <input
                                        v-model.trim="form.list_icon"
                                        class="form-control"
                                        placeholder="fas fa-book"
                                    />
                                    <small class="text-muted d-block mt-1">
                                        Example: fas fa-book, fas fa-users, fas fa-cog
                                    </small>
                                </div>

                                <div class="form-group mb-0">
                                    <label>Menu Order</label>
                                    <input
                                        v-model.number="form.menu_order"
                                        type="number"
                                        min="0"
                                        class="form-control"
                                        placeholder="1"
                                    />
                                </div>
                            </div>

                            <div class="card-footer d-flex flex-wrap gap-2">
                                <button
                                    class="btn"
                                    :class="isEdit ? 'btn-warning' : 'btn-primary'"
                                    :disabled="savingPermission"
                                    @click="submitPermission"
                                >
                                    <span v-if="savingPermission">
                                        <i class="fas fa-spinner fa-spin mr-1"></i>
                                        {{ isEdit ? "Updating..." : "Saving..." }}
                                    </span>
                                    <span v-else>
                                        {{ isEdit ? "Update" : "Save" }}
                                    </span>
                                </button>

                                <button
                                    class="btn btn-outline-secondary"
                                    type="button"
                                    @click="resetForm"
                                >
                                    Reset
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-8 col-md-7">
                        <div class="card card-success permission-card shadow-sm">
                            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                                <h3 class="card-title mb-0">Permission List</h3>
                                <div class="permission-list-count">
                                    Total: {{ permissionList.length }}
                                </div>
                            </div>

                            <div class="card-body table-responsive p-0">
                                <table class="table table-hover mb-0">
                                    <thead>
                                    <tr>
                                        <th style="width: 60px">#</th>
                                        <th>Route Name</th>
                                        <th>Title</th>
                                        <th style="width: 110px">Type</th>
                                        <th style="width: 140px">Icon</th>
                                        <th style="width: 100px">Order</th>
                                        <th style="width: 170px">Action</th>
                                    </tr>
                                    </thead>

                                    <tbody>
                                    <tr v-if="permissionLoading">
                                        <td colspan="7" class="text-center py-4 text-muted">
                                            <i class="fas fa-spinner fa-spin mr-2"></i>
                                            Loading permissions...
                                        </td>
                                    </tr>

                                    <tr v-else-if="!paginatedPermissions.length">
                                        <td colspan="7" class="text-center text-muted py-4">
                                            No permissions found
                                        </td>
                                    </tr>

                                    <tr
                                        v-for="(permission, index) in paginatedPermissions"
                                        :key="permission.id"
                                    >
                                        <td>{{ index + 1 + (currentPage - 1) * PER_PAGE }}</td>

                                        <td>
                                            <span class="badge badge-info permission-badge">
                                                {{ permission.route_name }}
                                            </span>
                                        </td>

                                        <td>{{ permission.title }}</td>

                                        <td>
                                            <span
                                                class="badge permission-type-badge"
                                                :class="permissionTypeClass(permission.type)"
                                            >
                                                {{ permissionTypeLabel(permission.type) }}
                                            </span>
                                        </td>

                                        <td>
                                            <div class="permission-icon-cell">
                                                <i :class="permission.list_icon || 'fas fa-circle'"></i>
                                                <span class="ml-1 small text-muted">
                                                    {{ permission.list_icon || "-" }}
                                                </span>
                                            </div>
                                        </td>

                                        <td>{{ permission.menu_order }}</td>

                                        <td>
                                            <button
                                                class="btn btn-info btn-sm mr-1"
                                                type="button"
                                                @click="editPermission(permission)"
                                            >
                                                Edit
                                            </button>

                                            <button
                                                class="btn btn-danger btn-sm"
                                                type="button"
                                                @click="deletePermission(permission.id)"
                                            >
                                                Delete
                                            </button>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="card-footer d-flex justify-content-between align-items-center">
                                <button
                                    class="btn btn-sm btn-secondary"
                                    type="button"
                                    :disabled="currentPage === 1"
                                    @click="prevPage"
                                >
                                    Previous
                                </button>

                                <span>Page {{ currentPage }} / {{ totalPages }}</span>

                                <button
                                    class="btn btn-sm btn-secondary"
                                    type="button"
                                    :disabled="currentPage >= totalPages"
                                    @click="nextPage"
                                >
                                    Next
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card card-warning permission-card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title mb-0">Assign Permission To User</h3>
                            </div>

                            <div class="card-body">
                                <div class="form-group mb-4">
                                    <label>Search User Name</label>
                                    <div class="search-input-wrap">
                                        <i class="fas fa-search search-input-icon"></i>
                                        <input
                                            v-model.trim="userSearch"
                                            type="text"
                                            class="form-control search-input"
                                            placeholder="Type user name..."
                                        />
                                    </div>
                                </div>

                                <div v-if="userLoading" class="assign-loading-state text-center py-4 mb-4">
                                    <i class="fas fa-spinner fa-spin mr-2"></i>
                                    Loading users...
                                </div>

                                <div
                                    v-else-if="showSearchResults && filteredUsers.length"
                                    class="search-user-results mb-4"
                                >
                                    <div class="search-user-results__title">
                                        Search Results ({{ filteredUsers.length }})
                                    </div>

                                    <div class="row">
                                        <div
                                            v-for="user in filteredUsers"
                                            :key="user.id"
                                            class="col-xl-3 col-lg-4 col-md-6 mb-3"
                                        >
                                            <div
                                                class="user-search-card"
                                                :class="{ active: selectedUserId === user.id }"
                                                @click="selectUser(user)"
                                            >
                                                <div class="user-search-card__top">
                                                    <img
                                                        :src="userAvatar(user)"
                                                        alt="User"
                                                        class="user-search-card__avatar"
                                                        @error="onImageError"
                                                    />

                                                    <div class="user-search-card__info">
                                                        <div class="user-search-card__name">
                                                            {{ user.name || "No Name" }}
                                                        </div>

                                                        <div class="user-search-card__email">
                                                            {{ user.email || "No email" }}
                                                        </div>

                                                        <div class="mt-1">
                                                            <span
                                                                class="badge user-level-badge"
                                                                :class="userLevelClass(user.level)"
                                                            >
                                                                {{ userLevelLabel(user.level) }}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div
                                    v-else-if="showSearchResults"
                                    class="assign-empty-state text-center"
                                >
                                    <div class="assign-empty-state__icon">
                                        <i class="fas fa-search"></i>
                                    </div>
                                    <div class="assign-empty-state__title">No user found</div>
                                    <div class="assign-empty-state__text">
                                        Try another user name.
                                    </div>
                                </div>

                                <div v-if="selectedUser" class="selected-user-box mb-4">
                                    <div class="d-flex justify-content-between align-items-center flex-wrap">
                                        <div class="selected-user-box__left d-flex align-items-center">
                                            <img
                                                :src="userAvatar(selectedUser)"
                                                alt="Selected User"
                                                class="selected-user-box__avatar"
                                                @error="onImageError"
                                            />

                                            <div>
                                                <div class="selected-user-box__label">Selected User</div>
                                                <div class="selected-user-box__name">
                                                    {{ selectedUser.name || "Unknown User" }}
                                                </div>
                                                <div class="selected-user-box__email">
                                                    {{ selectedUser.email || "No email" }}
                                                </div>
                                                <div class="mt-1">
                                                    <span
                                                        class="badge user-level-badge"
                                                        :class="userLevelClass(selectedUser.level)"
                                                    >
                                                        {{ userLevelLabel(selectedUser.level) }}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="mt-2 mt-md-0 d-flex flex-wrap gap-2">
                                            <button
                                                class="btn btn-sm btn-outline-info"
                                                type="button"
                                                :disabled="loadingSelectedPermissions"
                                                @click="loadUserPermissions"
                                            >
                                                <span v-if="loadingSelectedPermissions">
                                                    <i class="fas fa-spinner fa-spin mr-1"></i> Loading...
                                                </span>
                                                <span v-else>Reload Permissions</span>
                                            </button>

                                            <button
                                                class="btn btn-sm btn-outline-secondary"
                                                type="button"
                                                @click="resetUserForm"
                                            >
                                                Clear User
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <div v-if="!selectedUserId" class="assign-empty-state text-center">
                                    <div class="assign-empty-state__icon">
                                        <i class="fas fa-user-lock"></i>
                                    </div>
                                    <div class="assign-empty-state__title">No user selected</div>
                                    <div class="assign-empty-state__text">
                                        Search a user by name and click on a user card to load and assign permissions.
                                    </div>
                                </div>

                                <template v-else>
                                    <div v-if="loadingSelectedPermissions" class="assign-loading-state text-center py-4">
                                        <i class="fas fa-spinner fa-spin mr-2"></i>
                                        Loading permission for selected user...
                                    </div>

                                    <div v-else-if="permissionList.length" class="row">
                                        <div
                                            v-for="permission in permissionList"
                                            :key="permission.id"
                                            class="col-lg-3 col-md-4 col-sm-6 mb-3"
                                        >
                                            <label
                                                class="permission-check-card mb-0"
                                                :class="{ checked: selectedPermissionSet.has(permission.id) }"
                                            >
                                                <input
                                                    type="checkbox"
                                                    :checked="selectedPermissionSet.has(permission.id)"
                                                    @change="togglePermission(permission.id)"
                                                />

                                                <span class="permission-check-card__content">
                                                    <span class="permission-check-card__title">
                                                        {{ permission.title }}
                                                    </span>
                                                    <small class="permission-check-card__meta">
                                                        {{ permission.route_name }}
                                                    </small>
                                                </span>
                                            </label>
                                        </div>
                                    </div>

                                    <div v-else class="text-muted">No permissions available.</div>
                                </template>
                            </div>

                            <div class="card-footer d-flex justify-content-between align-items-center flex-wrap">
                                <button
                                    class="btn btn-outline-secondary"
                                    type="button"
                                    @click="resetUserForm"
                                >
                                    Reset
                                </button>

                                <button
                                    class="btn btn-success"
                                    type="button"
                                    :disabled="!selectedUserId || savingUserPermissions || loadingSelectedPermissions"
                                    @click="saveUserPermissions"
                                >
                                    <span v-if="savingUserPermissions">
                                        <i class="fas fa-spinner fa-spin mr-1"></i> Saving...
                                    </span>
                                    <span v-else>Save Permission</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card card-info permission-card shadow-sm">
                            <div class="card-header d-flex justify-content-between align-items-center flex-wrap">
                                <h3 class="card-title mb-0">User Permission List</h3>
                                <div class="permission-list-count">
                                    Total Users: {{ userPermissionRows.length }}
                                </div>
                            </div>

                            <div class="card-body table-responsive p-0">
                                <table class="table table-bordered table-hover mb-0">
                                    <thead>
                                    <tr>
                                        <th style="width: 70px">#</th>
                                        <th style="width: 320px">User</th>
                                        <th>Permissions</th>
                                        <th style="width: 160px">Action</th>
                                    </tr>
                                    </thead>

                                    <tbody>
                                    <tr v-if="userPermissionLoading">
                                        <td colspan="4" class="text-center py-4 text-muted">
                                            <i class="fas fa-spinner fa-spin mr-2"></i>
                                            Loading user permission list...
                                        </td>
                                    </tr>

                                    <tr v-else-if="!userPermissionRows.length">
                                        <td colspan="4" class="text-center text-muted py-4">
                                            No user permissions found
                                        </td>
                                    </tr>

                                    <tr
                                        v-for="(user, index) in userPermissionRows"
                                        :key="user.id"
                                    >
                                        <td>{{ index + 1 }}</td>

                                        <td>
                                            <div class="user-list-cell">
                                                <img
                                                    :src="userAvatar(user)"
                                                    alt="User"
                                                    class="user-list-cell__avatar"
                                                    @error="onImageError"
                                                />

                                                <div>
                                                    <div class="font-weight-bold user-list-cell__name">
                                                        {{ user.name || "No Name" }}
                                                    </div>
                                                    <small class="d-block text-muted">
                                                        {{ user.email || "No email" }}
                                                    </small>
                                                    <span
                                                        class="badge user-level-badge mt-1"
                                                        :class="userLevelClass(user.level)"
                                                    >
                                                        {{ userLevelLabel(user.level) }}
                                                    </span>
                                                </div>
                                            </div>
                                        </td>

                                        <td>
                                            <template v-if="user.permissions.length">
                                                <span
                                                    v-for="perm in user.permissions"
                                                    :key="perm.id"
                                                    class="badge badge-success mr-1 mb-1 user-perm-badge"
                                                >
                                                    {{ perm.title }}
                                                </span>
                                            </template>

                                            <span v-else class="text-muted">No permissions</span>
                                        </td>

                                        <td>
                                            <button
                                                class="btn btn-warning btn-sm mr-1"
                                                type="button"
                                                @click="editUserPermission(user)"
                                            >
                                                Edit
                                            </button>

                                            <button
                                                class="btn btn-danger btn-sm"
                                                type="button"
                                                @click="removeUserPermission(user.id)"
                                            >
                                                Delete
                                            </button>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";
import CustomTable from "../includes/tables/CustomTable.vue";
import axios from "axios";

const API_BASE = import.meta.env.VITE_URL || window.location.origin;
const API_URL = `${API_BASE}/api`;
const PER_PAGE = 20;
const DEFAULT_AVATAR = "https://ui-avatars.com/api/?name=User&background=E9ECEF&color=6C757D&size=128";

const TYPE_MAP = {
    1: { label: "Admin", className: "permission-type-badge--admin" },
    2: { label: "Author", className: "permission-type-badge--author" },
    3: { label: "User", className: "permission-type-badge--user" },
};

const permissionLoading = ref(false);
const userLoading = ref(false);
const userPermissionLoading = ref(false);
const loadingSelectedPermissions = ref(false);
const savingPermission = ref(false);
const savingUserPermissions = ref(false);

const currentPage = ref(1);
const isEdit = ref(false);

const permissions = ref([]);
const users = ref([]);
const userPermissionList = ref([]);

const userSearch = ref("");
const selectedUserId = ref(null);
const selectedPermissionIds = ref([]);

const form = reactive(createDefaultForm());

function createDefaultForm() {
    return {
        id: null,
        route_name: "",
        title: "",
        type: 3,
        list_icon: "",
        menu_order: 0,
    };
}

function asArray(payload, key = null) {
    if (Array.isArray(payload)) return payload;
    if (key && Array.isArray(payload?.[key])) return payload[key];
    if (Array.isArray(payload?.data)) return payload.data;
    return [];
}

function normalizePermission(item = {}) {
    return {
        id: Number(item.id || 0),
        route_name: String(item.route_name || "").trim(),
        title: String(item.title || "").trim(),
        type: Number(item.type ?? 3),
        list_icon: String(item.list_icon || "").trim(),
        menu_order: Number(item.menu_order ?? 0),
    };
}

function normalizeUser(item = {}) {
    return {
        ...item,
        id: Number(item.id || 0),
        name: String(item.name || item.username || "").trim(),
        email: String(item.email || "").trim(),
        level: item.level ?? 3,
    };
}

function normalizePermissionSummary(item = {}) {
    return {
        id: Number(item.id || 0),
        title: String(item.title || "").trim(),
    };
}

function normalizeUserPermissionRow(item = {}) {
    return {
        ...normalizeUser(item),
        permissions: Array.isArray(item.permissions)
            ? item.permissions.map(normalizePermissionSummary).filter((perm) => perm.id)
            : [],
    };
}

const permissionList = computed(() =>
    asArray(permissions.value)
        .map(normalizePermission)
        .filter((item) => item.id && item.route_name && item.title)
        .sort((a, b) => a.menu_order - b.menu_order || a.id - b.id)
);

const userList = computed(() =>
    asArray(users.value, "users")
        .map(normalizeUser)
        .filter((user) => user.id)
);

const userPermissionRows = computed(() =>
    asArray(userPermissionList.value)
        .map(normalizeUserPermissionRow)
        .filter((user) => user.id)
);

const totalPages = computed(() => Math.max(1, Math.ceil(permissionList.value.length / PER_PAGE)));

const paginatedPermissions = computed(() => {
    const start = (currentPage.value - 1) * PER_PAGE;
    return permissionList.value.slice(start, start + PER_PAGE);
});

const showSearchResults = computed(() => userSearch.value.trim().length > 0);

const filteredUsers = computed(() => {
    const keyword = userSearch.value.trim().toLowerCase();

    if (!keyword) return [];

    return userList.value
        .filter((user) => {
            const level = userLevelLabel(user.level).toLowerCase();

            return (
                user.name.toLowerCase().includes(keyword) ||
                user.email.toLowerCase().includes(keyword) ||
                level.includes(keyword)
            );
        })
        .slice(0, 24);
});

const selectedUser = computed(() =>
    userList.value.find((user) => user.id === Number(selectedUserId.value)) || null
);

const selectedPermissionSet = computed(() => new Set(selectedPermissionIds.value.map(Number)));

watch(
    () => permissionList.value.length,
    () => {
        if (currentPage.value > totalPages.value) {
            currentPage.value = totalPages.value;
        }
    }
);

function permissionTypeLabel(type) {
    return TYPE_MAP[Number(type)]?.label || "User";
}

function permissionTypeClass(type) {
    return TYPE_MAP[Number(type)]?.className || TYPE_MAP[3].className;
}

function userLevelLabel(level) {
    if (level === "admin" || Number(level) === 1) return "Admin";
    if (level === "author" || Number(level) === 2) return "Author";
    return "User";
}

function userLevelClass(level) {
    if (level === "admin" || Number(level) === 1) return "user-level-badge--admin";
    if (level === "author" || Number(level) === 2) return "user-level-badge--author";
    return "user-level-badge--user";
}

function buildAvatarFromName(name = "User") {
    return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=E9ECEF&color=495057&size=128`;
}

function userAvatar(user) {
    if (!user) return DEFAULT_AVATAR;

    const image =
        user.image ||
        user.avatar ||
        user.photo ||
        user.profile_image ||
        user.profile_photo ||
        user.profile_photo_url ||
        "";

    if (!image) return buildAvatarFromName(user.name || "User");
    if (/^https?:\/\//i.test(image)) return image;
    if (String(image).startsWith("/")) return `${API_BASE}${image}`;
    return `${API_BASE}/storage/${image}`;
}

function onImageError(event) {
    event.target.onerror = null;
    event.target.src = DEFAULT_AVATAR;
}

function getErrorMessage(error, fallback = "Something went wrong.") {
    return error?.response?.data?.message || error?.response?.data?.error || fallback;
}

function validatePermissionForm() {
    if (!form.route_name || !form.title) {
        alert("Route name and permission title are required.");
        return false;
    }

    if (![1, 2, 3].includes(Number(form.type))) {
        alert("User type is invalid.");
        return false;
    }

    if (Number(form.menu_order) < 0) {
        alert("Menu order must be 0 or greater.");
        return false;
    }

    return true;
}

function getPermissionPayload() {
    return {
        route_name: form.route_name.trim(),
        title: form.title.trim(),
        type: Number(form.type),
        list_icon: form.list_icon ? form.list_icon.trim() : null,
        menu_order: Number(form.menu_order ?? 0),
    };
}

async function loadPermissions() {
    permissionLoading.value = true;

    try {
        const { data } = await axios.get(`${API_URL}/permissions/simple`);
        permissions.value = asArray(data);
    } catch (error) {
        console.error("Failed to load permissions", error);
        permissions.value = [];
    } finally {
        permissionLoading.value = false;
    }
}

async function loadUsers() {
    userLoading.value = true;

    try {
        const { data } = await axios.get(`${API_URL}/users`);
        users.value = data;
    } catch (error) {
        console.error("Failed to load users", error);
        users.value = [];
    } finally {
        userLoading.value = false;
    }
}

async function loadUserPermissionList() {
    userPermissionLoading.value = true;

    try {
        const { data } = await axios.get(`${API_URL}/user-permissions`);
        userPermissionList.value = data;
    } catch (error) {
        console.error("Failed to load user permission list", error);
        userPermissionList.value = [];
    } finally {
        userPermissionLoading.value = false;
    }
}

async function loadUserPermissions() {
    if (!selectedUserId.value) {
        selectedPermissionIds.value = [];
        return;
    }

    loadingSelectedPermissions.value = true;

    try {
        const { data } = await axios.get(`${API_URL}/user-permissions/${selectedUserId.value}`);

        const items = Array.isArray(data?.permissions)
            ? data.permissions
            : Array.isArray(data?.data)
                ? data.data
                : Array.isArray(data)
                    ? data
                    : [];

        selectedPermissionIds.value = items
            .map((item) => Number(typeof item === "object" ? item.id : item))
            .filter(Boolean);
    } catch (error) {
        console.error("Failed to load user permissions", error);
        selectedPermissionIds.value = [];
    } finally {
        loadingSelectedPermissions.value = false;
    }
}

async function refreshAfterPermissionChange() {
    await Promise.all([loadPermissions(), loadUserPermissionList()]);
}

function togglePermission(id) {
    const permissionId = Number(id);
    const set = new Set(selectedPermissionIds.value);

    if (set.has(permissionId)) {
        set.delete(permissionId);
    } else {
        set.add(permissionId);
    }

    selectedPermissionIds.value = Array.from(set);
}

async function selectUser(user) {
    selectedUserId.value = Number(user.id);
    userSearch.value = user.name || user.email || "";
    await loadUserPermissions();
}

async function saveUserPermissions() {
    if (!selectedUserId.value) {
        alert("Please select a user first.");
        return;
    }

    savingUserPermissions.value = true;

    try {
        await axios.post(`${API_URL}/user-permissions`, {
            user_id: selectedUserId.value,
            permissions: selectedPermissionIds.value,
        });

        await Promise.all([loadUserPermissionList(), loadUserPermissions()]);
    } catch (error) {
        console.error("Failed to save permissions", error);
        alert(getErrorMessage(error, "Failed to save permissions."));
    } finally {
        savingUserPermissions.value = false;
    }
}

async function editUserPermission(user) {
    selectedUserId.value = Number(user.id);
    userSearch.value = user.name || user.email || "";
    selectedPermissionIds.value = Array.isArray(user.permissions)
        ? user.permissions.map((perm) => Number(perm.id)).filter(Boolean)
        : [];

    await loadUserPermissions();

    window.scrollTo({
        top: document.body.scrollHeight * 0.3,
        behavior: "smooth",
    });
}

async function removeUserPermission(id) {
    if (!confirm("Remove all permissions for this user?")) return;

    try {
        await axios.delete(`${API_URL}/user-permissions/${id}`);

        if (Number(selectedUserId.value) === Number(id)) {
            resetUserForm();
        }

        await loadUserPermissionList();
    } catch (error) {
        console.error("Failed to remove user permissions", error);
        alert(getErrorMessage(error, "Failed to remove user permissions."));
    }
}

async function submitPermission() {
    if (!validatePermissionForm()) return;

    savingPermission.value = true;

    try {
        const payload = getPermissionPayload();

        if (isEdit.value && form.id) {
            await axios.post(`${API_URL}/permissions/${form.id}`, {
                ...payload,
                _method: "PUT",
            });
        } else {
            await axios.post(`${API_URL}/permissions`, payload);
        }

        resetForm();
        await refreshAfterPermissionChange();
    } catch (error) {
        console.error("Failed to save permission", error);
        alert(
            getErrorMessage(
                error,
                isEdit.value ? "Failed to update permission." : "Failed to create permission."
            )
        );
    } finally {
        savingPermission.value = false;
    }
}

function editPermission(permission) {
    form.id = permission.id;
    form.route_name = permission.route_name || "";
    form.title = permission.title || "";
    form.type = Number(permission.type ?? 3);
    form.list_icon = permission.list_icon || "";
    form.menu_order = Number(permission.menu_order ?? 0);
    isEdit.value = true;

    window.scrollTo({
        top: 0,
        behavior: "smooth",
    });
}

async function deletePermission(id) {
    if (!confirm("Delete this permission?")) return;

    try {
        await axios.post(`${API_URL}/permissions/${id}`, {
            _method: "DELETE",
        });

        if (selectedPermissionIds.value.includes(Number(id))) {
            selectedPermissionIds.value = selectedPermissionIds.value.filter(
                (permissionId) => Number(permissionId) !== Number(id)
            );
        }

        await refreshAfterPermissionChange();
    } catch (error) {
        console.error("Failed to delete permission", error);
        alert(getErrorMessage(error, "Failed to delete permission."));
    }
}

function resetForm() {
    Object.assign(form, createDefaultForm());
    isEdit.value = false;
}

function resetUserForm() {
    userSearch.value = "";
    selectedUserId.value = null;
    selectedPermissionIds.value = [];
}

function nextPage() {
    if (currentPage.value < totalPages.value) currentPage.value += 1;
}

function prevPage() {
    if (currentPage.value > 1) currentPage.value -= 1;
}

onMounted(async () => {
    await Promise.all([
        loadPermissions(),
        loadUsers(),
        loadUserPermissionList(),
    ]);
});
</script>

<style scoped>
.permission-page {
    min-height: 100vh;
}

.page-title {
    font-size: 1.75rem;
    font-weight: 700;
    color: #1f2937;
}

.page-subtitle {
    color: #6c757d;
    font-size: 0.95rem;
}

.permission-card {
    border: 0;
    border-radius: 16px;
    overflow: hidden;
    background: #fff;
}

.permission-card .card-header {
    border-bottom: 0;
    font-weight: 600;
}

.permission-card .card-body {
    padding: 1rem 1.25rem;
}

.permission-card .card-footer {
    background: transparent;
    border-top: 1px solid #edf2f7;
    padding: 1rem 1.25rem;
}

.permission-list-count {
    font-size: 0.875rem;
    font-weight: 700;
    color: #6b7280;
}

.permission-badge,
.user-perm-badge {
    padding: 0.45rem 0.7rem;
    border-radius: 999px;
    font-weight: 600;
}

.permission-type-badge,
.user-level-badge {
    padding: 0.45rem 0.7rem;
    border-radius: 999px;
    font-weight: 700;
    font-size: 0.76rem;
}

.permission-type-badge--admin,
.user-level-badge--admin {
    background: #fee2e2;
    color: #b91c1c;
}

.permission-type-badge--author,
.user-level-badge--author {
    background: #fef3c7;
    color: #b45309;
}

.permission-type-badge--user,
.user-level-badge--user {
    background: #dbeafe;
    color: #1d4ed8;
}

.permission-icon-cell {
    display: flex;
    align-items: center;
    min-width: 90px;
}

.assign-empty-state {
    border: 1px dashed #d9b56d;
    border-radius: 16px;
    background: #fffaf1;
    padding: 2rem 1rem;
}

.assign-empty-state__icon {
    width: 64px;
    height: 64px;
    margin: 0 auto 12px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(255, 193, 7, 0.12);
    color: #d39e00;
    font-size: 1.5rem;
}

.assign-empty-state__title {
    font-size: 1.05rem;
    font-weight: 700;
    color: #3d3d3d;
    margin-bottom: 6px;
}

.assign-empty-state__text {
    color: #6c757d;
    max-width: 520px;
    margin: 0 auto;
}

.assign-loading-state {
    border: 1px dashed #cbd5e1;
    border-radius: 14px;
    background: #f8fafc;
    color: #475569;
}

.search-input-wrap {
    position: relative;
}

.search-input-icon {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    z-index: 2;
}

.search-input {
    padding-left: 40px;
}

.search-user-results {
    border: 1px solid #e9ecef;
    border-radius: 14px;
    padding: 16px;
    background: #f8fafc;
}

.search-user-results__title {
    font-size: 0.9rem;
    font-weight: 700;
    color: #4b5563;
    margin-bottom: 12px;
}

.user-search-card {
    border: 1px solid #dee2e6;
    border-radius: 14px;
    padding: 14px;
    background: #fff;
    cursor: pointer;
    transition: all 0.2s ease;
    min-height: 108px;
}

.user-search-card:hover {
    border-color: #80bdff;
    box-shadow: 0 6px 14px rgba(0, 123, 255, 0.08);
    transform: translateY(-1px);
}

.user-search-card.active {
    border-color: #007bff;
    box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.12);
    background: #f4f9ff;
}

.user-search-card__top {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-search-card__avatar {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #e5e7eb;
    flex-shrink: 0;
}

.user-search-card__info {
    min-width: 0;
}

.user-search-card__name {
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 4px;
    line-height: 1.2;
}

.user-search-card__email {
    font-size: 0.9rem;
    color: #6b7280;
    word-break: break-word;
    line-height: 1.2;
}

.selected-user-box {
    padding: 14px 16px;
    border-radius: 14px;
    background: #fff8e8;
    border: 1px solid #f3d79a;
}

.selected-user-box__left {
    gap: 14px;
}

.selected-user-box__avatar {
    width: 58px;
    height: 58px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #f0d58a;
    flex-shrink: 0;
}

.selected-user-box__label {
    font-size: 12px;
    color: #856404;
    margin-bottom: 4px;
    text-transform: uppercase;
    font-weight: 700;
    letter-spacing: 0.04em;
}

.selected-user-box__name {
    font-size: 16px;
    font-weight: 700;
    color: #5f4b1b;
}

.selected-user-box__email {
    margin-top: 4px;
    color: #7c6a34;
    font-size: 0.92rem;
}

.permission-check-card {
    display: flex;
    align-items: center;
    gap: 10px;
    min-height: 64px;
    width: 100%;
    padding: 12px 14px;
    border: 1px solid #dee2e6;
    border-radius: 14px;
    background: #fff;
    cursor: pointer;
    transition: all 0.2s ease;
}

.permission-check-card:hover {
    border-color: #80bdff;
    box-shadow: 0 6px 14px rgba(0, 123, 255, 0.08);
}

.permission-check-card.checked {
    border-color: #007bff;
    background: #f4f9ff;
    box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.08);
}

.permission-check-card input[type="checkbox"] {
    transform: scale(1.08);
    flex-shrink: 0;
    margin-top: 0;
}

.permission-check-card__content {
    display: flex;
    flex-direction: column;
    min-width: 0;
}

.permission-check-card__title {
    font-weight: 600;
    line-height: 1.25;
    color: #1f2937;
}

.permission-check-card__meta {
    color: #6b7280;
}

.user-list-cell {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-list-cell__avatar {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #e5e7eb;
    flex-shrink: 0;
}

.user-list-cell__name {
    color: #1f2937;
}

.table td,
.table th {
    vertical-align: middle;
}

.form-control {
    border-radius: 10px;
    min-height: 42px;
    box-shadow: none !important;
}

.form-control:focus {
    border-color: #80bdff;
    box-shadow: 0 0 0 0.15rem rgba(0, 123, 255, 0.15) !important;
}

.gap-2 {
    gap: 0.5rem;
}

body.dark-mode .permission-page .page-title,
body.dark-mode .permission-page .card-title {
    color: #f9fafb;
}

body.dark-mode .permission-page .page-subtitle,
body.dark-mode .permission-page .text-muted,
body.dark-mode .permission-page label,
body.dark-mode .permission-page .breadcrumb-item a,
body.dark-mode .permission-page .breadcrumb-item.active,
body.dark-mode .permission-list-count {
    color: #cbd5e1 !important;
}

body.dark-mode .permission-card {
    background: #2b3035;
    color: #e5e7eb;
}

body.dark-mode .permission-card .card-footer {
    border-top-color: rgba(255, 255, 255, 0.08);
}

body.dark-mode .permission-page .table {
    color: #e5e7eb;
}

body.dark-mode .permission-page .table td,
body.dark-mode .permission-page .table th {
    border-color: rgba(255, 255, 255, 0.08);
}

body.dark-mode .permission-type-badge--admin,
body.dark-mode .user-level-badge--admin {
    background: rgba(239, 68, 68, 0.18);
    color: #fecaca;
}

body.dark-mode .permission-type-badge--author,
body.dark-mode .user-level-badge--author {
    background: rgba(245, 158, 11, 0.18);
    color: #fde68a;
}

body.dark-mode .permission-type-badge--user,
body.dark-mode .user-level-badge--user {
    background: rgba(59, 130, 246, 0.18);
    color: #bfdbfe;
}

body.dark-mode .assign-empty-state {
    background: #3a3324;
    border-color: #8a6d3b;
}

body.dark-mode .assign-empty-state__title {
    color: #fff3cd;
}

body.dark-mode .assign-empty-state__text {
    color: #d8dee6;
}

body.dark-mode .assign-loading-state {
    background: #252b33;
    border-color: #3a4048;
    color: #dbe4ee;
}

body.dark-mode .search-user-results {
    background: #252b33;
    border-color: #3a4048;
}

body.dark-mode .search-user-results__title {
    color: #dbe4ee;
}

body.dark-mode .user-search-card {
    background: #343a40;
    border-color: #495057;
}

body.dark-mode .user-search-card__avatar,
body.dark-mode .user-list-cell__avatar {
    border-color: #495057;
}

body.dark-mode .user-search-card__name,
body.dark-mode .user-list-cell__name,
body.dark-mode .permission-check-card__title {
    color: #fff;
}

body.dark-mode .user-search-card__email,
body.dark-mode .permission-check-card__meta {
    color: #cbd5e1;
}

body.dark-mode .user-search-card.active {
    background: #1f3a56;
    border-color: #6ea8fe;
}

body.dark-mode .selected-user-box {
    background: #3a3324;
    border-color: #8a6d3b;
}

body.dark-mode .selected-user-box__avatar {
    border-color: #8a6d3b;
}

body.dark-mode .selected-user-box__label {
    color: #f5d68a;
}

body.dark-mode .selected-user-box__name {
    color: #fff3cd;
}

body.dark-mode .selected-user-box__email {
    color: #e8d9aa;
}

body.dark-mode .permission-check-card {
    background: #343a40;
    border-color: #495057;
}

body.dark-mode .permission-check-card.checked {
    background: #1f3a56;
    border-color: #6ea8fe;
    box-shadow: 0 0 0 3px rgba(110, 168, 254, 0.16);
}

body.dark-mode .form-control {
    background-color: #343a40;
    border-color: #495057;
    color: #fff;
}

body.dark-mode .form-control::placeholder {
    color: #adb5bd;
}
</style>

<style>
body.dark-mode .content-wrapper.permission-page,
html.dark-mode .content-wrapper.permission-page,
.dark-mode .content-wrapper.permission-page {
    background: #0f172a !important;
}

body.dark-mode .permission-page,
html.dark-mode .permission-page,
.dark-mode .permission-page {
    color: #e5e7eb !important;
}

body.dark-mode .permission-page .page-title,
html.dark-mode .permission-page .page-title,
.dark-mode .permission-page .page-title {
    color: #f8fafc !important;
}

body.dark-mode .permission-page .page-subtitle,
html.dark-mode .permission-page .page-subtitle,
.dark-mode .permission-page .page-subtitle {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .permission-card,
body.dark-mode .permission-page .card,
html.dark-mode .permission-page .permission-card,
html.dark-mode .permission-page .card,
.dark-mode .permission-page .permission-card,
.dark-mode .permission-page .card {
    background: #111827 !important;
    color: #e5e7eb !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
}

body.dark-mode .permission-page .card-header,
html.dark-mode .permission-page .card-header,
.dark-mode .permission-page .card-header {
    border-bottom-color: rgba(255, 255, 255, 0.08) !important;
    color: #f8fafc !important;
}

body.dark-mode .permission-page .card-body,
body.dark-mode .permission-page .card-footer,
html.dark-mode .permission-page .card-body,
html.dark-mode .permission-page .card-footer,
.dark-mode .permission-page .card-body,
.dark-mode .permission-page .card-footer {
    background: #111827 !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .permission-page .permission-list-count,
html.dark-mode .permission-page .permission-list-count,
.dark-mode .permission-page .permission-list-count {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .form-control,
body.dark-mode .permission-page select.form-control,
html.dark-mode .permission-page .form-control,
html.dark-mode .permission-page select.form-control,
.dark-mode .permission-page .form-control,
.dark-mode .permission-page select.form-control {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .permission-page .form-control:focus,
body.dark-mode .permission-page select.form-control:focus,
html.dark-mode .permission-page .form-control:focus,
html.dark-mode .permission-page select.form-control:focus,
.dark-mode .permission-page .form-control:focus,
.dark-mode .permission-page select.form-control:focus {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #60a5fa !important;
    box-shadow: 0 0 0 0.12rem rgba(96, 165, 250, 0.18) !important;
}

body.dark-mode .permission-page label,
html.dark-mode .permission-page label,
.dark-mode .permission-page label {
    color: #dbe4ec !important;
}

body.dark-mode .permission-page .table,
html.dark-mode .permission-page .table,
.dark-mode .permission-page .table {
    color: #e5e7eb !important;
}

body.dark-mode .permission-page .table thead th,
html.dark-mode .permission-page .table thead th,
.dark-mode .permission-page .table thead th {
    background: #1f2937 !important;
    color: #f8fafc !important;
    border-color: #334155 !important;
}

body.dark-mode .permission-page .table td,
body.dark-mode .permission-page .table th,
html.dark-mode .permission-page .table td,
html.dark-mode .permission-page .table th,
.dark-mode .permission-page .table td,
.dark-mode .permission-page .table th {
    border-color: #334155 !important;
}

body.dark-mode .permission-page .table-hover tbody tr:hover,
html.dark-mode .permission-page .table-hover tbody tr:hover,
.dark-mode .permission-page .table-hover tbody tr:hover {
    background: rgba(96, 165, 250, 0.08) !important;
    color: #fff !important;
}

body.dark-mode .permission-page .search-input,
html.dark-mode .permission-page .search-input,
.dark-mode .permission-page .search-input {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .permission-page .search-input-icon,
html.dark-mode .permission-page .search-input-icon,
.dark-mode .permission-page .search-input-icon {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .user-search-card,
body.dark-mode .permission-page .selected-user-box,
body.dark-mode .permission-page .permission-check-card,
html.dark-mode .permission-page .user-search-card,
html.dark-mode .permission-page .selected-user-box,
html.dark-mode .permission-page .permission-check-card,
.dark-mode .permission-page .user-search-card,
.dark-mode .permission-page .selected-user-box,
.dark-mode .permission-page .permission-check-card {
    background: #1f2937 !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .permission-page .user-search-card.active,
body.dark-mode .permission-page .permission-check-card.checked,
html.dark-mode .permission-page .user-search-card.active,
html.dark-mode .permission-page .permission-check-card.checked,
.dark-mode .permission-page .user-search-card.active,
.dark-mode .permission-page .permission-check-card.checked {
    border-color: #60a5fa !important;
    box-shadow: 0 0 0 1px rgba(96, 165, 250, 0.3) !important;
}

body.dark-mode .permission-page .user-search-card__name,
body.dark-mode .permission-page .selected-user-box__name,
body.dark-mode .permission-page .user-list-cell__name,
html.dark-mode .permission-page .user-search-card__name,
html.dark-mode .permission-page .selected-user-box__name,
html.dark-mode .permission-page .user-list-cell__name,
.dark-mode .permission-page .user-search-card__name,
.dark-mode .permission-page .selected-user-box__name,
.dark-mode .permission-page .user-list-cell__name {
    color: #f8fafc !important;
}

body.dark-mode .permission-page .user-search-card__email,
body.dark-mode .permission-page .selected-user-box__email,
html.dark-mode .permission-page .user-search-card__email,
html.dark-mode .permission-page .selected-user-box__email,
.dark-mode .permission-page .user-search-card__email,
.dark-mode .permission-page .selected-user-box__email {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .assign-empty-state,
body.dark-mode .permission-page .assign-loading-state,
html.dark-mode .permission-page .assign-empty-state,
html.dark-mode .permission-page .assign-loading-state,
.dark-mode .permission-page .assign-empty-state,
.dark-mode .permission-page .assign-loading-state {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .text-muted,
html.dark-mode .permission-page .text-muted,
.dark-mode .permission-page .text-muted {
    color: #94a3b8 !important;
}

body.dark-mode .permission-page .breadcrumb-item.active,
html.dark-mode .permission-page .breadcrumb-item.active,
.dark-mode .permission-page .breadcrumb-item.active {
    color: #cbd5e1 !important;
}

body.dark-mode .permission-page .breadcrumb a,
html.dark-mode .permission-page .breadcrumb a,
.dark-mode .permission-page .breadcrumb a {
    color: #93c5fd !important;
}
</style>
