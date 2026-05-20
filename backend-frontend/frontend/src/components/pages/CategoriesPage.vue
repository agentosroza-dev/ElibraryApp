<template>
    <div class="content-wrapper category-page" style="min-height: 1416px">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2">
                    <div class="col-sm-6">
                        <h1>Category List</h1>
                    </div>
                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">Home</router-link>
                            </li>
                            <li class="breadcrumb-item active">Category</li>
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
                                    <i class="fas fa-layer-group mr-2"></i>
                                    {{ form.id ? "Edit Category" : "New Category" }}
                                </h3>
                                <span v-if="form.id" class="badge badge-warning">
                                    Editing #{{ form.id }}
                                </span>
                            </div>

                            <div class="card-body">
                                <form @submit.prevent="saveCategory">
                                    <!-- Name -->
                                    <div class="form-group">
                                        <label class="mb-1">
                                            Name <span class="text-danger">*</span>
                                        </label>
                                        <input
                                            v-model.trim="form.name"
                                            type="text"
                                            class="form-control"
                                            placeholder="e.g. Computer Science, AI, Foreign language"
                                        />
                                        <small v-if="errors.name" class="text-danger">
                                            {{ errors.name[0] }}
                                        </small>
                                    </div>

                                    <!-- Slug -->
                                    <div class="form-group">
                                        <label class="mb-1">Slug</label>
                                        <input
                                            v-model.trim="form.slug"
                                            type="text"
                                            class="form-control"
                                            placeholder="enter-category-slug"
                                        />
                                        <small v-if="errors.slug" class="text-danger">
                                            {{ errors.slug[0] }}
                                        </small>
                                    </div>

                                    <!-- Description -->
                                    <div class="form-group">
                                        <label class="mb-1">Description</label>
                                        <textarea
                                            v-model.trim="form.description"
                                            class="form-control"
                                            rows="3"
                                            placeholder="Short description about this category"
                                        ></textarea>
                                        <small v-if="errors.description" class="text-danger">
                                            {{ errors.description[0] }}
                                        </small>
                                    </div>

                                    <!-- Active -->
                                    <div class="form-group mb-3">
                                        <div class="custom-control custom-switch">
                                            <input
                                                id="active"
                                                v-model="form.is_active"
                                                type="checkbox"
                                                class="custom-control-input"
                                            />
                                            <label class="custom-control-label" for="active">
                                                Active category
                                            </label>
                                        </div>
                                    </div>

                                    <!-- Actions -->
                                    <div class="d-flex align-items-center">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save mr-1"></i>
                                            {{ form.id ? "Update Category" : "Create Category" }}
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
                                        Category List
                                    </h3>
                                    <small class="text-muted d-block">
                                        Total: {{ categories.length }} categories
                                    </small>
                                </div>

                                <div class="ml-auto mt-2 mt-md-0">
                                    <div class="input-group input-group-sm" style="width: 220px">
                                        <input
                                            v-model.trim="search"
                                            type="text"
                                            class="form-control"
                                            placeholder="Search category..."
                                            @input="filterCategories"
                                            @keyup.enter="filterCategories"
                                        />
                                        <div class="input-group-append">
                                            <button class="btn btn-outline-secondary" @click="filterCategories">
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
                                        <th style="width: 130px">Status</th>
                                        <th style="width: 150px" class="text-right">Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr v-if="!categories.length">
                                        <td colspan="5" class="text-center py-4 text-muted">
                                            <i class="far fa-folder-open mr-1"></i>
                                            No categories found. Create your first one.
                                        </td>
                                    </tr>

                                    <tr v-for="(cat, index) in categories" :key="cat.id">
                                        <td>{{ index + 1 }}</td>
                                        <td>
                                            <div class="font-weight-bold mb-0">{{ cat.name }}</div>
                                            <small
                                                v-if="cat.description"
                                                class="text-muted d-block text-truncate"
                                                style="max-width: 320px"
                                            >
                                                {{ cat.description }}
                                            </small>
                                        </td>
                                        <td>
                                            <div class="font-weight-bold mb-0">{{ cat.slug }}</div>
                                        </td>
                                        <td>
                                                <span
                                                    class="badge"
                                                    :class="cat.is_active ? 'badge-success' : 'badge-secondary'"
                                                >
                                                    <i
                                                        class="fas"
                                                        :class="
                                                            cat.is_active
                                                                ? 'fa-check-circle mr-1'
                                                                : 'fa-pause-circle mr-1'
                                                        "
                                                    ></i>
                                                    {{ cat.is_active ? "Active" : "Inactive" }}
                                                </span>
                                        </td>
                                        <td class="text-right">
                                            <button
                                                class="btn btn-sm btn-outline-primary mr-1"
                                                @click="editCategory(cat)"
                                            >
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button
                                                class="btn btn-sm btn-outline-danger"
                                                @click="deleteCategory(cat.id)"
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
    apiGetCategories,
    apiCreateCategory,
    apiUpdateCategory,
    apiDeleteCategory,
} from "@func/api/category.js";

