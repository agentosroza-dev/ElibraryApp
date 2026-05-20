export async function apiShowItem(id) {
    return await axios.get(window.API_URL + `/items/${id}`);
}

export const apiGetItems = (params = {}) => {
    return axios.get(window.API_URL + "/items", { params });
};

export const apiGetItemsAdmin = (params = {}) => {
    return axios.get(window.API_URL + "/items", { params });
};

export const apiGetItem = (id) => {
    return axios.get(window.API_URL + `/items/${id}`);
};

export const apiCreateItem = (payload) => {
    return axios.post(window.API_URL + "/items", payload, {
        headers: { "Content-Type": "multipart/form-data" },
    });
};

export const apiUpdateItem = (id, payload) => {
    return axios.post(window.API_URL + `/items/${id}`, payload, {
        headers: { "Content-Type": "multipart/form-data" },
    });
};

export const apiDeleteItem = (id) => {
    return axios.delete(window.API_URL + `/items/${id}`);
};

/*====== new view / favorite/ book tag======*/

export function apiRecordBookView(bookId) {
    return axios.post(window.API_URL + `/books/${bookId}/view`);
}


export function apiGetBookViewCount(bookId) {
    if (!bookId) throw new Error("bookId is required");

    return axios.get(`${window.API_URL}/books/${bookId}/views/count`);
}

export function apiCheckFavorite(bookId) {
    return axios.get(window.API_URL + `/books/${bookId}/favorite/check`);
}

export function apiAddFavorite(bookId) {
    return axios.post(window.API_URL + `/books/${bookId}/favorite`);
}

export function apiRemoveFavorite(bookId) {
    return axios.delete(window.API_URL + `/books/${bookId}/favorite`);
}

export function apiGetMyFavoriteBooks() {
    return axios.get(window.API_URL + `/my-favorite-books`);
}

export function apiUpdateBookTags(bookId, tagIds) {
    return axios.put(window.API_URL + `/books/${bookId}/tags`, {
        tag_ids: tagIds,
    });
}


export function apiGetPdfProgressList(params = {}) {
    return axios.get(window.API_URL +`/pdf-progress/pdf-progress-list`, { params });
}




export function apiSearchBooks(params = {}) {
    return axios.get(window.API_URL +`/search/books`, { params });
}

export function apiGetTrendingSearches(params = {}) {
    return axios.get(window.API_URL +`/search/trending`, { params });
}

export function apiGetSuggestedBooks(params = {}) {
    return axios.get(window.API_URL +`/search/suggested`, { params });
}



