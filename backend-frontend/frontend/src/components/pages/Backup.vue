<template>
    <div class="content-wrapper backup-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2 align-items-center">
                    <div class="col-sm-6">
                        <h1 class="mb-1">Backup Management</h1>
                        <p class="text-muted mb-0">Create and manage your backup files.</p>
                    </div>

                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right mb-0">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">Home</router-link>
                            </li>
                            <li class="breadcrumb-item active">Backups</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <!-- Toolbar -->
                <div class="card backup-toolbar-card shadow-sm">
                    <div class="card-body">
                        <div class="backup-toolbar">
                            <div class="backup-toolbar__left">
                                <div class="backup-icon">
                                    <i class="fas fa-database"></i>
                                </div>

                                <div>
                                    <h3 class="backup-toolbar__title mb-1">Backup Center</h3>
                                    <p class="backup-toolbar__text mb-0">
                                        Search, create, download, and delete backup files.
                                    </p>
                                </div>
                            </div>

                            <div class="backup-toolbar__right">
                                <div class="search-box">
                                    <i class="fas fa-search search-box__icon"></i>
                                    <input
                                        v-model.trim="search"
                                        type="text"
                                        class="form-control search-box__input"
                                        placeholder="Search backup file..."
                                    />
                                    <button
                                        v-if="search"
                                        type="button"
                                        class="search-box__clear"
                                        @click="search = ''"
                                    >
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>

                                <button
                                    type="button"
                                    class="btn btn-outline-secondary btn-toolbar-action"
                                    :disabled="loading"
                                    @click="fetchBackups"
                                >
                                    <i class="fas fa-sync-alt mr-1"></i>
                                    Refresh
                                </button>

                                <button
                                    type="button"
                                    class="btn btn-success btn-toolbar-action"
                                    :disabled="loading"
                                    @click="createBackup"
                                >
                                    <i class="fas fa-plus mr-1"></i>
                                    Create Backup
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Summary -->
                <div class="row mb-3">
                    <div class="col-md-4 col-sm-6 col-12">
                        <div class="small-box bg-info">
                            <div class="inner">
                                <h3>{{ backups.length }}</h3>
                                <p>Total Backups</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-archive"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4 col-sm-6 col-12">
                        <div class="small-box bg-success">
                            <div class="inner">
                                <h3>{{ filteredBackups.length }}</h3>
                                <p>Search Results</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-search"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4 col-sm-12 col-12">
                        <div class="small-box bg-secondary">
                            <div class="inner">
                                <h3>{{ latestBackupDate }}</h3>
                                <p>Latest Backup</p>
                            </div>
                            <div class="icon">
                                <i class="fas fa-clock"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Table -->
                <div class="card backup-table-card shadow-sm">
                    <div class="card-header border-0">
                        <div class="d-flex justify-content-between align-items-center flex-wrap">
                            <h3 class="card-title mb-2 mb-md-0">Backup File List</h3>
                            <span class="badge badge-light backup-count-badge">
                                {{ filteredBackups.length }} item(s)
                            </span>
                        </div>
                    </div>

                    <div class="card-body p-0">
                        <div v-if="loading" class="backup-state">
                            <i class="fas fa-spinner fa-spin backup-state__icon"></i>
                            <p class="mb-0">Loading backups...</p>
                        </div>

                        <div v-else-if="filteredBackups.length === 0" class="backup-state">
                            <i class="fas fa-folder-open backup-state__icon"></i>
                            <h5 class="mb-2">
                                {{ backups.length === 0 ? "No backups available" : "No matching backups found" }}
                            </h5>
                            <p class="text-muted mb-0">
                                {{
                                    backups.length === 0
                                        ? "Create a new backup to get started."
                                        : "Try another search keyword."
                                }}
                            </p>
                        </div>

                        <div v-else class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                <tr>
                                    <th style="width: 70px">#</th>
                                    <th>File Name</th>
                                    <th style="width: 150px">Size</th>
                                    <th style="width: 220px">Created Date</th>
                                    <th style="width: 240px" class="text-center">Actions</th>
                                </tr>
                                </thead>

                                <tbody>
                                <tr v-for="(backup, index) in filteredBackups" :key="backup.name">
                                    <td>
                                        <span class="backup-index">{{ index + 1 }}</span>
                                    </td>

                                    <td>
                                        <div class="backup-file-cell">
                                            <div class="backup-file-icon">
                                                <i class="fas fa-file-archive"></i>
                                            </div>
                                            <div class="backup-file-info">
                                                <div class="backup-file-name">
                                                    {{ formatBackupName(backup.name) }}
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                            <span class="badge badge-info px-3 py-2">
                                                {{ backup.size_human || "-" }}
                                            </span>
                                    </td>

                                    <td>
                                        <div class="backup-date">
                                            {{ backup.date_human || "-" }}
                                        </div>
                                    </td>

                                    <td class="text-center">
                                        <div class="btn-group-actions">
                                            <button
                                                type="button"
                                                class="btn btn-primary btn-sm"
                                                :disabled="actionLoading === backup.name"
                                                @click="downloadBackup(backup.name)"
                                            >
                                                <i class="fas fa-download mr-1"></i>
                                                Download
                                            </button>

                                            <button
                                                type="button"
                                                class="btn btn-danger btn-sm"
                                                :disabled="actionLoading === backup.name"
                                                @click="deleteBackup(backup.name)"
                                            >
                                                <i class="fas fa-trash mr-1"></i>
                                                Delete
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import Swal from "sweetalert2";
import { MessageModal, LoadingModal, CloseModal } from "@func/swal";
import {
    apiGetBackups,
    apiCreateBackup,
    apiDownloadBackup,
    apiDeleteBackup,
} from "@func/api/backup";
import { downloadBlobResponse } from "@func/download";

