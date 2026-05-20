<template>
    <div class="content-wrapper chat-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2 align-items-center">
                    <div class="col-sm-6">
                        <h1 class="m-0 page-title">
                            {{ $t("chat-page.title") }}
                        </h1>
                    </div>

                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right mb-0">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">
                                    {{ $t("chat-page.home") }}
                                </router-link>
                            </li>
                            <li class="breadcrumb-item active">
                                {{ $t("chat-page.chats") }}
                            </li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="card chat-card">
                    <div class="chat-topbar">
                        <div class="chat-search">
                            <i class="fas fa-search chat-search__icon"></i>

                            <input
                                v-model="searchQuery"
                                class="chat-search__input"
                                type="search"
                                :placeholder="$t('chat-page.search_placeholder')"
                                :aria-label="$t('chat-page.search')"
                            />

                            <button
                                v-if="searchQuery"
                                type="button"
                                class="chat-search__clear"
                                :aria-label="$t('chat-page.clear')"
                                @click="clearSearchQuery"
                            >
                                <i class="fas fa-times"></i>
                            </button>
                        </div>

                        <button
                            v-if="!searchQuery"
                            type="button"
                            class="btn chat-new-btn"
                            @click="chatModal?.openChatModal()"
                        >
                            <i class="fas fa-pen"></i>
                            <span>{{ $t("chat-page.new_group") }}</span>
                        </button>
                    </div>

                    <div ref="listBox" class="chat-list">
                        <ul
                            v-if="searchQuery"
                            class="nav nav-pills nav-sidebar flex-column chat-ul"
                            role="menu"
                        >
                            <li class="nav-header chat-header">
                                <span class="chat-header__label">
                                    {{ $t("chat-page.results") }}
                                </span>
                            </li>

                            <li
                                v-for="user in filteredUsers"
                                :key="`u-${user.id}`"
                                class="nav-item"
                                @click="clearSearchQuery"
                            >
                                <UserOption :user="user" />
                            </li>

                            <li
                                v-for="chat in sortedFilteredChats"
                                :key="`c-${chat.id}`"
                                class="nav-item"
                                @click="clearSearchQuery"
                            >
                                <ChatOption :chat="chat" />
                            </li>

                            <li v-if="isLoadingMoreSearch" class="chat-state">
                                <span class="chat-spinner"></span>
                                <span>{{ $t("chat-page.loading") }}</span>
                            </li>

                            <li
                                v-if="!isLoadingMoreSearch && filteredUsers.length === 0 && sortedFilteredChats.length === 0"
                                class="chat-state chat-empty"
                            >
                                <i class="fas fa-search chat-empty__icon"></i>
                                <span>
                                    {{ $t("chat-page.no_results_for") }} "{{ searchQuery }}"
                                </span>
                            </li>
                        </ul>

                        <ul
                            v-else
                            class="nav nav-pills nav-sidebar flex-column chat-ul"
                            role="menu"
                        >
                            <li class="nav-header chat-header">
                                <span class="chat-header__label">
                                    {{ $t("chat-page.recent") }}
                                </span>
                            </li>

                            <li
                                v-for="chat in sortedRecentChats"
                                :key="`r-${chat.id}`"
                                class="nav-item"
                                @click="clearSearchQuery"
                            >
                                <ChatOption :chat="chat" />
                            </li>

                            <li v-if="isLoadingMore" class="chat-state">
                                <span class="chat-spinner"></span>
                                <span>{{ $t("chat-page.loading") }}</span>
                            </li>

                            <li
                                v-if="!isLoadingMore && sortedRecentChats.length === 0"
                                class="chat-state chat-empty"
                            >
                                <i class="fas fa-comments chat-empty__icon"></i>
                                <span>{{ $t("chat-page.no_conversations") }}</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <ChatModal ref="chatModal" />
</template>


<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "vuex";
import { useI18n } from "vue-i18n";

import emptyPhoto from "@assets/images/emptyuser.png";
import { MessageModal } from "@func/swal";
import { apiGetChatFile, apiGetChats } from "@func/api/chat";
import { apiGetUsers } from "@func/api/user";

import ChatOption from "@com/includes/controls/ChatOption.vue";
import UserOption from "@com/includes/controls/UserOption.vue";
import ChatModal from "@com/includes/controls/ChatModal.vue";

const router = useRouter();
const route = useRoute();
const store = useStore();
const { t } = useI18n();

const userData = computed(() => store.state.user);

const listBox = ref(null);
const chatModal = ref(null);

