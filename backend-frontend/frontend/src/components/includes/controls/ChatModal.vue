<template>
    <div class="modal fade" :id="id" ref="chatModal" aria-modal="true" role="dialog">
        <div class="modal-dialog modal-lg chat-modal-dialog" role="document">
            <div class="modal-content chat-modal">
                <div class="modal-header chat-modal__header">
                    <div class="d-flex align-items-center">
                        <div class="chat-modal__titleIcon">
                            <i class="fas fa-comments"></i>
                        </div>

                        <div class="ml-2">
                            <h4 class="modal-title mb-0">
                                {{ $t("chat-modal.title") }}
                            </h4>
                            <small class="text-muted d-block">
                                {{ chatId ? "" : $t("chat-modal.create_subtitle") }}
                            </small>
                        </div>
                    </div>

                    <button
                        type="button"
                        class="close chat-close"
                        @click="hideChatModal"
                        :aria-label="$t('chat-modal.close')"
                    >
                        <span aria-hidden="true">×</span>
                    </button>
                </div>

                <div class="modal-body chat-modal__body">
                    <div class="chat-card">
                        <div class="chat-profile">
                            <div class="chat-profile__avatarWrap">
                                <img
                                    class="chat-profile__avatar"
                                    :src="chatData.photo ?? emptyPhoto"
                                    :alt="$t('chat-modal.profile_picture')"
                                />

                                <input
                                    ref="fileInput"
                                    @change="onChangePhoto"
                                    type="file"
                                    class="d-none"
                                    :accept="allowedExtensions.map((ext) => '.' + ext).join(', ')"
                                    :id="'-FILE-INPUT-' + id"
                                />

                                <div v-if="chatData.updatable" class="chat-profile__actions">
                                    <button
                                        type="button"
                                        class="btn btn-primary btn-sm chat-action-btn"
                                        :title="$t('chat-modal.upload')"
                                        @click.prevent.stop="triggerFilePicker"
                                    >
                                        <i class="fas fa-upload"></i>
                                    </button>

                                    <button
                                        type="button"
                                        class="btn btn-danger btn-sm chat-action-btn"
                                        :title="$t('chat-modal.remove')"
                                        @click="onDeletePhoto()"
                                    >
                                        <i class="fas fa-trash"></i>
                                    </button>

                                    <button
                                        type="button"
                                        class="btn btn-secondary btn-sm chat-action-btn"
                                        :title="$t('chat-modal.reset')"
                                        @click="onResetPhoto()"
                                    >
                                        <i class="fas fa-undo-alt"></i>
                                    </button>
                                </div>

                                <div v-if="chatDataErr.photo" class="invalid-feedback d-block mt-1">
                                    {{ chatDataErr.photo }}
                                </div>
                            </div>

                            <div class="chat-profile__meta">
                                <div class="chat-profile__nameRow">
                                    <span
                                        class="badge badge-pill chat-badge"
                                        :class="chatData.type === 'group' ? 'badge-info' : 'badge-secondary'"
                                    >
                                        {{ chatData.type === "group" ? $t("chat-modal.group") : $t("chat-modal.direct") }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="chat-form">
                            <div class="form-group mb-0">
                                <label class="chat-label">
                                    {{ $t("chat-modal.name") }}
                                </label>

                                <input
                                    v-model="chatData.name"
                                    :disabled="!chatData.updatable"
                                    type="text"
                                    class="form-control chat-input"
                                    :class="[
                                        { 'is-invalid': chatDataErr.name },
                                        chatData.type !== 'group' ? 'chat-input--direct' : 'chat-input--group'
                                    ]"
                                    :placeholder="chatData.type === 'group'
                                        ? $t('chat-modal.enter_group_name')
                                        : $t('chat-modal.enter_name')"
                                />

                                <span class="invalid-feedback">{{ chatDataErr.name }}</span>
                            </div>

                            <div v-if="!chatId" class="form-group mb-0">
                                <label class="chat-label">
                                    {{ $t("chat-modal.add_members") }}
                                </label>

                                <div class="input-group mb-2">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text chat-input-icon">
                                            <i class="fas fa-search"></i>
                                        </span>
                                    </div>

                                    <input
                                        v-model="searchQuery"
                                        type="text"
                                        class="form-control chat-input chat-input--withIcon"
                                        :class="{ 'is-invalid': chatDataErr.user_ids }"
                                        :placeholder="$t('chat-modal.search_users')"
                                    />
                                </div>

                                <span v-if="chatDataErr.user_ids" class="invalid-feedback d-block">
                                    {{ chatDataErr.user_ids }}
                                </span>

                                <div v-if="searchQuery && availableUsers.length" class="chat-list">
                                    <button
                                        v-for="user in availableUsers"
                                        :key="user.id"
                                        type="button"
                                        class="chat-list__item"
                                        @click="addMember(user)"
                                    >
                                        <img
                                            :src="user.photo || emptyPhoto"
                                            class="chat-list__avatar"
                                            :alt="$t('chat-modal.user_avatar')"
                                        />

                                        <div class="chat-list__content">
                                            <div class="chat-list__title">{{ user.name }}</div>
                                            <div class="chat-list__sub">{{ user.email }}</div>
                                        </div>

                                        <i class="fas fa-plus chat-list__endIcon"></i>
                                    </button>
                                </div>

                                <div v-if="searchQuery && !availableUsers.length" class="text-muted small">
                                    {{ $t("chat-modal.no_users_found") }}
                                </div>

                                <div v-if="selectedUsers.length" class="mt-3">
                                    <div class="text-muted small mb-2">
                                        {{ $t("chat-modal.selected_members") }}
                                    </div>

                                    <div class="chat-chips">
                                        <span
                                            v-for="member in selectedUsers"
                                            :key="member.id"
                                            class="chat-chip"
                                        >
                                            <img
                                                :src="member.photo || emptyPhoto"
                                                class="chat-chip__avatar"
                                                :alt="$t('chat-modal.user_avatar')"
                                            />

                                            <span class="chat-chip__text">{{ member.name }}</span>

                                            <button
                                                type="button"
                                                class="chat-chip__remove"
                                                @click="removeMember(member.id)"
                                                :title="$t('chat-modal.remove')"
                                            >
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div v-if="chatId && chatData.type === 'group'" class="form-group mb-0">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <label class="chat-label mb-0">
                                        {{ $t("chat-modal.members") }}
                                    </label>

                                    <span class="text-muted small">
                                        {{ chatMembers.length }} {{ $t("chat-modal.members_count") }}
                                    </span>
                                </div>

                                <div v-if="chatData.updatable" class="mb-2">
                                    <div class="input-group mb-2">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text chat-input-icon">
                                                <i class="fas fa-user-plus"></i>
                                            </span>
                                        </div>

                                        <input
                                            v-model="memberSearchQuery"
                                            type="text"
                                            class="form-control chat-input chat-input--withIcon"
                                            :placeholder="$t('chat-modal.search_users_to_add')"
                                        />
                                    </div>

                                    <div v-if="memberSearchQuery && availableMemberUsers.length" class="chat-list">
                                        <button
                                            v-for="user in availableMemberUsers"
                                            :key="user.id"
                                            type="button"
                                            class="chat-list__item"
                                            @click="addChatMember(user)"
                                        >
                                            <img
                                                :src="user.photo || emptyPhoto"
                                                class="chat-list__avatar"
                                                :alt="$t('chat-modal.user_avatar')"
                                            />

                                            <div class="chat-list__content">
                                                <div class="chat-list__title">{{ user.name }}</div>
                                                <div class="chat-list__sub">{{ user.email }}</div>
                                            </div>

                                            <i class="fas fa-plus chat-list__endIcon"></i>
                                        </button>
                                    </div>

                                    <div v-if="memberSearchQuery && !availableMemberUsers.length" class="text-muted small">
                                        {{ $t("chat-modal.no_users_found") }}
                                    </div>
                                </div>

                                <div class="chat-members">
                                    <div v-if="isLoadingMembers" class="chat-members__loading">
                                        <i class="fas fa-spinner fa-spin mr-2"></i>
                                        {{ $t("chat-modal.loading_members") }}
                                    </div>

                                    <div
                                        v-for="member in chatMembers"
                                        :key="member.id"
                                        class="chat-members__row"
                                    >
                                        <div class="chat-members__left">
                                            <img
                                                :src="member.user?.photo || emptyPhoto"
                                                class="chat-members__avatar"
                                                :alt="$t('chat-modal.user_avatar')"
                                            />

                                            <div class="chat-members__info">
                                                <div class="chat-members__name">
                                                    {{ member.user?.name }}

                                                    <span
                                                        v-if="member.role === 'admin'"
                                                        class="badge badge-info ml-2"
                                                    >
                                                        {{ $t("chat-modal.admin") }}
                                                    </span>
                                                </div>

                                                <div class="chat-members__email">
                                                    {{ member.user?.email }}
                                                </div>
                                            </div>
                                        </div>

                                        <button
                                            v-if="chatData.updatable"
                                            type="button"
                                            class="btn btn-outline-danger btn-sm"
                                            @click="removeChatMember(member)"
                                            :title="$t('chat-modal.remove_member')"
                                        >
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>

                                    <div
                                        v-if="!isLoadingMembers && !chatMembers.length"
                                        class="text-muted small text-center py-3"
                                    >
                                        {{ $t("chat-modal.no_other_members") }}
                                    </div>
                                </div>

                                <div
                                    v-if="memberMeta && memberMeta.current_page < memberMeta.last_page"
                                    class="text-center mt-2"
                                >
                                    <button
                                        type="button"
                                        @click="loadMoreMembers"
                                        class="btn btn-sm btn-outline-primary"
                                        :disabled="isLoadingMembers"
                                    >
                                        {{ $t("chat-modal.load_more") }}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div
                    v-if="chatId && chatData.type !== 'group'"
                    class="modal-footer chat-modal__footer justify-content-between"
                >
                    <button type="button" class="btn btn-default" @click="hideChatModal">
                        {{ $t("chat-modal.close") }}
                    </button>

                    <button type="button" class="btn btn-danger" @click="deleteDirectChat">
                        <i class="fas fa-trash mr-1"></i>
                        {{ $t("chat-modal.delete_chat") }}
                    </button>
                </div>

                <div
                    v-else-if="chatId && chatData.type === 'group'"
                    class="modal-footer chat-modal__footer justify-content-between"
                >
                    <button type="button" class="btn btn-default" @click="hideChatModal">
                        {{ $t("chat-modal.close") }}
                    </button>

                    <div class="d-flex flex-wrap chat-footer-actions">
                        <button type="button" class="btn btn-warning" @click="leaveChat">
                            <i class="fas fa-sign-out-alt mr-1"></i>
                            {{ $t("chat-modal.leave") }}
                        </button>

                        <button
                            v-if="chatData.updatable"
                            type="button"
                            class="btn btn-danger"
                            @click="deleteChat"
                        >
                            <i class="fas fa-trash mr-1"></i>
                            {{ $t("chat-modal.delete_group") }}
                        </button>

                        <button
                            v-if="chatData.updatable"
                            type="button"
                            class="btn btn-primary"
                            @click="submitChat"
                        >
                            <i class="fas fa-save mr-1"></i>
                            {{ $t("chat-modal.update") }}
                        </button>
                    </div>
                </div>

                <div
                    v-else-if="!chatId || chatData.updatable"
                    class="modal-footer chat-modal__footer justify-content-between"
                >
                    <button type="button" class="btn btn-default" @click="hideChatModal">
                        {{ $t("chat-modal.close") }}
                    </button>

                    <button type="button" class="btn btn-primary" @click="submitChat">
                        <i class="fas" :class="chatId ? 'fa-save' : 'fa-plus'"></i>
                        <span class="ml-1">
                            {{ chatId ? $t("chat-modal.update_chat") : $t("chat-modal.create_chat") }}
                        </span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>


