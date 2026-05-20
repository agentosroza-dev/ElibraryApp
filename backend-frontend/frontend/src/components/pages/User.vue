<template>
    <div class="content-wrapper users-page">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-3 align-items-center">
                    <div class="col-sm-6">
                        <h1 class="page-title mb-1">List Users</h1>
                    </div>

                    <div class="col-sm-6">
                        <ol class="breadcrumb float-sm-right mb-0">
                            <li class="breadcrumb-item">
                                <router-link :to="{ name: 'dashboard' }">Home</router-link>
                            </li>
                            <li class="breadcrumb-item active">Users</li>
                        </ol>
                    </div>
                </div>
            </div>
        </section>

        <section class="content">
            <div class="container-fluid">
                <!-- Top summary -->
                <div class="row mb-4">
                    <div class="col-md-3 col-sm-6 mb-3">
                        <div class="small-stat-card">
                            <div class="small-stat-card__icon bg-primary">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="small-stat-card__content">
                                <div class="small-stat-card__label">Total Users</div>
                                <div class="small-stat-card__value">{{ users.length }}</div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 col-sm-6 mb-3">
                        <div class="small-stat-card">
                            <div class="small-stat-card__icon bg-danger">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            <div class="small-stat-card__content">
                                <div class="small-stat-card__label">Admins</div>
                                <div class="small-stat-card__value">{{ totalAdmins }}</div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 col-sm-6 mb-3">
                        <div class="small-stat-card">
                            <div class="small-stat-card__icon bg-info">
                                <i class="fas fa-user-edit"></i>
                            </div>
                            <div class="small-stat-card__content">
                                <div class="small-stat-card__label">Authors</div>
                                <div class="small-stat-card__value">{{ totalAuthors }}</div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 col-sm-6 mb-3">
                        <div class="small-stat-card">
                            <div class="small-stat-card__icon bg-success">
                                <i class="fas fa-user"></i>
                            </div>
                            <div class="small-stat-card__content">
                                <div class="small-stat-card__label">Users</div>
                                <div class="small-stat-card__value">{{ totalNormalUsers }}</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Main table card -->
                <div class="card users-card shadow-sm">
                    <div class="card-header users-card__header d-flex align-items-center justify-content-between">

                        <h3 class="card-title font-weight-bold mb-0">
                            Users List
                            <button class="btn btn-primary btn-sm ml-3" @click="openCreateModal">
                                <i class="fas fa-plus mr-1"></i>
                                Create User
                            </button>
                        </h3>

                    </div>

                    <div class="card-body p-0">
                        <CustomTable
                            :title="''"
                            :data="users"
                            :columns="columns"
                            :pageSize="25"
                        />
                    </div>
                </div>
            </div>
            &nbsp;
        </section>
    </div>

    <!-- Modal -->
    <div class="modal fade" ref="userModal" tabindex="-1" aria-hidden="true">
        <form @submit.prevent="saveUser">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content user-modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">
                            <i class="fas fa-user-circle mr-2"></i>
                            {{ isEditMode ? "Edit User" : "Create User" }}
                        </h4>

                        <button type="button" class="close" @click="hideUserModal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>

                    <div class="modal-body">
                        <div class="row">
                            <div class="form-group col-md-6">
                                <label>Name</label>
                                <input
                                    v-model.trim="userObject.name"
                                    type="text"
                                    class="form-control"
                                    :class="{ 'is-invalid': userObjectErr.name }"
                                    placeholder="Enter full name"
                                />
                                <div class="invalid-feedback">{{ userObjectErr.name }}</div>
                            </div>

                            <div class="form-group col-md-6">
                                <label>Email</label>
                                <input
                                    v-model.trim="userObject.email"
                                    type="email"
                                    class="form-control"
                                    :class="{ 'is-invalid': userObjectErr.email }"
                                    placeholder="Enter email address"
                                />
                                <div class="invalid-feedback">{{ userObjectErr.email }}</div>
                            </div>

                            <div class="form-group col-md-6">
                                <label>Level</label>
                                <select
                                    v-model="userObject.level"
                                    class="form-control"
                                    :class="{ 'is-invalid': userObjectErr.level }"
                                >
                                    <option value="">Select level</option>
                                    <option value="admin">Admin</option>
                                    <option value="author">Author</option>
                                    <option value="user">User</option>
                                </select>
                                <div class="invalid-feedback">{{ userObjectErr.level }}</div>
                            </div>

                            <div class="form-group col-md-6">
                                <label>
                                    Password
                                    <small v-if="isEditMode" class="text-muted">
                                        (leave blank to keep current password)
                                    </small>
                                </label>
                                <input
                                    v-model="userObject.password"
                                    type="password"
                                    class="form-control"
                                    :class="{ 'is-invalid': userObjectErr.password }"
                                    :placeholder="isEditMode ? 'Leave blank if no change' : 'Enter password'"
                                />
                                <div class="invalid-feedback">{{ userObjectErr.password }}</div>
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer justify-content-between">
                        <button type="button" class="btn btn-outline-secondary" @click="hideUserModal">
                            Close
                        </button>

                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save mr-1"></i>
                            {{ isEditMode ? "Update User" : "Save User" }}
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</template>

