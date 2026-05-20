<template>
    <div class="content-wrapper" style="min-height: 1416px">
        <!-- Header -->
        <!--        <section class="content-header">-->
        <!--            <div class="container-fluid d-flex justify-content-between align-items-center">-->
        <!--                <div>-->
        <!--                    <h1>PDF Viewer</h1>-->
        <!--                    <small class="text-muted">-->
        <!--                        {{ title || "Open PDF from Google Drive" }}-->
        <!--                    </small>-->
        <!--                </div>-->

        <!--                &lt;!&ndash; Back to items list &ndash;&gt;-->
        <!--                <router-link :to="{ name: 'items.index' }" class="btn btn-secondary btn-sm">-->
        <!--                    <i class="fas fa-arrow-left mr-1"></i>-->
        <!--                    Back-->
        <!--                </router-link>-->
        <!--            </div>-->
        <!--        </section>-->

        <!-- Content -->
        <section class="content">
            <div class="container-fluid">

                <!-- Loading -->
                <div v-if="loading" class="text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x"></i>
                    <div class="text-muted mt-2">Loading PDF…</div>
                </div>

                <!-- Error -->
                <div v-else-if="error" class="alert alert-danger">
                    <b>Error:</b> {{ error }}
                    <div class="mt-2 small text-muted">
                        Tip: Google Drive file must be shared as “Anyone with the link”.
                    </div>
                </div>

                <!-- Iframe -->
                <div v-else class="card shadow-sm">
                    <div class="card-header d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-file-pdf text-danger mr-2"></i>
                            <b class="text-truncate" style="max-width: 520px;">{{ title || "PDF Preview" }}</b>
                        </div>

                        <div class="d-flex gap-2">
                            <a
                                v-if="rawFileUrl"
                                :href="rawFileUrl"
                                target="_blank"
                                rel="noopener"
                                class="btn btn-sm btn-outline-primary"
                            >
                                Open Original
                            </a>
                            <a
                                v-if="previewUrl"
                                :href="previewUrl"
                                target="_blank"
                                rel="noopener"
                                class="btn btn-sm btn-primary"
                            >
                                Open Preview
                            </a>
                        </div>
                    </div>

                    <div class="card-body p-0">
                        <iframe
                            v-if="previewUrl"
                            :src="previewUrl"
                            style="width:100%; height: 80vh; border: none;"
                            @load="onIframeLoad"
                        ></iframe>

                        <div v-else class="p-4 text-muted">
                            No PDF URL provided.
                        </div>
                    </div>
                </div>

                <!-- Debug (optional) -->
                <div v-if="debug" class="mt-3 small text-muted">
                    <div><b>rawFileUrl:</b> {{ rawFileUrl }}</div>
                    <div><b>previewUrl:</b> {{ previewUrl }}</div>
                </div>

            </div>
        </section>
    </div>
</template>

<script setup>
import { computed, ref, watchEffect } from "vue";
import { useRoute } from "vue-router";

const route = useRoute();

const loading = ref(true);
const error = ref("");
const debug = ref(false); // set true if you want to see URLs on screen

// Read query params: /items/pdf?file=...&title=...
const rawFileUrl = computed(() => {
    const file = route.query.file;

    // If your link is encoded, Vue Router returns decoded string already,
    // but sometimes you might receive it still encoded.
    if (!file) return "";

    try {
        // If it's percent-encoded, decode it; if not, this won't hurt
        return decodeURIComponent(String(file));
    } catch {
        return String(file);
    }
});

const title = computed(() => {
    const t = route.query.title;
    if (!t) return "";
    try {
        return decodeURIComponent(String(t));
    } catch {
        return String(t);
    }
});

// Extract Google Drive file id from many possible formats
const extractDriveFileId = (url) => {
    if (!url) return "";

    // common: https://drive.google.com/file/d/<ID>/view
    const m1 = url.match(/\/file\/d\/([^/]+)/);
    if (m1?.[1]) return m1[1];

    // alternate: https://drive.google.com/open?id=<ID>
    const m2 = url.match(/[?&]id=([^&]+)/);
    if (m2?.[1]) return m2[1];

    // alternate: https://drive.google.com/uc?id=<ID>&export=download
    const m3 = url.match(/\/uc\?id=([^&]+)/);
    if (m3?.[1]) return m3[1];

    return "";
};

// ✅ Best iframe URL for Drive: /preview
const previewUrl = computed(() => {
    const url = rawFileUrl.value;
    if (!url) return "";

    // If it's a Google Drive link, convert to /preview
    if (url.includes("drive.google.com")) {
        const fileId = extractDriveFileId(url);
        if (!fileId) return "";
        return `https://drive.google.com/file/d/${fileId}/preview`;
    }

    // If it's not Drive, you can fallback to Google viewerng
    // WARNING: viewerng needs public URL accessible by Google
    return `https://drive.google.com/viewerng/viewer?embedded=true&url=${encodeURIComponent(url)}`;
});

const onIframeLoad = () => {
    loading.value = false;
};

watchEffect(() => {
    loading.value = true;
    error.value = "";

    if (!rawFileUrl.value) {
        loading.value = false;
        error.value = "Missing ?file= parameter.";
        return;
    }

    // If drive URL but cannot extract ID, fail early
    if (rawFileUrl.value.includes("drive.google.com") && !extractDriveFileId(rawFileUrl.value)) {
        loading.value = false;
        error.value = "Invalid Google Drive file link. Cannot extract file ID.";
    }
});
</script>
