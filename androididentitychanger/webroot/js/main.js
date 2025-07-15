document.addEventListener('DOMContentLoaded', () => {
    if (typeof ksu !== 'object' || typeof ksu.exec !== 'function') {
        showToast("Error: KernelSU API not found!", "error", 5000);
        return;
    }

    const buttonContainer = document.getElementById('button-container');
    const additionalMenu = document.getElementById('additional-menu');

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

    function exec(command) {
        return new Promise((resolve, reject) => {
            const callbackName = `cb_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
            const timeoutId = setTimeout(() => {
                delete window[callbackName];
                reject(new Error(`Timeout running: ${command}`));
            }, 10000);

            window[callbackName] = (exitCode, stdout, stderr) => {
                clearTimeout(timeoutId);
                delete window[callbackName];
                if (exitCode === 0) {
                    resolve(stdout);
                } else {
                    reject(new Error(stderr || `Command failed with exit code: ${exitCode}`));
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

    async function runScript(scriptPath, button) {
        const fileName = scriptPath.split('/').pop();
        showToast(`Running: ${fileName}`, "info");
        button.classList.add("executing");
        button.disabled = true;

        try {
            const output = await exec(`sh ${scriptPath}`);
            showToast(output.trim() || `Script ${fileName} completed.`, "success");
        } catch (error) {
            showToast(`Failed to run ${fileName}`, "error");
            console.error(error);
        } finally {
            button.classList.remove("executing");
            button.disabled = false;
        }
    }

    // Helper function to format button labels nicely
    function formatLabel(fileName) {
        return fileName
            .replace(/\.sh$/i, '')
            .replace(/_/g, ' ')
            .replace(/-/g, ' ')
            .replace(/\b\w/g, c => c.toUpperCase());
    }

    async function initializeApp() {
        try {
            const modulePath = '/data/adb/modules/androididentitychanger';
            const findScriptsCmd = `find ${modulePath}/scripts -type f -name "*.sh"`;

            buttonContainer.innerHTML = '<p class="loading-text">Searching profiles...</p>';
            additionalMenu.innerHTML = ''; // Clear additional menu

            const scriptList = await exec(findScriptsCmd);

            if (scriptList && scriptList.trim()) {
                const scripts = scriptList.trim().split('\n').filter(s => s);

                const additionalScripts = [];
                const mainScripts = [];

                scripts.forEach(scriptPath => {
                    const fileName = scriptPath.split('/').pop().toLowerCase();
                    if (fileName === 'reset_default.sh' || fileName === 'reboot.sh') {
                        additionalScripts.push(scriptPath);
                    } else {
                        mainScripts.push(scriptPath);
                    }
                });

                // Sort scripts alphabetically by formatted label
                mainScripts.sort((a, b) => {
                    const labelA = formatLabel(a.split('/').pop());
                    const labelB = formatLabel(b.split('/').pop());
                    return labelA.localeCompare(labelB);
                });

                additionalScripts.sort((a, b) => {
                    const labelA = formatLabel(a.split('/').pop());
                    const labelB = formatLabel(b.split('/').pop());
                    return labelA.localeCompare(labelB);
                });

                // Render main menu buttons
                buttonContainer.innerHTML = '';
                mainScripts.forEach(scriptPath => {
                    const fileName = scriptPath.split('/').pop();
                    const button = document.createElement('button');
                    button.className = 'action-button';
                    button.textContent = formatLabel(fileName);
                    button.title = fileName; // Tooltip with original filename
                    button.addEventListener('click', () => runScript(scriptPath, button));
                    buttonContainer.appendChild(button);
                });

                // Render additional menu buttons
                additionalMenu.innerHTML = '';
                additionalScripts.forEach(scriptPath => {
                    const fileName = scriptPath.split('/').pop();
                    const button = document.createElement('button');
                    button.className = 'action-button';
                    button.textContent = formatLabel(fileName);
                    button.title = fileName;
                    button.addEventListener('click', () => runScript(scriptPath, button));
                    additionalMenu.appendChild(button);
                });

            } else {
                buttonContainer.innerHTML = '<p class="loading-text">No profiles (.sh) found.</p>';
            }
        } catch (error) {
            showToast("Module initialization failed!", "error");
            buttonContainer.innerHTML = '<p class="loading-text">Error loading profiles.</p>';
            console.error("Initialization failed:", error);
            if (error.message && error.message.includes("No such file or directory")) {
                showToast("Make sure the /scripts folder exists inside your module!", "error", 5000);
            }
        }
    }

    initializeApp();
});
