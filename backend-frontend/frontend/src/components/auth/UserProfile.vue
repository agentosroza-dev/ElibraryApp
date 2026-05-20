<template>
    <div class="content-wrapper profile-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2 align-items-center">
                    <div class="col-sm-6">
                        <h1 class="mb-0">Profile</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right mb-0">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">Home</router-link>
                            </li>
                            <li class="breadcrumb-item active">Profile</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-lg-4 col-xl-3">
                        <div class="card card-primary card-outline shadow-sm">
                            <div class="card-body box-profile text-center">
                                <div class="profile-avatar-wrap mb-3">
                                    <img
                                        class="profile-user-img img-fluid img-circle profile-avatar"
                                        :src="tempPhoto"
                                        alt="User profile"
                                    />
                                </div>

                                <input
                                    id="file-input"
                                    type="file"
                                    class="d-none"
                                    accept=".jpg,.jpeg,.png"
                                    @change="onUpdatePhoto"
                                />

                                <div class="d-flex justify-content-center flex-wrap mb-3">
                                    <label for="file-input" class="btn btn-primary btn-sm m-1 mb-0">
                                        <i class="fas fa-upload mr-1"></i> Upload
                                    </label>

                                    <button
                                        type="button"
                                        class="btn btn-danger btn-sm m-1"
                                        @click="onDeletePhoto"
                                    >
                                        <i class="fas fa-trash mr-1"></i> Delete
                                    </button>

                                    <button
                                        type="button"
                                        class="btn btn-secondary btn-sm m-1"
                                        @click="onResetPhoto"
                                    >
                                        <i class="fas fa-undo-alt mr-1"></i> Reset
                                    </button>

                                    <button
                                        v-if="changedPhoto"
                                        type="button"
                                        class="btn btn-success btn-sm m-1"
                                        @click="updatePhoto"
                                    >
                                        <i class="fas fa-check mr-1"></i> Save
                                    </button>
                                </div>

                                <h3 class="profile-username text-center mb-1">
                                    {{ profileForm.name || userData?.name || "User" }}
                                </h3>

                                <p class="text-muted text-center mb-3">
                                    {{ userData?.email || "example@email.com" }}
                                </p>

                                <div class="mb-3">
                                    <span class="level-badge">
                                        {{ userData?.level || "Member" }}
                                    </span>
                                </div>

                                <div class="profile-mini-info text-left">
                                    <div class="mini-info-item">
                                        <span class="mini-info-labelx text-center">About</span>
                                        <span class="mini-info-valuex text-truncate-2 text-center">
                                            {{ aboutForm.about_me || "No about me yet." }}
                                        </span>
                                    </div>

                                    <div class="mini-info-item">
                                        <span class="mini-info-labelx text-center">Interests</span>
                                        <span class="mini-info-valuex text-center">
                                            {{ formattedInterests }}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-8 col-xl-9">
                        <div class="card shadow-sm mb-3">
                            <div class="card-body p-2">
                                <div class="nav nav-pills profile-top-nav">
                                    <button
                                        type="button"
                                        class="nav-link"
                                        :class="{ active: activeTab === 'profile' }"
                                        @click="activeTab = 'profile'"
                                    >
                                        <i class="fas fa-user mr-2"></i>
                                        User information
                                    </button>

                                    <button
                                        type="button"
                                        class="nav-link"
                                        :class="{ active: activeTab === 'password' }"
                                        @click="activeTab = 'password'"
                                    >
                                        <i class="fas fa-lock mr-2"></i>
                                        Change Password
                                    </button>

                                    <button
                                        type="button"
                                        class="nav-link"
                                        :class="{ active: activeTab === 'about' }"
                                        @click="activeTab = 'about'"
                                    >
                                        <i class="fas fa-id-card mr-2"></i>
                                        About Me & Interests
                                    </button>

                                    <button
                                        type="button"
                                        class="nav-link"
                                        :class="{ active: activeTab === 'favorites' }"
                                        @click="openFavoritesTab"
                                    >
                                        <i class="fas fa-heart mr-2"></i>
                                        My Favorite
                                    </button>

                                    <!--                                    <button-->
                                    <!--                                        type="button"-->
                                    <!--                                        class="nav-link"-->
                                    <!--                                        :class="{ active: activeTab === 'logs' }"-->
                                    <!--                                        @click="openLogsTab"-->
                                    <!--                                    >-->
                                    <!--                                        <i class="fas fa-desktop mr-2"></i>-->
                                    <!--                                        Device Logs-->
                                    <!--                                    </button>-->

                                    <button
                                        type="button"
                                        class="nav-link"
                                        :class="{ active: activeTab === 'login-history' }"
                                        @click="openLoginHistoryTab"
                                    >
                                        <i class="fas fa-history mr-2"></i>
                                        Login History
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div v-if="activeTab === 'profile'" class="card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title">Edit Information</h3>
                            </div>
                            <div class="card-body">
                                <form @submit.prevent="saveProfileInfo">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Full Name</label>
                                                <input
                                                    v-model.trim="profileForm.name"
                                                    type="text"
                                                    class="form-control"
                                                    placeholder="Enter your full name"
                                                />
                                            </div>
                                        </div>

                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Email</label>
                                                <input
                                                    :value="userData?.email || ''"
                                                    type="email"
                                                    class="form-control"
                                                    disabled
                                                />
                                                <small class="text-muted">Email is read only.</small>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="text-right">
                                        <button
                                            type="button"
                                            class="btn btn-secondary mr-2"
                                            @click="resetProfileInfo"
                                        >
                                            Reset
                                        </button>
                                        <button
                                            type="submit"
                                            class="btn btn-primary"
                                            :disabled="loadingProfile"
                                        >
                                            Save Profile
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div v-else-if="activeTab === 'password'" class="card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title">Update Password</h3>
                            </div>
                            <div class="card-body">
                                <form @submit.prevent="changePassword">
                                    <div v-if="!userData?.password_null" class="form-group row">
                                        <label class="col-sm-3 col-form-label">Old Password</label>
                                        <div class="col-sm-9">
                                            <input
                                                v-model="passwordForm.old_password"
                                                type="password"
                                                class="form-control"
                                                placeholder="Old Password"
                                                :class="{ 'is-invalid': !!passwordError.old_password }"
                                            />
                                            <div class="invalid-feedback">
                                                {{ passwordError.old_password }}
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">New Password</label>
                                        <div class="col-sm-9">
                                            <input
                                                v-model="passwordForm.new_password"
                                                type="password"
                                                class="form-control"
                                                placeholder="New Password"
                                                :class="{ 'is-invalid': !!passwordError.new_password }"
                                            />
                                            <div class="invalid-feedback">
                                                {{ passwordError.new_password }}
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Confirm Password</label>
                                        <div class="col-sm-9">
                                            <input
                                                v-model="passwordForm.new_password_confirmation"
                                                type="password"
                                                class="form-control"
                                                placeholder="Confirm Password"
                                            />
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <div class="offset-sm-3 col-sm-9">
                                            <div class="custom-control custom-checkbox">
                                                <input
                                                    id="terminate-sessions"
                                                    v-model="passwordForm.terminate_sessions"
                                                    type="checkbox"
                                                    class="custom-control-input"
                                                />
                                                <label class="custom-control-label" for="terminate-sessions">
                                                    Terminate all sessions
                                                </label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="text-right">
                                        <button
                                            type="button"
                                            class="btn btn-danger mr-2"
                                            @click="resetPasswordForm"
                                        >
                                            Cancel
                                        </button>
                                        <button type="submit" class="btn btn-outline-primary">
                                            Save Password
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div v-else-if="activeTab === 'about'" class="card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title">About Me & Interests</h3>
                            </div>
                            <div class="card-body">
                                <form @submit.prevent="saveAboutInfo">
                                    <div class="form-group">
                                        <label>About Me</label>
                                        <textarea
                                            v-model="aboutForm.about_me"
                                            class="form-control"
                                            rows="5"
                                            maxlength="2000"
                                            placeholder="Write something about yourself..."
                                        ></textarea>
                                        <small class="text-muted">
                                            {{ aboutLength }}/2000 characters
                                        </small>
                                    </div>

                                    <div class="form-group">
                                        <label>Interests</label>
                                        <select
                                            v-model="aboutForm.interests"
                                            class="form-control"
                                            multiple
                                            size="8"
                                        >
                                            <option
                                                v-for="tag in interestOptions"
                                                :key="tag.id"
                                                :value="tag.id"
                                            >
                                                {{ tag.name }}
                                            </option>
                                        </select>
                                        <small class="text-muted">
                                            Hold Ctrl / Command to select multiple interests.
                                        </small>
                                    </div>

                                    <div v-if="selectedInterestObjects.length" class="mb-3">
                                        <span
                                            v-for="tag in selectedInterestObjects"
                                            :key="tag.id"
                                            class="badge badge-pill badge-primary interest-badge"
                                        >
                                            {{ tag.name }}
                                        </span>
                                    </div>

                                    <div class="text-right">
                                        <button
                                            type="button"
                                            class="btn btn-secondary mr-2"
                                            @click="resetAboutInfo"
                                        >
                                            Reset
                                        </button>
                                        <button type="submit" class="btn btn-primary">
                                            Save About Me
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div v-else-if="activeTab === 'favorites'" class="card shadow-sm">
                            <div class="card-header">
                                <h3 class="card-title">My Favorite</h3>
                            </div>

                            <div v-if="favoritesLoading" class="card-body text-center text-muted py-4">
                                Loading favorites...
                            </div>

                            <div v-else class="card-body p-0">
                                <ul v-if="favoriteList.length" class="list-group list-group-flush">
                                    <li
                                        v-for="(item, index) in favoriteList"
                                        :key="favoriteKey(item, index)"
                                        class="list-group-item favorite-list-item"
                                    >
                                        <router-link
                                            :to="bookDetailsRoute(item)"
                                            class="favorite-link d-flex align-items-center"
                                        >
                                            <img
                                                :src="item.image"
                                                :alt="item.title"
                                                class="favorite-list-image mr-3"
                                                @error="onFavoriteImageError"
                                            />

                                            <div class="flex-grow-1 min-width-0">
                                                <h5 class="mb-1 favorite-title">{{ item.title }}</h5>
                                                <p class="text-muted mb-1">{{ item.author }}</p>

                                                <div v-if="item.tags.length">
                                                    <span
                                                        v-for="(tag, tagIndex) in item.tags"
                                                        :key="`${favoriteKey(item, index)}-${tagIndex}`"
                                                        class="badge badge-light border mr-1"
                                                    >
                                                        {{ tag }}
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="text-danger favorite-heart">
                                                <i class="fas fa-heart"></i>
                                            </div>
                                        </router-link>
                                    </li>
                                </ul>

                                <div v-else class="p-4 text-center text-muted">
                                    No favorite books yet.
                                </div>
                            </div>
                        </div>

                        <!--                        <div v-else-if="activeTab === 'logs'" class="card shadow-sm">-->
                        <!--                            <div class="card-header d-flex justify-content-between align-items-center">-->
                        <!--                                <h3 class="card-title mb-0">Device Logs</h3>-->

                        <!--                                <button-->
                        <!--                                    type="button"-->
                        <!--                                    class="btn btn-sm btn-primary"-->
                        <!--                                    :disabled="logsLoading"-->
                        <!--                                    @click="loadLogs(true)"-->
                        <!--                                >-->
                        <!--                                    Refresh-->
                        <!--                                </button>-->
                        <!--                            </div>-->

                        <!--                            <div v-if="logsLoading" class="card-body text-center text-muted py-4">-->
                        <!--                                Loading device logs...-->
                        <!--                            </div>-->

                        <!--                            <div v-else class="card-body p-0">-->
                        <!--                                <div class="table-responsive">-->
                        <!--                                    <table class="table table-hover mb-0">-->
                        <!--                                        <thead>-->
                        <!--                                        <tr>-->
                        <!--                                            <th>Device</th>-->
                        <!--                                            <th>Browser</th>-->
                        <!--                                            <th>IP Address</th>-->
                        <!--                                            <th>Last Active</th>-->
                        <!--                                            <th>Status</th>-->
                        <!--                                        </tr>-->
                        <!--                                        </thead>-->

                        <!--                                        <tbody v-if="deviceLogs.length">-->
                        <!--                                        <tr v-for="(log, index) in deviceLogs" :key="log.id || index">-->
                        <!--                                            <td>{{ log.device }}</td>-->
                        <!--                                            <td>{{ log.browser }}</td>-->
                        <!--                                            <td>{{ log.ip }}</td>-->
                        <!--                                            <td>{{ log.last_active }}</td>-->
                        <!--                                            <td>-->
                        <!--                                                    <span-->
                        <!--                                                        v-if="log.current"-->
                        <!--                                                        class="badge badge-success"-->
                        <!--                                                    >-->
                        <!--                                                        Current-->
                        <!--                                                    </span>-->
                        <!--                                                <span-->
                        <!--                                                    v-else-->
                        <!--                                                    class="badge badge-secondary"-->
                        <!--                                                >-->
                        <!--                                                        Saved-->
                        <!--                                                    </span>-->
                        <!--                                            </td>-->
                        <!--                                        </tr>-->
                        <!--                                        </tbody>-->

                        <!--                                        <tbody v-else>-->
                        <!--                                        <tr>-->
                        <!--                                            <td colspan="5" class="text-center text-muted py-4">-->
                        <!--                                                No device logs found.-->
                        <!--                                            </td>-->
                        <!--                                        </tr>-->
                        <!--                                        </tbody>-->
                        <!--                                    </table>-->
                        <!--                                </div>-->
                        <!--                            </div>-->
                        <!--                        </div>-->

                        <div v-else-if="activeTab === 'login-history'" class="card shadow-sm">
                            <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <h3 class="card-title mb-0">Login History</h3>

                                <button
                                    type="button"
                                    class="btn btn-sm btn-primary"
                                    :disabled="loginHistoryLoading"
                                    @click="loadLoginHistory(true, loginHistoryPagination.current_page)"
                                >
                                    Refresh
                                </button>
                            </div>

                            <div v-if="loginHistoryLoading" class="card-body text-center text-muted py-4">
                                Loading login history...
                            </div>

                            <div v-else class="card-body p-0">
                                <div class="table-responsive profile-table-wrap">
                                    <table class="table table-hover mb-0 align-middle login-history-table">

                                        <tr>
                                            <th>Device</th>
                                            <th>Browser / OS</th>
                                            <th>IP</th>
                                            <th>Location</th>
                                            <th>Login At</th>

                                            <th>Last Seen</th>
                                            <th>Last Active</th>
                                            <th>Status</th>
                                        </tr>

                                        <tbody v-if="loginHistoryRows.length">
                                        <tr v-for="item in loginHistoryRows" :key="item.id">
                                            <td class="device-col">
                                                <div class="font-weight-bold text-wrap">
                                                    {{ item.device_name || "Unknown Device" }}
                                                </div>

                                                <span class="badge" :class="badgeClass(item.device_type)">
                            {{ item.device_type || "Unknown" }}
                        </span>
                                            </td>

                                            <td class="browser-col">
                                                <div>{{ item.browser || "-" }}</div>
                                                <small class="text-muted d-block">{{ item.platform || "-" }}</small>
                                            </td>

                                            <td>{{ item.ip_address || "-" }}</td>
                                            <td>{{ item.location || "-" }}</td>
                                            <td>{{ formatDateTime(item.login_at) }}</td>
                                            <td>{{ formatDateTime(item.last_seen_at) }}</td>
                                            <td>{{ getDurationFromNow(item.login_at) }}</td>

                                            <td>
                        <span
                            v-if="item.is_current"
                            class="badge badge-success"
                        >
                            Current Device
                        </span>

                                                <span
                                                    v-else-if="item.logout_at"
                                                    class="badge badge-secondary"
                                                >
                            Logged Out
                        </span>

                                                <span
                                                    v-else
                                                    class="badge badge-warning"
                                                >
                            Previous Login
                        </span>
                                            </td>
                                        </tr>
                                        </tbody>

                                        <tbody v-else>
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-4">
                                                No login history found.
                                            </td>
                                        </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div
                                v-if="loginHistoryPagination.last_page > 1"
                                class="card-footer d-flex justify-content-between align-items-center flex-wrap gap-2"
                            >
                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-sm"
                                    :disabled="loginHistoryPagination.current_page <= 1 || loginHistoryLoading"
                                    @click="loadLoginHistory(true, loginHistoryPagination.current_page - 1)"
                                >
                                    Previous
                                </button>

                                <span>
            Page {{ loginHistoryPagination.current_page }} / {{ loginHistoryPagination.last_page }}
        </span>

                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-sm"
                                    :disabled="loginHistoryPagination.current_page >= loginHistoryPagination.last_page || loginHistoryLoading"
                                    @click="loadLoginHistory(true, loginHistoryPagination.current_page + 1)"
                                >
                                    Next
                                </button>
                            </div>
                        </div>

                        <div v-else class="card shadow-sm">
                            <div class="card-body">
                                <p class="mb-0">No section selected.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<script setup>
