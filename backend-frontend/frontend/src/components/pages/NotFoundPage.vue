<template>
    <div class="notfound-wrapper d-flex align-items-center justify-content-center">
        <div class="notfound-card text-center">
            <div class="notfound-code">404</div>

            <h2 class="notfound-title">Page Not Found</h2>

            <p class="notfound-text">
                Sorry, the page you are looking for doesn’t exist or has been moved.
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
.notfound-wrapper {
    min-height: 100vh;
    background: linear-gradient(135deg, #f8fafc, #e9ecef);
    padding: 20px;
}

.notfound-card {
    max-width: 480px;
    width: 100%;
    background: #fff;
    border-radius: 20px;
    padding: 40px 30px;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
}

.notfound-code {
    font-size: 90px;
    font-weight: 800;
    color: #dc3545;
    line-height: 1;
}

.notfound-title {
    font-size: 24px;
    font-weight: 700;
    margin-top: 10px;
    color: #343a40;
}

.notfound-text {
    color: #6c757d;
    margin-top: 10px;
    font-size: 0.95rem;
}

.gap-2 {
    gap: 0.5rem;
}

/* Dark mode support */
body.dark-mode .notfound-wrapper {
    background: linear-gradient(135deg, #1f2937, #111827);
}

body.dark-mode .notfound-card {
    background: #2b3035;
    color: #e5e7eb;
}

body.dark-mode .notfound-title {
    color: #f9fafb;
}

body.dark-mode .notfound-text {
    color: #cbd5e1;
}
</style>