<script setup>
import { computed, h, onMounted, onBeforeUnmount, reactive, ref } from "vue"
import CustomTable from "../includes/tables/CustomTable.vue"

import { apiGetDetailUsers, apiReadDetailUser, apiDeleteUser } from "@func/api/user"
import { apiCreateUser, apiUpdateUser } from "@/functions/api/user"
import { CloseModal, LoadingModal, MessageModal } from "@func/swal"

const userModal = ref(null)
const users = ref([])
const meta = ref({})

const userObject = reactive({
    id: null,
    name: "",
    email: "",
    level: "user",
    password: "",
})

const userObjectErr = reactive({
    name: "",
    email: "",
    level: "",
    password: "",
})

const defaultUserObject = {
    id: null,
    name: "",
    email: "",
    level: "user",
    password: "",
}

const defaultUserObjectErr = {
    name: "",
    email: "",
    level: "",
    password: "",
}

const isEditMode = computed(() => !!userObject.id)

const totalAdmins = computed(() =>
    users.value.filter((u) => String(u.level || "").toLowerCase() === "admin").length
)

const totalAuthors = computed(() =>
    users.value.filter((u) => String(u.level || "").toLowerCase() === "author").length
)

const totalNormalUsers = computed(() =>
    users.value.filter((u) => String(u.level || "").toLowerCase() === "user").length
)

function getLevelBadgeClass(level) {
    const normalized = String(level || "").toLowerCase()

    if (normalized === "admin") return "badge badge-danger"
    if (normalized === "author") return "badge badge-info"
    return "badge badge-primary"
}

const columns = [
    {
        header: "ID",
        accessorKey: "id",
    },
    {
        header: "Name",
        accessorKey: "name",
    },
    {
        header: "Email",
        accessorKey: "email",
    },
    {
        header: "Level",
        accessorKey: "level",
        cell: ({
                   row: {
                       original: { level },
                   },
               }) =>
            h(
                "span",
                {
                    class: getLevelBadgeClass(level),
                    style:
                        "padding:6px 10px;border-radius:999px;font-size:12px;font-weight:700;text-transform:capitalize;",
                },
                level || "user"
            ),
    },
    {
        accessorKey: "action",
        header: () => h("span", { class: "font-weight-bold" }, "Actions"),
        cell: ({
                   row: {
                       original: { id },
                   },
               }) => [
            h(
                "button",
                {
                    onClick: () => viewUser(id),
                    class: "btn btn-sm btn-outline-primary mx-1",
                    title: "Edit User",
                    type: "button",
                },
                h("i", { class: "fa fa-pen" })
            ),
            h(
                "button",
                {
                    onClick: () => removeUser(id),
                    class: "btn btn-sm btn-outline-danger mx-1",
                    title: "Delete User",
                    type: "button",
                },
                h("i", { class: "fa fa-trash" })
            ),
        ],
        enableSorting: false,
    },
]

