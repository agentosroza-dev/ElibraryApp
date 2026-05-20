<template>
    <div class="auth-page" :style="pageBackgroundStyle">
        <div class="auth-overlay"></div>

        <div class="auth-layout">
            <div class="auth-top-content">
                <span class="brand-badge">Police Academy of Cambodia</span>
                <p class="side-text">
                    Set a strong new password to protect your account and continue
                    using the PAC E-Library platform securely.
                </p>
            </div>

            <div class="auth-panel-wrap">
                <div class="auth-panel">
                    <div class="logo-wrapper">
                        <img
                            :src="logoImage"
                            alt="PAC E-Library"
                            class="logo-image"
                        />
                        <h1 class="auth-title">Set New Password</h1>
                        <p class="auth-subtitle">
                            Enter your new password below
                        </p>
                    </div>

                    <form
                        @submit.prevent="setNewPassword"
                        novalidate
                        class="auth-form"
                    >
                        <div class="form-group">
                            <label for="password" class="form-label">
                                New Password
                            </label>

                            <div
                                class="input-wrapper"
                                :class="{ 'has-error': !!userError.password }"
                            >
                                <i class="fas fa-lock input-icon"></i>
                                <input
                                    id="password"
                                    v-model="user.password"
                                    :type="showPassword ? 'text' : 'password'"
                                    class="form-input"
                                    placeholder="Enter new password"
                                    autocomplete="new-password"
                                />
                                <button
                                    type="button"
                                    class="toggle-password"
                                    @click="showPassword = !showPassword"
                                    aria-label="Toggle password visibility"
                                >
                                    <i
                                        :class="
                                            showPassword
                                                ? 'fas fa-eye-slash'
                                                : 'fas fa-eye'
                                        "
                                    ></i>
                                </button>
                            </div>

                            <small v-if="userError.password" class="error-text">
                                {{ userError.password }}
                            </small>
                        </div>

                        <div class="form-group">
                            <label
                                for="password_confirmation"
                                class="form-label"
                            >
                                Confirm Password
                            </label>

                            <div
                                class="input-wrapper"
                                :class="{
                                    'has-error': !!userError.password_confirmation
                                }"
                            >
                                <i class="fas fa-lock input-icon"></i>
                                <input
                                    id="password_confirmation"
                                    v-model="user.password_confirmation"
                                    :type="showConfirmPassword ? 'text' : 'password'"
                                    class="form-input"
                                    placeholder="Confirm new password"
                                    autocomplete="new-password"
                                />
                                <button
                                    type="button"
                                    class="toggle-password"
                                    @click="showConfirmPassword = !showConfirmPassword"
                                    aria-label="Toggle confirm password visibility"
                                >
                                    <i
                                        :class="
                                            showConfirmPassword
                                                ? 'fas fa-eye-slash'
                                                : 'fas fa-eye'
                                        "
                                    ></i>
                                </button>
                            </div>

                            <small
                                v-if="userError.password_confirmation"
                                class="error-text"
                            >
                                {{ userError.password_confirmation }}
                            </small>
                        </div>

                        <button
                            type="submit"
                            class="btn-submit"
                            :disabled="isSubmitting"
                        >
                            {{
                                isSubmitting
                                    ? "Resetting Password..."
                                    : "Reset Password"
                            }}
                        </button>
                    </form>

                    <div class="extra-links">
                        <router-link :to="{ name: 'auth.signin' }">
                            Go back to login
                        </router-link>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import axios from "axios";
import Swal from "sweetalert2";
import { computed, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { LoadingModal, MessageModal, CloseModal } from "@func/swal";

import campusImage from "@/assets/images/PAC_location.jpg";
import logoImage from "@/assets/images/PAC_E-Library.png";

const route = useRoute();
const router = useRouter();

const isSubmitting = ref(false);
const showPassword = ref(false);
const showConfirmPassword = ref(false);

const user = reactive({
    password: "",
    password_confirmation: "",
});

const userError = reactive({
    password: "",
    password_confirmation: "",
});

const pageBackgroundStyle = computed(() => ({
    backgroundImage: `url(${campusImage})`,
}));

function clearErrors() {
    userError.password = "";
    userError.password_confirmation = "";
}

function resetData() {
    user.password = "";
    user.password_confirmation = "";
    clearErrors();
    showPassword.value = false;
    showConfirmPassword.value = false;
}

async function setNewPassword() {
    if (isSubmitting.value) return;

    clearErrors();
    isSubmitting.value = true;

    try {
        LoadingModal();

        const response = await axios.post(new URL(route.params.api_url), {
            password: user.password,
            password_confirmation: user.password_confirmation,
        });

        resetData();

        await Swal.fire({
            title: response?.data?.message || "Password reset successfully.",
            text: "You can now sign in with your new password.",
            icon: "success",
            confirmButtonColor: "#28a745",
            confirmButtonText: "Go to Sign In",
        });

        router.push({ name: "auth.signin" });
    } catch (error) {
        const response = error?.response;

        if (!response) {
            MessageModal("error", "Error", error?.message || "Reset failed.");
            return;
        }

        if (response.status === 422) {
            const errors = response?.data?.errors || {};
            userError.password = errors.password?.[0] || "";
            userError.password_confirmation =
                errors.password_confirmation?.[0] || "";
            CloseModal();
            return;
        }

        MessageModal(
            "error",
            "Error",
            response?.data?.message || "Unable to reset password."
        );
    } finally {
        isSubmitting.value = false;
    }
}
</script>

<style scoped>
.auth-page {
    position: relative;
    min-height: 100vh;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
    overflow: hidden;
}

.auth-overlay {
    position: absolute;
    inset: 0;
    background:
        linear-gradient(
            180deg,
            rgba(10, 46, 92, 0.50) 0%,
            rgba(10, 46, 92, 0.34) 38%,
            rgba(248, 250, 252, 0.10) 100%
        );
}

.auth-layout {
    position: relative;
    z-index: 1;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 24px;
    gap: 28px;
}

.auth-top-content {
    width: 100%;
    max-width: 720px;
    text-align: center;
    color: #ffffff;
}

.brand-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 38px;
    padding: 0 16px;
    border-radius: 999px;
    background: rgba(242, 101, 34, 0.95);
    color: #ffffff;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.4px;
    box-shadow: 0 8px 20px rgba(242, 101, 34, 0.22);
}

