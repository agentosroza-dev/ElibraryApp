<template>
    <aside class="main-sidebar sidebar-dark-primary elevation-4">
        <router-link :to="{ name: 'dashboard' }" class="brand-link text-center">
            <img :src="logoImg" class="brand-image img-circle elevation-3" alt="Logo" />
            <span class="brand-text font-weight-light">{{ t("logo-brand-text") }}</span>
        </router-link>

        <div class="sidebar">
            <router-link
                v-if="hasProfilePermission && hasRoute('profile')"
                :to="{ name: 'profile' }"
                class="d-block profile-link"
            >
                <div class="user-panel mt-3 pb-3 mb-3 d-flex align-items-center">
                    <div class="image">
                        <img :src="userPhoto" class="img-circle elevation-2" alt="User" @error="onUserImageError" />
                    </div>
                    <div class="info">
                        <span class="d-block text-white">{{ userName }}</span>
                    </div>
                </div>
            </router-link>

            <nav class="mt-2">
                <ul class="nav nav-pills nav-sidebar flex-column" role="menu">
                    <li v-for="permission in menuPermissions" :key="permission.id" class="nav-item">
                        <router-link
                            v-if="hasRoute(permission.route_name)"
                            :to="{ name: permission.route_name }"
                            class="nav-link"
                            active-class="active"
                        >
                            <i :class="iconClass(permission.list_icon)"></i>

                            <p class="menu-text">
                                <span>{{ permissionLabel(permission) }}</span>

                                <span
                                    v-if="permission.route_name === 'list.chats' && unreadTotal > 0"
                                    class="badge badge-info right"
                                >
                                    {{ unreadTotal }}
                                </span>
                            </p>
                        </router-link>
                    </li>
                </ul>
            </nav>
        </div>
    </aside>
</template>

<script setup>
import {
    computed,
    nextTick,
    onBeforeUnmount,
    onMounted,
    ref,
    watch,
} from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";

import emptyPhoto from "@assets/images/emptyuser.png";
import logoImg from "/PAC_E-Library.png";

const store = useStore();
const router = useRouter();
const { t, te } = useI18n();

const permissions = ref([]);
const chats = ref([]);
const unreadTotal = ref(0);
const loadingUnread = ref(false);

let unreadRefreshTimer = null;
let pollingTimer = null;
let echoUserId = null;
let pendingUnreadRefresh = false;

const API_BASE = String(import.meta.env.VITE_URL || window.location.origin).replace(/\/+$/, "");

const userData = computed(() => {
    const user = store.state?.user;
    return user && typeof user === "object" ? user : {};
});

const userId = computed(() => Number(userData.value?.id) || 0);

const userName = computed(() =>
    String(userData.value?.name || "User").trim() || "User"
);

const userPhoto = computed(() => {
    const photo = String(userData.value?.photo || "").trim();
    return photo || emptyPhoto;
});

const normalizedPermissions = computed(() => {
    const seen = new Set();

    return (Array.isArray(permissions.value) ? permissions.value : [])
        .map((item) => ({
            id: Number(item?.id) || 0,
            title: String(item?.title || "").trim(),
            route_name: String(item?.route_name || "").trim(),
            list_icon: String(item?.list_icon || "").trim(),
            menu_order: Number(item?.menu_order || 0),
            i18n_key: String(item?.i18n_key || "").trim(),
        }))
        .filter((item) => {
            if (!item.id || !item.route_name) return false;
            if (seen.has(item.route_name)) return false;

            seen.add(item.route_name);
            return true;
        })
        .sort((a, b) => {
            if (a.menu_order !== b.menu_order) return a.menu_order - b.menu_order;
            return a.id - b.id;
        });
});

const hasProfilePermission = computed(() =>
    normalizedPermissions.value.some((item) => item.route_name === "profile")
);

const menuPermissions = computed(() =>
    normalizedPermissions.value.filter((item) => item.route_name !== "profile")
);

function normalizeArray(data) {
    if (Array.isArray(data)) return data;
    if (Array.isArray(data?.data)) return data.data;
    if (Array.isArray(data?.chats)) return data.chats;
    if (Array.isArray(data?.data?.chats)) return data.data.chats;
    return [];
}

function normalizeUnreadCount(chat) {
    return Number(
        chat?.unread_count ??
        chat?.unreadCount ??
        chat?.unread_messages_count ??
        chat?.unreadMessagesCount ??
        0
    ) || 0;
}

