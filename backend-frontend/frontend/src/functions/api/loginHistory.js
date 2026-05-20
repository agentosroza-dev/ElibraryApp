
import axios from "axios";

export function apiGetLoginHistories(params = {}) {
    return axios.get(window.API_URL + `/login-history`, { params });
}

export function apiGetCurrentLoginHistory() {
    return axios.get(window.API_URL + `/login-history/current`);
}


// https://api.ipify.org?format=json
// https://ipinfo.io/json
// https://api64.ipify.org?format=json

const IP_SERVICES = [
    "https://api.ipify.org?format=json",
    "https://ifconfig.me/all.json",
    "https://ipinfo.io/json",
    "https://api64.ipify.org?format=json"
];

async function fetchIpFrom(url, timeout = 1500) {
    const { data } = await axios.get(url, { timeout });

    const ip =
        data?.ip ||
        data?.ip_addr ||
        data?.ip_address ||
        data?.IPAddress ||
        null;

    return typeof ip === "string" && ip.trim() ? ip.trim() : null;
}

// export async function getPublicIP() {
//     for (const url of IP_SERVICES) {
//         try {
//             const ip = await fetchIpFrom(url);
//             if (ip) return ip;
//         } catch (error) {
//             console.warn(`Failed to get public IP from ${url}:`, error?.message || error);
//         }
//     }
//
//     return null;
// }





export async function getPublicIP() {
    for (const url of IP_SERVICES) {
        try {
            const { data } = await axios.get(url, { timeout: 1500 });

            const ip =
                data?.ip ||
                data?.ip_addr ||
                data?.ip_address ||
                data?.IPAddress;

            if (ip) return String(ip).trim();
        } catch (e) {
            console.warn("IP service failed:", url);
        }
    }

    return null;
}
