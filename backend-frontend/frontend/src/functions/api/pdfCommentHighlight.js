
export function apiGetPdfCommentHighlights(params = {}) {
    return axios.get(window.API_URL + "/pdf-comment-highlights", { params });
}

export function apiCreatePdfCommentHighlight(payload) {
    return axios.post(window.API_URL + "/pdf-comment-highlights", payload);
}

export function apiUpdatePdfCommentHighlight(id, payload) {
    return axios.put(window.API_URL + `/pdf-comment-highlights/${id}`, payload);
}

export function apiDeletePdfCommentHighlight(id) {
    return axios.delete(window.API_URL + `/pdf-comment-highlights/${id}`);
}
