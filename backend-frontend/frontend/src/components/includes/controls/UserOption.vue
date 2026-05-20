<template>
    <a
        @click="createPersonalChat"
        class="nav-link"
        role="button"
        :aria-label="$t('user-option.open_chat_with', { name: user.name })"
    >
        <img
            class="nav-icon img-circle elevation-3 my-1"
            :src="user.photo || emptyPhoto"
            :alt="$t('user-option.user_photo')"
        />

        <p class="chat-name">
            {{ user.name || $t("user-option.unknown_user") }}
        </p>

        <br />

        <p class="chat-message">
            {{ user.email || $t("user-option.no_email") }}
        </p>
    </a>
</template>

<script setup>
import emptyPhoto from "@assets/images/emptyuser.png";
import { apiCreateChat } from "@func/api/chat";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import { MessageModal } from "@func/swal";

const router = useRouter();
const { t } = useI18n();

const props = defineProps({
    user: {
        type: Object,
        required: true,
    },
});

async function createPersonalChat() {
    try {
        const response = await apiCreateChat({
            type: "personal",
            user_ids: [props.user.id],
        });

        window.dispatchEvent(
            new CustomEvent("chatUpdated", {
                detail: response.data.chat,
            })
        );

        router.push({
            name: "chats",
            params: { chatId: response.data.chat.id },
        });
    } catch (error) {
        return MessageModal(
            "error",
            t("user-option.error_title"),
            error?.response?.data?.message ||
            error?.message ||
            t("user-option.error_message")
        );
    }
}
</script>
