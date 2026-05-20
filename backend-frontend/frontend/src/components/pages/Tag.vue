<template>
    <div class="content-wrapper tags-page" style="min-height: 1416px">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1>Tag List</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">Home</router-link>
                            </li>
                            <li class="breadcrumb-item active">Tags</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <div class="row">
                    <!-- FORM -->
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h3 class="card-title mb-0">
                                    <i class="fas fa-tags mr-2"></i>
                                    {{ form.id ? "Edit Tag" : "New Tag" }}
                                </h3>
                                <span v-if="form.id" class="badge badge-warning">
                                    Editing #{{ form.id }}
                                </span>
                            </div>

                            <div class="card-body">
                                <form @submit.prevent="saveTag">
                                    <div class="form-group">
                                        <label class="mb-1">
                                            Name <span class="text-danger">*</span>
                                        </label>
                                        <input
                                            v-model.trim="form.name"
                                            type="text"
                                            class="form-control"
                                            placeholder="e.g. IT, AI, Foreign language, Anti-drug, Criminal investigation"
                                        />
                                        <small v-if="errors.name" class="text-danger">
                                            {{ errors.name[0] }}
                                        </small>
                                    </div>

                                    <div class="form-group">
                                        <label class="mb-1">Slug</label>
                                        <input
                                            v-model.trim="form.slug"
                                            type="text"
                                            class="form-control"
                                            placeholder="e.g. IT, AI, Foreign language, Anti-drug, Criminal investigation"
                                        />
                                        <small class="text-muted d-block">
                                            Leave blank to auto-generate from name
                                        </small>
                                        <small v-if="errors.slug" class="text-danger">
                                            {{ errors.slug[0] }}
                                        </small>
                                    </div>

                                    <div class="d-flex align-items-center">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save mr-1"></i>
                                            {{ form.id ? "Update Tag" : "Create Tag" }}
                                        </button>

                                        <button
                                            v-if="form.id"
                                            type="button"
                                            class="btn btn-outline-secondary ml-2"
                                            @click="resetForm"
                                        >
                                            <i class="fas fa-times mr-1"></i>
                                            Cancel
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- LIST -->
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header d-flex flex-wrap align-items-center">
                                <div>
                                    <h3 class="card-title mb-0">
                                        <i class="fas fa-list-ul mr-2"></i>
                                        Tag List
                                    </h3>
                                    <small class="text-muted d-block">
                                        Total: {{ tags.length }} tags
                                    </small>
                                </div>

                                <div class="ml-auto mt-2 mt-md-0">
                                    <div class="input-group input-group-sm" style="width: 220px">
                                        <input
                                            v-model.trim="search"
                                            type="text"
                                            class="form-control"
                                            placeholder="Search tag..."
                                            @input="loadTags"
                                            @keyup.enter="loadTags"
                                        />
                                        <div class="input-group-append">
                                            <button class="btn btn-outline-secondary" @click="loadTags">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="card-body p-0 table-responsive">
                                <table class="table table-striped table-hover mb-0">
                                    <thead>
                                    <tr>
                                        <th style="width: 60px">#</th>
                                        <th>Name</th>
                                        <th>Slug</th>
                                        <th style="width: 170px" class="text-right">Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr v-if="!tags.length">
                                        <td colspan="4" class="text-center py-4 text-muted">
                                            <i class="far fa-folder-open mr-1"></i>
                                            No tags found.
                                        </td>
                                    </tr>

                                    <tr v-for="(tag, index) in tags" :key="tag.id">
                                        <td>{{ index + 1 }}</td>
                                        <td class="font-weight-bold">{{ tag.name }}</td>
                                        <td>{{ tag.slug }}</td>
                                        <td class="text-right">
                                            <button
                                                class="btn btn-sm btn-outline-primary mr-1"
                                                @click="editTag(tag)"
                                            >
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button
                                                class="btn btn-sm btn-outline-danger"
                                                @click="deleteTag(tag.id)"
                                            >
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import {
    apiGetTags,
    apiCreateTag,
    apiUpdateTag,
    apiDeleteTag,
} from "@func/api/tag.js";

const tags = ref([]);
const search = ref("");
const errors = ref({});

const defaultForm = () => ({
    id: null,
    name: "",
    slug: "",
});

const form = ref(defaultForm());

const normalizeList = (payload) => {
    if (Array.isArray(payload)) return payload;
    if (payload && Array.isArray(payload.data)) return payload.data;
    return [];
};

const loadTags = async () => {
    try {
        const res = await apiGetTags({ search: search.value });
        tags.value = normalizeList(res.data);
    } catch (error) {
        console.error("Failed to load tags:", error?.response || error);
    }
};

const saveTag = async () => {
    errors.value = {};

    if (!form.value.name) {
        errors.value.name = ["Name is required"];
        return;
    }

    const payload = {
        name: form.value.name,
        slug: form.value.slug,
    };

    try {
        if (form.value.id) {
            await apiUpdateTag(form.value.id, payload);
        } else {
            await apiCreateTag(payload);
        }

        await loadTags();
        resetForm();
    } catch (error) {
        console.error("Save tag error:", error?.response || error);

        if (error?.response?.status === 422) {
            errors.value = error.response.data.errors || {};
            return;
        }

        alert(error?.response?.data?.message || "Failed to save tag");
    }
};

const editTag = (tag) => {
    form.value = {
        id: tag.id,
        name: tag.name || "",
        slug: tag.slug || "",
    };
    errors.value = {};
};

const resetForm = () => {
    form.value = defaultForm();
    errors.value = {};
};