<script setup>
import emptyPhoto from "@assets/images/emptyuser.png";
import Swal from "sweetalert2";
import axios from "axios";
import { onMounted, reactive, ref, computed, watch } from "vue";
import { useI18n } from "vue-i18n";
import {
    apiCreateChat,
    apiUpdateGroupChat,
    apiDeleteGroupChat,
    apiLeaveGroupChat,
    apiReadChat,
    apiGetChatFile,
} from "@func/api/chat";
import { apiGetMembers, apiAddMember, apiRemoveMember } from "@func/api/chat_member";
import { apiGetUsers } from "@func/api/user";
import { LoadingModal, MessageModal, CloseModal } from "@func/swal";
import { useRouter } from "vue-router";

const router = useRouter();
const { t } = useI18n();

const emit = defineEmits(["chatCreated", "chatUpdated", "chatDeleted"]);

const props = defineProps({
    id: {
        type: String,
        default: () => "chatModal" + Math.random().toString(36).substr(2, 9),
    },
    chatId: {
        type: Number,
        default: null,
    },
});

const chatModal = ref(null);
const fileInput = ref(null);
const tempChatPhoto = ref(null);

const chatData = reactive({
    name: "",
    type: "group",
    photo: null,
    user_ids: [],
    updatable: true,
});