function setChats(data) {
    chats.value = normalizeArray(data);
    unreadTotal.value = chats.value.reduce((total, chat) => {
        return total + normalizeUnreadCount(chat);
    }, 0);
}

async function getChatsUnreadCount() {
    if (loadingUnread.value) {
        pendingUnreadRefresh = true;
        return;
    }

    try {
        loadingUnread.value = true;
        pendingUnreadRefresh = false;

        const axiosInstance = window.axios;
        if (!axiosInstance) return;

        const { data } = await axiosInstance.get(`${API_BASE}/api/chats`);
        setChats(data);
    } catch (error) {
        console.error(
            "Failed to refresh sidebar unread:",
            error?.response?.data || error?.message || error
        );
    } finally {
        loadingUnread.value = false;

        if (pendingUnreadRefresh) {
            pendingUnreadRefresh = false;
            requestUnreadRefresh(100);
        }
    }
}

function requestUnreadRefresh(delay = 120) {
    clearTimeout(unreadRefreshTimer);

    unreadRefreshTimer = setTimeout(() => {
        getChatsUnreadCount();
    }, Number(delay) || 120);
}

function getEventChatId(detail = {}) {
    return (
        detail?.chat_id ||
        detail?.chatId ||
        detail?.chat?.id ||
        detail?.chat?.chat_id ||
        detail?.message?.chat_id ||
        detail?.message?.chatId ||
        null
    );
}

function markLocalChatRead(chatId) {
    const id = Number(chatId) || 0;
    if (!id) return;

    chats.value = chats.value.map((chat) => {
        if (Number(chat?.id) !== id) return chat;

        return {
            ...chat,
            unread_count: 0,
            unreadCount: 0,
            unread_messages_count: 0,
            unreadMessagesCount: 0,
        };
    });

    unreadTotal.value = chats.value.reduce((total, chat) => {
        return total + normalizeUnreadCount(chat);
    }, 0);
}

function handleChatEvent(event) {
    const detail = event?.detail || {};
    const type = String(detail?.type || "").trim();
    const chatId = getEventChatId(detail);

    if (
        type === "read" ||
        type === "chat-read" ||
        type === "group-read" ||
        detail?.read === true
    ) {
        markLocalChatRead(chatId);
        requestUnreadRefresh(80);
        return;
    }

    requestUnreadRefresh(80);
}

function registerWindowEvents() {
    window.addEventListener("chatUpdated", handleChatEvent);
    window.addEventListener("chatRead", handleChatEvent);
    window.addEventListener("groupRead", handleChatEvent);
    window.addEventListener("messageCreated", handleChatEvent);
    window.addEventListener("messageSent", handleChatEvent);
    window.addEventListener("messageRead", handleChatEvent);
    window.addEventListener("refreshChatUnread", handleChatEvent);
}

function unregisterWindowEvents() {
    window.removeEventListener("chatUpdated", handleChatEvent);
    window.removeEventListener("chatRead", handleChatEvent);
    window.removeEventListener("groupRead", handleChatEvent);
    window.removeEventListener("messageCreated", handleChatEvent);
    window.removeEventListener("messageSent", handleChatEvent);
    window.removeEventListener("messageRead", handleChatEvent);
    window.removeEventListener("refreshChatUnread", handleChatEvent);
}

function registerEchoEvents() {
    if (!window.Echo || !userId.value) return;
    if (echoUserId === userId.value) return;

    leaveEchoEvents();
    echoUserId = userId.value;

    try {
        const refresh = () => requestUnreadRefresh(80);

        window.Echo.private(`users.${echoUserId}`)
            .listen(".message.created", refresh)
            .listen("MessageCreated", refresh)
            .listen(".message.sent", refresh)
            .listen("MessageSent", refresh)
            .listen(".message.read", refresh)
            .listen("MessageRead", refresh)
            .listen(".chat.updated", refresh)
            .listen("ChatUpdated", refresh);

        window.Echo.private(`user.${echoUserId}`)
            .listen(".message.created", refresh)
            .listen("MessageCreated", refresh)
            .listen(".message.read", refresh)
            .listen("MessageRead", refresh);
    } catch (error) {
        console.warn("Echo sidebar listener error:", error?.message || error);
        echoUserId = null;
    }
}

