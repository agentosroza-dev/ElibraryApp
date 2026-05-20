<template></template>


<script setup>
import Swal from "sweetalert2";
import { onMounted } from "vue";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";

import { postSignOut } from "@/functions/api/auth";
import { MessageModal } from "@func/swal";

const router = useRouter();
const { t } = useI18n();

onMounted(async () => {
    const result = await Swal.fire({
        title: t("logout.confirm_title"),
        text: t("logout.confirm_text"),
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: t("logout.confirm_button"),
        cancelButtonText: t("logout.cancel_button"),
    });

    if (!result.isConfirmed) {
        router.back();
        return;
    }

    try {
        const token =
            localStorage.getItem("auth_token") ||
            localStorage.getItem("token") ||
            "";

        await postSignOut(token);

        localStorage.removeItem("auth_token");
        localStorage.removeItem("token");
        localStorage.removeItem("user");

        router.replace({ name: "auth.signin" });
    } catch (error) {
        MessageModal(
            "error",
            t("logout.error_title"),
            error?.response?.data?.message || error?.message || t("logout.error_message")
        );
    }
});
</script>