const chatDataErr = reactive({
    name: "",
    photo: "",
    user_ids: "",
});

const defaultChatData = JSON.parse(JSON.stringify(chatData));
const defaultChatDataErr = JSON.parse(JSON.stringify(chatDataErr));

const allowedExtensions = ["jpg", "jpeg", "png"];

function showError(error) {
    return MessageModal(
        "error",
        t("chat-modal.error_title"),
        error?.response?.data?.message || error?.message || t("chat-modal.error_message")
    );
}

async function onChatUpdated(chat) {
    Object.assign(chatData, chat);

    if (chat.type === "group" && chat.photo) {
        try {
            const photoResponse = await apiGetChatFile(chat.photo);
            chatData.photo = URL.createObjectURL(photoResponse.data);
        } catch {
            chatData.photo = null;
        }
    } else {
        chatData.photo = chat.photo;
    }
}

function triggerFilePicker() {
    if (!fileInput.value) return;

    fileInput.value.value = null;
    fileInput.value.click();
}

const searchQuery = ref("");
const filteredUsers = ref([]);
const selectedUsers = ref([]);
let searchTimeout = null;

const availableUsers = computed(() => {
    const selectedIds = selectedUsers.value.map((member) => member.id);
    return filteredUsers.value.filter((user) => !selectedIds.includes(user.id));
});

