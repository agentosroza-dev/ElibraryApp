<template>
    <div class="content-wrapper chat-view">
        <section class="content pt-3">
            <div class="container-fluid">
                <div class="card chat-card">
                    <div class="chat-toolbar">
                        <router-link
                            :to="{ name: 'list.chats' }"
                            class="btn btn-primary btn-sm chat-back-btn"
                        >
                            <i class="fas fa-arrow-left mr-1"></i>
                            {{ $t("chat-view.back") }}
                        </router-link>
                    </div>

                    <div class="chat-header">
                        <div class="chat-header__left">
                            <img
                                :src="chatAvatar"
                                class="chat-avatar"
                                :alt="$t('chat-view.chat_avatar')"
                            />

                            <div class="chat-header__meta">
                                <div class="chat-title">
                                    {{ chatData.name || $t("chat-view.chat") }}
                                </div>

                                <div class="chat-subtitle">
                                    <span v-if="chatData.type === 'group'">
                                        {{ $t("chat-view.group") }}
                                    </span>
                                    <span v-else>
                                        {{ $t("chat-view.direct") }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="chat-header__right">
                            <button
                                type="button"
                                class="btn btn-sm btn-outline-secondary chat-icon-btn"
                                :title="$t('chat-view.edit_chat')"
                                @click="openEditChat"
                            >
                                <i class="fas fa-edit"></i>
                            </button>
                        </div>
                    </div>

                    <div class="chat-body">
                        <div
                            ref="messagesContainer"
                            class="chat-messages"
                            @scroll="onMessagesScroll"
                        >
                            <div v-if="isLoadingMore" class="chat-loading-top">
                                <i class="fas fa-spinner fa-spin mr-2"></i>
                                {{ $t("chat-view.loading_older") }}
                            </div>

                            <div v-if="!messages.length" class="chat-empty">
                                {{ $t("chat-view.empty_messages") }}
                            </div>

                            <div
                                v-for="msg in messages"
                                :key="msg.id"
                                class="msg"
                                :class="isOwnMessage(msg) ? 'msg--me' : 'msg--other'"
                            >
                                <img
                                    class="msg__avatar"
                                    :src="msg.user?.photo || emptyPhoto"
                                    :alt="$t('chat-view.user_avatar')"
                                />

                                <div class="msg__content">
                                    <div class="msg__meta">
                                        <div class="msg__name">
                                            {{ msg.user?.name || $t("chat-view.unknown_user") }}
                                        </div>

                                        <div class="msg__time">
                                            {{ formatFullDateTime(msg.created_at) }}
                                            <span
                                                v-if="msg.type === 'text' && msg.updated_at !== msg.created_at"
                                                class="msg__edited"
                                            >
                                                • {{ $t("chat-view.edited") }}
                                            </span>
                                        </div>

                                        <div
                                            v-if="isOwnMessage(msg) && editingMessageId !== msg.id"
                                            class="msg__actions"
                                        >
                                            <button
                                                v-if="msg.type === 'text'"
                                                type="button"
                                                class="btn btn-xs btn-light msg__action"
                                                :title="$t('chat-view.edit')"
                                                @click="startEdit(msg)"
                                            >
                                                <i class="fas fa-pen"></i>
                                            </button>

                                            <button
                                                type="button"
                                                class="btn btn-xs btn-light msg__action msg__action--danger"
                                                :title="$t('chat-view.delete')"
                                                @click="deleteMessage(msg.id)"
                                            >
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="bubble" :class="isOwnMessage(msg) ? 'bubble--me' : 'bubble--other'">
                                        <div v-if="editingMessageId === msg.id" class="bubble__edit">
                                            <input
                                                v-model="editingMessage"
                                                type="text"
                                                class="form-control form-control-sm"
                                                :placeholder="$t('chat-view.edit_message_placeholder')"
                                                @keyup.enter="saveEdit"
                                                @keyup.esc="cancelEdit"
                                            />

                                            <div class="bubble__edit-actions">
                                                <button
                                                    type="button"
                                                    class="btn btn-sm btn-success"
                                                    @click="saveEdit"
                                                >
                                                    {{ $t("chat-view.save") }}
                                                </button>

                                                <button
                                                    type="button"
                                                    class="btn btn-sm btn-secondary"
                                                    @click="cancelEdit"
                                                >
                                                    {{ $t("chat-view.cancel") }}
                                                </button>
                                            </div>
                                        </div>

                                        <div
                                            v-else-if="msg.type === 'text'"
                                            class="bubble__text"
                                            v-html="linkify(msg.content)"
                                        ></div>

                                        <div v-else-if="msg.type === 'image'" class="bubble__media">
                                            <img
                                                :src="msg.content"
                                                class="bubble__img"
                                                :alt="$t('chat-view.image')"
                                                @click="openFile(msg.content)"
                                            />
                                        </div>

                                        <div v-else-if="msg.type === 'video'" class="bubble__media">
                                            <video controls :src="msg.content" class="bubble__video"></video>
                                        </div>

                                        <div v-else-if="msg.type === 'audio'" class="bubble__media">
                                            <audio controls :src="msg.content" class="bubble__audio"></audio>
                                        </div>

                                        <div v-else-if="msg.type === 'file'" class="bubble__file">
                                            <a
                                                :href="msg.content"
                                                target="_blank"
                                                rel="noopener"
                                                class="bubble__file-link"
                                            >
                                                <i class="fas fa-file mr-2"></i>
                                                <span class="bubble__file-name">
                                                    {{ msg.originalContent || $t("chat-view.download_file") }}
                                                </span>
                                                <i class="fas fa-external-link-alt ml-2 opacity-75"></i>
                                            </a>
                                        </div>

                                        <div v-else class="bubble__text">
                                            {{ $t("chat-view.unsupported_message") }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="chat-footer">
                        <div v-if="selectedFile" class="composer-preview">
                            <div class="composer-chip">
                                <i :class="fileTypeIcon" class="mr-2"></i>
                                <span class="composer-chip__name">{{ selectedFile.name }}</span>
                            </div>

                            <button
                                type="button"
                                class="btn btn-sm btn-outline-danger"
                                :title="$t('chat-view.clear_file')"
                                @click="clearSelectedFile"
                            >
                                <i class="fas fa-times"></i>
                            </button>
                        </div>

                        <div v-if="isRecording" class="composer-recording">
                            <div class="recording-badge" :class="isPaused ? 'recording-badge--paused' : ''">
                                <span class="recording-dot" :class="{ blink: !isPaused }"></span>
                                <span class="ml-2">
                                    {{ isPaused ? $t("chat-view.paused") : $t("chat-view.recording") }}
                                    {{ recordingDuration }}s / {{ audioDuration }}s
                                </span>
                            </div>

                            <div class="recording-actions">
                                <button
                                    type="button"
                                    class="btn btn-sm"
                                    :class="isPaused ? 'btn-info' : 'btn-warning'"
                                    @click="pauseRecording"
                                >
                                    <i :class="isPaused ? 'fas fa-microphone' : 'fas fa-pause'"></i>
                                    <span class="ml-1">
                                        {{ isPaused ? $t("chat-view.resume") : $t("chat-view.pause") }}
                                    </span>
                                </button>

                                <button
                                    type="button"
                                    class="btn btn-sm btn-success"
                                    @click="stopRecording(false)"
                                >
                                    <i class="fas fa-paper-plane mr-1"></i>
                                    {{ $t("chat-view.send") }}
                                </button>

                                <button
                                    type="button"
                                    class="btn btn-sm btn-danger"
                                    @click="stopRecording(true)"
                                >
                                    <i class="fas fa-times mr-1"></i>
                                    {{ $t("chat-view.cancel") }}
                                </button>
                            </div>
                        </div>

                        <div class="composer">
                            <input
                                ref="fileInput"
                                type="file"
                                class="d-none"
                                @change="onFileSelected"
                            />

                            <button
                                type="button"
                                class="btn btn-light composer-btn"
                                :title="$t('chat-view.attach_file')"
                                :disabled="isRecording"
                                @click="openFilePicker"
                            >
                                <i class="fas fa-paperclip"></i>
                            </button>

                            <input
                                v-model="newMessage"
                                type="text"
                                class="form-control composer-input"
                                :placeholder="$t('chat-view.type_message')"
                                :disabled="isRecording || !!selectedFile"
                                @keyup.enter="sendMessage"
                            />

                            <button
                                v-if="!newMessage.trim() && !selectedFile"
                                type="button"
                                class="btn btn-light composer-btn"
                                :title="$t('chat-view.record_voice')"
                                :disabled="isRecording"
                                @click="startRecording"
                            >
                                <i class="fas fa-microphone"></i>
                            </button>

                            <button
                                v-else-if="isSending"
                                type="button"
                                class="btn btn-primary composer-btn composer-btn--send"
                                disabled
                            >
                                <span
                                    class="spinner-border spinner-border-sm"
                                    role="status"
                                    aria-hidden="true"
                                ></span>
                            </button>

                            <button
                                v-else
                                type="button"
                                class="btn btn-primary composer-btn composer-btn--send"
                                :title="$t('chat-view.send')"
                                @click="sendMessage"
                            >
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <ChatModal
        ref="chatModal"
        :chatId="chatId"
        @chatUpdated="onChatUpdated"
        @chatDeleted="onChatDeleted"
    />
</template>


<script setup>
import emptyPhoto from "@assets/images/emptyuser.png";
import { useRoute, useRouter } from "vue-router";
import { useStore } from "vuex";
import { useI18n } from "vue-i18n";
import { computed, onMounted, onBeforeUnmount, ref, watch, nextTick, reactive } from "vue";
import Swal from "sweetalert2";

import { MessageModal } from "@func/swal";
import { apiReadChat, apiGetChatFile } from "@func/api/chat";
import {
    apiGetMessages,
    apiCreateMessage,
    apiUpdateMessage,
    apiDeleteMessage,
    apiMarkAllMessagesAsSeen,
} from "@func/api/chat_message";
import { formatFullDateTime } from "@func/datetime";
import ChatModal from "@com/includes/controls/ChatModal.vue";

const store = useStore();
const router = useRouter();
const route = useRoute();
const { t } = useI18n();

const chatId = computed(() => Number(route.params.chatId));
const chatModal = ref(null);

const userData = computed(() => store.state.user);

function isOwnMessage(message) {
    return message.user_id === userData.value?.id;
}

const chatData = reactive({
    name: "",
    photo: null,
    type: "",
    updatable: false,
});

const defaultChatData = JSON.parse(JSON.stringify(chatData));

const chatAvatar = computed(() => chatData.photo ?? emptyPhoto);

const messages = ref([]);
const messageMeta = ref(null);
const isLoadingMore = ref(false);
const messagesContainer = ref(null);

const newMessage = ref("");
const editingMessageId = ref(null);
const editingMessage = ref("");

const selectedFile = ref(null);
const fileInput = ref(null);

const isSending = ref(false);
const isRecording = ref(false);
const isPaused = ref(false);
const recordingDuration = ref(0);

let mediaRecorder = null;
const audioDuration = 60;
let audioChunks = [];
let recordingTimer = null;
let isCancelledRecording = false;

function showError(error, callback = onChatDeleted) {
    return MessageModal(
        "error",
        t("chat-view.error_title"),
        error?.response?.data?.message || error?.message || t("chat-view.error_message"),
        callback
    );
}

function openEditChat() {
    chatModal.value?.openChatModal?.();
}

function openFilePicker() {
    fileInput.value?.click?.();
}

function escapeHtml(str) {
    return (str ?? "")
        .toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function linkify(text) {
    const safe = escapeHtml(text);
    const urlRegex = /(https?:\/\/[^\s<]+)/g;

    return safe.replace(urlRegex, (url) => {
        const trimmed = url.replace(/[),.\]]+$/g, "");
        const trailing = url.slice(trimmed.length);

        return `<a href="${trimmed}" target="_blank" rel="noopener noreferrer" class="chat-link">${trimmed}</a>${trailing}`;
    });
}

async function onMessagesScroll() {
    const el = messagesContainer.value;
    if (!el) return;

    if (el.scrollTop <= 60) {
        await loadMoreMessages();
    }
}

onMounted(async () => {
    await readChat();
});

onBeforeUnmount(() => {
    try {
        if (window.Echo) {
            window.Echo.leave(`MessageEvent.${chatId.value}`);
        }
    } catch {}

    stopRecording(true);
});

watch(
    () => route.params.chatId,
    async (newChatId, oldChatId) => {
        if (oldChatId && window.Echo) {
            window.Echo.leave(`MessageEvent.${oldChatId}`);
        }

        if (newChatId) {
            resetData();
            await readChat();
        }
    }
);

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

    window.dispatchEvent(new CustomEvent("chatUpdated", { detail: chat }));
}

