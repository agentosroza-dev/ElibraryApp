export function apiGetBookTags(bookId) {
    return axios.get(window.API_URL + `/books/${bookId}/tags`);
}