function leaveEchoEvents() {
    if (!window.Echo || !echoUserId) return;

    try {
        window.Echo.leave(`private-users.${echoUserId}`);
        window.Echo.leave(`users.${echoUserId}`);
        window.Echo.leave(`private-user.${echoUserId}`);
        window.Echo.leave(`user.${echoUserId}`);
    } catch (error) {
        console.warn("Echo sidebar leave error:", error?.message || error);
    } finally {
        echoUserId = null;
    }
}

function startPolling() {
    stopPolling();

    pollingTimer = setInterval(() => {
        if (document.hidden) return;
        getChatsUnreadCount();
    }, 7000);
}

function stopPolling() {
    if (pollingTimer) {
        clearInterval(pollingTimer);
        pollingTimer = null;
    }
}

function hasRoute(name) {
    const routeName = String(name || "").trim();
    return !!routeName && router.hasRoute(routeName);
}

function iconClass(icon) {
    return [
        "nav-icon",
        String(icon || "fas fa-circle").trim() || "fas fa-circle",
    ];
}

function onUserImageError(event) {
    if (event?.target) event.target.src = emptyPhoto;
}

function makePermissionI18nKey(title) {
    const map = {
        Dashboard: "dashboard.label",
        Profile: "profile",
        Library: "library",
        Search: "search",
        Chats: "chats",
        "Books List": "items",
        "Post Books": "permissions.items.author",
        "Users Permissions": "permissions.users.permissions",
        Categories: "categories",
        Users: "users",
        Backups: "backups",
        Tag: "tags",
    };

    return map[String(title || "").trim()] || "";
}

function permissionLabel(permission) {
    if (!permission || typeof permission !== "object") return "";

    const explicitKey = String(permission.i18n_key || "").trim();
    if (explicitKey && te(explicitKey)) return t(explicitKey);

    const routeMap = {
        dashboard: "dashboard.label",
        profile: "profile",
        "library.book": "library",
        "search.book": "search",
        "list.chats": "chats",
        "items.author": "permissions.items.author",
        items: "items",
        categories: "categories",
        tags: "tags",
        users: "users",
        "users.permissions": "permissions.users.permissions",
        backups: "backups",
    };

    const routeKey = routeMap[String(permission.route_name || "").trim()] || "";
    if (routeKey && te(routeKey)) return t(routeKey);

    const generatedKey = makePermissionI18nKey(permission.title);
    if (generatedKey && te(generatedKey)) return t(generatedKey);

    return String(permission.title || "").trim();
}

async function getPermissions() {
    try {
        const axiosInstance = window.axios;
        if (!axiosInstance) {
            permissions.value = [];
            return;
        }

        const params = {};
        if (userId.value > 0) params.user_id = userId.value;

        const { data } = await axiosInstance.get(`${API_BASE}/api/permissions`, {
            params,
        });

        permissions.value = Array.isArray(data)
            ? data
            : Array.isArray(data?.data)
                ? data.data
                : [];
    } catch (error) {
        console.error(
            "Failed to load permissions:",
            error?.response?.data || error?.message || error
        );

        permissions.value = [];
    }
}

watch(
    userId,
    async (id) => {
        if (!id) return;

        await nextTick();

        getPermissions();
        getChatsUnreadCount();
        registerEchoEvents();
        startPolling();
    },
    { immediate: true }
);

onMounted(() => {
    registerWindowEvents();
    requestUnreadRefresh(100);
});

onBeforeUnmount(() => {
    clearTimeout(unreadRefreshTimer);
    stopPolling();
    unregisterWindowEvents();
    leaveEchoEvents();
});
</script>

<style scoped>
.main-sidebar {
    background-color: #1f2d3d;
}

.brand-link {
    background-color: #1a252f;
}

.sidebar {
    background-color: #2c3b4e;
    color: #fff;
}

.profile-link {
    text-decoration: none;
}

.user-panel {
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.user-panel .image img {
    width: 34px;
    height: 34px;
    object-fit: cover;
}

.nav-sidebar .nav-link {
    display: flex;
    align-items: center;
    gap: 0.35rem;
    cursor: pointer;
    transition:
        background-color 0.18s ease,
        color 0.18s ease;
}

.nav-sidebar .nav-link:hover {
    background-color: rgba(255, 255, 255, 0.08);
}

.nav-sidebar .nav-link.active {
    background-color: #007bff;
    color: #fff;
}

.nav-sidebar .nav-icon {
    width: 1.6rem;
    text-align: center;
}

.menu-text {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 0;
}

.badge.right {
    margin-left: auto;
    min-width: 22px;
    text-align: center;
}
</style>