.side-title {
    margin: 16px 0 12px;
    font-size: 42px;
    line-height: 1.15;
    font-weight: 800;
}

.side-text {
    margin: 0 auto;
    max-width: 560px;
    font-size: 16px;
    line-height: 1.8;
    color: rgba(255, 255, 255, 0.94);
}

.auth-panel-wrap {
    width: 100%;
    display: flex;
    justify-content: center;
}

.auth-panel {
    width: 100%;
    max-width: 520px;
    padding: 40px 36px;
    border-radius: 28px;
    background: rgba(255, 255, 255, 0.96);
    border: 1px solid rgba(255, 255, 255, 0.45);
    box-shadow:
        0 20px 60px rgba(15, 23, 42, 0.16),
        0 8px 24px rgba(15, 23, 42, 0.08);
    backdrop-filter: blur(10px);
}

.logo-wrapper {
    text-align: center;
    margin-bottom: 28px;
}

.logo-image {
    width: 96px;
    height: auto;
    display: inline-block;
    margin-bottom: 12px;
}

.auth-title {
    margin: 0;
    color: #0a2e5c;
    font-size: 32px;
    font-weight: 800;
    line-height: 1.2;
    text-align: center;
}

.auth-subtitle {
    margin: 8px 0 0;
    color: #64748b;
    font-size: 14px;
    line-height: 1.6;
    text-align: center;
}

.auth-form {
    margin-top: 10px;
}

.form-group {
    margin-bottom: 18px;
}

.form-label {
    display: block;
    margin-bottom: 8px;
    color: #1e293b;
    font-size: 14px;
    font-weight: 700;
    text-align: left;
}

.input-wrapper {
    display: flex;
    align-items: center;
    gap: 12px;
    min-height: 54px;
    padding: 0 16px;
    border: 1px solid #d7dee8;
    border-radius: 14px;
    background: #ffffff;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.input-wrapper:focus-within {
    border-color: #0a2e5c;
    box-shadow: 0 0 0 4px rgba(10, 46, 92, 0.08);
}

.input-wrapper.has-error {
    border-color: #dc3545;
}

.input-icon {
    color: #94a3b8;
    font-size: 15px;
}

.form-input {
    flex: 1;
    width: 100%;
    border: 0;
    outline: 0;
    background: transparent;
    color: #0f172a;
    font-size: 15px;
}

.form-input::placeholder {
    color: #94a3b8;
}

.toggle-password {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 0;
    padding: 0;
    background: transparent;
    color: #94a3b8;
    cursor: pointer;
}

.error-text {
    display: block;
    margin-top: 6px;
    color: #dc3545;
    font-size: 12px;
    font-weight: 600;
    text-align: left;
}

.btn-submit {
    width: 100%;
    min-height: 54px;
    margin-top: 8px;
    border: 0;
    border-radius: 14px;
    background: #0a2e5c;
    color: #ffffff;
    font-size: 16px;
    font-weight: 800;
    cursor: pointer;
    transition: background-color 0.2s ease, transform 0.2s ease;
    box-shadow: 0 12px 24px rgba(242, 101, 34, 0.24);
}

.btn-submit:hover:not(:disabled) {
    background: #1e7e34;
    transform: translateY(-1px);
}

.btn-submit:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    box-shadow: none;
}

.extra-links {
    margin-top: 18px;
    text-align: center;
}

.extra-links a {
    color: #0a2e5c;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
}

.extra-links a:hover {
    text-decoration: underline;
}

@media (max-width: 767.98px) {
    .auth-layout {
        padding: 18px;
        gap: 20px;
    }

    .side-title {
        font-size: 28px;
    }

    .side-text {
        font-size: 15px;
        line-height: 1.7;
    }

    .auth-panel {
        padding: 28px 20px;
        border-radius: 22px;
    }

    .logo-image {
        width: 84px;
    }

    .auth-title {
        font-size: 26px;
    }
}
</style>