function onChatDeleted() {
    router.push({ name: "dashboard" });
}

async function readChat() {
    try {
        if (window.Echo) {
            window.Echo.leave(`MessageEvent.${chatId.value}`);
        }

        const [chatRes, msgRes] = await Promise.all([
            apiReadChat(chatId.value),
            apiGetMessages(chatId.value),
        ]);

        const chat = chatRes.data.chat;
        await onChatUpdated(chat);

        messages.value = (msgRes.data.chat_messages || []).reverse();
        messageMeta.value = msgRes.data.meta || null;

        await processMessages(messages.value);

        await nextTick();
        scrollToBottom();

        await apiMarkAllMessagesAsSeen(chatId.value);

        if (window.Echo) {
            window.Echo.private(`MessageEvent.${chatId.value}`)
                .listen(".MessageCreated", async (e) => {
                    const newMsg = e.message;

                    if (newMsg.type !== "text") {
                        newMsg.content = await loadFile(newMsg.content);
                    }

                    messages.value.push(newMsg);

                    await nextTick();

                    if (isNearBottom()) {
                        scrollToBottom();
                    }
                })
                .listen(".MessageUpdated", async (e) => {
                    const updatedMsg = e.message;

                    if (updatedMsg.type !== "text") {
                        updatedMsg.content = await loadFile(updatedMsg.content);
                    }

                    messages.value = messages.value.map((m) =>
                        m.id === updatedMsg.id ? updatedMsg : m
                    );
                })
                .listen(".MessageDeleted", (e) => {
                    messages.value = messages.value.filter((m) => m.id !== e.messageId);
                });
        }
    } catch (error) {
        return showError(error);
    }
}

