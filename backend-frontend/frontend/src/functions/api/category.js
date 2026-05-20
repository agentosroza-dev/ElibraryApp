export async function apiGetCategories() {
    // GET /api/categories
    return await axios.get(window.API_URL + "/categories");
}

export async function apiCreateCategory(payload) {
    // POST /api/categories
    return await axios.post(window.API_URL + "/categories", payload);
}
export async function apiUpdateCategory(id, payload) {
    // PUT /api/categories/{id}
    return await axios.put(window.API_URL + `/categories/${id}`, payload);
}
export async function apiDeleteCategory(id) {
    // DELETE /api/categories/{id}
    return await axios.delete(window.API_URL + `/categories/${id}`);
}
export async function apiShowCategory(id) {
    // GET /api/categories/{id}
    return await axios.get(window.API_URL + `/categories/${id}`);
}