const deleteTag = async (id) => {
    if (!confirm("Delete this tag?")) return;

    try {
        await apiDeleteTag(id);
        await loadTags();

        if (form.value.id === id) {
            resetForm();
        }
    } catch (error) {
        console.error("Delete tag error:", error?.response || error);
        alert(error?.response?.data?.message || "Failed to delete tag");
    }
};

onMounted(loadTags);
</script>

<style>
body.dark-mode .content-wrapper.tags-page,
html.dark-mode .content-wrapper.tags-page,
.dark-mode .content-wrapper.tags-page {
    background: #0f172a !important;
}

body.dark-mode .tags-page,
html.dark-mode .tags-page,
.dark-mode .tags-page {
    color: #e5e7eb !important;
}

body.dark-mode .tags-page h1,
body.dark-mode .tags-page h2,
body.dark-mode .tags-page h3,
body.dark-mode .tags-page h4,
body.dark-mode .tags-page h5,
body.dark-mode .tags-page h6,
html.dark-mode .tags-page h1,
html.dark-mode .tags-page h2,
html.dark-mode .tags-page h3,
html.dark-mode .tags-page h4,
html.dark-mode .tags-page h5,
html.dark-mode .tags-page h6,
.dark-mode .tags-page h1,
.dark-mode .tags-page h2,
.dark-mode .tags-page h3,
.dark-mode .tags-page h4,
.dark-mode .tags-page h5,
.dark-mode .tags-page h6 {
    color: #f8fafc !important;
}

body.dark-mode .tags-page .card,
html.dark-mode .tags-page .card,
.dark-mode .tags-page .card {
    background: #111827 !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
    color: #e5e7eb !important;
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.35) !important;
}

body.dark-mode .tags-page .card-header,
html.dark-mode .tags-page .card-header,
.dark-mode .tags-page .card-header {
    background: #1f2937 !important;
    border-bottom-color: rgba(255, 255, 255, 0.08) !important;
    color: #f8fafc !important;
}

body.dark-mode .tags-page .card-body,
html.dark-mode .tags-page .card-body,
.dark-mode .tags-page .card-body {
    background: #111827 !important;
    color: #e5e7eb !important;
}

body.dark-mode .tags-page .form-control,
html.dark-mode .tags-page .form-control,
.dark-mode .tags-page .form-control {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .tags-page .form-control:focus,
html.dark-mode .tags-page .form-control:focus,
.dark-mode .tags-page .form-control:focus {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #60a5fa !important;
    box-shadow: 0 0 0 0.12rem rgba(96, 165, 250, 0.2) !important;
}

body.dark-mode .tags-page label,
html.dark-mode .tags-page label,
.dark-mode .tags-page label {
    color: #dbe4ec !important;
}

body.dark-mode .tags-page .table,
html.dark-mode .tags-page .table,
.dark-mode .tags-page .table {
    color: #e5e7eb !important;
}

body.dark-mode .tags-page .table thead th,
html.dark-mode .tags-page .table thead th,
.dark-mode .tags-page .table thead th {
    background: #1f2937 !important;
    color: #f8fafc !important;
    border-color: #334155 !important;
}

body.dark-mode .tags-page .table td,
body.dark-mode .tags-page .table th,
html.dark-mode .tags-page .table td,
html.dark-mode .tags-page .table th,
.dark-mode .tags-page .table td,
.dark-mode .tags-page .table th {
    border-color: #334155 !important;
}

body.dark-mode .tags-page .table-striped tbody tr:nth-of-type(odd),
html.dark-mode .tags-page .table-striped tbody tr:nth-of-type(odd),
.dark-mode .tags-page .table-striped tbody tr:nth-of-type(odd) {
    background: rgba(255, 255, 255, 0.02) !important;
}

body.dark-mode .tags-page .table-hover tbody tr:hover,
html.dark-mode .tags-page .table-hover tbody tr:hover,
.dark-mode .tags-page .table-hover tbody tr:hover {
    background: rgba(96, 165, 250, 0.08) !important;
    color: #fff !important;
}

body.dark-mode .tags-page .input-group-text,
html.dark-mode .tags-page .input-group-text,
.dark-mode .tags-page .input-group-text {
    background: #1f2937 !important;
    color: #cbd5e1 !important;
    border-color: #334155 !important;
}

body.dark-mode .tags-page .btn-outline-secondary,
html.dark-mode .tags-page .btn-outline-secondary,
.dark-mode .tags-page .btn-outline-secondary {
    color: #cbd5e1 !important;
    border-color: #475569 !important;
}

body.dark-mode .tags-page .btn-outline-secondary:hover,
html.dark-mode .tags-page .btn-outline-secondary:hover,
.dark-mode .tags-page .btn-outline-secondary:hover {
    background: #334155 !important;
    color: #fff !important;
}

body.dark-mode .tags-page .text-muted,
html.dark-mode .tags-page .text-muted,
.dark-mode .tags-page .text-muted {
    color: #94a3b8 !important;
}

body.dark-mode .tags-page .breadcrumb,
body.dark-mode .tags-page .breadcrumb-item.active,
html.dark-mode .tags-page .breadcrumb,
html.dark-mode .tags-page .breadcrumb-item.active,
.dark-mode .tags-page .breadcrumb,
.dark-mode .tags-page .breadcrumb-item.active {
    color: #cbd5e1 !important;
}

body.dark-mode .tags-page .breadcrumb a,
html.dark-mode .tags-page .breadcrumb a,
.dark-mode .tags-page .breadcrumb a {
    color: #93c5fd !important;
}
</style>