import emptyPhoto from "@assets/images/emptyuser.png";
import { computed, reactive, ref, watch, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
import { CloseModal, LoadingModal, MessageModal } from "@func/swal";
import {
    patchChangePassword,
    patchCreatePassword,
    patchUpdateUserPhoto,
} from "@func/api/auth";
import {
    apiGetProfile,
    apiUpdateProfile,
    apiUpdateAbout,
    apiGetProfileFavorites,
    apiGetProfileLogs,
    apiGetInterestTags,
} from "@func/api/user";
import { apiGetLoginHistories } from "@func/api/loginHistory.js";

const router = useRouter();
const store = useStore();

const activeTab = ref("profile");
const loadingProfile = ref(false);

const favoritesLoading = ref(false);
const logsLoading = ref(false);
const loginHistoryLoading = ref(false);

const favoritesLoaded = ref(false);
const logsLoaded = ref(false);
const loginHistoryLoaded = ref(false);

const favoriteList = ref([]);
const deviceLogs = ref([]);
const loginHistoryRows = ref([]);
const tempPhoto = ref(emptyPhoto);
const interestOptions = ref([]);

const loginHistoryPagination = reactive({
    current_page: 1,
    last_page: 1,
    per_page: 10,
    total: 0,
});

const userData = computed(() => store.state.user || {});
const userPhoto = computed(() => store.state.user?.photo || null);

const profileForm = reactive({
    name: "",
});

const aboutForm = reactive({
    about_me: "",
    interests: [],
});

function getDurationFromNow(date) {
    if (!date) return "-";

    const diff = Date.now() - new Date(date).getTime();

    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return "just now";
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    return `${days}d ago`;
}

const passwordForm = reactive({
    old_password: "",
    new_password: "",
    new_password_confirmation: "",
    terminate_sessions: false,
});

const passwordError = reactive({
    old_password: "",
    new_password: "",
});

const aboutLength = computed(() => String(aboutForm.about_me || "").length);

const changedPhoto = computed(() => {
    return tempPhoto.value !== (userPhoto.value || emptyPhoto);
});

const selectedInterestObjects = computed(() => {
    const ids = new Set(normalizeInterestIds(aboutForm.interests));
    return interestOptions.value.filter((tag) => ids.has(Number(tag.id)));
});

const formattedInterests = computed(() => {
    return selectedInterestObjects.value.length
        ? selectedInterestObjects.value.map((tag) => tag.name).join(", ")
        : "No interests yet.";
});

function setStoreUser(payload = {}) {
    store.commit("setUser", {
        ...store.state.user,
        ...payload,
    });
}

function normalizeInterestIds(value) {
    if (!Array.isArray(value)) return [];

    return [...new Set(
        value
            .map((item) => Number(item))
            .filter((item) => Number.isInteger(item) && item > 0)
    )];
}

function normalizeInterestObjects(value) {
    if (!Array.isArray(value)) return [];

    return value
        .map((item) => ({
            id: Number(item?.id || 0),
            name: String(item?.name || "").trim(),
        }))
        .filter((item) => item.id > 0 && item.name);
}

function normalizeFavorites(value) {
    if (!Array.isArray(value)) return [];

    return value
        .map((item) => {
            const book = item?.book || item?.item || item?.book_item || item;

            const id = Number(
                book?.id ||
                item?.book_id ||
                item?.item_id ||
                item?.item?.id ||
                item?.book?.id ||
                0
            );

            const authorName =
                book?.author?.name ||
                book?.author_name ||
                book?.author ||
                item?.author?.name ||
                item?.author_name ||
                item?.author ||
                "Unknown Author";

            const image =
                book?.cover_url ||
                book?.cover ||
                book?.image ||
                item?.cover_url ||
                item?.cover ||
                item?.image ||
                emptyPhoto;

            const tags = Array.isArray(book?.tags || item?.tags)
                ? (book?.tags || item?.tags)
                    .map((tag) => {
                        if (typeof tag === "string") return tag.trim();
                        return String(tag?.name || tag?.title || "").trim();
                    })
                    .filter(Boolean)
                : [];

            return {
                id,
                favorite_id: Number(item?.favorite_id || item?.pivot?.id || item?.id || 0),
                slug: String(book?.slug || item?.slug || ""),
                title: String(book?.title || item?.title || "Untitled"),
                author: String(authorName),
                image: String(image || emptyPhoto),
                tags,
            };
        })
        .filter((item) => item.id > 0);
}

function favoriteKey(item, index) {
    return `${item?.id || "book"}-${item?.favorite_id || index}`;
}

function bookDetailsRoute(item) {
    return {
        name: "book.details",
        params: { id: Number(item?.id || 0) },
    };
}

function onFavoriteImageError(event) {
    event.target.src = emptyPhoto;
}

function normalizeLogs(value) {
    if (!Array.isArray(value)) return [];

    return value.map((log, index) => ({
        id: log?.id || `log_${index}`,
        device: String(log?.device || "-"),
        browser: String(log?.browser || "-"),
        ip: String(log?.ip || "-"),
        last_active: String(log?.last_active || "-"),
        current: Boolean(log?.current),
    }));
}

function normalizeLoginHistories(value) {
    if (!Array.isArray(value)) return [];

    return value.map((item, index) => ({
        id: Number(item?.id) || `history_${index}`,
        device_name: String(item?.device_name || "Unknown Device"),
        device_type: String(item?.device_type || "Unknown"),
        browser: String(item?.browser || "-"),
        platform: String(item?.platform || "-"),
        ip_address: String(item?.ip_address || "-"),
        location: String(item?.location || "-"),
        login_at: String(item?.login_at || ""),
        last_seen_at: String(item?.last_seen_at || ""),
        logout_at: String(item?.logout_at || ""),
        is_current: Boolean(item?.is_current),
    }));
}

function formatDateTime(value) {
    if (!value) return "-";

    try {
        return new Date(value).toLocaleString();
    } catch {
        return value;
    }
}

function badgeClass(type) {
    const key = String(type || "").toLowerCase();

    if (key === "mobile") return "badge-success";
    if (key === "tablet") return "badge-warning";
    if (key === "desktop") return "badge-primary";

    return "badge-secondary";
}

function syncProfileForm() {
    profileForm.name = userData.value?.name || "";
}

function syncAboutForm() {
    aboutForm.about_me = userData.value?.about_me || "";
    aboutForm.interests = normalizeInterestObjects(userData.value?.interests).map((tag) => tag.id);
}

function syncPhoto() {
    tempPhoto.value = userPhoto.value || emptyPhoto;
}

watch(
    userData,
    () => {
        syncProfileForm();
        syncAboutForm();
    },
    { immediate: true, deep: true }
);

watch(
    userPhoto,
    () => {
        syncPhoto();
    },
    { immediate: true }
);

async function loadInterestTags() {
    try {
        const { data } = await apiGetInterestTags();
        interestOptions.value = normalizeInterestObjects(data?.interests);
    } catch (error) {
        console.error("Failed to load interest tags:", error);
        interestOptions.value = [];
    }
}

async function loadProfile() {
    loadingProfile.value = true;

    try {
        const { data } = await apiGetProfile();
        const profile = data?.user || {};

        setStoreUser({
            ...profile,
            interests: normalizeInterestObjects(profile?.interests),
        });

        favoriteList.value = normalizeFavorites(data?.favorites);
        deviceLogs.value = normalizeLogs(data?.device_logs);

        favoritesLoaded.value = true;
        logsLoaded.value = true;
    } catch (error) {
        console.error("Failed to load profile:", error);
        favoriteList.value = [];
        deviceLogs.value = [];
        favoritesLoaded.value = false;
        logsLoaded.value = false;
    } finally {
        loadingProfile.value = false;
    }
}

async function loadFavorites(force = false) {
    if (favoritesLoading.value || (favoritesLoaded.value && !force)) return;

    favoritesLoading.value = true;

    try {
        const { data } = await apiGetProfileFavorites();
        favoriteList.value = normalizeFavorites(data?.favorites);
        favoritesLoaded.value = true;
    } catch (error) {
        console.error("Failed to load favorites:", error);
        favoriteList.value = [];
        favoritesLoaded.value = true;
    } finally {
        favoritesLoading.value = false;
    }
}

async function loadLogs(force = false) {
    if (logsLoading.value || (logsLoaded.value && !force)) return;

    logsLoading.value = true;

    try {
        const { data } = await apiGetProfileLogs();
        deviceLogs.value = normalizeLogs(data?.device_logs);
        logsLoaded.value = true;
    } catch (error) {
        console.error("Failed to load logs:", error);
        deviceLogs.value = [];
        logsLoaded.value = true;
    } finally {
        logsLoading.value = false;
    }
}

async function loadLoginHistory(force = false, page = 1) {
    if (loginHistoryLoading.value) return;
    if (loginHistoryLoaded.value && !force && loginHistoryPagination.current_page === page) return;

    loginHistoryLoading.value = true;

    try {
        const { data } = await apiGetLoginHistories({
            page,
            per_page: loginHistoryPagination.per_page,
        });

        loginHistoryRows.value = normalizeLoginHistories(data?.data);
        loginHistoryPagination.current_page = Number(data?.current_page || 1);
        loginHistoryPagination.last_page = Number(data?.last_page || 1);
        loginHistoryPagination.per_page = Number(data?.per_page || 10);
        loginHistoryPagination.total = Number(data?.total || 0);
        loginHistoryLoaded.value = true;
    } catch (error) {
        console.error("Failed to load login history:", error);
        loginHistoryRows.value = [];
        loginHistoryPagination.current_page = 1;
        loginHistoryPagination.last_page = 1;
        loginHistoryPagination.total = 0;
        loginHistoryLoaded.value = true;
    } finally {
        loginHistoryLoading.value = false;
    }
}

function openFavoritesTab() {
    activeTab.value = "favorites";
    loadFavorites();
}

function openLogsTab() {
    activeTab.value = "logs";
    loadLogs();
}

function openLoginHistoryTab() {
    activeTab.value = "login-history";
    loadLoginHistory();
}

async function saveProfileInfo() {
    try {
        LoadingModal();

        const payload = {
            name: String(profileForm.name || "").trim(),
        };

        const { data } = await apiUpdateProfile(payload);

        setStoreUser(data?.user || payload);

        await MessageModal("success", "Success");
    } catch (error) {
        await MessageModal(
            "error",
            "Error",
            error.response?.data?.message || error.message || "Failed to update profile."
        );
    }
}

function resetProfileInfo() {
    syncProfileForm();
}

async function saveAboutInfo() {
    try {
        LoadingModal();

        const payload = {
            about_me: String(aboutForm.about_me || "").trim(),
            interests: normalizeInterestIds(aboutForm.interests),
        };

        const { data } = await apiUpdateAbout(payload);

        setStoreUser({
            about_me: data?.user?.about_me ?? payload.about_me,
            interests: normalizeInterestObjects(data?.user?.interests),
        });

        syncAboutForm();

        await MessageModal("success", "Success");
    } catch (error) {
        await MessageModal(
            "error",
            "Error",
            error.response?.data?.message || error.message || "Failed to update about me."
        );
    }
}

function resetAboutInfo() {
    syncAboutForm();
}

function resetPasswordErrors() {
    passwordError.old_password = "";
    passwordError.new_password = "";
}

function resetPasswordForm() {
    passwordForm.old_password = "";
    passwordForm.new_password = "";
    passwordForm.new_password_confirmation = "";
    passwordForm.terminate_sessions = false;
    resetPasswordErrors();
}

async function changePassword() {
    try {
        LoadingModal();
        resetPasswordErrors();

        const response = userData.value?.password_null
            ? await patchCreatePassword(passwordForm)
            : await patchChangePassword(passwordForm);

        await MessageModal("success", "Success", response.data.message, () => {
            resetPasswordForm();
            router.push({ name: "dashboard" });
        });
    } catch (error) {
        if (!error.response) {
            return MessageModal("error", "Error", error.message || "Something went wrong.");
        }

        if (error.response.status === 422) {
            passwordError.old_password = error.response.data.errors?.old_password?.[0] || "";
            passwordError.new_password = error.response.data.errors?.new_password?.[0] || "";
            return CloseModal();
        }

        return MessageModal(
            "error",
            "Error",
            error.response.data.message || "Failed to change password."
        );
    }
}

function readFileAsDataUrl(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

function cropImageToSquare(src, size = 454) {
    return new Promise((resolve, reject) => {
        const img = new Image();

        img.onload = () => {
            const canvas = document.createElement("canvas");
            const ctx = canvas.getContext("2d");

            if (!ctx) {
                reject(new Error("Canvas context is not available."));
                return;
            }

            canvas.width = size;
            canvas.height = size;

            const cropSize = Math.min(img.width, img.height);
            const x = (img.width - cropSize) / 2;
            const y = (img.height - cropSize) / 2;

            ctx.drawImage(img, x, y, cropSize, cropSize, 0, 0, size, size);
            resolve(canvas.toDataURL("image/png"));
        };

        img.onerror = reject;
        img.src = src;
    });
}

async function onUpdatePhoto(event) {
    try {
        const file = event.target.files?.[0];
        event.target.value = null;

        if (!file) return;

        const ext = file.name.split(".").pop()?.toLowerCase();
        const allowedExtensions = ["jpg", "jpeg", "png"];

        if (!allowedExtensions.includes(ext)) {
            return MessageModal("error", "Error", "Only jpg, jpeg, and png files are allowed.");
        }

        const fileSrc = await readFileAsDataUrl(file);
        tempPhoto.value = await cropImageToSquare(fileSrc);
    } catch (error) {
        await MessageModal("error", "Error", error.message || "Failed to process image.");
    }
}

function onDeletePhoto() {
    tempPhoto.value = emptyPhoto;
}

function onResetPhoto() {
    syncPhoto();
}

async function updatePhoto() {
    try {
        LoadingModal();

        const photo = tempPhoto.value === emptyPhoto ? null : tempPhoto.value;
        const response = await patchUpdateUserPhoto({ photo });

        store.commit("setUserPhoto", response.data.photo || null);
        tempPhoto.value = response.data.photo || emptyPhoto;

        await MessageModal("success", "Success");
    } catch (error) {
        await MessageModal(
            "error",
            "Error",
            error.response?.data?.message || error.message || "Failed to update photo."
        );
    }
}

onMounted(async () => {
    await Promise.all([
        loadInterestTags(),
        loadProfile(),
    ]);
});
</script>

<style scoped>
.profile-page {
    min-height: 100vh;
}

.shadow-sm {
    box-shadow: 0 0.125rem 0.5rem rgba(0, 0, 0, 0.08);
}

.profile-avatar-wrap {
    display: flex;
    justify-content: center;
    align-items: center;
}

.profile-avatar {
    width: 110px;
    height: 110px;
    object-fit: cover;
    border: 4px solid #fff;
    box-shadow: 0 0.25rem 1rem rgba(0, 0, 0, 0.12);
}

.profile-mini-info {
    border-top: 1px solid #ececec;
    padding-top: 0.75rem;
}

.mini-info-item {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    padding: 0.6rem 0;
    border-bottom: 1px dashed #ececec;
    font-size: 0.92rem;
}

.mini-info-item:last-child {
    border-bottom: 0;
}



.profile-top-nav {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 0.5rem;
}

.profile-top-nav .nav-link {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.35rem;
    min-height: 42px;
    padding: 0.55rem 0.7rem;
    border-radius: 0.6rem;
    font-weight: 600;
    font-size: 0.88rem;
    line-height: 1.1;
    border: 1px solid #dee2e6;
    background: #f8f9fa;
    color: #495057;
    transition: all 0.2s ease;
    text-align: center;
    white-space: nowrap;
}

.profile-top-nav .nav-link.active {
    background: #007bff;
    color: #fff;
    border-color: #007bff;
}

.profile-top-nav .nav-link:hover {
    transform: translateY(-1px);
}

.profile-table-wrap {
    overflow-x: auto;
}

.login-history-table {
    min-width: 1080px;
}

.login-history-table .device-col {
    min-width: 170px;
}

.login-history-table .browser-col {
    min-width: 150px;
}



.interest-badge {
    font-size: 0.86rem;
    padding: 0.5rem 0.75rem;
    margin-right: 0.45rem;
    margin-bottom: 0.45rem;
}

.table thead th {
    border-top: 0;
    background: #f8f9fa;
    font-weight: 600;
    white-space: nowrap;
}

.text-truncate-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.level-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.38rem 0.85rem;
    border-radius: 999px;
    font-size: 0.8rem;
    font-weight: 700;
    line-height: 1;
    background: rgba(0, 123, 255, 0.1);
    color: #007bff;
    border: 1px solid rgba(0, 123, 255, 0.18);
}

.favorite-list-image {
    width: 60px;
    height: 80px;
    object-fit: cover;
    border-radius: 6px;
}



.favorite-list-item {
    padding: 0;
}

.favorite-link {
    padding: 0.75rem 1.25rem;
    color: inherit;
    text-decoration: none;
    transition: background-color 0.18s ease, transform 0.18s ease;
}

.favorite-link:hover {
    color: inherit;
    text-decoration: none;
    background-color: #f8f9fa;
}

.favorite-title {
    color: #212529;
    font-weight: 700;
}

.favorite-link:hover .favorite-title {
    color: #007bff;
}

.favorite-heart {
    flex: 0 0 auto;
}

.min-width-0 {
    min-width: 0;
}

@media (max-width: 991.98px) {
    .mini-info-item {
        flex-direction: column;
        align-items: flex-start;
    }
}
@media (max-width: 991.98px) {
    .mini-info-item {
        flex-direction: column;
        align-items: flex-start;
    }

    .profile-top-nav {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .profile-top-nav .nav-link {
        font-size: 0.82rem;
        padding: 0.5rem 0.6rem;
    }
}

@media (max-width: 575.98px) {
    .profile-top-nav {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .profile-top-nav .nav-link {
        min-height: 40px;
        font-size: 0.8rem;
    }
}
</style>

<style>
.content-wrapper.profile-page {
    background-color: #f4f6f9 !important;
    min-height: calc(100vh - 57px);
}

body.dark-mode .content-wrapper.profile-page,
body[class*="dark-mode"] .content-wrapper.profile-page {
    background-color: #0f172a !important;
}

body.dark-mode .favorite-link:hover,
body[class*="dark-mode"] .favorite-link:hover {
    background-color: rgba(255, 255, 255, 0.06);
}

body.dark-mode .favorite-title,
body[class*="dark-mode"] .favorite-title {
    color: #e5e7eb;
}

body.dark-mode .favorite-link:hover .favorite-title,
body[class*="dark-mode"] .favorite-link:hover .favorite-title {
    color: #60a5fa;
}

.content-wrapper.profile-page .content-header,
.content-wrapper.profile-page .content,
.content-wrapper.profile-page .container-fluid {
    background: transparent !important;
}
</style>