watch(searchQuery, (newQuery) => {
    if (searchTimeout) clearTimeout(searchTimeout);

    if (!newQuery.trim()) {
        filteredUsers.value = [];
        return;
    }

    searchTimeout = setTimeout(async () => {
        try {
            const response = await apiGetUsers({ search: newQuery });
            filteredUsers.value = response.data.users;
        } catch (error) {
            showError(error);
        }
    }, 450);
});

function addMember(user) {
    if (!selectedUsers.value.find((member) => member.id === user.id)) {
        selectedUsers.value.push(user);
        chatData.user_ids.push(user.id);
    }

    searchQuery.value = "";
    filteredUsers.value = [];
}

function removeMember(userId) {
    selectedUsers.value = selectedUsers.value.filter((member) => member.id !== userId);
    chatData.user_ids = chatData.user_ids.filter((id) => id !== userId);
}

const chatMembers = ref([]);
const memberMeta = ref(null);
const isLoadingMembers = ref(false);

const memberSearchQuery = ref("");
const filteredMemberUsers = ref([]);
let memberSearchTimeout = null;

const availableMemberUsers = computed(() => {
    const existingUserIds = chatMembers.value.map((member) => member.user_id);
    return filteredMemberUsers.value.filter((user) => !existingUserIds.includes(user.id));
});

watch(memberSearchQuery, (newQuery) => {
    if (memberSearchTimeout) clearTimeout(memberSearchTimeout);

    if (!newQuery.trim()) {
        filteredMemberUsers.value = [];
        return;
    }

    memberSearchTimeout = setTimeout(async () => {
        try {
            const response = await apiGetUsers({ search: newQuery });
            filteredMemberUsers.value = response.data.users;
        } catch (error) {
            showError(error);
        }
    }, 450);
});

async function loadMembers() {
    if (!props.chatId) return;

    isLoadingMembers.value = true;

    try {
        const response = await apiGetMembers(props.chatId);
        chatMembers.value = response.data.chat_members;
        memberMeta.value = response.data.meta;
    } catch (error) {
        showError(error);
    } finally {
        isLoadingMembers.value = false;
    }
}

async function loadMoreMembers() {
    if (!memberMeta.value || memberMeta.value.current_page >= memberMeta.value.last_page) return;

    isLoadingMembers.value = true;

    try {
        const nextPage = memberMeta.value.current_page + 1;
        const response = await apiGetMembers(props.chatId, { page: nextPage });

        chatMembers.value = [...chatMembers.value, ...response.data.chat_members];
        memberMeta.value = response.data.meta;
    } catch (error) {
        showError(error);
    } finally {
        isLoadingMembers.value = false;
    }
}

async function addChatMember(user) {
    try {
        LoadingModal();

        const response = await apiAddMember(props.chatId, { user_id: user.id });

        chatMembers.value.push(response.data.chat_member);
        memberSearchQuery.value = "";
        filteredMemberUsers.value = [];

        CloseModal();
    } catch (error) {
        CloseModal();
        showError(error);
    }
}

