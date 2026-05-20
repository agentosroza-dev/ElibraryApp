<template>
    <router-link
        class="nav-link chat-option"
        :to="{ name: 'chats', params: { chatId } }"
        @click="handleOpenChat"
    >
        <div class="chat-option__avatar">
            <img
                :src="photoSrc"
                class="img-circle elevation-1 chat-option__image"
                :alt="t('chat-option.chat_photo')"
                @error="onImageError"
            />
        </div>

        <div class="chat-option__content">
            <div class="chat-option__title-row">
                <p class="chat-option__title text-truncate">
                    {{ displayName }}
                </p>

                <span v-if="isGroup" class="chat-option__group-pill">
                    {{ t("chat-option.group") }}
                </span>
            </div>

            <p class="chat-option__preview text-truncate">
                {{ previewText }}
            </p>
        </div>

        <div class="chat-option__meta">
            <span class="chat-option__time">{{ timeText }}</span>

            <span v-if="localUnreadCount > 0" class="chat-option__badge">
                {{ localUnreadCount }}
            </span>
        </div>
    </router-link>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { useI18n } from "vue-i18n";
import emptyPhoto from "@assets/images/emptyuser.png";

const { t } = useI18n();

const props = defineProps({
    chat: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(["read", "opened"]);

const localUnreadCount = ref(0);

const chatId = computed(() => Number(props.chat?.id) || 0);
const isGroup = computed(() => String(props.chat?.type || "") === "group");

const displayName = computed(() => {
    return String(props.chat?.name || t("chat-option.unknown")).trim();
});

const photoSrc = computed(() => {
    return String(props.chat?.photo || "").trim() || emptyPhoto;
});

const lastMessage = computed(() => props.chat?.last_message || null);

watch(
    () =>
        props.chat?.unread_count ??
        props.chat?.unreadCount ??
        props.chat?.unread_messages_count ??
        props.chat?.unreadMessagesCount,
    (value) => {
        localUnreadCount.value = Number(value || 0);
    },
    { immediate: true }
);

function handleOpenChat() {
    if (!chatId.value) return;

    const hadUnread = localUnreadCount.value > 0;

    if (hadUnread) {
        localUnreadCount.value = 0;
    }

    const detail = {
        type: "read",
        read: true,
        chat_id: chatId.value,
        chatId: chatId.value,
        unread_count: 0,
        chat: {
            ...props.chat,
            unread_count: 0,
            unreadCount: 0,
            unread_messages_count: 0,
            unreadMessagesCount: 0,
        },
    };

    window.dispatchEvent(new CustomEvent("chatRead", { detail }));
    window.dispatchEvent(new CustomEvent("messageRead", { detail }));
    window.dispatchEvent(new CustomEvent("chatUpdated", { detail }));
    window.dispatchEvent(new CustomEvent("refreshChatUnread", { detail }));

    emit("read", detail);
    emit("opened", detail);
}

function onImageError(event) {
    if (event?.target) {
        event.target.src = emptyPhoto;
    }
}

function safeText(value) {
    return (value ?? "").toString().trim();
}

function extractUrl(text) {
    const match = safeText(text).match(/https?:\/\/[^\s]+/i);
    return match ? match[0] : "";
}

function detectType(url) {
    if (!url) return "none";

    if (/\.(png|jpe?g|gif|webp|bmp)$/i.test(url) || url.includes("/images/")) {
        return "image";
    }

    if (/\.(mp4|mov|mkv)$/i.test(url)) {
        return "video";
    }

    if (/\.(mp3|wav|aac|ogg|webm)$/i.test(url)) {
        return "audio";
    }

    if (
        /\.(pdf|docx?|xlsx?|pptx?|zip|rar|7z)$/i.test(url) ||
        url.includes("/files/")
    ) {
        return "file";
    }

    return "link";
}

function getFileExtension(url) {
    if (!url) return "";

    const cleanUrl = url.split("?")[0];
    const parts = cleanUrl.split(".");

    if (parts.length < 2) return "";

    return parts.pop().toLowerCase();
}

const FILE_TYPE_MAP = {
    pdf: { icon: "📄", label: "PDF" },
    doc: { icon: "📝", label: "DOC" },
    docx: { icon: "📝", label: "DOCX" },
    xls: { icon: "📊", label: "XLS" },
    xlsx: { icon: "📊", label: "XLSX" },
    ppt: { icon: "📽", label: "PPT" },
    pptx: { icon: "📽", label: "PPTX" },
    zip: { icon: "🗜", label: "ZIP" },
    rar: { icon: "🗜", label: "RAR" },
    "7z": { icon: "🗜", label: "7Z" },
};

const messageText = computed(() => {
    return safeText(
        lastMessage.value?.message ||
        lastMessage.value?.text ||
        lastMessage.value?.body ||
        lastMessage.value?.content
    );
});

const fileUrl = computed(() => extractUrl(messageText.value));
const fileType = computed(() => detectType(fileUrl.value));

const noMessageText = computed(() => {
    return isGroup.value
        ? t("chat-option.no_messages_group")
        : t("chat-option.no_messages");
});

const previewText = computed(() => {
    if (!lastMessage.value) return noMessageText.value;

    if (fileType.value === "image") return `🖼️ ${t("chat-option.photo")}`;
    if (fileType.value === "video") return `🎥 ${t("chat-option.video")}`;
    if (fileType.value === "audio") return `🔊 ${t("chat-option.audio")}`;

    if (fileType.value === "file") {
        const ext = getFileExtension(fileUrl.value);

        if (FILE_TYPE_MAP[ext]) {
            const { icon, label } = FILE_TYPE_MAP[ext];
            return `${icon} ${label}`;
        }

        return `📎 ${t("chat-option.file")}`;
    }

    if (fileType.value === "link") return `🔗 ${t("chat-option.link")}`;

    const raw = messageText.value;

    if (!raw) return noMessageText.value;

    if (raw === displayName.value) {
        return isGroup.value
            ? t("chat-option.group_created")
            : t("chat-option.new_conversation");
    }

    const sender =
        safeText(lastMessage.value?.user?.name) ||
        safeText(lastMessage.value?.sender_name);

    if (isGroup.value && sender) {
        return `${sender}: ${raw}`;
    }

    return raw;
});

const timeText = computed(() => {
    const timeValue = lastMessage.value?.created_at || props.chat?.updated_at;
    if (!timeValue) return "";

    const date = new Date(timeValue);
    if (Number.isNaN(date.getTime())) return "";

    return `${String(date.getHours()).padStart(2, "0")}:${String(
        date.getMinutes()
    ).padStart(2, "0")}`;
});
</script>

<style scoped>
.chat-option {
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    padding: 12px 16px;
    color: inherit;
    text-decoration: none;
    border-bottom: 1px solid var(--divider, rgba(0, 0, 0, 0.06));
    transition: background-color 0.18s ease;
}

.chat-option:hover {
    background: var(--hover, rgba(0, 0, 0, 0.03));
    text-decoration: none;
}

.chat-option__avatar {
    flex: 0 0 52px;
    width: 52px;
    height: 52px;
}

.chat-option__image {
    display: block;
    width: 52px;
    height: 52px;
    object-fit: cover;
    border-radius: 999px;
}

.chat-option__content {
    flex: 1;
    min-width: 0;
}

.chat-option__title-row {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 0;
}

.chat-option__title {
    margin: 0;
    min-width: 0;
    font-size: 14px;
    font-weight: 800;
    line-height: 1.2;
    color: var(--text-1, #111827);
}

.chat-option__preview {
    margin: 4px 0 0;
    font-size: 13px;
    line-height: 1.25;
    color: var(--text-2, #6b7280);
}

.chat-option__group-pill {
    flex: 0 0 auto;
    padding: 2px 8px;
    border-radius: 999px;
    border: 1px solid var(--border, rgba(0, 0, 0, 0.08));
    background: var(--surface-3, rgba(0, 0, 0, 0.05));
    color: var(--text-2, #4b5563);
    font-size: 11px;
    font-weight: 700;
    line-height: 1.2;
}

.chat-option__meta {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    justify-content: center;
    gap: 6px;
    min-width: 56px;
    margin-left: auto;
}

.chat-option__time {
    white-space: nowrap;
    font-size: 11.5px;
    line-height: 1;
    color: var(--text-3, #9ca3af);
}

.chat-option__badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 22px;
    height: 22px;
    padding: 0 6px;
    border-radius: 999px;
    background: var(--accent, #3b6ef8);
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    line-height: 1;
}

.chat-option.router-link-active {
    background: var(--accent-bg, rgba(59, 110, 248, 0.08));
}

.chat-option.router-link-active .chat-option__title {
    color: var(--text-1, #111827);
}
</style>

<style>
body.dark-mode .chat-option,
html.dark-mode .chat-option,
.dark-mode .chat-option {
    color: #e9ecef !important;
}

body.dark-mode .chat-option .chat-option__title,
html.dark-mode .chat-option .chat-option__title,
.dark-mode .chat-option .chat-option__title {
    color: #eef0f4 !important;
}

body.dark-mode .chat-option .chat-option__preview,
body.dark-mode .chat-option .chat-option__time,
html.dark-mode .chat-option .chat-option__preview,
html.dark-mode .chat-option .chat-option__time,
.dark-mode .chat-option .chat-option__preview,
.dark-mode .chat-option .chat-option__time {
    color: #a0a9bc !important;
}

body.dark-mode .chat-option .chat-option__group-pill,
html.dark-mode .chat-option .chat-option__group-pill,
.dark-mode .chat-option .chat-option__group-pill {
    background: rgba(255, 255, 255, 0.07) !important;
    border-color: rgba(255, 255, 255, 0.1) !important;
    color: #e9ecef !important;
}

body.dark-mode .chat-option .chat-option__image,
html.dark-mode .chat-option .chat-option__image,
.dark-mode .chat-option .chat-option__image {
    border: 1px solid rgba(255, 255, 255, 0.08);
}
</style>