function handleModalHidden() {
    resetData()
}

onMounted(async () => {
    if (userModal.value) {
        $(userModal.value).on("hidden.bs.modal", handleModalHidden)
    }

    await fetchUsers()
})

onBeforeUnmount(() => {
    if (userModal.value) {
        $(userModal.value).off("hidden.bs.modal", handleModalHidden)
    }
})

async function fetchUsers() {
    try {
        LoadingModal()

        const response = await apiGetDetailUsers()
        const { data, meta: metaData } = response.data

        users.value = Array.isArray(data) ? data : []
        meta.value = metaData || {}

        CloseModal()
    } catch (error) {
        CloseModal()
        MessageModal(
            "error",
            "Error",
            error?.response?.data?.message || "An error occurred while fetching users."
        )
    }
}

async function saveUser() {
    try {
        clearErrors()
        LoadingModal()

        const payload = {
            name: userObject.name,
            email: userObject.email,
            level: userObject.level || "user",
            password: userObject.password,
        }

        if (isEditMode.value && !payload.password) {
            delete payload.password
        }

        let response

        if (isEditMode.value) {
            response = await apiUpdateUser(userObject.id, payload)
            onUserUpdate(response.data.user)
        } else {
            response = await apiCreateUser(payload)
            onUserCreate(response.data.user)
        }

        hideUserModal()
        MessageModal("success", "Success", response.data.message || "User saved successfully.")
    } catch (error) {
        if (!error.response) {
            CloseModal()
            return MessageModal("error", "Error", error.message || "Something went wrong.")
        }

        if (error.response.status === 422) {
            const errors = error.response.data.errors || {}

            Object.keys(userObjectErr).forEach((key) => {
                userObjectErr[key] = errors[key]?.[0] || ""
            })

            CloseModal()
            return
        }

        CloseModal()
        MessageModal(
            "error",
            "Error",
            error.response.data.message || "Failed to save user."
        )
    }
}

async function viewUser(id) {
    try {
        LoadingModal()

        const response = await apiReadDetailUser(id)
        const user = response.data.user || {}

        Object.assign(userObject, {
            id: user.id ?? null,
            name: user.name ?? "",
            email: user.email ?? "",
            level: user.level ?? "user",
            password: "",
        })

        showUserModal()
        CloseModal()
    } catch (error) {
        CloseModal()
        MessageModal(
            "error",
            "Error",
            error?.response?.data?.message || error.message || "Failed to load user."
        )
    }
}

async function removeUser(id) {
    Swal.fire({
        icon: "warning",
        title: "Delete User",
        text: "Are you sure you want to delete this user? This action cannot be undone.",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Yes, delete it!",
    }).then(async (result) => {
        if (!result.isConfirmed) return

        try {
            LoadingModal()
            const response = await apiDeleteUser(id)
            onUserDelete(id)
            MessageModal("success", "Success", response.data.message || "User deleted successfully.")
        } catch (error) {
            CloseModal()
            MessageModal(
                "error",
                "Error",
                error?.response?.data?.message || error.message || "Failed to delete user."
            )
        }
    })
}

function openCreateModal() {
    resetData()
    showUserModal()
}

function showUserModal() {
    clearErrors()
    $(userModal.value).modal("show")
}

function hideUserModal() {
    $(userModal.value).modal("hide")
}

function resetData() {
    Object.assign(userObject, { ...defaultUserObject })
    Object.assign(userObjectErr, { ...defaultUserObjectErr })
}

function clearErrors() {
    Object.assign(userObjectErr, { ...defaultUserObjectErr })
}