async function removeChatMember(member) {
    const result = await Swal.fire({
        icon: "warning",
        title: t("chat-modal.remove_member_title"),
        text: t("chat-modal.remove_member_text", {
            name: member.user?.name || t("chat-modal.this_user"),
        }),
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: t("chat-modal.remove_member_confirm"),
        cancelButtonText: t("chat-modal.cancel"),
    });

    if (!result.isConfirmed) return;

    try {
        LoadingModal();

        await apiRemoveMember(props.chatId, member.user_id);

        chatMembers.value = chatMembers.value.filter((item) => item.id !== member.id);

        CloseModal();
    } catch (error) {
        CloseModal();
        showError(error);
    }
}

onMounted(() => {
    $(chatModal.value).on("show.bs.modal", async function () {
        if (!props.chatId) return;

        try {
            LoadingModal();

            await readChat(props.chatId);

            CloseModal();
        } catch (error) {
            CloseModal();
            showError(error);
        }
    });

    $(chatModal.value).on("hide.bs.modal", async function () {
        resetData();
    });
});

function openChatModal() {
    $(chatModal.value).modal("show");
}

function hideChatModal() {
    $(chatModal.value).modal("hide");
}

async function submitChat() {
    try {
        LoadingModal();

        if (props.chatId) await updateChat();
        else await createChat();

        CloseModal();
    } catch (error) {
        if (error.response?.status === 422) {
            Object.keys(chatDataErr).forEach((key) => {
                chatDataErr[key] = error.response.data.errors?.[key]?.[0] || "";
            });

            CloseModal();
            return;
        }

        CloseModal();
        return showError(error);
    }
}

async function readChat(chatId) {
    const response = await apiReadChat(chatId);

    await onChatUpdated(response.data.chat);

    tempChatPhoto.value = chatData.photo;

    if (chatData.type === "group") {
        await loadMembers();
    }
}

async function createChat() {
    const response = await apiCreateChat(chatData);

    emit("chatCreated", response.data.chat);
    window.dispatchEvent(new CustomEvent("chatCreated", { detail: response.data.chat }));

    hideChatModal();

    router.push({ name: "chats", params: { chatId: response.data.chat.id } });
}

async function updateChat() {
    const payload = { ...chatData };

    if (chatData.photo === tempChatPhoto.value) {
        delete payload.photo;
    }

    const response = await apiUpdateGroupChat(props.chatId, payload);

    emit("chatUpdated", response.data.chat);
    window.dispatchEvent(new CustomEvent("chatUpdated", { detail: response.data.chat }));

    hideChatModal();
}

async function deleteChat() {
    const result = await Swal.fire({
        icon: "warning",
        title: t("chat-modal.delete_group_title"),
        text: t("chat-modal.delete_group_text"),
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: t("chat-modal.delete_confirm"),
        cancelButtonText: t("chat-modal.cancel"),
    });

    if (!result.isConfirmed) return;

    try {
        LoadingModal();

        await apiDeleteGroupChat(props.chatId);

        hideChatModal();
        CloseModal();

        await router.replace({ name: "list.chats" });

        emit("chatDeleted", props.chatId);
        window.dispatchEvent(new CustomEvent("chatDeleted", { detail: props.chatId }));
    } catch (error) {
        CloseModal();
        showError(error);
    }
}

async function deleteDirectChat() {
    const result = await Swal.fire({
        icon: "warning",
        title: t("chat-modal.delete_chat_title"),
        text: t("chat-modal.delete_chat_text"),
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: t("chat-modal.delete_confirm"),
        cancelButtonText: t("chat-modal.cancel"),
    });

    if (!result.isConfirmed) return;

    try {
        LoadingModal();

        await axios.delete(window.API_URL + `/chats/${props.chatId}`);

        hideChatModal();
        CloseModal();

        await router.replace({ name: "list.chats" });
    } catch (error) {
        CloseModal();
        showError(error);
    }
}