const categories = ref([]);
const allCategories = ref([]);
const search = ref("");

const defaultForm = () => ({
    id: null,
    name: "",
    slug: "",
    description: "",
    is_active: true,
});

const form = ref(defaultForm());
const errors = ref({});

const normalizeCategoryList = (payload) => {
    if (Array.isArray(payload)) return payload;
    if (payload && Array.isArray(payload.data)) return payload.data;
    return [];
};

const loadCategories = async () => {
    try {
        const res = await apiGetCategories();
        const list = normalizeCategoryList(res.data);
        allCategories.value = list;
        categories.value = [...list];
    } catch (error) {
        console.error("Failed to load categories:", error?.response || error);
    }
};

const filterCategories = () => {
    const term = search.value.toLowerCase();

    if (!term) {
        categories.value = [...allCategories.value];
        return;
    }

    categories.value = allCategories.value.filter((cat) => {
        const name = (cat.name || "").toLowerCase();
        const slug = (cat.slug || "").toLowerCase();
        const description = (cat.description || "").toLowerCase();

        return (
            name.includes(term) ||
            slug.includes(term) ||
            description.includes(term)
        );
    });
};

const saveCategory = async () => {
    errors.value = {};

    if (!form.value.name) {
        errors.value.name = ["Name is required"];
        return;
    }

    const payload = {
        name: form.value.name,
        slug: form.value.slug,
        description: form.value.description,
        is_active: form.value.is_active ? 1 : 0,
    };

    try {
        if (form.value.id) {
            await apiUpdateCategory(form.value.id, payload);
        } else {
            await apiCreateCategory(payload);
        }

        await loadCategories();
        filterCategories();
        resetForm();
    } catch (error) {
        console.error("Save category error:", error?.response || error);

        if (error?.response?.status === 422) {
            errors.value = error.response.data.errors || {};
            return;
        }

        alert(error?.response?.data?.message || "Failed to save category");
    }
};

const editCategory = (cat) => {
    form.value = {
        id: cat.id,
        name: cat.name || "",
        slug: cat.slug || "",
        description: cat.description || "",
        is_active: !!cat.is_active,
    };
    errors.value = {};
};

const resetForm = () => {
    form.value = defaultForm();
    errors.value = {};
};

const deleteCategory = async (id) => {
    if (!confirm("Delete this category?")) return;

    try {
        await apiDeleteCategory(id);
        await loadCategories();
        filterCategories();

        if (form.value.id === id) {
            resetForm();
        }
    } catch (error) {
        console.error("Delete category error:", error?.response || error);
        alert(error?.response?.data?.message || "Failed to delete category");
    }
};

onMounted(loadCategories);
</script>

<style>
body.dark-mode .content-wrapper.category-page,
html.dark-mode .content-wrapper.category-page,
.dark-mode .content-wrapper.category-page {
    background: #0f172a !important;
}

body.dark-mode .category-page,
html.dark-mode .category-page,
.dark-mode .category-page {
    color: #e5e7eb !important;
}

body.dark-mode .category-page h1,
body.dark-mode .category-page h2,
body.dark-mode .category-page h3,
body.dark-mode .category-page h4,
body.dark-mode .category-page h5,
body.dark-mode .category-page h6,
html.dark-mode .category-page h1,
html.dark-mode .category-page h2,
html.dark-mode .category-page h3,
html.dark-mode .category-page h4,
html.dark-mode .category-page h5,
html.dark-mode .category-page h6,
.dark-mode .category-page h1,
.dark-mode .category-page h2,
.dark-mode .category-page h3,
.dark-mode .category-page h4,
.dark-mode .category-page h5,
.dark-mode .category-page h6 {
    color: #f8fafc !important;
}

