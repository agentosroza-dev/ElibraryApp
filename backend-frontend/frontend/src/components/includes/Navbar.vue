<template>
    <nav class="main-header navbar navbar-expand navbar-light custom-navbar">
        <!-- Left -->
        <ul class="navbar-nav">
            <li class="nav-item">
                <a class="nav-link toggle-btn" data-widget="pushmenu" href="#" role="button">
                    <i class="fas fa-bars"></i>
                </a>
            </li>
        </ul>


        <!-- Right -->
        <ul class="navbar-nav ml-auto align-items-center">
            <!-- Fullscreen -->
            <li class="nav-item">
                <a class="nav-link nav-btn nav-action" data-widget="fullscreen" href="#" role="button">
                    <i class="fas fa-expand-arrows-alt mr-1"></i>
                    <span class="d-none d-md-inline">{{ $t("navbar-fullscreen") }}</span>
                </a>
            </li>

            <!-- Dark Mode -->
            <li class="nav-item mx-3">
                <div class="custom-control custom-switch custom-switch-lg">
                    <input
                        id="darkSwitch"
                        v-model="darkModel"
                        type="checkbox"
                        class="custom-control-input"
                    />
                    <label class="custom-control-label theme-label" for="darkSwitch">
                        <i class="fas mr-1" :class="isDark ? 'fa-moon' : 'fa-sun'"></i>
                        <span class="d-none d-md-inline">
                            {{ isDark ? $t("navbar-dark") : $t("navbar-light") }}
                        </span>
                    </label>
                </div>
            </li>

            <!-- Language Switch -->
            <li class="nav-item mx-3">
                <div class="d-flex align-items-center">
                    <span :class="flagIcon" class="mr-2"></span>

                    <div class="custom-control custom-switch">
                        <input
                            id="langSwitch"
                            v-model="langModel"
                            type="checkbox"
                            class="custom-control-input"
                        />
                        <label class="custom-control-label" for="langSwitch"></label>
                    </div>
                </div>
            </li>

            <!-- Notifications -->
            <li class="nav-item dropdown notification-dropdown">
                <a
                    class="nav-link notification-toggle"
                    data-toggle="dropdown"
                    href="#"
                    role="button"
                    @click.prevent="loadNotifications"
                >
                    <i class="far fa-bell"></i>

                    <span
                        v-if="unreadCount > 0"
                        class="badge badge-danger navbar-badge notification-badge"
                    >
                        {{ unreadCount > 99 ? "99+" : unreadCount }}
                    </span>
                </a>

                <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right notification-menu">
                    <div class="notification-header">
                        <div>
                            <strong>{{ unreadCount }} Notifications</strong>
                            <small>Book activities</small>
                        </div>

                        <button
                            type="button"
                            class="btn btn-sm btn-light refresh-btn"
                            :disabled="loading"
                            @click.stop="loadNotifications"
                        >
                            <i class="fas fa-sync-alt" :class="{ 'fa-spin': loading }"></i>
                        </button>
                    </div>

                    <div class="dropdown-divider"></div>

                    <div class="notification-actions">
                        <button
                            type="button"
                            class="btn btn-sm btn-outline-primary"
                            :disabled="!notifications.length || loading"
                            @click.stop="markAllRead"
                        >
                            <i class="fas fa-check-double mr-1"></i>
                            All Read
                        </button>

                        <button
                            type="button"
                            class="btn btn-sm btn-outline-danger"
                            :disabled="!notifications.length || loading"
                            @click.stop="clearAll"
                        >
                            <i class="fas fa-trash-alt mr-1"></i>
                            Clear
                        </button>
                    </div>

                    <div class="dropdown-divider"></div>

                    <div v-if="loading" class="notification-empty">
                        <i class="fas fa-spinner fa-spin"></i>
                        <span>Loading notifications...</span>
                    </div>

                    <div v-else-if="!notifications.length" class="notification-empty">
                        <i class="far fa-bell-slash"></i>
                        <span>No notifications</span>
                    </div>

                    <div v-else class="notification-list">
                        <router-link
                            v-for="item in notifications"
                            :key="item.id"
                            class="dropdown-item notification-item"
                            :class="{ unread: !item.read_at }"
                            :to="notificationRoute(item)"
                            @mouseover="markAsRead(item)"
                            @click="handleNotificationClick(item)"
                        >
                            <div class="notification-icon" :class="iconClass(item.type)">
                                <i :class="iconName(item.type)"></i>
                            </div>

                            <div class="notification-content">
                                <div class="notification-title">
                                    {{ item.title }}
                                    <span v-if="!item.read_at" class="unread-dot"></span>
                                </div>

                                <div class="notification-message">
                                    {{ item.message }}
                                </div>

                                <div class="notification-time">
                                    {{ formatDate(item.created_at) }}
                                </div>
                            </div>
                        </router-link>
                    </div>
                </div>
            </li>

            <!-- Sign Out -->
            <li class="nav-item">
                <router-link :to="{ name: 'auth.signout' }" class="nav-link nav-btn nav-logout">
                    <i class="fas fa-sign-out-alt mr-1"></i>
                    <span class="d-none d-md-inline">{{ $t("navbar-signout") }}</span>
                </router-link>
            </li>
        </ul>
    </nav>
