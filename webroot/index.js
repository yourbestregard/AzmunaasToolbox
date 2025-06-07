import { ModuleInterface } from "../assets/ModuleInterface.js";
import { ApplicationInterface } from "../assets/ApplicationInterface.js";
import { FileInterface } from "../assets/FileInterface.js";

// Menginisialisasi interface API WebUI X
const module = new ModuleInterface();
const app = new ApplicationInterface();
const file = new FileInterface();

// Dapatkan referensi ke elemen log dan tema
const logOutput = document.getElementById('logOutput');
const themePicker = document.getElementById('themePicker');

// Jalur ke file preferensi tema di direktori flags modul
const THEME_PREFERENCE_FILE = 'theme_preference.txt';

/**
 * Fungsi untuk memperbarui area log dengan pesan berformat waktu dan tipe.
 * Pesan akan digulir otomatis ke bawah.
 * @param {string} message - Pesan yang akan dicatat.
 * @param {string} [type='info'] - Tipe pesan (misal: 'info', 'success', 'warning', 'error').
 */
const updateLog = (message, type = 'info') => {
    const timestamp = new Date().toLocaleTimeString();
    let formattedMessage = `[${timestamp}] `;

    if (type === 'error') {
        formattedMessage += `[ERROR] ${message}\n`;
    } else if (type === 'warning') {
        formattedMessage += `[PERINGATAN] ${message}\n`;
    } else if (type === 'success') {
        formattedMessage += `[BERHASIL] ${message}\n`;
    } else {
        formattedMessage += `${message}\n`;
    }
    logOutput.value += formattedMessage;
    logOutput.scrollTop = logOutput.scrollHeight;
};

// Fungsi toast sederhana sebagai pengganti jika tidak ada API toast langsung
const toast = (message, duration = 2000) => {
    // Implementasi toast sederhana atau biarkan kosong jika WebUI X memiliki toast bawaan
    // Di lingkungan nyata, WebUI X akan menyediakan fungsi toast global.
    // Untuk tujuan demo, kita akan log ke konsol atau logOutput.
    updateLog(`Toast: ${message}`);
};

/**
 * Redirect ke link menggunakan perintah am.
 * @param {string} link - Link yang akan dibuka di browser.
 */
function linkRedirect(link) {
    toast("Redirecting to " + link);
    setTimeout(async () => {
        try {
            const result = await module.execute(`am start -a android.intent.action.VIEW -d ${link}`, { env: { PATH: '/system/bin' }});
            if (result.code !== 0) {
                toast("Failed to open link");
                updateLog(`Gagal membuka link: ${result.stderr}`, 'error');
            }
        } catch (error) {
            toast("Failed to open link");
            updateLog(`Error saat membuka link: ${error.message}`, 'error');
        }
    }, 100);
}
window.linkRedirect = linkRedirect; // Jadikan global agar bisa diakses dari HTML

