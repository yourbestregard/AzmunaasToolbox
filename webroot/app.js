// app.js
//
// Skrip JavaScript utama untuk antarmuka WebUI X Azmunaa's Toolbox.
// Skrip ini bertanggung jawab untuk:
//   - Menginisialisasi koneksi dengan KernelSU WebUI API (ModuleInterface, ApplicationInterface, FileInterface).
//   - Memuat dan menampilkan informasi modul dari `module.prop`.
//   - Mengelola status toggle fitur (spoof Xiaomi 15, spoof userdebug, nonaktifkan spoof PIF)
//     dengan berinteraksi dengan file bendera melalui `executor.sh`.
//   - Mengeksekusi skrip-skrip sistem yang berbeda melalui `executor.sh`.
//   - Menangani fungsi reboot perangkat.
//   - Menampilkan log eksekusi dan memuat ulang log dari file.

document.addEventListener('DOMContentLoaded', async () => {
    // Dapatkan referensi ke elemen textarea untuk output log
    const logOutput = document.getElementById('logOutput');

    /**
     * Fungsi untuk memperbarui area log dengan pesan berformat waktu dan tipe.
     * @param {string} message - Pesan yang akan dicatat.
     * @param {string} [type='info'] - Tipe pesan (misal: 'info', 'success', 'warning', 'error').
     */
    const updateLog = (message, type = 'info') => {
        const timestamp = new Date().toLocaleTimeString(); // Dapatkan waktu saat ini
        let formattedMessage = `[${timestamp}] `;

        // Tambahkan prefix berdasarkan tipe pesan untuk visualisasi yang lebih baik
        if (type === 'error') {
            formattedMessage += `[ERROR] ${message}\n`;
        } else if (type === 'warning') {
            formattedMessage += `[PERINGATAN] ${message}\n`;
        } else if (type === 'success') {
            formattedMessage += `[BERHASIL] ${message}\n`;
        } else {
            formattedMessage += `${message}\n`;
        }
        logOutput.value += formattedMessage; // Tambahkan pesan ke textarea
        logOutput.scrollTop = logOutput.scrollHeight; // Gulir otomatis ke bawah
    };

    updateLog('Memuat Azmunaa\'s Toolbox WebUI...');

    // ================================================
    //  Inisialisasi API KernelSU WebUI X
    // ================================================

    // Inisialisasi ModuleInterface: Digunakan untuk mendapatkan informasi modul dan mengeksekusi skrip shell.
    const module = new ModuleInterface();
    // Inisialisasi ApplicationInterface: Digunakan untuk berinteraksi dengan fungsionalitas tingkat aplikasi,
    // seperti memicu reboot perangkat.
    const app = new ApplicationInterface();
    // Inisialisasi FileInterface: Digunakan untuk berinteraksi dengan sistem file modul (misal: membaca/menulis flags).
    const file = new FileInterface(); // Meskipun tidak langsung digunakan lagi, tetap ada jika diperlukan

    // ================================================
    //  Memuat dan Menampilkan Informasi Modul
    // ================================================

    // Mendapatkan informasi modul dari KernelSU dan menampilkannya di UI.
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
            // Panggil executor.sh dengan aksi 'get_status' untuk mendapatkan status semua flag.
            const result = await module.execute('scripts/executor.sh', ['get_status']);
            if (result.code === 0) {
                // Parsing output dari executor.sh untuk menemukan status flag yang spesifik.
                const lines = result.stdout.split('\n');
                for (const line of lines) {
                    if (line.includes(`${flagName}_enabled`)) {
                        return line.endsWith(':true');
                    }
                }
            }
            // Log peringatan jika status tidak dapat diambil atau executor.sh gagal.
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
            // Panggil executor.sh dengan aksi 'toggle' dan nama fitur.
            const result = await module.execute('scripts/executor.sh', ['toggle', flagName]);
            if (result.code === 0) {
                updateLog(`Status ${flagName} berhasil diubah.`);
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
        const isEnabled = await readFlagStatus(flagName); // Baca status awal
        checkbox.checked = isEnabled; // Atur status checkbox
        checkbox.addEventListener('change', async () => {
            // Ketika status checkbox berubah, panggil setFlagStatus
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
        button.disabled = true; // Nonaktifkan tombol untuk mencegah klik ganda selama eksekusi
        updateLog(`Menjalankan skrip: ${scriptName}.sh...`);
        try {
            // Panggil executor.sh dengan aksi 'execute' dan nama skrip.
            // Output stdout/stderr dari executor.sh akan langsung ditangkap di sini.
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
            button.disabled = false; // Selalu aktifkan kembali tombol setelah eksekusi selesai (berhasil/gagal)
        }
    };

    // ================================================
    //  Event Listener untuk Tombol Eksekusi Skrip
    // ================================================

    // Tambahkan event listener 'click' untuk setiap tombol skrip.
    document.getElementById('executeKeybox').addEventListener('click', () => executeScript('install_keybox', 'executeKeybox'));
    document.getElementById('executeClearAppsData').addEventListener('click', () => executeScript('clear_apps_data', 'executeClearAppsData'));
    document.getElementById('executeKillApps').addEventListener('click', () => executeScript('kill_apps', 'executeKillApps'));
    document.getElementById('executeReplaceSound').addEventListener('click', () => executeScript('replace_charging_sound', 'executeReplaceSound'));

    // ================================================
    //  Event Listener untuk Tombol Reboot
    // ================================================

    // Menambahkan event listener 'click' untuk tombol reboot.
    document.getElementById('rebootButton').addEventListener('click', async () => {
        updateLog('Memicu reboot perangkat...');
        try {
            // Coba panggil `ApplicationInterface.reboot()` yang merupakan API bawaan WebUI X.
            await app.reboot();
            updateLog('Perangkat sedang reboot.', 'success');
        } catch (error) {
            // Jika API reboot gagal (misal: tidak diizinkan atau tidak tersedia), coba eksekusi skrip reboot.
            updateLog(`Gagal memicu reboot melalui API: ${error.message}. Mencoba menggunakan skrip.`, 'warning');
            try {
                // Panggil skrip `reboot.sh` yang telah dibuat sebelumnya.
                await module.execute('scripts/reboot.sh');
                updateLog('Reboot dipicu melalui skrip shell.', 'success');
            } catch (scriptError) {
                // Jika skrip reboot juga gagal, log error.
                updateLog(`Gagal memicu reboot melalui skrip: ${scriptError.message}`, 'error');
                updateLog('Pastikan KernelSU memiliki izin reboot atau skrip reboot.sh ada dan dapat dieksekusi.', 'error');
            }
        }
    });

    // ================================================
    //  Fungsionalitas Refresh Log
    // ================================================

    // Buat elemen tombol 'Refresh Log' secara dinamis.
    const refreshLogButton = document.createElement('button');
    refreshLogButton.className = 'webui-button'; // Terapkan gaya WebUI X
    refreshLogButton.textContent = 'Refresh Log';
    // Tambahkan tombol di atas area textarea log (menggunakan `prepend`)
    document.querySelector('.log-section').prepend(refreshLogButton);

    // Tambahkan event listener 'click' untuk tombol 'Refresh Log'.
    refreshLogButton.addEventListener('click', async () => {
        updateLog('Memuat ulang log eksekusi dari file...', 'info');
        logOutput.value = ''; // Bersihkan log yang ada di textarea sebelum memuat ulang
        try {
            const logFilePath = 'executor_log.txt'; // Jalur ke file log `executor.sh`
            // Gunakan `module.execute('cat <filepath>')` untuk membaca konten file log.
            const logContent = await module.execute(`cat ${logFilePath}`);
            if (logContent.code === 0) {
                logOutput.value = logContent.stdout; // Tampilkan isi log file di textarea
                updateLog('Log berhasil dimuat ulang.', 'success');
            } else {
                updateLog(`Gagal membaca log dari ${logFilePath}: ${logContent.stderr || logContent.stdout}`, 'error');
            }
        } catch (error) {
            updateLog(`Error saat refresh log: ${error.message}`, 'error');
        }
    });

    updateLog('WebUI siap. Silakan atur fitur atau jalankan skrip.');
});