</template>

<script setup>
import axios from "axios";
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useI18n } from "vue-i18n";
import { getCurrentLocale, getLocales, setCurrentLocale } from "@/lang/index.js";
import {
    apiClearAllNotifications,
    apiGetNotifications,
    apiMarkAllNotificationsRead,
    apiMarkNotificationRead,
} from "@func/api/notification";

/* ----------------------------- Dark Mode ----------------------------- */
const DARK_KEY = "dark-mode";
const isDark = ref(false);

function applyDark(value) {
    document.body.classList.toggle("dark-mode", !!value);
}

function readDark() {
    const value = localStorage.getItem(DARK_KEY);
    return value === "true" || value === "1";
}

function writeDark(value) {
    localStorage.setItem(DARK_KEY, value ? "true" : "false");
}

function syncDark() {
    const value = readDark();
    isDark.value = value;
    applyDark(value);
}

const darkModel = computed({
    get: () => isDark.value,
    set: (value) => {
        isDark.value = !!value;
        writeDark(isDark.value);
        applyDark(isDark.value);
        window.dispatchEvent(new Event("theme-changed"));
    },
});

function onStorage(e) {
    if (e.key === DARK_KEY) syncDark();
}

function onThemeChanged() {
    syncDark();
}

/* --------------------------- Language Switch -------------------------- */
const DEFAULT_LOCALE = "km";
const { locale: i18nLocale } = useI18n();

const locales = ref(getLocales());
const currentLocale = ref(getCurrentLocale());

const kmLocale = computed(() => {
    return locales.value.find((item) => item.prefix === "km") || locales.value[0];
});

const enLocale = computed(() => {
    return locales.value.find((item) => item.prefix === "en") || locales.value[1] || locales.value[0];
});

function applyLocale(newLocale) {
    if (!newLocale) return;

    setCurrentLocale(newLocale);
    currentLocale.value = newLocale;
    i18nLocale.value = newLocale.prefix;
    axios.defaults.headers.common.LOCALE = newLocale.prefix;
}

function syncLocale() {
    const savedLocale = getCurrentLocale();

    if (savedLocale?.prefix) {
        applyLocale(savedLocale);
        return;
    }

    applyLocale(kmLocale.value);
}

const langModel = computed({
    get: () => i18nLocale.value === "en",
    set: (checked) => {
        applyLocale(checked ? enLocale.value : kmLocale.value);
    },
});

const flagIcon = computed(() => {
    return i18nLocale.value === "en" ? "fi fi-gb" : "fi fi-kh";
});