async function leaveChat() {
    const result = await Swal.fire({
        icon: "warning",
        title: t("chat-modal.leave_chat_title"),
        text: t("chat-modal.leave_chat_text"),
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: t("chat-modal.leave_confirm"),
        cancelButtonText: t("chat-modal.cancel"),
    });

    if (!result.isConfirmed) return;

    try {
        LoadingModal();

        await apiLeaveGroupChat(props.chatId);

        hideChatModal();
        CloseModal();

        emit("chatDeleted", props.chatId);
        window.dispatchEvent(new CustomEvent("chatDeleted", { detail: props.chatId }));
    } catch (error) {
        CloseModal();
        showError(error);
    }
}

function onChangePhoto(event) {
    const files = event.target.files;
    if (!files || !files.length) return;

    const fileName = files[0].name;
    const idxDot = fileName.lastIndexOf(".") + 1;
    const extFile = fileName.substr(idxDot).toLowerCase();

    if (!allowedExtensions.includes(extFile)) {
        chatDataErr.photo = t("chat-modal.photo_invalid");
        return;
    }

    const reader = new FileReader();

    reader.onloadend = function () {
        const img = new Image();

        img.onload = function () {
            const canvas = document.createElement("canvas");
            const ctx = canvas.getContext("2d");

            canvas.width = 454;
            canvas.height = 454;

            const size = Math.min(img.width, img.height);
            const x = (img.width - size) / 2;
            const y = (img.height - size) / 2;

            ctx.drawImage(img, x, y, size, size, 0, 0, 454, 454);

            chatData.photo = canvas.toDataURL("image/png");
            chatDataErr.photo = "";
        };

        img.src = reader.result;
    };

    reader.readAsDataURL(files[0]);
    event.target.value = null;
}

function onDeletePhoto() {
    chatData.photo = null;
}

function onResetPhoto() {
    chatData.photo = tempChatPhoto.value ? tempChatPhoto.value : null;
}

function resetData() {
    Object.assign(chatData, defaultChatData);
    Object.assign(chatDataErr, defaultChatDataErr);

    tempChatPhoto.value = null;

    selectedUsers.value = [];
    filteredUsers.value = [];
    searchQuery.value = "";

    chatMembers.value = [];
    memberMeta.value = null;

    memberSearchQuery.value = "";
    filteredMemberUsers.value = [];
}

defineExpose({
    openChatModal,
    hideChatModal,
});
</script>

<style scoped>
:global(body) {
    --chat-bg: #ffffff;
    --chat-surface: #ffffff;
    --chat-border: rgba(0, 0, 0, 0.08);
    --chat-muted: rgba(0, 0, 0, 0.55);
    --chat-text: rgba(0, 0, 0, 0.88);
    --chat-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
    --chat-ring: 0 0 0 0.2rem rgba(0, 123, 255, 0.18);
}