const searchQuery = ref("");
const filteredChats = ref([]);
const filteredUsers = ref([]);

const recentChats = ref([]);
const chatMeta = ref(null);

const filteredChatMeta = ref(null);
const filteredUserMeta = ref(null);

const isLoadingMore = ref(false);
const isLoadingMoreSearch = ref(false);

let searchTimeout = null;

const DARK_KEY = "dark-mode";

function readDarkFromStorage() {
    const value = localStorage.getItem(DARK_KEY);
    return value === "true" || value === "1";
}

function applyDarkClass(enabled) {
    document.body.classList.toggle("dark-mode", !!enabled);
}

function syncThemeFromStorage() {
    applyDarkClass(readDarkFromStorage());
}

const onStorage = (event) => {
    if (event.key === DARK_KEY) {
        syncThemeFromStorage();
    }
};

const onThemeChanged = () => {
    syncThemeFromStorage();
};

const sortedRecentChats = computed(() => {
    return [...recentChats.value].sort((a, b) => {
        const timeA = a.last_message?.created_at;
        const timeB = b.last_message?.created_at;
        return new Date(timeB || 0) - new Date(timeA || 0);
    });
});

const sortedFilteredChats = computed(() => {
    return [...filteredChats.value].sort((a, b) => {
        const timeA = a.last_message?.created_at;
        const timeB = b.last_message?.created_at;
        return new Date(timeB || 0) - new Date(timeA || 0);
    });
});

onMounted(async () => {
    syncThemeFromStorage();

    window.addEventListener("storage", onStorage);
    window.addEventListener("theme-changed", onThemeChanged);
    window.addEventListener("chatCreated", onChatCreated);
    window.addEventListener("chatUpdated", onChatUpdated);
    window.addEventListener("chatDeleted", onChatDeleted);

    if (userData.value?.id) {
        subscribeToChatChannel(userData.value.id);
    }

    try {
        const response = await apiGetChats();

        recentChats.value = response.data.chats || [];
        chatMeta.value = response.data.meta || null;

        await processChatImages(recentChats.value);
    } catch (error) {
        showError(error);
    }
});

onBeforeUnmount(() => {
    if (searchTimeout) {
        clearTimeout(searchTimeout);
    }

    window.removeEventListener("storage", onStorage);
    window.removeEventListener("theme-changed", onThemeChanged);
    window.removeEventListener("chatCreated", onChatCreated);
    window.removeEventListener("chatUpdated", onChatUpdated);
    window.removeEventListener("chatDeleted", onChatDeleted);

    if (userData.value?.id && window.Echo) {
        window.Echo.leave(`ChatEvent.${userData.value.id}`);
    }
});

watch(
    () => userData.value?.id,
    (newId, oldId) => {
        if (newId && newId !== oldId) {
            if (oldId && window.Echo) {
                window.Echo.leave(`ChatEvent.${oldId}`);
            }

            subscribeToChatChannel(newId);
        }
    }
);

watch(searchQuery, (newQuery) => {
    if (searchTimeout) {
        clearTimeout(searchTimeout);
    }

    if (!newQuery.trim()) {
        filteredChats.value = [];
        filteredUsers.value = [];
        filteredChatMeta.value = null;
        filteredUserMeta.value = null;
        return;
    }

    searchTimeout = setTimeout(async () => {
        try {
            const [chatsRes, usersRes] = await Promise.all([
                apiGetChats({ search: newQuery }),
                apiGetUsers({ search: newQuery }),
            ]);

            filteredChats.value = chatsRes.data.chats || [];
            filteredUsers.value = usersRes.data.users || [];
            filteredChatMeta.value = chatsRes.data.meta || null;
            filteredUserMeta.value = usersRes.data.meta || null;

            await processChatImages(filteredChats.value);
        } catch (error) {
            showError(error);
        }
    }, 500);
});

function showError(error) {
    MessageModal(
        "error",
        t("chat-page.error_title"),
        error?.response?.data?.message || error?.message || t("chat-page.error_message")
    );
}

async function loadMoreChats() {
    if (isLoadingMore.value || !chatMeta.value) return;
    if (chatMeta.value.current_page >= chatMeta.value.last_page) return;

    isLoadingMore.value = true;

    try {
        const nextPage = chatMeta.value.current_page + 1;
        const response = await apiGetChats({ page: nextPage });

        const newChats = response.data.chats || [];
        chatMeta.value = response.data.meta || chatMeta.value;

        await processChatImages(newChats);
        recentChats.value = [...recentChats.value, ...newChats];
    } catch (error) {
        showError(error);
    } finally {
        isLoadingMore.value = false;
    }
}