watch(
    () => i18nLocale.value,
    (value) => {
        axios.defaults.headers.common.LOCALE = value || DEFAULT_LOCALE;
    },
    { immediate: true }
);

/* ----------------------------- Notifications ----------------------------- */
const notifications = ref([]);
const unreadCount = ref(0);
const loading = ref(false);
const readingIds = ref(new Set());

let notificationTimer = null;

async function loadNotifications() {
    if (loading.value) return;

    loading.value = true;

    try {
        const { data } = await apiGetNotifications();

        notifications.value = Array.isArray(data?.notifications)
            ? data.notifications
            : [];

        unreadCount.value = Number(data?.unread_count || 0);
    } catch (error) {
        console.error("Failed to load notifications:", error);
    } finally {
        loading.value = false;
    }
}

async function markAsRead(item) {
    if (!item?.id || item.read_at || readingIds.value.has(item.id)) return;

    readingIds.value.add(item.id);

    const oldReadAt = item.read_at;
    const oldUnreadCount = unreadCount.value;

    item.read_at = new Date().toISOString();
    unreadCount.value = Math.max(0, unreadCount.value - 1);

    try {
        await apiMarkNotificationRead(item.id);
    } catch (error) {
        item.read_at = oldReadAt;
        unreadCount.value = oldUnreadCount;
        console.error("Failed to mark notification read:", error);
    } finally {
        readingIds.value.delete(item.id);
    }
}

async function handleNotificationClick(item) {
    await markAsRead(item);
}

async function markAllRead() {
    try {
        await apiMarkAllNotificationsRead();

        const now = new Date().toISOString();

        notifications.value = notifications.value.map((item) => ({
            ...item,
            read_at: item.read_at || now,
        }));

        unreadCount.value = 0;
    } catch (error) {
        console.error("Failed to mark all notifications read:", error);
    }
}

async function clearAll() {
    try {
        await apiClearAllNotifications();
        notifications.value = [];
        unreadCount.value = 0;
    } catch (error) {
        console.error("Failed to clear notifications:", error);
    }
}

function iconName(type) {
    if (type === "book_created") return "fas fa-book-medical";
    if (type === "book_updated") return "fas fa-book-reader";
    return "far fa-bell";
}

function iconClass(type) {
    if (type === "book_created") return "created";
    if (type === "book_updated") return "updated";
    return "default";
}

function notificationRoute(item) {
    const id = item?.item_id || item?.item?.id;

    if (!id) {
        return { name: "dashboard" };
    }

    return {
        name: "book.details",
        params: { id },
    };
}

function formatDate(value) {
    if (!value) return "";

    const date = new Date(value);
    const now = new Date();
    const diff = Math.floor((now - date) / 1000);

    if (Number.isNaN(diff)) return "";

    if (diff < 60) return "Just now";
    if (diff < 3600) return `${Math.floor(diff / 60)} mins ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} hours ago`;

    return date.toLocaleDateString();
}

function onNotificationUpdated() {
    loadNotifications();
}

/* ------------------------------ Lifecycle ----------------------------- */
onMounted(() => {
    syncDark();
    syncLocale();
    loadNotifications();

    notificationTimer = window.setInterval(loadNotifications, 30000);

    window.addEventListener("storage", onStorage);
    window.addEventListener("theme-changed", onThemeChanged);
    window.addEventListener("notifications-updated", onNotificationUpdated);
});

onBeforeUnmount(() => {
    if (notificationTimer) {
        window.clearInterval(notificationTimer);
        notificationTimer = null;
    }

    window.removeEventListener("storage", onStorage);
    window.removeEventListener("theme-changed", onThemeChanged);
    window.removeEventListener("notifications-updated", onNotificationUpdated);
});
</script>

<style scoped>
.custom-navbar {
    min-height: 64px;
    border-bottom: 1px solid rgba(15, 23, 42, 0.08);
}

.nav-btn {
    border-radius: 999px;
    transition: all 0.2s ease;
}