function isNearBottom() {
    const el = messagesContainer.value;
    if (!el) return true;

    const distance = el.scrollHeight - (el.scrollTop + el.clientHeight);
    return distance < 180;
}

async function loadMoreMessages() {
    if (isLoadingMore.value || !messageMeta.value) return;
    if (messageMeta.value.current_page >= messageMeta.value.last_page) return;

    const container = messagesContainer.value;
    if (!container) return;

    isLoadingMore.value = true;
    const previousScrollHeight = container.scrollHeight;

    try {
        const nextPage = messageMeta.value.current_page + 1;
        const response = await apiGetMessages(chatId.value, { page: nextPage });

        const olderMessages = (response.data.chat_messages || []).reverse();

        messageMeta.value = response.data.meta || messageMeta.value;

        await processMessages(olderMessages);

        messages.value = [...olderMessages, ...messages.value];

        await nextTick();

        container.scrollTop = container.scrollHeight - previousScrollHeight;
    } catch (error) {
        return showError(error);
    } finally {
        isLoadingMore.value = false;
    }
}

async function sendMessage() {
    try {
        if (isSending.value) return;

        isSending.value = true;

        if (selectedFile.value) {
            const type = getFileType(selectedFile.value);

            const response = await apiCreateMessage(chatId.value, {
                content: selectedFile.value,
                type,
            });

            const fileMsg = response.data.chat_message;

            await processMessages([fileMsg]);

            messages.value.push(fileMsg);

            clearSelectedFile();
        } else {
            if (!newMessage.value.trim()) return;

            const text = newMessage.value.trim();
            newMessage.value = "";

            const response = await apiCreateMessage(chatId.value, {
                content: text,
                type: "text",
            });

            messages.value.push(response.data.chat_message);
        }

        await nextTick();
        scrollToBottom();
    } catch (error) {
        return showError(error);
    } finally {
        isSending.value = false;
    }
}