document.addEventListener('DOMContentLoaded', async () => {
    updateLog('Memuat Azmunaa's Toolbox WebUI...');

    // ================================================
    //  Memuat dan Menampilkan Informasi Modul
    // ================================================

    try {
        const moduleInfo = await module.getModuleInfo();
        document.getElementById('module-name').textContent = moduleInfo.name;
        document.getElementById('module-version').textContent = moduleInfo.version;
        document.getElementById('module-author').textContent = moduleInfo.author;
        document.getElementById('module-description').textContent = moduleInfo.description || 'Tidak ada deskripsi.';
        updateLog(`Informasi modul dimuat: ${moduleInfo.name} (${moduleInfo.version})`, 'success');
    } catch (error) {
        updateLog(`Error memuat info modul: ${error.message}`, 'error');
    }

    // ================================================
    //  Fungsi untuk Mengelola Status Fitur (Flags) melalui executor.sh
    // ================================================

    /**
     * Membaca status (aktif/nonaktif) sebuah fitur toggle dari file bendera melalui `executor.sh`.
     * @param {string} flagName - Nama dasar fitur (misal: 'xiaomi_15_spoof').
     * @returns {Promise<boolean>} - `true` jika fitur aktif (file bendera ada), `false` jika tidak.
     */
    const readFlagStatus = async (flagName) => {
        try {
            const result = await module.execute('scripts/executor.sh', ['get_status']);
            if (result.code === 0) {
                const lines = result.stdout.split('\n');
                for (const line of lines) {
                    if (line.includes(`${flagName}_enabled`)) {
                        return line.endsWith(':true');
                    }
                }
            }
            updateLog(`Gagal mendapatkan status flag ${flagName} dari executor.sh: ${result.stderr || result.stdout}`, 'warning');
            return false;
        } catch (error) {
            updateLog(`Error membaca status flag ${flagName}: ${error.message}`, 'error');
            return false;
        }
    };

    /**
     * Mengatur status (aktif/nonaktif) sebuah fitur toggle dengan memanggil `executor.sh`.
     * @param {string} flagName - Nama dasar fitur (misal: 'xiaomi_15_spoof').
     * @param {boolean} enabled - `true` untuk mengaktifkan, `false` untuk menonaktifkan.
     */
    const setFlagStatus = async (flagName, enabled) => {
        updateLog(`Mengatur status flag ${flagName} menjadi: ${enabled ? 'Aktif' : 'Nonaktif'}...`);
        try {
            const result = await module.execute('scripts/executor.sh', ['toggle', flagName]);
            if (result.code === 0) {
                updateLog(`Status ${flagName} berhasil diubah.`, 'success');
                updateLog('Perubahan akan diterapkan setelah reboot.');
            } else {
                updateLog(`Gagal mengatur status flag ${flagName}: ${result.stderr || result.stdout}`, 'error');
            }
        } catch (error) {
            updateLog(`Error mengatur status flag ${flagName}: ${error.message}`, 'error');
        }
    };

    /**
     * Menginisialisasi status awal checkbox toggle dan menambahkan event listener.
     * @param {string} toggleId - ID HTML dari elemen checkbox toggle.
     * @param {string} flagName - Nama fitur yang terkait dengan toggle (digunakan untuk memanipulasi flag).
     */
    const initializeToggle = async (toggleId, flagName) => {
        const checkbox = document.getElementById(toggleId);
        const isEnabled = await readFlagStatus(flagName);
        checkbox.checked = isEnabled;
        checkbox.addEventListener('change', async () => {
            await setFlagStatus(flagName, checkbox.checked);
        });
    };

    // Inisialisasi semua toggle fitur saat DOM selesai dimuat.
    await initializeToggle('toggleXiaomi15', 'xiaomi_15_spoof');
    await initializeToggle('toggleUserBuildSpoof', 'user_build_spoof');
    await initializeToggle('togglePifSpoofDisable', 'pif_spoof_disable');

    // ================================================
    //  Fungsi untuk Mengeksekusi Skrip melalui executor.sh
    // ================================================

    /**
     * Mengeksekusi skrip shell modul melalui `executor.sh`.
     * @param {string} scriptName - Nama dasar skrip yang akan dieksekusi (misal: 'install_keybox').
     * @param {string} buttonId - ID HTML dari tombol yang memicu eksekusi, untuk menonaktifkannya.
     */
    const executeScript = async (scriptName, buttonId) => {
        const button = document.getElementById(buttonId);
        button.disabled = true;
        updateLog(`Menjalankan skrip: ${scriptName}.sh...`);
        try {
            const result = await module.execute('scripts/executor.sh', ['execute', scriptName]);
            if (result.code === 0) {
                updateLog(`Skrip ${scriptName}.sh berhasil dieksekusi.`, 'success');
                if (result.stdout) updateLog(`Output STDOUT: \n${result.stdout}`);
                if (result.stderr) updateLog(`Output STDERR: \n${result.stderr}`, 'warning');
            } else {
                updateLog(`Skrip ${scriptName}.sh GAGAL dieksekusi. Exit code: ${result.code}`, 'error');
                if (result.stdout) updateLog(`Output STDOUT: \n${result.stdout}`, 'error');
                if (result.stderr) updateLog(`Output STDERR: \n${result.stderr}`, 'error');
            }
        } catch (error) {
            updateLog(`Error eksekusi skrip ${scriptName}.sh: ${error.message}`, 'error');
        } finally {
            button.disabled = false;
        }
    };

    // ================================================
    //  Event Listener untuk Tombol Eksekusi Skrip
    // ================================================

    document.getElementById('executeKeybox').addEventListener('click', () => executeScript('install_keybox', 'executeKeybox'));
    document.getElementById('executeClearAppsData').addEventListener('click', () => executeScript('clear_apps_data', 'executeClearAppsData'));
    document.getElementById('executeKillApps').addEventListener('click', () => executeScript('kill_apps', 'executeKillApps'));
    document.getElementById('executeReplaceSound').addEventListener('click', () => executeScript('replace_charging_sound', 'executeReplaceSound'));

    // ================================================
    //  Event Listener untuk Tombol Reboot
    // ================================================

    document.getElementById('rebootButton').addEventListener('click', async () => {
        updateLog('Memicu reboot perangkat...');
        try {
            await app.reboot();
            updateLog('Perangkat sedang reboot.', 'success');
        } catch (error) {
            updateLog(`Gagal memicu reboot melalui API: ${error.message}. Mencoba menggunakan skrip.`, 'warning');
            try {
                await module.execute('scripts/reboot.sh');
                updateLog('Reboot dipicu melalui skrip shell.', 'success');
            } catch (scriptError) {
                updateLog(`Gagal memicu reboot melalui skrip: ${scriptError.message}`, 'error');
                updateLog('Pastikan KernelSU memiliki izin reboot atau skrip reboot.sh ada dan dapat dieksekusi.', 'error');
            }
        }
    });

    // ================================================
    //  Fungsionalitas Refresh Log
    // ================================================

    document.getElementById('refreshLogButton').addEventListener('click', async () => {
        updateLog('Memuat ulang log eksekusi dari file...', 'info');
        logOutput.value = '';
        try {
            const logFilePath = 'executor_log.txt';
            const logContent = await module.execute(`cat ${logFilePath}`);
            if (logContent.code === 0) {
                logOutput.value = logContent.stdout;
                updateLog('Log berhasil dimuat ulang.', 'success');
            } else {
                updateLog(`Gagal membaca log dari ${logFilePath}: ${logContent.stderr || logContent.stdout}`, 'error');
            }
        } catch (error) {
            updateLog(`Error saat refresh log: ${error.message}`, 'error');
        }
    });

    // ================================================
    //  Fungsionalitas Tema Aplikasi Dinamis (Simulasi)
    // ================================================

    /**
     * Menerapkan tema yang dipilih ke elemen <body> HTML.
     * @param {string} themeName - Nama tema (misal: 'default', 'dark', 'blue-accent').
     */
    const applyTheme = (themeName) => {
        document.body.classList.remove('theme-dark', 'theme-blue-accent', 'theme-green-accent');
        if (themeName !== 'default') {
            document.body.classList.add(`theme-${themeName}`);
        }
        updateLog(`Tema diubah menjadi: ${themeName}.`, 'info');
    };

    /**
     * Menyimpan preferensi tema ke file di modul.
     * @param {string} themeName - Nama tema yang akan disimpan.
     */
    const saveThemePreference = async (themeName) => {
        try {
            await file.writeFile(`flags/${THEME_PREFERENCE_FILE}`, themeName);
            updateLog(`Preferensi tema \'${themeName}\' berhasil disimpan.`, 'info');
        } catch (error) {
            updateLog(`Error menyimpan preferensi tema: ${error.message}`, 'error');
        }
    };

    /**
     * Memuat preferensi tema saat WebUI dimuat dan menerapkannya.
     */
    const loadAndApplyTheme = async () => {
        try {
            const result = await file.readFile(`flags/${THEME_PREFERENCE_FILE}`);
            if (result.code === 0 && result.stdout) {
                const savedTheme = result.stdout.trim();
                themePicker.value = savedTheme;
                applyTheme(savedTheme);
            } else {
                applyTheme('default');
                themePicker.value = 'default';
                updateLog('Preferensi tema tidak ditemukan, menerapkan tema default.', 'info');
            }
        } catch (error) {
            updateLog(`Error memuat preferensi tema: ${error.message}. Menerapkan tema default.`, 'error');
            applyTheme('default');
            themePicker.value = 'default';
        }
    };

    // Muat dan terapkan tema saat WebUI pertama kali dimuat
    await loadAndApplyTheme();

    // Event listener untuk perubahan pada pemilihan tema
    themePicker.addEventListener('change', async (event) => {
        const selectedTheme = event.target.value;
        applyTheme(selectedTheme);
        await saveThemePreference(selectedTheme);
    });

    updateLog('WebUI siap. Silakan atur fitur atau jalankan skrip.');
});

// Simulate MD3 ripple animation
// Usage: class="ripple-element" style="position: relative; overflow: hidden;"
// Note: Require background-color to work properly
function applyRippleEffect() {
    document.querySelectorAll('.ripple-element').forEach(element => {
        if (element.dataset.rippleListener !== "true") {
            element.addEventListener("pointerdown", async (event) => {
                const handlePointerUp = () => {
                    ripple.classList.add("end");
                    setTimeout(() => {
                        ripple.classList.remove("end");
                        ripple.remove();
                    }, duration * 1000);
                    element.removeEventListener("pointerup", handlePointerUp);
                    element.removeEventListener("pointercancel", handlePointerUp);
                };
                element.addEventListener("pointerup", () => setTimeout(handlePointerUp, 80));
                element.addEventListener("pointercancel", () => setTimeout(handlePointerUp, 80));

                const ripple = document.createElement("span");
                ripple.classList.add("ripple");

                const rect = element.getBoundingClientRect();
                const width = rect.width;
                const size = Math.max(rect.width, rect.height);
                const x = event.clientX - rect.left - size / 2;
                const y = event.clientY - rect.top - size / 2;

                let duration = 0.2 + (width / 800) * 0.4;
                duration = Math.min(0.8, Math.max(0.2, duration));

                ripple.style.width = ripple.style.height = `${size}px`;
                ripple.style.left = `${x}px`;
                ripple.style.top = `${y}px`;
                ripple.style.animationDuration = `${duration}s`;
                ripple.style.transition = `opacity ${duration}s ease`;

                const computedStyle = window.getComputedStyle(element);
                const bgColor = computedStyle.backgroundColor || "rgba(0, 0, 0, 0)";
                const isDarkColor = (color) => {
                    const rgb = color.match(/\d+/g);
                    if (!rgb) return false;
                    const [r, g, b] = rgb.map(Number);
                    return (r * 0.299 + g * 0.587 + b * 0.114) < 96;
                };
                ripple.style.backgroundColor = isDarkColor(bgColor) ? "rgba(255, 255, 255, 0.2)" : "";

                await new Promise(resolve => setTimeout(resolve, 80));
                if (isScrolling) return;
                element.appendChild(ripple);
            });
            element.dataset.rippleListener = "true";
        }
    });
}

let isScrolling = false, scrollTimeout;
window.addEventListener('scroll', () => {
    isScrolling = true;
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => isScrolling = false, 200);
});

document.addEventListener('DOMContentLoaded', () => {
    applyRippleEffect();
});
