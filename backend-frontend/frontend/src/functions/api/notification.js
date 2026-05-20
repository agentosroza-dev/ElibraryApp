export function apiGetNotifications() {
    return axios.get(window.API_URL + "/notifications");
}

export function apiMarkNotificationRead(id) {
    return axios.patch(window.API_URL + `/notifications/${id}/read`);
}

export function apiMarkAllNotificationsRead() {
    return axios.patch(window.API_URL + "/notifications/read-all");
}

export function apiClearAllNotifications() {
    return axios.delete(window.API_URL + "/notifications/clear-all");
}