function getFileType(file) {
    const mime = file.type || "";

    if (mime.startsWith("image/")) return "image";
    if (mime.startsWith("video/")) return "video";
    if (mime.startsWith("audio/")) return "audio";

    return "file";
}

function onFileSelected(event) {
    const file = event.target.files?.[0];
    if (!file) return;

    selectedFile.value = file;
    event.target.value = null;
}

function clearSelectedFile() {
    selectedFile.value = null;
}

const fileTypeIcon = computed(() => {
    if (!selectedFile.value) return "fas fa-file";

    const type = getFileType(selectedFile.value);

    if (type === "image") return "fas fa-image";
    if (type === "video") return "fas fa-video";
    if (type === "audio") return "fas fa-microphone";

    return "fas fa-file";
});

async function loadFile(uri) {
    try {
        const response = await apiGetChatFile(uri);
        return URL.createObjectURL(response.data);
    } catch {
        return emptyPhoto;
    }
}

function openFile(url) {
    window.open(url, "_blank", "noopener,noreferrer");
}

async function processMessages(msgs) {
    await Promise.all(
        (msgs || []).map(async (msg) => {
            if (msg.type !== "text") {
                msg.content = await loadFile(msg.content);
            }
        })
    );
}

async function startRecording() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

        mediaRecorder = new MediaRecorder(stream);
        audioChunks = [];
        isCancelledRecording = false;

        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                audioChunks.push(event.data);
            }
        };

        mediaRecorder.onstop = async () => {
            stream.getTracks().forEach((track) => track.stop());

            if (isCancelledRecording || audioChunks.length === 0) return;

            const blob = new Blob(audioChunks, { type: "audio/webm" });

            const file = new File([blob], `VOICE-${Date.now()}.webm`, {
                type: "audio/webm",
            });

            try {
                const response = await apiCreateMessage(chatId.value, {
                    content: file,
                    type: "audio",
                });

                const voiceMsg = response.data.chat_message;

                await processMessages([voiceMsg]);

                messages.value.push(voiceMsg);

                await nextTick();
                scrollToBottom();
            } catch (error) {
                showError(error);
            }
        };

        mediaRecorder.start();

        isRecording.value = true;
        isPaused.value = false;
        recordingDuration.value = 0;

        clearInterval(recordingTimer);

        recordingTimer = setInterval(() => {
            if (!isPaused.value) {
                recordingDuration.value++;

                if (recordingDuration.value >= audioDuration) {
                    stopRecording(false);
                }
            }
        }, 1000);
    } catch {
        MessageModal(
            "error",
            t("chat-view.error_title"),
            t("chat-view.microphone_denied")
        );
    }
}