async function loadMoreSearchResults() {
    if (isLoadingMoreSearch.value) return;

    const canLoadMoreChats =
        filteredChatMeta.value &&
        filteredChatMeta.value.current_page < filteredChatMeta.value.last_page;

    const canLoadMoreUsers =
        filteredUserMeta.value &&
        filteredUserMeta.value.current_page < filteredUserMeta.value.last_page;

    if (!canLoadMoreChats && !canLoadMoreUsers) return;

    isLoadingMoreSearch.value = true;

    try {
        const requests = [
            canLoadMoreChats
                ? apiGetChats({
                    search: searchQuery.value,
                    page: filteredChatMeta.value.current_page + 1,
                })
                : Promise.resolve(null),

            canLoadMoreUsers
                ? apiGetUsers({
                    search: searchQuery.value,
                    page: filteredUserMeta.value.current_page + 1,
                })
                : Promise.resolve(null),
        ];

        const [chatsRes, usersRes] = await Promise.all(requests);

        if (chatsRes) {
            const newChats = chatsRes.data.chats || [];
            filteredChatMeta.value = chatsRes.data.meta || filteredChatMeta.value;

            await processChatImages(newChats);

            filteredChats.value = [...filteredChats.value, ...newChats];
        }

        if (usersRes) {
            const newUsers = usersRes.data.users || [];
            filteredUserMeta.value = usersRes.data.meta || filteredUserMeta.value;

            filteredUsers.value = [...filteredUsers.value, ...newUsers];
        }
    } catch (error) {
        showError(error);
    } finally {
        isLoadingMoreSearch.value = false;
    }
}

function clearSearchQuery() {
    searchQuery.value = "";
}

async function processChatImages(chats) {
    await Promise.all(
        (chats || []).map(async (chat) => {
            if (!chat.photo) {
                chat.photo = emptyPhoto;
                return;
            }

            if (chat.type === "group") {
                chat.photo = await loadChatImage(chat.photo);
            }
        })
    );
}

async function loadChatImage(uri) {
    try {
        const response = await apiGetChatFile(uri);
        return URL.createObjectURL(response.data);
    } catch {
        return emptyPhoto;
    }
}

function subscribeToChatChannel(userId) {
    if (!window.Echo) return;

    window.Echo.private(`ChatEvent.${userId}`)
        .listen(".ChatCreated", async (event) => {
            const chat = event.chat;

            await processChatImages([chat]);

            recentChats.value.unshift(chat);
        })
        .listen(".ChatUpdated", async (event) => {
            const chat = event.chat;

            await processChatImages([chat]);

            const exists = recentChats.value.some((item) => item.id === chat.id);

            if (exists) {
                recentChats.value = recentChats.value.map((item) =>
                    item.id === chat.id ? chat : item
                );
            } else {
                recentChats.value.unshift(chat);
            }
        })
        .listen(".ChatDeleted", (event) => {
            const id = event.chatId;

            recentChats.value = recentChats.value.filter((item) => item.id !== id);

            if (route.name === "chats" && route.params.chatId == id) {
                router.push({ name: "dashboard" });
            }
        });
}

async function onChatCreated(event) {
    const chat = event.detail;

    await processChatImages([chat]);

    recentChats.value.unshift(chat);
}

async function onChatUpdated(event) {
    const chat = event.detail;

    await processChatImages([chat]);

    const exists = recentChats.value.some((item) => item.id === chat.id);

    if (exists) {
        recentChats.value = recentChats.value.map((item) =>
            item.id === chat.id ? chat : item
        );
    } else {
        recentChats.value.unshift(chat);
    }
}

function onChatDeleted(event) {
    const id = event.detail;

    recentChats.value = recentChats.value.filter((item) => item.id !== id);
}
</script>

<style scoped>
.chat-page {
    --bg: #f0f2f5;
    --surface: #ffffff;
    --surface-2: #f7f8fa;
    --surface-3: #eef0f3;

    --border: rgba(0, 0, 0, 0.07);
    --divider: rgba(0, 0, 0, 0.05);

    --text-1: #0d0f12;
    --text-2: #4b5260;
    --text-3: #8e97a6;

    --accent: #3b6ef8;
    --accent-bg: rgba(59, 110, 248, 0.08);

    --hover: rgba(0, 0, 0, 0.03);
    --active: rgba(0, 0, 0, 0.06);

    --radius-card: 20px;
    --radius-input: 14px;
    --radius-btn: 12px;

    --shadow-card: 0 2px 16px rgba(0, 0, 0, 0.07), 0 0 0 1px rgba(0, 0, 0, 0.05);
    --shadow-topbar: 0 1px 0 var(--divider);

    min-height: 100%;
    background: var(--bg);
    color: var(--text-1);
    padding-bottom: 1rem;
}