const backups = ref([]);
const loading = ref(false);
const actionLoading = ref("");
const search = ref("");

function ensureZipExtension(filename) {
    const name = String(filename || "").trim();
    if (!name) return "backup.zip";
    return name.toLowerCase().endsWith(".zip") ? name : `${name}.zip`;
}

function formatBackupName(filename) {
    return ensureZipExtension(filename);
}

const filteredBackups = computed(() => {
    const keyword = search.value.toLowerCase().trim();

    if (!keyword) return backups.value;

    return backups.value.filter((backup) =>
        formatBackupName(backup.name).toLowerCase().includes(keyword)
    );
});

const latestBackupDate = computed(() => {
    if (!backups.value.length) return "-";
    return backups.value[0]?.date_human || "-";
});

async function fetchBackups() {
    try {
        loading.value = true;
        const response = await apiGetBackups();
        backups.value = Array.isArray(response.data?.backups) ? response.data.backups : [];
    } catch (error) {
        MessageModal("error", "Error", error?.response?.data?.message || error.message);
    } finally {
        loading.value = false;
    }
}

onMounted(() => {
    fetchBackups();
});

async function createBackup() {
    const result = await Swal.fire({
        title: "Create Backup",
        text: "Select backup type",
        icon: "question",
        input: "select",
        inputOptions: {
            db: "Database Only",
            files: "Files Only",
            full: "All Data",
        },
        inputPlaceholder: "Select backup type",
        showCancelButton: true,
        confirmButtonText: "Create Backup",
        confirmButtonColor: "#28a745",
        cancelButtonText: "Cancel",
        inputValidator: (value) => {
            if (!value) {
                return "Please select backup type";
            }
        },
    });

    if (!result.isConfirmed) return;

    try {
        LoadingModal();

        const response = await apiCreateBackup({
            flag: result.value,
        });

        CloseModal();
        await MessageModal("success", "Success", response.data?.message || "Backup created successfully");
        await fetchBackups();
    } catch (error) {
        CloseModal();
        MessageModal("error", "Error", error?.response?.data?.message || error.message);
    }
}

