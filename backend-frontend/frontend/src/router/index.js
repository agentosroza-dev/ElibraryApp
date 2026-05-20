import { createRouter, createWebHistory } from "vue-router";
import axios from "axios";

// Auth pages
import Signin from "@com/auth/SignIn.vue";
import Signout from "@com/auth/SignOut.vue";
import Signup from "@com/auth/SignUp.vue";
import VerifyEmail from "@com/auth/VerifyEmail.vue";
import ResetPassword from "@com/auth/ResetPassword.vue";
import SetNewPassword from "@com/auth/SetNewPassword.vue";
import GoogleCallback from "@com/auth/GoogleCallback.vue";
import GoogleCallbackError from "@com/auth/GoogleCallbackError.vue";

// Main pages
import Dashboard from "@com/pages/Dashboard.vue";
import UserProfile from "@com/auth/UserProfile.vue";
import ChatBox from "@com/pages/ChatBox.vue";
import Chats from "@com/pages/Chats.vue";
import Backup from "@com/pages/Backup.vue";
import Category from "@com/pages/CategoriesPage.vue";
import Tag from "@com/pages/Tag.vue";
import ItemsPage from "@com/pages/ItemsPage.vue";
import ItemsPageAuthor from "@com/pages/ItemsPageAuthor.vue";
import ItemsView from "@com/pages/ItemView.vue";
import ItemPdfViewer from "@com/pages/ItemPdfViewer.vue";
import User from "@com/pages/User.vue";
import UserPermissions from "@com/pages/UserPermissions.vue";
import LibraryBook from "@com/pages/Library.vue";
import SearchBook from "@com/pages/Search.vue";
import BookDetails from "@com/pages/BookDetails.vue";
import BookDetailView from "@com/pages/BookDetailView.vue";

import ForbiddenPage from "@com/pages/ForbiddenPage.vue";
import NotFoundPage from "@com/pages/NotFoundPage.vue";

// Layout includes
import Navbar from "@com/includes/Navbar.vue";
import Footer from "@com/includes/Footer.vue";
import Sidebar from "@com/includes/Sidebar.vue";

const API_BASE = import.meta.env.VITE_URL || window.location.origin;
const API_URL = `${API_BASE}/api`;

const includes = {
    navbar: Navbar,
    sidebar: Sidebar,
    footer: Footer,
};

function withLayout(component) {
    return {
        default: component,
        ...includes,
    };
}

const PUBLIC_ROUTE_NAMES = new Set([
    "auth.signin",
    "auth.signup",
    "auth.verify.email",
    "auth.reset.password",
    "auth.set.password",
    "auth.google.callback",
    "auth.google.callback.error",
    "403",
    "404",
]);

const IGNORE_PERMISSION_ROUTE_NAMES = new Set([
    "dashboard",
    "profile",
    "auth.signout",
]);

let permissionSet = null;
let permissionPromise = null;

function getToken() {
    return localStorage.getItem("token");
}

function isAuthenticated() {
    return Boolean(getToken());
}

function normalizePermissions(data) {
    return (Array.isArray(data) ? data : [])
        .map((item) => String(item?.route_name || "").trim())
        .filter(Boolean);
}

async function loadPermissionSet(force = false) {
    if (permissionSet && !force) {
        return permissionSet;
    }

    if (permissionPromise && !force) {
        return permissionPromise;
    }

    permissionPromise = axios
        .get(`${API_URL}/permissions`, {
            headers: {
                Authorization: `Bearer ${getToken()}`,
            },
        })
        .then(({ data }) => {
            permissionSet = new Set(normalizePermissions(data));
            return permissionSet;
        })
        .catch((error) => {
            console.error("Failed to load permissions", error);
            permissionSet = new Set();
            throw error;
        })
        .finally(() => {
            permissionPromise = null;
        });

    return permissionPromise;
}

function clearPermissionCache() {
    permissionSet = null;
    permissionPromise = null;
}