.page-title {
    color: var(--text-1);
    font-size: 22px;
    font-weight: 800;
    letter-spacing: -0.3px;
}

.breadcrumb {
    background: transparent;
    font-size: 13px;
    color: var(--text-3);
}

.breadcrumb a {
    color: var(--accent);
    text-decoration: none;
}

.breadcrumb-item.active {
    color: var(--text-3);
}

.chat-card {
    overflow: hidden;
    border: none;
    border-radius: var(--radius-card);
    background: var(--surface);
    box-shadow: var(--shadow-card);
}

.chat-topbar {
    position: sticky;
    top: 0;
    z-index: 10;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 16px 18px;
    background: var(--surface);
    box-shadow: var(--shadow-topbar);
}

.chat-search {
    position: relative;
    display: flex;
    flex: 1;
    align-items: center;
}

.chat-search__icon {
    position: absolute;
    left: 16px;
    z-index: 1;
    font-size: 13px;
    color: var(--text-3);
    pointer-events: none;
}

.chat-search__input {
    width: 100%;
    height: 44px;
    padding: 0 44px 0 42px;
    border: 1.5px solid var(--border);
    border-radius: var(--radius-input);
    outline: none;
    background: var(--surface-2);
    color: var(--text-1);
    font-size: 14px;
    transition: border-color 0.18s, background 0.18s, box-shadow 0.18s;
    appearance: none;
    -webkit-appearance: none;
}

.chat-search__input::placeholder {
    color: var(--text-3);
}

.chat-search__input:focus {
    border-color: var(--accent);
    background: var(--surface);
    box-shadow: 0 0 0 3px var(--accent-bg);
}

.chat-search__input::-webkit-search-cancel-button {
    -webkit-appearance: none;
}

.chat-search__clear {
    position: absolute;
    right: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    border: none;
    border-radius: 8px;
    background: var(--surface-3);
    color: var(--text-2);
    font-size: 11px;
    cursor: pointer;
    transition: background 0.15s, color 0.15s;
}

.chat-search__clear:hover {
    background: var(--active);
    color: var(--text-1);
}

.chat-new-btn {
    display: flex;
    align-items: center;
    gap: 7px;
    height: 44px;
    padding: 0 16px;
    border: none;
    border-radius: var(--radius-btn);
    background: var(--accent);
    color: #fff;
    font-size: 13.5px;
    font-weight: 700;
    white-space: nowrap;
    box-shadow: 0 2px 12px rgba(59, 110, 248, 0.35);
    transition: opacity 0.15s, transform 0.12s;
}

.chat-new-btn:hover {
    opacity: 0.92;
    transform: translateY(-1px);
    color: #fff;
}

.chat-new-btn:active {
    transform: translateY(0);
    opacity: 1;
}

.chat-new-btn .fa-pen {
    font-size: 12px;
    opacity: 0.9;
}

.chat-list {
    overflow-y: auto;
    max-height: calc(100vh - 230px);
    background: var(--surface);
}

.chat-ul {
    margin: 0;
    padding-left: 0;
    list-style: none;
}

.chat-ul > .nav-item {
    margin: 0;
}

.chat-header {
    display: flex !important;
    align-items: center;
    padding: 18px 16px 8px !important;
    background: transparent !important;
}

.chat-header__label {
    color: var(--text-3);
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.14em;
    text-transform: uppercase;
}

.chat-state {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 24px 20px;
    color: var(--text-3);
    font-size: 13.5px;
    text-align: center;
    list-style: none;
}

.chat-empty {
    flex-direction: column;
    gap: 10px;
    padding: 40px 20px;
}

.chat-empty__icon {
    font-size: 28px;
    color: var(--surface-3);
}

