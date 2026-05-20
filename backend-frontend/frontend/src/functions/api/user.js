export function apiGetUsers(params = {}) {
    return axios.get(window.API_URL + '/users', { params });
}

export function apiGetUsers_author(params = {}) {
    return axios.get(window.API_URL + '/users', {
        params: {
            ...params,
            level: 2, // 1=admin, 2=author, 3=user
        },
    });
}

export function apiGetDetailUsers(params = {}) {
    return axios.get(window.API_URL + `/manage/users`, { params });
}

export function apiReadDetailUser(id) {
    return axios.get(window.API_URL + `/manage/users/read/${id}`);
}

export function apiCreateUser(data) {
    return axios.post(window.API_URL + `/manage/users/create`, data);
}

export function apiUpdateUser(id, data) {
    return axios.put(window.API_URL + `/manage/users/update/${id}`, data);
}

export function apiDeleteUser(id) {
    return axios.delete(window.API_URL + `/manage/users/delete/${id}`);
}

export const apiGetAuthors = (params = {}) => {
    return axios.get(window.API_URL + "/users", { params });
};


export function apiGetProfile() {
    return axios.get(window.API_URL +`/users/profile`);
}

export function apiUpdateProfile(payload) {
    return axios.patch(window.API_URL +`/users/profile`, payload);
}

export function apiUpdateAbout(payload) {
    return axios.patch(window.API_URL +`/users/about`, payload);
}

export function apiGetInterestTags() {
    return axios.get(window.API_URL +`/users/interests`);
}

export function apiGetUserTagInterests() {
    return axios.get(window.API_URL +`/users/user-tag-interests`);
}
export function apiGetRecommendedBooks(params = {}) {
    return axios.get(window.API_URL +"/users/recommended-books", { params });
}

export function apiGetRecommendedOverallBooks(params = {}) {
    return axios.get(window.API_URL +"/users/recommended-overall-books", { params });
}

export function apiGetSimilarTitleBooks(id, params = {}) {
    return axios.get(window.API_URL + `/users/books/${id}/similar-titles`, { params });
}

export function apiGetProfileFavorites() {
    return axios.get(window.API_URL +`/users/favorites`);
}

export function apiGetProfileLogs() {
    return axios.get(window.API_URL +`/users/logs`);
}