function pauseRecording() {
    if (!mediaRecorder || mediaRecorder.state === "inactive") return;

    if (isPaused.value) {
        mediaRecorder.resume();
        isPaused.value = false;
    } else {
        mediaRecorder.pause();
        isPaused.value = true;
    }
}

function stopRecording(cancel) {
    isCancelledRecording = cancel;

    if (mediaRecorder && mediaRecorder.state !== "inactive") {
        mediaRecorder.stop();
    }

    isRecording.value = false;
    isPaused.value = false;

    clearInterval(recordingTimer);
    recordingTimer = null;
}

function startEdit(msg) {
    editingMessageId.value = msg.id;
    editingMessage.value = msg.content;
}

function cancelEdit() {
    editingMessageId.value = null;
    editingMessage.value = "";
}

async function saveEdit() {
    if (!editingMessage.value.trim()) return;

    try {
        const response = await apiUpdateMessage(chatId.value, editingMessageId.value, {
            content: editingMessage.value.trim(),
        });

        messages.value = messages.value.map((m) =>
            m.id === editingMessageId.value ? response.data.chat_message : m
        );

        cancelEdit();
    } catch (error) {
        if (error.response?.status === 422) {
            return MessageModal(
                "error",
                t("chat-view.validation_error"),
                error.response.data.errors?.content?.[0] || t("chat-view.invalid_input")
            );
        }

        return showError(error);
    }
}

async function deleteMessage(messageId) {
    const result = await Swal.fire({
        title: t("chat-view.delete_confirm_title"),
        text: t("chat-view.delete_confirm_text"),
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: t("chat-view.delete_confirm_button"),
        cancelButtonText: t("chat-view.cancel"),
    });

    if (!result.isConfirmed) return;

    try {
        await apiDeleteMessage(chatId.value, messageId);
        messages.value = messages.value.filter((m) => m.id !== messageId);
    } catch (error) {
        return showError(error);
    }
}

function scrollToBottom() {
    const el = messagesContainer.value;
    if (!el) return;

    el.scrollTop = el.scrollHeight;
}

function resetData() {
    Object.assign(chatData, defaultChatData);

    messages.value = [];
    messageMeta.value = null;
    newMessage.value = "";
    editingMessageId.value = null;
    editingMessage.value = "";
    selectedFile.value = null;

    stopRecording(true);
}
</script>

<style scoped>
.chat-view {
    --bg: #f5f7fb;
    --card: #ffffff;
    --surface: #ffffff;
    --surface-2: #f8fafc;
    --border: rgba(0, 0, 0, 0.08);
    --text: #111827;
    --muted: #6b7280;
    --bubble-me: #2563eb;
    --bubble-me-text: #ffffff;
    --bubble-other: #f3f4f6;
    --bubble-other-text: #111827;
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
    --radius-lg: 16px;
    --radius-md: 12px;
    --radius-sm: 10px;

    min-height: 100%;
    background: var(--bg);
    color: var(--text);
    padding-bottom: 1rem;
}

