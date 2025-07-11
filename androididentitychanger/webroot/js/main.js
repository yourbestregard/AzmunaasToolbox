document.addEventListener('DOMContentLoaded', () => {
    // Periksa API KernelSU di awal
    if (typeof ksu !== 'object' || typeof ksu.exec !== 'function') {
        showToast("Error: API KernelSU tidak ditemukan!", "error", 5000);
        return;
    }

    const buttonContainer = document.getElementById('button-container');

    // Fungsi notifikasi "toast"
    function showToast(message, type = "info", duration = 3000) {
        const container = document.getElementById("toast-container");
        if (!container) return;
        const toast = document.createElement("div");
        toast.className = `toast ${type}`;
        toast.textContent = message;
        toast.style.animationDuration = `${duration / 1000}s`;
        container.appendChild(toast);
        setTimeout(() => toast.remove(), duration);
    }

    // Fungsi pembungkus Promise untuk ksu.exec
    function exec(command) {
        return new Promise((resolve, reject) => {
            const callbackName = `cb_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
            const timeoutId = setTimeout(() => {
                delete window[callbackName];
                reject(new Error(`Timeout saat menjalankan: ${command}`));
            }, 10000);

            window[callbackName] = (exitCode, stdout, stderr) => {
                clearTimeout(timeoutId);
                delete window[callbackName];
                if (exitCode === 0) {
                    resolve(stdout);
                } else {
                    reject(new Error(stderr || `Perintah gagal dengan kode: ${exitCode}`));
                }
            };

            try {
                ksu.exec(command, null, callbackName);
            } catch (e) {
                clearTimeout(timeoutId);
                delete window[callbackName];
                reject(e);
            }
        });
    }

    // Fungsi untuk menjalankan skrip yang dipilih
    async function runScript(scriptPath, button) {
        const fileName = scriptPath.split('/').pop();
        showToast(`Menjalankan: ${fileName}`, "info");
        button.classList.add("executing");
        button.disabled = true;

        try {
            const output = await exec(`sh ${scriptPath}`);
            showToast(output.trim() || `Skrip ${fileName} selesai.`, "success");
        } catch (error) {
            showToast(`Gagal menjalankan ${fileName}`, "error");
            console.error(error);
        } finally {
            button.classList.remove("executing");
            button.disabled = false;
        }
    }

    // Fungsi utama untuk inisialisasi
    async function initializeApp() {
        try {
            const modulePath = '/data/adb/modules/androididentitychanger';

            const commandToFindScripts = `find ${modulePath}/scripts -type f -name "*.sh"`;
            
            buttonContainer.innerHTML = '<p class="loading-text">Mencari profil...</p>';
            const scriptList = await exec(commandToFindScripts);

            if (scriptList && scriptList.trim()) {
                const scripts = scriptList.trim().split('\n').filter(s => s);
                buttonContainer.innerHTML = '';

                scripts.forEach(scriptPath => {
                    const fileName = scriptPath.split('/').pop();
                    const button = document.createElement('button');
                    button.className = 'action-button';
                    button.textContent = fileName.replace('.sh', '');
                    button.addEventListener('click', () => runScript(scriptPath, button));
                    buttonContainer.appendChild(button);
                });
            } else {
                buttonContainer.innerHTML = '<p class="loading-text">Tidak ada profil (.sh) ditemukan.</p>';
            }
        } catch (error) {
            showToast("Inisialisasi modul gagal!", "error");
            buttonContainer.innerHTML = '<p class="loading-text">Error saat memuat profil.</p>';
            console.error("Initialization failed:", error);
            if (error.message && error.message.includes("No such file or directory")) {
                showToast("Pastikan folder /scripts sudah ada di dalam modul Anda!", "error", 5000);
            }
        }
    }

    // Jalankan aplikasi
    initializeApp();
});