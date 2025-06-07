document.addEventListener('DOMContentLoaded', () => {
    const logOutput = document.getElementById('logOutput');

    function appendLog(message) {
        logOutput.value += message + '\n';
        logOutput.scrollTop = logOutput.scrollHeight;
    }

    async function sendCommand(action, feature = '') {
        appendLog(`Mengirim perintah: ${action} ${feature || ''}...`);
        try {
            // Asumsi: KernelSU WebUI memungkinkan pemanggilan skrip shell secara langsung
            // Path ini harus sesuai dengan lokasi skrip executor di dalam modul yang diinstal
            const url = `/data/adb/modules/azmunaas_toolbox/scripts/executor.sh?action=${action}&feature=${feature}`;
            const response = await fetch(url, {
                method: 'GET',
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const text = await response.text();
            appendLog(`Output: \n${text}`);
            if (action === 'toggle') {
                updateToggleStates();
            }
        } catch (error) {
            appendLog(`Error eksekusi: ${error.message}`);
        }
    }

    async function updateToggleStates() {
        try {
            const url = `/data/adb/modules/azmunaas_toolbox/scripts/executor.sh?action=get_status`;
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const text = await response.text();
            const lines = text.split('\n').filter(line => line.trim() !== '');

            lines.forEach(line => {
                const [key, value] = line.split(':');
                if (key && value) {
                    let checkbox;
                    if (key === 'xiaomi_15_spoof_enabled') {
                        checkbox = document.getElementById('toggleXiaomi15');
                    } else if (key === 'user_build_spoof_enabled') {
                        checkbox = document.getElementById('toggleUserBuildSpoof');
                    } else if (key === 'pif_spoof_disable_enabled') {
                        checkbox = document.getElementById('togglePifSpoofDisable');
                    }
                    if (checkbox) {
                        checkbox.checked = (value === 'true');
                    }
                }
            });
            appendLog("Status toggle diperbarui.");
        } catch (error) {
            appendLog(`Error mendapatkan status: ${error.message}`);
        }
    }

    document.getElementById('toggleXiaomi15').addEventListener('change', (e) => {
        sendCommand('toggle', 'xiaomi_15_spoof');
    });
    document.getElementById('toggleUserBuildSpoof').addEventListener('change', (e) => {
        sendCommand('toggle', 'user_build_spoof');
    });
    document.getElementById('togglePifSpoofDisable').addEventListener('change', (e) => {
        sendCommand('toggle', 'pif_spoof_disable');
    });

    document.getElementById('executeKeybox').addEventListener('click', () => {
        sendCommand('execute', 'install_keybox');
    });
    document.getElementById('executeClearAppsData').addEventListener('click', () => {
        sendCommand('execute', 'clear_apps_data');
    });
    document.getElementById('executeKillApps').addEventListener('click', () => {
        sendCommand('execute', 'kill_apps');
    });
    document.getElementById('executeReplaceSound').addEventListener('click', () => {
        sendCommand('execute', 'replace_charging_sound');
    });

    updateToggleStates();
});