.chat-card {
    overflow: hidden;
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    background: var(--card);
    box-shadow: var(--shadow);
}

.chat-toolbar {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding: 12px 14px 0;
    background: var(--card);
}

.chat-back-btn {
    border-radius: 10px;
}

.chat-header {
    position: sticky;
    top: 0;
    z-index: 5;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 14px;
    background: var(--card);
    border-bottom: 1px solid var(--border);
}

.chat-header__left {
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
}

.chat-avatar {
    width: 42px;
    height: 42px;
    flex: 0 0 auto;
    object-fit: cover;
    border: 1px solid var(--border);
    border-radius: 50%;
}

.chat-header__meta {
    min-width: 0;
}

.chat-title {
    max-width: 58vw;
    overflow: hidden;
    color: var(--text);
    font-weight: 700;
    line-height: 1.1;
    white-space: nowrap;
    text-overflow: ellipsis;
}

.chat-subtitle {
    margin-top: 2px;
    color: var(--muted);
    font-size: 12px;
}

.chat-icon-btn {
    border-radius: 10px;
}

.chat-body {
    background: var(--bg);
}

.chat-messages {
    height: calc(100vh - 250px);
    overflow-y: auto;
    padding: 14px;
    scroll-behavior: smooth;
}

.chat-loading-top {
    display: flex;
    align-items: center;
    gap: 6px;
    width: fit-content;
    margin: 0 auto 12px;
    padding: 6px 10px;
    border: 1px solid var(--border);
    border-radius: 999px;
    background: var(--surface);
    color: var(--muted);
    font-size: 12px;
}

.chat-empty {
    padding: 24px 8px;
    color: var(--muted);
    font-size: 14px;
    text-align: center;
}

.msg {
    display: flex;
    align-items: flex-end;
    gap: 10px;
    margin-bottom: 14px;
}

.msg--me {
    flex-direction: row-reverse;
}

.msg__avatar {
    width: 32px;
    height: 32px;
    flex: 0 0 auto;
    object-fit: cover;
    border: 1px solid var(--border);
    border-radius: 50%;
}

.msg__content {
    display: flex;
    flex-direction: column;
    gap: 6px;
    max-width: min(760px, 74%);
}

.msg--me .msg__content {
    align-items: flex-end;
}

.msg__meta {
    display: grid;
    grid-template-columns: 1fr auto auto;
    align-items: center;
    gap: 8px;
    padding: 0 4px;
}

.msg--me .msg__meta {
    grid-template-columns: auto auto 1fr;
}

.msg__name {
    color: var(--text);
    font-size: 12px;
    font-weight: 700;
    opacity: 0.9;
}

.msg__time {
    color: var(--muted);
    font-size: 11px;
    white-space: nowrap;
}

.msg__edited {
    opacity: 0.85;
}

.msg__actions {
    display: inline-flex;
    gap: 6px;
}

.msg__action {
    padding: 2px 8px;
    border-radius: 10px;
    line-height: 1.2;
}

.msg__action--danger {
    color: #dc2626;
}

.bubble {
    overflow: hidden;
    padding: 10px 12px;
    border: 1px solid var(--border);
    border-radius: 16px;
}

.bubble--me {
    border-color: rgba(255, 255, 255, 0.12);
    border-bottom-right-radius: 8px;
    background: var(--bubble-me);
    color: var(--bubble-me-text);
}

.bubble--other {
    border-bottom-left-radius: 8px;
    background: var(--bubble-other);
    color: var(--bubble-other-text);
}

.bubble__text {
    white-space: pre-wrap;
    word-break: break-word;
    font-size: 14px;
    line-height: 1.45;
}

.bubble__text :deep(.chat-link) {
    color: inherit;
    font-weight: 600;
    text-decoration: underline;
}

.msg--me .bubble__text :deep(.chat-link) {
    color: rgba(255, 255, 255, 0.95);
}

.msg--other .bubble__text :deep(.chat-link) {
    color: #2563eb;
}

.bubble__media {
    display: flex;
    align-items: center;
    justify-content: center;
}

.bubble__img {
    width: 100%;
    max-width: 320px;
    max-height: 320px;
    object-fit: cover;
    border: 1px solid var(--border);
    border-radius: 12px;
    cursor: pointer;
}

.bubble__video {
    width: 100%;
    max-width: 360px;
    border: 1px solid var(--border);
    border-radius: 12px;
}

