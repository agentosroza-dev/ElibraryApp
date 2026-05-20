<template>
    <div class="login-page" :style="pageBackgroundStyle">
        <div class="login-overlay"></div>

        <div class="login-layout">
            <div class="login-side-content">
                <span class="brand-badge">Police Academy of Cambodia</span>
                <h2 class="side-title">Digital Knowledge for Police Academy</h2>
                <p class="side-text">
                    Access books, legal documents, and academic resources in one
                    secure digital library platform.
                </p>
            </div>

            <div class="login-panel-wrap">
                <div class="login-panel">
                    <div class="logo-wrapper">
                        <img
                            :src="logoImage"
                            alt="PAC E-Library"
                            class="logo-image"
                        />
                        <h1 class="login-title">Welcome Back</h1>
                        <p class="login-subtitle">
                            Sign in to access your account
                        </p>
                    </div>

                    <form @submit.prevent="signIn" novalidate class="login-form">
                        <div class="form-group">
                            <label for="email" class="form-label">Email</label>
                            <div
                                class="input-wrapper"
                                :class="{ 'has-error': !!userError.email }"
                            >
                                <i class="fas fa-envelope input-icon"></i>
                                <input
                                    id="email"
                                    v-model.trim="user.email"
                                    type="email"
                                    class="form-input"
                                    placeholder="Enter your email"
                                    autocomplete="email"
                                />
                            </div>
                            <small v-if="userError.email" class="error-text">
                                {{ userError.email }}
                            </small>
                        </div>

                        <div class="form-group">
                            <label for="password" class="form-label">Password</label>
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
                                    placeholder="Enter your password"
                                    autocomplete="current-password"
                                />
                                <button
                                    type="button"
                                    class="toggle-password"
                                    @click="togglePassword"
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

                        <button
                            type="submit"
                            class="btn-login"
                            :disabled="isSubmitting"
                        >
                            {{ isSubmitting ? "Signing In..." : "Sign In" }}
                        </button>
                    </form>


                    <!--                    <div class="social-auth-links text-center mt-2 mb-3">-->
                    <!--                        <button @click="googleSignIn" class="btn btn-block btn-danger">-->
                    <!--                            <i class="fab fa-google-plus mr-2"></i> Sign in using Google+-->
                    <!--                        </button>-->
                    <!--                    </div>-->

                    <div class="extra-links">
                        <router-link :to="{ name: 'auth.reset.password' }">
                            Forgot password?
                        </router-link>
                    </div>

                    <!--                    <p class="mb-0">-->
                    <!--                        <router-link :to="{ name: 'auth.signup' }" class="text-center"-->
                    <!--                        >Register a new membership-->
                    <!--                        </router-link-->
                    <!--                        >-->
                    <!--                    </p>-->

                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { computed, reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { useStore } from "vuex";
import { postSignIn } from "@func/api/auth";
import { MessageModal, CloseModal } from "@func/swal";

import campusImage from "@/assets/images/PAC_location.jpg";
import logoImage from "@/assets/images/PAC_E-Library.png";

const router = useRouter();
const store = useStore();

const isSubmitting = ref(false);
const showPassword = ref(false);

const user = reactive({
    email: "",
    password: "",
});

const userError = reactive({
    email: "",
    password: "",
});

const pageBackgroundStyle = computed(() => ({
    backgroundImage: `url(${campusImage})`,
}));

function clearErrors() {
    userError.email = "";
    userError.password = "";
}

function resetForm() {
    user.email = "";
    user.password = "";
    clearErrors();
    showPassword.value = false;
}

function togglePassword() {
    showPassword.value = !showPassword.value;
}

import { getPublicIP } from "@func/api/loginHistory.js";


// async function signIn() {
//     if (isSubmitting.value) return;
//
//     clearErrors();
//     isSubmitting.value = true;
//
//     try {
//         let ip = null;
//
//         try {
//             ip = await getPublicIP();
//         } catch {
//             ip = null;
//         }
//
//         const payload = {
//             email: String(user.email || "").trim(),
//             password: String(user.password || ""),
//         };
//
//         if (ip) {
//             payload.ip_address = ip;
//         }
//
//         const response = await postSignIn(payload);
//
//         const token = response?.data?.token;
//         if (token) {
//             localStorage.setItem("auth_token", token);
//             localStorage.setItem("token", token);
//         }
//
//         await store.dispatch("verifyAccount");
//
//         const intendedPath = localStorage.getItem("intendedPath");
//         resetForm();
//
//         if (intendedPath) {
//             localStorage.removeItem("intendedPath");
//             await router.replace(intendedPath);
//         } else {
//             await router.replace({ name: "dashboard" });
//         }
//
//         CloseModal();
//     } catch (error) {
//         const response = error?.response;
//
//         if (!response) {
//             MessageModal("error", "Error", error?.message || "Sign in failed.");
//             return;
//         }
//
//         if (response.status === 422) {
//             const errors = response?.data?.errors || {};
//             userError.email = errors.email?.[0] || "";
//             userError.password = errors.password?.[0] || "";
//             CloseModal();
//             return;
//         }
//
//         MessageModal(
//             "error",
//             "Error",
//             response?.data?.message || "Unable to sign in."
//         );
//     } finally {
//         isSubmitting.value = false;
//     }
// }
async function signIn() {
    if (isSubmitting.value) return;

    clearErrors();
    isSubmitting.value = true;

    try {
        let ip = null;

        // ✅ prevent slow API blocking login
        try {
            ip = await Promise.race([
                getPublicIP(),
                new Promise((resolve) => setTimeout(() => resolve(null), 1500)),
            ]);
        } catch {
            ip = null;
        }

        const payload = {
            email: String(user.email || "").trim(),
            password: String(user.password || ""),
        };

        if (ip) {
            payload.ip_address = ip;
        }

        const { data } = await postSignIn(payload);

        const token = data?.token;

        if (!token) {
            throw new Error("Token not received");
        }

        // ✅ unified token
        localStorage.setItem("auth_token", token);
        localStorage.setItem("token", token);

        await store.dispatch("verifyAccount");

        const intendedPath = localStorage.getItem("intendedPath");

        resetForm();

        if (intendedPath) {
            localStorage.removeItem("intendedPath");
            await router.replace(intendedPath);
        } else {
            await router.replace({ name: "dashboard" });
        }

        CloseModal();
    } catch (error) {
        console.error("SignIn error:", error);

        const response = error?.response;

        if (!response) {
            MessageModal(
                "error",
                "Connection Error",
                error?.message || "Unable to connect to server."
            );
            return;
        }

        if (response.status === 422) {
            const errors = response?.data?.errors || {};
            userError.email = errors.email?.[0] || "";
            userError.password = errors.password?.[0] || "";
            CloseModal();
            return;
        }

        MessageModal(
            "error",
            "Error",
            response?.data?.message || "Unable to sign in."
        );
    } finally {
        isSubmitting.value = false;
    }
}


</script>

<style scoped>
:global(body.login-page),
:global(body) {
    margin: 0;
}

/* 60% white/light
   30% navy
   10% orange */

.login-page {
    position: relative;
    min-height: 100vh;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
    overflow: hidden;
}

.login-overlay {
    position: absolute;
    inset: 0;
    background:
        linear-gradient(
            90deg,
            rgba(10, 46, 92, 0.68) 0%,
            rgba(10, 46, 92, 0.45) 35%,
            rgba(248, 250, 252, 0.20) 65%,
            rgba(248, 250, 252, 0.08) 100%
        );
}

.login-layout {
    position: relative;
    z-index: 1;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 32px;
    padding: 32px 48px;
}

.login-side-content {
    width: 100%;
    max-width: 520px;
    color: #ffffff;
}

.brand-badge {
    display: inline-flex;
    align-items: center;
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
    margin: 18px 0 12px;
    font-size: 44px;
    line-height: 1.15;
    font-weight: 800;
}

.side-text {
    margin: 0;
    max-width: 460px;
    font-size: 16px;
    line-height: 1.8;
    color: rgba(255, 255, 255, 0.92);
}

.login-panel-wrap {
    width: 100%;
    max-width: 520px;
    display: flex;
    justify-content: flex-end;
}

.login-panel {
    width: 100%;
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
    width: 100px;
    height: auto;
    display: inline-block;
    margin-bottom: 12px;
}

.login-title {
    margin: 0;
    color: #0a2e5c;
    font-size: 32px;
    font-weight: 800;
    line-height: 1.2;
}

.login-subtitle {
    margin: 8px 0 0;
    color: #64748b;
    font-size: 14px;
    line-height: 1.6;
}

.login-form {
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
}

.btn-login {
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

.btn-login:hover:not(:disabled) {
    background: #1e7e34;
    transform: translateY(-1px);
}

.btn-login:disabled {
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

@media (max-width: 1199.98px) {
    .login-layout {
        padding: 28px 32px;
    }

    .side-title {
        font-size: 38px;
    }

    .login-panel {
        padding: 34px 28px;
    }
}

@media (max-width: 991.98px) {
    .login-layout {
        flex-direction: column;
        justify-content: center;
        align-items: stretch;
        padding: 24px;
    }

    .login-side-content {
        max-width: 100%;
        text-align: center;
    }

    .side-text {
        max-width: 100%;
    }

    .login-panel-wrap {
        max-width: 100%;
        justify-content: center;
    }

    .login-panel {
        max-width: 560px;
        margin: 0 auto;
    }
}

@media (max-width: 767.98px) {
    .login-overlay {
        background:
            linear-gradient(
                180deg,
                rgba(10, 46, 92, 0.72) 0%,
                rgba(10, 46, 92, 0.52) 40%,
                rgba(10, 46, 92, 0.38) 100%
            );
    }

    .login-layout {
        padding: 18px;
    }

    .login-side-content {
        display: none;
    }

    .login-panel {
        padding: 28px 20px;
        border-radius: 22px;
    }

    .logo-image {
        width: 88px;
    }

    .login-title {
        font-size: 28px;
    }
}
</style>