async function downloadBackup(filename) {
    try {
        actionLoading.value = filename;
        LoadingModal();

        const response = await apiDownloadBackup(filename);
        downloadBlobResponse(response, ensureZipExtension(filename));

        CloseModal();
    } catch (error) {
        CloseModal();
        MessageModal("error", "Error", error?.response?.data?.message || error.message);
    } finally {
        actionLoading.value = "";
    }
}

async function deleteBackup(filename) {
    const result = await Swal.fire({
        title: "Delete Backup",
        text: `Are you sure you want to delete "${formatBackupName(filename)}"?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Delete",
        confirmButtonColor: "#dc3545",
        cancelButtonText: "Cancel",
    });

    if (!result.isConfirmed) return;

    try {
        actionLoading.value = filename;
        LoadingModal();

        const response = await apiDeleteBackup(filename);
        backups.value = backups.value.filter((backup) => backup.name !== filename);

        CloseModal();
        MessageModal("success", "Success", response.data?.message || "Backup deleted successfully");
    } catch (error) {
        CloseModal();
        MessageModal("error", "Error", error?.response?.data?.message || error.message);
    } finally {
        actionLoading.value = "";
    }
}
</script>

<style scoped>
.backup-page {
    padding-bottom: 1rem;
}

.backup-toolbar-card,
.backup-table-card {
    border: 0;
    border-radius: 14px;
    overflow: hidden;
}

.backup-toolbar-card .card-body {
    padding: 1.25rem;
}

.backup-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    flex-wrap: wrap;
}

.backup-toolbar__left {
    display: flex;
    align-items: center;
    gap: 1rem;
    min-width: 0;
}

.backup-toolbar__right {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
}

.backup-icon {
    width: 58px;
    height: 58px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #17a2b8, #007bff);
    color: #fff;
    font-size: 1.35rem;
    box-shadow: 0 10px 20px rgba(0, 123, 255, 0.18);
}

.backup-toolbar__title {
    font-size: 1.2rem;
    font-weight: 700;
}

.backup-toolbar__text {
    color: #6c757d;
}

.search-box {
    position: relative;
    width: 280px;
    max-width: 100%;
}

.search-box__icon {
    position: absolute;
    top: 50%;
    left: 12px;
    transform: translateY(-50%);
    color: #6c757d;
    pointer-events: none;
}

.search-box__input {
    height: 40px;
    border-radius: 10px;
    padding-left: 2.25rem;
    padding-right: 2.25rem;
}

.search-box__clear {
    position: absolute;
    top: 50%;
    right: 10px;
    transform: translateY(-50%);
    border: 0;
    background: transparent;
    color: #6c757d;
    cursor: pointer;
    padding: 0;
    line-height: 1;
}

.btn-toolbar-action {
    min-width: 128px;
    border-radius: 10px;
}

.backup-count-badge {
    font-size: 0.85rem;
    border-radius: 999px;
    padding: 0.55rem 0.85rem;
}

.backup-state {
    min-height: 280px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #6c757d;
    text-align: center;
    padding: 2rem 1rem;
}

.backup-state__icon {
    font-size: 2rem;
    margin-bottom: 0.75rem;
}

.table thead th {
    background: #f8f9fa;
    border-bottom: 1px solid #dee2e6;
    font-weight: 700;
}

.table td,
.table th {
    vertical-align: middle;
    padding: 0.9rem 1rem;
}

.backup-index {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: #eef3f8;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    color: #495057;
}

.backup-file-cell {
    display: flex;
    align-items: center;
    gap: 0.85rem;
    min-width: 0;
}

.backup-file-icon {
    width: 42px;
    height: 42px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #fff3cd;
    color: #d39e00;
    flex-shrink: 0;
}

.backup-file-info {
    min-width: 0;
}

.backup-file-name {
    font-weight: 600;
    color: #343a40;
    word-break: break-word;
}

.backup-date {
    color: #495057;
    font-weight: 500;
}

.btn-group-actions {
    display: inline-flex;
    gap: 0.5rem;
    flex-wrap: wrap;
    justify-content: center;
}

.card,
.small-box {
    box-shadow: 0 0.125rem 0.5rem rgba(0, 0, 0, 0.08);
}

/* Dark mode */
:deep(body.dark-mode) .backup-toolbar-card,
:deep(body.dark-mode) .backup-table-card,
:deep(body.dark-mode) .small-box {
    background-color: #1f2d3d !important;
    color: #e9ecef !important;
    box-shadow: 0 0.125rem 0.75rem rgba(0, 0, 0, 0.35);
}

:deep(body.dark-mode) .backup-toolbar__title,
:deep(body.dark-mode) .backup-file-name,
:deep(body.dark-mode) h1,
:deep(body.dark-mode) .card-title,
:deep(body.dark-mode) .breadcrumb-item.active {
    color: #ffffff !important;
}

:deep(body.dark-mode) .backup-toolbar__text,
:deep(body.dark-mode) .backup-state,
:deep(body.dark-mode) .backup-date,
:deep(body.dark-mode) .search-box__icon,
:deep(body.dark-mode) .search-box__clear,
:deep(body.dark-mode) .text-muted {
    color: #bfc7d1 !important;
}

:deep(body.dark-mode) .table thead th {
    background: #243447 !important;
    color: #ffffff !important;
    border-color: #32475b !important;
}

:deep(body.dark-mode) .table td {
    color: #e9ecef !important;
    border-color: #32475b !important;
    background-color: transparent !important;
}

:deep(body.dark-mode) .backup-index {
    background: #2b3d50 !important;
    color: #ffffff !important;
}

:deep(body.dark-mode) .backup-file-icon {
    background: rgba(255, 193, 7, 0.15) !important;
    color: #ffc107 !important;
}

:deep(body.dark-mode) .search-box__input {
    background-color: #243447 !important;
    color: #ffffff !important;
    border-color: #32475b !important;
}

:deep(body.dark-mode) .search-box__input::placeholder {
    color: #aeb8c2 !important;
}

:deep(body.dark-mode) .badge-light {
    background: #2b3d50 !important;
    color: #ffffff !important;
}

@media (max-width: 767.98px) {
    .backup-toolbar {
        align-items: stretch;
    }

    .backup-toolbar__left,
    .backup-toolbar__right {
        width: 100%;
    }

    .backup-toolbar__right {
        flex-direction: column;
        align-items: stretch;
    }

    .search-box {
        width: 100%;
    }

    .btn-toolbar-action {
        width: 100%;
    }

    .btn-group-actions {
        flex-direction: column;
        width: 100%;
    }

    .btn-group-actions .btn {
        width: 100%;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.backup-page,
html.dark-mode .content-wrapper.backup-page,
.dark-mode .content-wrapper.backup-page {
    background: #0f172a !important;
}

body.dark-mode .backup-page,
html.dark-mode .backup-page,
.dark-mode .backup-page {
    color: #e5e7eb !important;
}

body.dark-mode .backup-page .card,
body.dark-mode .backup-page .backup-toolbar-card,
body.dark-mode .backup-page .backup-table-card,
body.dark-mode .backup-page .small-box,
html.dark-mode .backup-page .card,
html.dark-mode .backup-page .backup-toolbar-card,
html.dark-mode .backup-page .backup-table-card,
html.dark-mode .backup-page .small-box,
.dark-mode .backup-page .card,
.dark-mode .backup-page .backup-toolbar-card,
.dark-mode .backup-page .backup-table-card,
.dark-mode .backup-page .small-box {
    background: #111827 !important;
    color: #e5e7eb !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.35) !important;
}

body.dark-mode .backup-page .card-header,
html.dark-mode .backup-page .card-header,
.dark-mode .backup-page .card-header {
    background: #1f2937 !important;
    color: #f8fafc !important;
    border-bottom-color: rgba(255, 255, 255, 0.08) !important;
}

body.dark-mode .backup-page h1,
body.dark-mode .backup-page h2,
body.dark-mode .backup-page h3,
body.dark-mode .backup-page h4,
body.dark-mode .backup-page h5,
body.dark-mode .backup-page h6,
body.dark-mode .backup-page .backup-toolbar__title,
body.dark-mode .backup-page .backup-file-name,
html.dark-mode .backup-page h1,
html.dark-mode .backup-page h2,
html.dark-mode .backup-page h3,
html.dark-mode .backup-page h4,
html.dark-mode .backup-page h5,
html.dark-mode .backup-page h6,
html.dark-mode .backup-page .backup-toolbar__title,
html.dark-mode .backup-page .backup-file-name,
.dark-mode .backup-page h1,
.dark-mode .backup-page h2,
.dark-mode .backup-page h3,
.dark-mode .backup-page h4,
.dark-mode .backup-page h5,
.dark-mode .backup-page h6,
.dark-mode .backup-page .backup-toolbar__title,
.dark-mode .backup-page .backup-file-name {
    color: #f8fafc !important;
}

body.dark-mode .backup-page .backup-toolbar__text,
body.dark-mode .backup-page .backup-date,
body.dark-mode .backup-page .backup-state,
html.dark-mode .backup-page .backup-toolbar__text,
html.dark-mode .backup-page .backup-date,
html.dark-mode .backup-page .backup-state,
.dark-mode .backup-page .backup-toolbar__text,
.dark-mode .backup-page .backup-date,
.dark-mode .backup-page .backup-state {
    color: #94a3b8 !important;
}

body.dark-mode .backup-page .search-box__input,
html.dark-mode .backup-page .search-box__input,
.dark-mode .backup-page .search-box__input {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .backup-page .search-box__icon,
body.dark-mode .backup-page .search-box__clear,
html.dark-mode .backup-page .search-box__icon,
html.dark-mode .backup-page .search-box__clear,
.dark-mode .backup-page .search-box__icon,
.dark-mode .backup-page .search-box__clear {
    color: #94a3b8 !important;
}

body.dark-mode .backup-page .table,
html.dark-mode .backup-page .table,
.dark-mode .backup-page .table {
    color: #e5e7eb !important;
}

body.dark-mode .backup-page .table thead th,
html.dark-mode .backup-page .table thead th,
.dark-mode .backup-page .table thead th {
    background: #1f2937 !important;
    color: #f8fafc !important;
    border-color: #334155 !important;
}

body.dark-mode .backup-page .table td,
body.dark-mode .backup-page .table th,
html.dark-mode .backup-page .table td,
html.dark-mode .backup-page .table th,
.dark-mode .backup-page .table td,
.dark-mode .backup-page .table th {
    border-color: #334155 !important;
}

body.dark-mode .backup-page .table-hover tbody tr:hover,
html.dark-mode .backup-page .table-hover tbody tr:hover,
.dark-mode .backup-page .table-hover tbody tr:hover {
    background: rgba(96, 165, 250, 0.08) !important;
}

body.dark-mode .backup-page .backup-index,
html.dark-mode .backup-page .backup-index,
.dark-mode .backup-page .backup-index {
    background: #243244 !important;
    color: #dbe4ec !important;
}

body.dark-mode .backup-page .backup-file-icon,
html.dark-mode .backup-page .backup-file-icon,
.dark-mode .backup-page .backup-file-icon {
    background: #332701 !important;
    color: #fbbf24 !important;
}

body.dark-mode .backup-page .backup-count-badge,
html.dark-mode .backup-page .backup-count-badge,
.dark-mode .backup-page .backup-count-badge {
    background: #1f2937 !important;
    color: #dbe4ec !important;
    border: 1px solid rgba(255, 255, 255, 0.08) !important;
}

body.dark-mode .backup-page .breadcrumb-item.active,
html.dark-mode .backup-page .breadcrumb-item.active,
.dark-mode .backup-page .breadcrumb-item.active {
    color: #cbd5e1 !important;
}

body.dark-mode .backup-page .breadcrumb a,
html.dark-mode .backup-page .breadcrumb a,
.dark-mode .backup-page .breadcrumb a {
    color: #93c5fd !important;
}
</style>