.bubble__audio {
    width: 280px;
    max-width: 100%;
}

.bubble__file-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: inherit;
    text-decoration: none;
}

.bubble__file-link:hover {
    text-decoration: underline;
}

.bubble__file-name {
    max-width: 360px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
}

.opacity-75 {
    opacity: 0.75;
}

.bubble__edit-actions {
    display: flex;
    gap: 8px;
    margin-top: 8px;
}

.chat-footer {
    padding: 12px;
    background: var(--card);
    border-top: 1px solid var(--border);
}

.composer-preview {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 10px;
}

.composer-chip {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    max-width: calc(100% - 48px);
    padding: 8px 10px;
    border: 1px solid var(--border);
    border-radius: 999px;
    background: var(--bg);
    color: var(--text);
}

.composer-chip__name {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
}

.composer-recording {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 10px;
    padding: 10px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--bg);
}

.recording-badge {
    display: inline-flex;
    align-items: center;
    color: var(--text);
    font-size: 13px;
    font-weight: 600;
}

.recording-badge--paused {
    opacity: 0.8;
}

.recording-dot {
    display: inline-block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #ef4444;
}

.blink {
    animation: blink 1s infinite;
}

@keyframes blink {
    0%,
    100% {
        opacity: 0.25;
    }
    50% {
        opacity: 1;
    }
}

.recording-actions {
    display: inline-flex;
    gap: 8px;
    flex-wrap: wrap;
}

.composer {
    display: grid;
    grid-template-columns: 44px 1fr 44px;
    align-items: center;
    gap: 10px;
}

.composer-btn {
    width: 44px;
    height: 42px;
    border: 1px solid var(--border);
    border-radius: 12px;
}

.composer-input {
    height: 42px;
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--bg);
    color: var(--text);
}

.composer-input:focus {
    background: var(--surface);
    color: var(--text);
    border-color: rgba(37, 99, 235, 0.35);
    box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.12);
}

.composer-input::placeholder {
    color: var(--muted);
}

.composer-btn--send {
    border: none;
}