.nav-btn:hover {
    background: rgba(13, 110, 253, 0.08);
}

.notification-dropdown {
    position: relative;
}

.notification-toggle {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: relative;
    transition: all 0.2s ease;
}

.notification-toggle:hover {
    background: rgba(13, 110, 253, 0.1);
}

.notification-toggle i {
    font-size: 1.15rem;
}

.notification-badge {
    top: 4px;
    right: 2px;
    font-size: 0.65rem;
    min-width: 18px;
    height: 18px;
    line-height: 18px;
    padding: 0 5px;
    border-radius: 999px;
}

.notification-menu {
    width: 390px;
    max-width: calc(100vw - 24px);
    border: 0;
    border-radius: 18px;
    overflow: hidden;
    box-shadow: 0 18px 50px rgba(15, 23, 42, 0.2);
    padding: 0;
}

.notification-header {
    padding: 16px 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, #f8fbff, #eef5ff);
}

.notification-header strong {
    display: block;
    font-size: 1rem;
    color: #111827;
}

.notification-header small {
    display: block;
    color: #6b7280;
    margin-top: 2px;
}

.refresh-btn {
    width: 34px;
    height: 34px;
    border-radius: 50%;
}

.notification-actions {
    padding: 10px 14px;
    display: flex;
    gap: 8px;
}

.notification-actions .btn {
    flex: 1;
    border-radius: 999px;
}

.notification-list {
    max-height: 390px;
    overflow-y: auto;
}

.notification-item {
    display: flex;
    gap: 12px;
    padding: 14px 16px;
    white-space: normal;
    border-left: 3px solid transparent;
    transition: all 0.2s ease;
}

.notification-item:hover {
    background: #f8fafc;
}

.notification-item.unread {
    background: #f0f7ff;
    border-left-color: #0d6efd;
}

.notification-icon {
    width: 42px;
    height: 42px;
    min-width: 42px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.notification-icon.created {
    background: rgba(25, 135, 84, 0.12);
    color: #198754;
}

.notification-icon.updated {
    background: rgba(13, 110, 253, 0.12);
    color: #0d6efd;
}

.notification-icon.default {
    background: rgba(108, 117, 125, 0.12);
    color: #6c757d;
}

.notification-content {
    min-width: 0;
    flex: 1;
}

.notification-title {
    font-weight: 700;
    color: #111827;
    line-height: 1.25;
    display: flex;
    align-items: center;
    gap: 6px;
}

.unread-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #dc3545;
    display: inline-block;
}

.notification-message {
    margin-top: 3px;
    color: #4b5563;
    font-size: 0.86rem;
    line-height: 1.35;
}

.notification-time {
    margin-top: 5px;
    color: #9ca3af;
    font-size: 0.78rem;
}

.notification-empty {
    padding: 28px 18px;
    text-align: center;
    color: #6b7280;
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
}

.notification-empty i {
    font-size: 1.5rem;
}

/* Dark Mode */
:global(body.dark-mode) .custom-navbar {
    background: #1f2937 !important;
    border-bottom-color: rgba(255, 255, 255, 0.08);
}

:global(body.dark-mode) .notification-menu {
    background: #111827;
    color: #e5e7eb;
}

:global(body.dark-mode) .notification-header {
    background: linear-gradient(135deg, #1f2937, #111827);
}

:global(body.dark-mode) .notification-header strong,
:global(body.dark-mode) .notification-title {
    color: #f9fafb;
}

:global(body.dark-mode) .notification-header small,
:global(body.dark-mode) .notification-message,
:global(body.dark-mode) .notification-empty {
    color: #9ca3af;
}

:global(body.dark-mode) .notification-item:hover {
    background: #1f2937;
}

:global(body.dark-mode) .notification-item.unread {
    background: rgba(13, 110, 253, 0.14);
}

:global(body.dark-mode) .dropdown-divider {
    border-color: rgba(255, 255, 255, 0.08);
}
</style>