body.dark-mode .category-page .card,
html.dark-mode .category-page .card,
.dark-mode .category-page .card {
    background: #111827 !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
    color: #e5e7eb !important;
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.35) !important;
}

body.dark-mode .category-page .card-header,
html.dark-mode .category-page .card-header,
.dark-mode .category-page .card-header {
    background: #1f2937 !important;
    border-bottom-color: rgba(255, 255, 255, 0.08) !important;
    color: #f8fafc !important;
}

body.dark-mode .category-page .card-body,
body.dark-mode .category-page .card-footer,
html.dark-mode .category-page .card-body,
html.dark-mode .category-page .card-footer,
.dark-mode .category-page .card-body,
.dark-mode .category-page .card-footer {
    background: #111827 !important;
    color: #e5e7eb !important;
}

body.dark-mode .category-page .form-control,
body.dark-mode .category-page textarea.form-control,
html.dark-mode .category-page .form-control,
html.dark-mode .category-page textarea.form-control,
.dark-mode .category-page .form-control,
.dark-mode .category-page textarea.form-control {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .category-page .form-control:focus,
html.dark-mode .category-page .form-control:focus,
.dark-mode .category-page .form-control:focus {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #60a5fa !important;
    box-shadow: 0 0 0 0.12rem rgba(96, 165, 250, 0.2) !important;
}

body.dark-mode .category-page .custom-control-label,
body.dark-mode .category-page label,
html.dark-mode .category-page .custom-control-label,
html.dark-mode .category-page label,
.dark-mode .category-page .custom-control-label,
.dark-mode .category-page label {
    color: #dbe4ec !important;
}

body.dark-mode .category-page .table,
html.dark-mode .category-page .table,
.dark-mode .category-page .table {
    color: #e5e7eb !important;
}

body.dark-mode .category-page .table thead th,
html.dark-mode .category-page .table thead th,
.dark-mode .category-page .table thead th {
    background: #1f2937 !important;
    color: #f8fafc !important;
    border-color: #334155 !important;
}

body.dark-mode .category-page .table td,
body.dark-mode .category-page .table th,
html.dark-mode .category-page .table td,
html.dark-mode .category-page .table th,
.dark-mode .category-page .table td,
.dark-mode .category-page .table th {
    border-color: #334155 !important;
}

body.dark-mode .category-page .table-striped tbody tr:nth-of-type(odd),
html.dark-mode .category-page .table-striped tbody tr:nth-of-type(odd),
.dark-mode .category-page .table-striped tbody tr:nth-of-type(odd) {
    background: rgba(255, 255, 255, 0.02) !important;
}

body.dark-mode .category-page .table-hover tbody tr:hover,
html.dark-mode .category-page .table-hover tbody tr:hover,
.dark-mode .category-page .table-hover tbody tr:hover {
    background: rgba(96, 165, 250, 0.08) !important;
    color: #fff !important;
}

body.dark-mode .category-page .input-group-text,
html.dark-mode .category-page .input-group-text,
.dark-mode .category-page .input-group-text {
    background: #1f2937 !important;
    color: #cbd5e1 !important;
    border-color: #334155 !important;
}

body.dark-mode .category-page .btn-outline-secondary,
html.dark-mode .category-page .btn-outline-secondary,
.dark-mode .category-page .btn-outline-secondary {
    color: #cbd5e1 !important;
    border-color: #475569 !important;
}

body.dark-mode .category-page .btn-outline-secondary:hover,
html.dark-mode .category-page .btn-outline-secondary:hover,
.dark-mode .category-page .btn-outline-secondary:hover {
    background: #334155 !important;
    color: #fff !important;
}

body.dark-mode .category-page .text-muted,
html.dark-mode .category-page .text-muted,
.dark-mode .category-page .text-muted {
    color: #94a3b8 !important;
}

body.dark-mode .category-page .breadcrumb,
body.dark-mode .category-page .breadcrumb-item.active,
html.dark-mode .category-page .breadcrumb,
html.dark-mode .category-page .breadcrumb-item.active,
.dark-mode .category-page .breadcrumb,
.dark-mode .category-page .breadcrumb-item.active {
    color: #cbd5e1 !important;
}

body.dark-mode .category-page .breadcrumb a,
html.dark-mode .category-page .breadcrumb a,
.dark-mode .category-page .breadcrumb a {
    color: #93c5fd !important;
}
</style>