.chat-spinner {
    display: inline-block;
    width: 16px;
    height: 16px;
    border: 2px solid var(--surface-3);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

@media (max-width: 767.98px) {
    .chat-topbar {
        padding: 14px;
    }

    .chat-new-btn {
        padding: 0 14px;
    }

    .page-title {
        font-size: 20px;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.chat-page,
html.dark-mode .content-wrapper.chat-page,
.dark-mode .content-wrapper.chat-page {
    background: #11141a !important;
}

body.dark-mode .chat-page,
html.dark-mode .chat-page,
.dark-mode .chat-page {
    --bg: #11141a;
    --surface: #191d26;
    --surface-2: #1e2330;
    --surface-3: #242838;

    --border: rgba(255, 255, 255, 0.08);
    --divider: rgba(255, 255, 255, 0.06);

    --text-1: #eef0f4;
    --text-2: #a0a9bc;
    --text-3: #6b7386;

    --accent: #4d80ff;
    --accent-bg: rgba(77, 128, 255, 0.12);

    --hover: rgba(255, 255, 255, 0.045);
    --active: rgba(255, 255, 255, 0.085);

    --shadow-card: 0 2px 24px rgba(0, 0, 0, 0.45), 0 0 0 1px rgba(255, 255, 255, 0.06);
}

body.dark-mode .chat-page .page-title,
html.dark-mode .chat-page .page-title,
.dark-mode .chat-page .page-title {
    color: var(--text-1) !important;
}

body.dark-mode .chat-page .breadcrumb,
body.dark-mode .chat-page .breadcrumb-item.active,
html.dark-mode .chat-page .breadcrumb,
html.dark-mode .chat-page .breadcrumb-item.active,
.dark-mode .chat-page .breadcrumb,
.dark-mode .chat-page .breadcrumb-item.active {
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .breadcrumb a,
html.dark-mode .chat-page .breadcrumb a,
.dark-mode .chat-page .breadcrumb a {
    color: var(--accent) !important;
}

body.dark-mode .chat-page .chat-card,
body.dark-mode .chat-page .card,
html.dark-mode .chat-page .chat-card,
html.dark-mode .chat-page .card,
.dark-mode .chat-page .chat-card,
.dark-mode .chat-page .card {
    background: var(--surface) !important;
    box-shadow: var(--shadow-card) !important;
    border: none !important;
}

body.dark-mode .chat-page .chat-topbar,
html.dark-mode .chat-page .chat-topbar,
.dark-mode .chat-page .chat-topbar,
body.dark-mode .chat-page .chat-list,
html.dark-mode .chat-page .chat-list,
.dark-mode .chat-page .chat-list {
    background: var(--surface) !important;
}

body.dark-mode .chat-page .chat-search__input,
html.dark-mode .chat-page .chat-search__input,
.dark-mode .chat-page .chat-search__input {
    background: var(--surface-2) !important;
    color: var(--text-1) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-page .chat-search__input:focus,
html.dark-mode .chat-page .chat-search__input:focus,
.dark-mode .chat-page .chat-search__input:focus {
    background: var(--surface) !important;
    color: var(--text-1) !important;
    border-color: var(--accent) !important;
    box-shadow: 0 0 0 3px var(--accent-bg) !important;
}

body.dark-mode .chat-page .chat-search__input::placeholder,
html.dark-mode .chat-page .chat-search__input::placeholder,
.dark-mode .chat-page .chat-search__input::placeholder {
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .chat-search__icon,
html.dark-mode .chat-page .chat-search__icon,
.dark-mode .chat-page .chat-search__icon {
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .chat-search__clear,
html.dark-mode .chat-page .chat-search__clear,
.dark-mode .chat-page .chat-search__clear {
    background: var(--surface-3) !important;
    color: var(--text-2) !important;
}

body.dark-mode .chat-page .chat-search__clear:hover,
html.dark-mode .chat-page .chat-search__clear:hover,
.dark-mode .chat-page .chat-search__clear:hover {
    background: var(--active) !important;
    color: var(--text-1) !important;
}

body.dark-mode .chat-page .nav-header.chat-header,
html.dark-mode .chat-page .nav-header.chat-header,
.dark-mode .chat-page .nav-header.chat-header {
    background: transparent !important;
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .chat-header__label,
html.dark-mode .chat-page .chat-header__label,
.dark-mode .chat-page .chat-header__label {
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .chat-state,
html.dark-mode .chat-page .chat-state,
.dark-mode .chat-page .chat-state {
    color: var(--text-3) !important;
}

body.dark-mode .chat-page .chat-empty__icon,
html.dark-mode .chat-page .chat-empty__icon,
.dark-mode .chat-page .chat-empty__icon {
    color: var(--surface-3) !important;
}
</style>
