<template>
    <div class="forbidden-wrapper d-flex align-items-center justify-content-center">
        <div class="forbidden-card text-center">
            <div class="forbidden-code">403</div>

            <h2 class="forbidden-title">Access Forbidden</h2>

            <p class="forbidden-text">
                You don’t have permission to access this page.
            </p>

            <div class="mt-4 d-flex justify-content-center gap-2 flex-wrap">
                <router-link
                    :to="{ name: 'dashboard' }"
                    class="btn btn-primary"
                >
                    <i class="fas fa-home mr-1"></i>
                    Go to Dashboard
                </router-link>

                <button
                    class="btn btn-outline-secondary"
                    @click="goBack"
                >
                    <i class="fas fa-arrow-left mr-1"></i>
                    Go Back
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { useRouter } from "vue-router";

const router = useRouter();

function goBack() {
    if (window.history.length > 1) {
        router.back();
    } else {
        router.push({ name: "dashboard" });
    }
}
</script>

<style scoped>
.forbidden-wrapper {
    min-height: 100vh;
    background: linear-gradient(135deg, #fff7ed, #ffe4e6);
    padding: 20px;
}

.forbidden-card {
    max-width: 480px;
    width: 100%;
    background: #fff;
    border-radius: 20px;
    padding: 40px 30px;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
}

.forbidden-code {
    font-size: 90px;
    font-weight: 800;
    color: #dc3545;
    line-height: 1;
}

.forbidden-title {
    font-size: 24px;
    font-weight: 700;
    margin-top: 10px;
    color: #343a40;
}

.forbidden-text {
    color: #6c757d;
    margin-top: 10px;
    font-size: 0.95rem;
}

.gap-2 {
    gap: 0.5rem;
}

/* Dark mode */
body.dark-mode .forbidden-wrapper {
    background: linear-gradient(135deg, #1f2937, #111827);
}

body.dark-mode .forbidden-card {
    background: #2b3035;
    color: #e5e7eb;
}

body.dark-mode .forbidden-title {
    color: #f9fafb;
}

body.dark-mode .forbidden-text {
    color: #cbd5e1;
}
</style>