@media (max-width: 576px) {
    .chat-messages {
        height: calc(100vh - 270px);
        padding: 12px;
    }

    .msg__content {
        max-width: 86%;
    }

    .bubble__img {
        max-width: 260px;
        max-height: 260px;
    }

    .bubble__audio {
        width: 240px;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.chat-view,
html.dark-mode .content-wrapper.chat-view,
.dark-mode .content-wrapper.chat-view {
    background: #0b1220 !important;
}

body.dark-mode .chat-view,
html.dark-mode .chat-view,
.dark-mode .chat-view {
    --bg: #0b1220;
    --card: #0f172a;
    --surface: #111827;
    --surface-2: #172033;
    --border: rgba(255, 255, 255, 0.08);
    --text: #e5e7eb;
    --muted: #9ca3af;
    --bubble-me: #2563eb;
    --bubble-me-text: #ffffff;
    --bubble-other: rgba(255, 255, 255, 0.08);
    --bubble-other-text: #e5e7eb;
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.35);
}

body.dark-mode .chat-view .chat-card,
body.dark-mode .chat-view .card,
html.dark-mode .chat-view .chat-card,
html.dark-mode .chat-view .card,
.dark-mode .chat-view .chat-card,
.dark-mode .chat-view .card {
    background: var(--card) !important;
    border-color: var(--border) !important;
    box-shadow: var(--shadow) !important;
}

body.dark-mode .chat-view .chat-header,
body.dark-mode .chat-view .chat-footer,
body.dark-mode .chat-view .chat-toolbar,
html.dark-mode .chat-view .chat-header,
html.dark-mode .chat-view .chat-footer,
html.dark-mode .chat-view .chat-toolbar,
.dark-mode .chat-view .chat-header,
.dark-mode .chat-view .chat-footer,
.dark-mode .chat-view .chat-toolbar {
    background: var(--card) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .chat-body,
body.dark-mode .chat-view .chat-messages,
html.dark-mode .chat-view .chat-body,
html.dark-mode .chat-view .chat-messages,
.dark-mode .chat-view .chat-body,
.dark-mode .chat-view .chat-messages {
    background: var(--bg) !important;
}

body.dark-mode .chat-view .chat-title,
body.dark-mode .chat-view .msg__name,
html.dark-mode .chat-view .chat-title,
html.dark-mode .chat-view .msg__name,
.dark-mode .chat-view .chat-title,
.dark-mode .chat-view .msg__name {
    color: var(--text) !important;
}

body.dark-mode .chat-view .chat-subtitle,
body.dark-mode .chat-view .chat-empty,
body.dark-mode .chat-view .chat-loading-top,
body.dark-mode .chat-view .msg__time,
html.dark-mode .chat-view .chat-subtitle,
html.dark-mode .chat-view .chat-empty,
html.dark-mode .chat-view .chat-loading-top,
html.dark-mode .chat-view .msg__time,
.dark-mode .chat-view .chat-subtitle,
.dark-mode .chat-view .chat-empty,
.dark-mode .chat-view .chat-loading-top,
.dark-mode .chat-view .msg__time {
    color: var(--muted) !important;
}

body.dark-mode .chat-view .chat-avatar,
body.dark-mode .chat-view .msg__avatar,
body.dark-mode .chat-view .bubble__img,
body.dark-mode .chat-view .bubble__video,
html.dark-mode .chat-view .chat-avatar,
html.dark-mode .chat-view .msg__avatar,
html.dark-mode .chat-view .bubble__img,
html.dark-mode .chat-view .bubble__video,
.dark-mode .chat-view .chat-avatar,
.dark-mode .chat-view .msg__avatar,
.dark-mode .chat-view .bubble__img,
.dark-mode .chat-view .bubble__video {
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .bubble--other,
html.dark-mode .chat-view .bubble--other,
.dark-mode .chat-view .bubble--other {
    background: var(--bubble-other) !important;
    color: var(--bubble-other-text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .msg--other .bubble__text .chat-link,
html.dark-mode .chat-view .msg--other .bubble__text .chat-link,
.dark-mode .chat-view .msg--other .bubble__text .chat-link {
    color: #60a5fa !important;
}

body.dark-mode .chat-view .composer-chip,
body.dark-mode .chat-view .composer-recording,
body.dark-mode .chat-view .chat-loading-top,
html.dark-mode .chat-view .composer-chip,
html.dark-mode .chat-view .composer-recording,
html.dark-mode .chat-view .chat-loading-top,
.dark-mode .chat-view .composer-chip,
.dark-mode .chat-view .composer-recording,
.dark-mode .chat-view .chat-loading-top {
    background: var(--surface) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .composer-input,
html.dark-mode .chat-view .composer-input,
.dark-mode .chat-view .composer-input {
    background: var(--surface-2) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .composer-input::placeholder,
html.dark-mode .chat-view .composer-input::placeholder,
.dark-mode .chat-view .composer-input::placeholder {
    color: var(--muted) !important;
}

body.dark-mode .chat-view .composer-input:focus,
html.dark-mode .chat-view .composer-input:focus,
.dark-mode .chat-view .composer-input:focus {
    background: var(--surface) !important;
    color: var(--text) !important;
    border-color: rgba(96, 165, 250, 0.45) !important;
    box-shadow: 0 0 0 0.2rem rgba(96, 165, 250, 0.12) !important;
}

body.dark-mode .chat-view .composer-btn,
html.dark-mode .chat-view .composer-btn,
.dark-mode .chat-view .composer-btn {
    background: var(--surface) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .composer-btn.btn-light,
html.dark-mode .chat-view .composer-btn.btn-light,
.dark-mode .chat-view .composer-btn.btn-light {
    background: var(--surface) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary,
html.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary,
.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary {
    color: #cbd5e1 !important;
    border-color: #475569 !important;
    background: transparent !important;
}

body.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary:hover,
html.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary:hover,
.dark-mode .chat-view .chat-icon-btn.btn-outline-secondary:hover {
    background: #1f2937 !important;
    color: #ffffff !important;
    border-color: #64748b !important;
}

body.dark-mode .chat-view .msg__action.btn-light,
html.dark-mode .chat-view .msg__action.btn-light,
.dark-mode .chat-view .msg__action.btn-light {
    background: var(--surface) !important;
    color: var(--text) !important;
    border-color: var(--border) !important;
}

body.dark-mode .chat-view .msg__action--danger,
html.dark-mode .chat-view .msg__action--danger,
.dark-mode .chat-view .msg__action--danger {
    color: #f87171 !important;
}

body.dark-mode .chat-view audio,
body.dark-mode .chat-view video,
html.dark-mode .chat-view audio,
html.dark-mode .chat-view video,
.dark-mode .chat-view audio,
.dark-mode .chat-view video {
    filter: brightness(0.92);
}
</style>