:global(body.dark-mode),
:global(body[class*="dark-mode"]) {
    --chat-bg: #1f232a;
    --chat-surface: #232831;
    --chat-border: rgba(255, 255, 255, 0.08);
    --chat-muted: rgba(255, 255, 255, 0.55);
    --chat-text: rgba(255, 255, 255, 0.88);
    --chat-shadow: 0 10px 30px rgba(0, 0, 0, 0.55);
    --chat-ring: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.chat-modal-dialog {
    max-width: 920px;
}

.chat-modal {
    background: var(--chat-surface);
    border: 1px solid var(--chat-border);
    border-radius: 14px;
    box-shadow: var(--chat-shadow);
    overflow: hidden;
}

.chat-modal__header {
    background: var(--chat-surface);
    border-bottom: 1px solid var(--chat-border);
}

.chat-modal__body {
    background: var(--chat-bg);
    padding: 18px;
}

.chat-modal__footer {
    background: var(--chat-surface);
    border-top: 1px solid var(--chat-border);
}

.chat-close {
    opacity: 0.85;
}
.chat-close:hover {
    opacity: 1;
}

.chat-modal__titleIcon {
    width: 38px;
    height: 38px;
    border-radius: 12px;
    display: grid;
    place-items: center;
    background: rgba(0, 123, 255, 0.12);
    color: #0b66ff;
}

.chat-card {
    background: var(--chat-surface);
    border: 1px solid var(--chat-border);
    border-radius: 14px;
    padding: 16px;
}

.chat-profile {
    display: flex;
    gap: 16px;
    align-items: center;
    padding-bottom: 14px;
    border-bottom: 1px dashed var(--chat-border);
    margin-bottom: 16px;
}

.chat-profile__avatarWrap {
    display: grid;
    place-items: center;
    gap: 10px;
}

.chat-profile__avatar {
    width: 92px;
    height: 92px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid rgba(0, 123, 255, 0.2);
    background: rgba(0, 0, 0, 0.03);
}

.chat-profile__actions {
    display: flex;
    gap: 8px;
}

.chat-action-btn {
    border-radius: 10px;
    padding: 0.35rem 0.55rem;
}

.chat-profile__meta {
    flex: 1;
    min-width: 0;
}

.chat-profile__nameRow {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
}

.chat-badge {
    border-radius: 999px;
    padding: 0.35rem 0.6rem;
}

.chat-form {
    display: grid;
    grid-template-columns: 1fr;
    gap: 14px;
}

.chat-label {
    color: var(--chat-text);
    font-weight: 600;
}

.chat-input {
    border-radius: 12px;
    border: 1px solid var(--chat-border);
    background: var(--chat-surface);
    color: var(--chat-text);
}

.chat-input:focus {
    border-color: rgba(0, 123, 255, 0.45);
    box-shadow: var(--chat-ring);
}

.chat-input-icon {
    border: 1px solid var(--chat-border);
    background: rgba(0, 0, 0, 0.02);
    color: var(--chat-muted);
    border-radius: 12px 0 0 12px;
}

.chat-input--withIcon {
    border-radius: 0 12px 12px 0;
}

:global(body.dark-mode) .chat-input-icon,
:global(body[class*="dark-mode"]) .chat-input-icon {
    background: rgba(255, 255, 255, 0.03);
}

.chat-list {
    border: 1px solid var(--chat-border);
    border-radius: 12px;
    overflow: auto;
    max-height: 190px;
    background: var(--chat-surface);
}

.chat-list__item {
    width: 100%;
    text-align: left;
    border: 0;
    background: transparent;
    padding: 10px 12px;
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    border-bottom: 1px solid var(--chat-border);
    transition: background 0.12s ease;
}

.chat-list__item:last-child {
    border-bottom: 0;
}

.chat-list__item:hover {
    background: rgba(0, 123, 255, 0.06);
}

.chat-list__avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    object-fit: cover;
    flex: 0 0 auto;
    border: 1px solid var(--chat-border);
    background: rgba(0, 0, 0, 0.03);
}

.chat-list__content {
    min-width: 0;
    flex: 1;
}

.chat-list__title {
    font-weight: 700;
    color: var(--chat-text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.chat-list__sub {
    color: var(--chat-muted);
    font-size: 0.85rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.chat-list__endIcon {
    color: rgba(0, 123, 255, 0.75);
}

.chat-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.chat-chip {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 10px;
    border: 1px solid var(--chat-border);
    border-radius: 999px;
    background: rgba(0, 123, 255, 0.06);
}

.chat-chip__avatar {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    object-fit: cover;
}

.chat-chip__text {
    color: var(--chat-text);
    font-weight: 600;
    font-size: 0.9rem;
}

.chat-chip__remove {
    border: 0;
    background: transparent;
    color: var(--chat-muted);
    cursor: pointer;
    padding: 0 2px;
}

.chat-chip__remove:hover {
    color: #dc3545;
}

.chat-members {
    border: 1px solid var(--chat-border);
    border-radius: 12px;
    overflow: hidden;
    background: var(--chat-surface);
    max-height: 260px;
    overflow-y: auto;
}

.chat-members__loading {
    padding: 14px;
    text-align: center;
    color: var(--chat-muted);
}

.chat-members__row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 10px 12px;
    border-bottom: 1px solid var(--chat-border);
}

.chat-members__row:last-child {
    border-bottom: 0;
}

.chat-members__left {
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
}

.chat-members__avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    object-fit: cover;
    border: 1px solid var(--chat-border);
}

.chat-members__info {
    min-width: 0;
}

.chat-members__name {
    font-weight: 700;
    color: var(--chat-text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.chat-members__email {
    color: var(--chat-muted);
    font-size: 0.85rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.chat-footer-actions {
    gap: 8px;
}

@media (max-width: 576px) {
    .chat-modal__body {
        padding: 12px;
    }
    .chat-card {
        padding: 12px;
    }
    .chat-profile {
        flex-direction: column;
        align-items: flex-start;
    }
}

/* Direct chat input background gray, group keep normal */
.chat-input--direct {
    background-color: #e5e7eb !important;
}

/* Group input keep default */
.chat-input--group {
    background-color: var(--chat-surface) !important;
}
</style>