function onUserCreate(user) {
    users.value.unshift(user)
}

function onUserUpdate(user) {
    users.value = users.value.map((u) => (u.id === user.id ? user : u))
}

function onUserDelete(id) {
    users.value = users.value.filter((u) => u.id !== id)
}
</script>

<style scoped>
.users-page {
    min-height: 100vh;
}

.page-title {
    font-size: 1.75rem;
    font-weight: 700;
    color: var(--text-color, #1f2937);
}

.page-subtitle {
    color: #6c757d;
    font-size: 0.95rem;
}

.users-card {
    border: 0;
    border-radius: 16px;
    overflow: hidden;
    background: #fff;
}

.users-card__header {
    padding: 1rem 1.25rem;
    background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    flex-wrap: wrap;
}

.small-stat-card {
    display: flex;
    align-items: center;
    gap: 14px;
    background: #fff;
    border-radius: 16px;
    padding: 18px;
    box-shadow: 0 8px 22px rgba(15, 23, 42, 0.06);
    height: 100%;
}

.small-stat-card__icon {
    width: 52px;
    height: 52px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 1.2rem;
    flex-shrink: 0;
}

.small-stat-card__content {
    min-width: 0;
}

.small-stat-card__label {
    font-size: 0.9rem;
    color: #6b7280;
    margin-bottom: 4px;
}

.small-stat-card__value {
    font-size: 1.4rem;
    font-weight: 700;
    color: #111827;
    line-height: 1;
}

.user-modal-content {
    border-radius: 18px;
    border: 0;
    overflow: hidden;
}

.user-modal-content .modal-header {
    background: linear-gradient(135deg, #007bff 0%, #0056d2 100%);
    color: #fff;
    border-bottom: 0;
}

.user-modal-content .modal-title {
    font-weight: 700;
}

.user-modal-content .close {
    color: #fff;
    opacity: 1;
    text-shadow: none;
}

.user-modal-content .modal-body {
    padding: 1.5rem;
}

.user-modal-content .modal-footer {
    border-top: 1px solid #edf2f7;
    padding: 1rem 1.5rem;
}

.form-control,
.custom-select,
select.form-control {
    border-radius: 10px;
    min-height: 42px;
    box-shadow: none !important;
}

.form-control:focus,
select.form-control:focus {
    border-color: #80bdff;
    box-shadow: 0 0 0 0.15rem rgba(0, 123, 255, 0.15) !important;
}

.badge {
    letter-spacing: 0.02em;
}

/* dark mode */
body.dark-mode .users-card,
body.dark-mode .small-stat-card,
body.dark-mode .user-modal-content {
    background: #2b3035;
    color: #e5e7eb;
}

body.dark-mode .users-card__header {
    background: linear-gradient(135deg, #2f3540 0%, #252b33 100%);
}

body.dark-mode .page-title,
body.dark-mode .small-stat-card__value,
body.dark-mode .card-title {
    color: #f9fafb;
}

body.dark-mode .page-subtitle,
body.dark-mode .small-stat-card__label,
body.dark-mode .text-muted,
body.dark-mode .modal-body label,
body.dark-mode .form-text,
body.dark-mode small.text-muted {
    color: #cbd5e1 !important;
}

body.dark-mode .form-control,
body.dark-mode select.form-control {
    background-color: #343a40;
    border-color: #495057;
    color: #fff;
}

body.dark-mode .form-control::placeholder {
    color: #adb5bd;
}

body.dark-mode .user-modal-content .modal-footer {
    border-top-color: rgba(255, 255, 255, 0.08);
}

body.dark-mode .breadcrumb-item a,
body.dark-mode .breadcrumb-item.active {
    color: #d1d5db;
}

@media (max-width: 767.98px) {
    .page-title {
        font-size: 1.4rem;
    }

    .users-card__header {
        align-items: flex-start;
    }
}
</style>

<style>
body.dark-mode .content-wrapper.users-page,
html.dark-mode .content-wrapper.users-page,
.dark-mode .content-wrapper.users-page {
    background: #0f172a !important;
}

body.dark-mode .users-page,
html.dark-mode .users-page,
.dark-mode .users-page {
    color: #e5e7eb !important;
}

body.dark-mode .users-page .page-title,
html.dark-mode .users-page .page-title,
.dark-mode .users-page .page-title {
    color: #f8fafc !important;
}

body.dark-mode .users-page .page-subtitle,
html.dark-mode .users-page .page-subtitle,
.dark-mode .users-page .page-subtitle {
    color: #94a3b8 !important;
}

body.dark-mode .users-page .users-card,
body.dark-mode .users-page .small-stat-card,
body.dark-mode .users-page .user-modal-content,
body.dark-mode .users-page .card,
html.dark-mode .users-page .users-card,
html.dark-mode .users-page .small-stat-card,
html.dark-mode .users-page .user-modal-content,
html.dark-mode .users-page .card,
.dark-mode .users-page .users-card,
.dark-mode .users-page .small-stat-card,
.dark-mode .users-page .user-modal-content,
.dark-mode .users-page .card {
    background: #111827 !important;
    color: #e5e7eb !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
}

body.dark-mode .users-page .users-card__header,
html.dark-mode .users-page .users-card__header,
.dark-mode .users-page .users-card__header {
    background: linear-gradient(135deg, #1f2937 0%, #111827 100%) !important;
    color: #f8fafc !important;
}

body.dark-mode .users-page .small-stat-card__label,
html.dark-mode .users-page .small-stat-card__label,
.dark-mode .users-page .small-stat-card__label {
    color: #94a3b8 !important;
}

body.dark-mode .users-page .small-stat-card__value,
html.dark-mode .users-page .small-stat-card__value,
.dark-mode .users-page .small-stat-card__value {
    color: #f8fafc !important;
}

body.dark-mode .users-page .modal-body,
body.dark-mode .users-page .modal-footer,
html.dark-mode .users-page .modal-body,
html.dark-mode .users-page .modal-footer,
.dark-mode .users-page .modal-body,
.dark-mode .users-page .modal-footer {
    background: #111827 !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .users-page .form-control,
body.dark-mode .users-page .custom-select,
body.dark-mode .users-page select.form-control,
html.dark-mode .users-page .form-control,
html.dark-mode .users-page .custom-select,
html.dark-mode .users-page select.form-control,
.dark-mode .users-page .form-control,
.dark-mode .users-page .custom-select,
.dark-mode .users-page select.form-control {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #334155 !important;
}

body.dark-mode .users-page .form-control:focus,
body.dark-mode .users-page select.form-control:focus,
html.dark-mode .users-page .form-control:focus,
html.dark-mode .users-page select.form-control:focus,
.dark-mode .users-page .form-control:focus,
.dark-mode .users-page select.form-control:focus {
    background: #0f172a !important;
    color: #e5e7eb !important;
    border-color: #60a5fa !important;
    box-shadow: 0 0 0 0.15rem rgba(96, 165, 250, 0.18) !important;
}

body.dark-mode .users-page .modal-header .close,
html.dark-mode .users-page .modal-header .close,
.dark-mode .users-page .modal-header .close {
    color: #fff !important;
}

body.dark-mode .users-page .text-muted,
html.dark-mode .users-page .text-muted,
.dark-mode .users-page .text-muted {
    color: #94a3b8 !important;
}

body.dark-mode .users-page .breadcrumb-item.active,
html.dark-mode .users-page .breadcrumb-item.active,
.dark-mode .users-page .breadcrumb-item.active {
    color: #cbd5e1 !important;
}

body.dark-mode .users-page .breadcrumb a,
html.dark-mode .users-page .breadcrumb a,
.dark-mode .users-page .breadcrumb a {
    color: #93c5fd !important;
}
</style>