const routes = [
    {
        path: "/login",
        name: "auth.signin",
        component: Signin,
        meta: { public: true },
    },
    {
        path: "/signout",
        name: "auth.signout",
        component: Signout,
        meta: { guard: true, ignorePermission: true },
    },
    {
        path: "/signup",
        name: "auth.signup",
        component: Signup,
        meta: { public: true },
    },
    {
        path: "/email/verify/:api_url",
        name: "auth.verify.email",
        component: VerifyEmail,
        meta: { public: true },
    },
    {
        path: "/password/reset",
        name: "auth.reset.password",
        component: ResetPassword,
        meta: { public: true },
    },
    {
        path: "/password/reset/:api_url",
        name: "auth.set.password",
        component: SetNewPassword,
        meta: { public: true },
    },
    {
        path: "/auth/google/callback",
        name: "auth.google.callback",
        component: GoogleCallback,
        meta: { public: true },
    },
    {
        path: "/auth/google/callback/error",
        name: "auth.google.callback.error",
        component: GoogleCallbackError,
        meta: { public: true },
    },

    {
        path: "/dashboard",
        name: "dashboard",
        components: withLayout(Dashboard),
        meta: { guard: true, ignorePermission: true },
    },
    {
        path: "/library",
        name: "library.book",
        components: withLayout(LibraryBook),
        meta: { guard: true },
    },

    {
        path: "/library/details/:id",
        name: "book.details",
        components: withLayout(BookDetails),
        meta: { guard: true, ignorePermission: true },
        props: {
            default: (route) => ({
                id: Number(route.params.id || 0),
            }),
        },
    },

    {
        path: "/library/details/view/:id/pdf-progress",
        name: "book.details.view",
        components: withLayout(BookDetailView),
        meta: { guard: true, ignorePermission: true  },
        props: {
            default: (route) => ({
                id: Number(route.params.id) || 0,
                file: String(route.query.file || ""),
                title: String(route.query.title || "Book Preview"),
            }),
        },
    },

    {
        path: "/search",
        name: "search.book",
        components: withLayout(SearchBook),
        meta: { guard: true },
    },
    {
        path: "/profile",
        name: "profile",
        components: withLayout(UserProfile),
        meta: { guard: true, ignorePermission: true },
    },
    {
        path: "/backups",
        name: "backups",
        components: withLayout(Backup),
        meta: { guard: true },
    },
    {
        path: "/tags",
        name: "tags",
        components: withLayout(Tag),
        meta: { guard: true },
    },

    {
        path: "/users",
        name: "users",
        components: withLayout(User),
        meta: { guard: true },
    },
    {
        path: "/users.permissions",
        name: "users.permissions",
        components: withLayout(UserPermissions),
        meta: { guard: true },
    },
    {
        path: "/chats/:chatId",
        name: "chats",
        components: withLayout(ChatBox),
        meta: { guard: true , ignorePermission: true},
        props: {
            default: true,
        },
    },
    {
        path: "/list.chats",
        name: "list.chats",
        components: withLayout(Chats),
        meta: { guard: true },
    },
    {
        path: "/list.chats/deleted/:chatId",
        name: "list.chats.deleted",
        components: withLayout(Chats),
        meta: { guard: true, ignorePermission: true  },
        props: {
            default: true,
        },
    },
    {
        path: "/categories",
        name: "categories",
        components: withLayout(Category),
        meta: { guard: true },
    },

    {
        path: "/items.author",
        name: "items.author",
        components: withLayout(ItemsPageAuthor),
        meta: { guard: true },
    },
    {
        path: "/items",
        name: "items",
        components: withLayout(ItemsPage),
        meta: { guard: true },
    },
    {
        path: "/items/view/:id",
        name: "items.view",
        components: withLayout(ItemsView),
        meta: { guard: true, ignorePermission: true  },
        props: {
            default: (route) => ({
                id: Number(route.params.id),
            }),
        },
    },
    {
        path: "/items/:itemId/pdf-progress",
        name: "items.pdf-progress",
        components: withLayout(ItemPdfViewer),
        meta: { guard: true, ignorePermission: true  },
        props: {
            default: (route) => ({
                itemId: Number(route.params.itemId),
                pdfUrl: route.query.file ?? null,
                title: route.query.title ?? "PDF Preview",
            }),
        },
    },

    {
        path: "/403",
        name: "403",
        component: ForbiddenPage,
        meta: { public: true },
    },
    {
        path: "/:pathMatch(.*)*",
        name: "404",
        component: NotFoundPage,
        meta: { public: true },
    },
];

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes,
});

router.beforeEach(async (to) => {
    const routeName = String(to.name || "");

    if (to.meta?.public || PUBLIC_ROUTE_NAMES.has(routeName)) {
        return true;
    }

    if (to.meta?.guard && !isAuthenticated()) {
        clearPermissionCache();
        return { name: "auth.signin" };
    }

    if (!to.meta?.guard) {
        return true;
    }

    if (to.meta?.ignorePermission || IGNORE_PERMISSION_ROUTE_NAMES.has(routeName)) {
        return true;
    }

    try {
        const permissions = await loadPermissionSet();

        if (!routeName) {
            return true;
        }

        if (!permissions.has(routeName)) {
            return {
                name: "403",
                query: { from: routeName },
            };
        }

        return true;
    } catch (error) {
        console.error("Router guard error:", error);
        clearPermissionCache();
        return { name: "auth.signin" };
    }
});

export default router;
