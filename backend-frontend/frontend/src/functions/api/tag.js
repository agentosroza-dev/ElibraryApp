
export const apiGetTags = (params = {}) => {
    return axios.get(window.API_URL +"/tags", { params });
};

export const apiCreateTag = (payload) => {
    return axios.post(window.API_URL +"/tags", payload);
};

export const apiGetTag = (id) => {
    return axios.get(window.API_URL +`/tags/${id}`);
};

export const apiUpdateTag = (id, payload) => {
    return axios.put(window.API_URL +`/tags/${id}`, payload);
};

export const apiDeleteTag = (id) => {
    return axios.delete(window.API_URL +`/tags/${id}`);
};

