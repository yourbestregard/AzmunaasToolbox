let forcePreview = true;
let shellRunning = false;
let initialPinchDistance = null;
let currentFontSize = 14;
const MIN_FONT_SIZE = 8;
const MAX_FONT_SIZE = 24;

const spoofVendingSdkToggle = document.getElementById('toggle-sdk-vending');
const spoofConfig = [
    { container: "sdk-vending-toggle-container", toggle: spoofVendingSdkToggle, type: 'spoofVendingSdk' }
];

/**
 * Executes a shell command with KernelSU privileges
 * @param {string} command - The shell command to execute
 * @returns {Promise<string>} A promise that resolves with stdout content
 * @throws {Error} If command execution fails with:
 *   - Non-zero exit code (includes stderr in error message)
 */
function exec(command) {
    return new Promise((resolve, reject) => {
        const callbackFuncName = `exec_callback_${Date.now()}`;
        window[callbackFuncName] = (errno, stdout, stderr) => {
            delete window[callbackFuncName];
            if (errno !== 0) {
                reject(new Error(`Command failed with exit code ${errno}: ${stderr}`));
                return;
            }
            resolve(stdout);
        };
        try {
            ksu.exec(command, "{}", callbackFuncName);
        } catch (error) {
            delete window[callbackFuncName];
            reject(error);
        }
    });
}

/**
 * Spawns shell process with ksu spawn
 * @param {string} command - The command to execute
 * @param {string[]} [args=[]] - Array of arguments to pass to the command
 * @returns {Object} A child process object with:
 *   - stdout: Stream for standard output
 *   - stderr: Stream for standard error
 *   - stdin: Stream for standard input
 *   - on(event, listener): Attach event listener ('exit', 'error')
 *   - emit(event, ...args): Emit events internally
 */
function spawn(command, args = []) {
    const child = {
        listeners: {},
        stdout: { listeners: {} },
        stderr: { listeners: {} },
        stdin: { listeners: {} },
        on: function(event, listener) {
            if (!this.listeners[event]) this.listeners[event] = [];
            this.listeners[event].push(listener);
        },
        emit: function(event, ...args) {
            if (this.listeners[event]) {
                this.listeners[event].forEach(listener => listener(...args));
            }
        }
    };
    ['stdout', 'stderr', 'stdin'].forEach(io => {
        child[io].on = child.on.bind(child[io]);
        child[io].emit = child.emit.bind(child[io]);
    });
    const callbackName = `spawn_callback_${Date.now()}`;
    window[callbackName] = child;
    child.on("exit", () => delete window[callbackName]);
    try {
        ksu.spawn(command, JSON.stringify(args), "{}", callbackName);
    } catch (error) {
        child.emit("error", error);
        delete window[callbackName];
    }
    return child;
}

// Apply button event listeners
function applyButtonEventListeners() {
    const fetchButton = document.getElementById('fetch');
    const previewFpToggle = document.getElementById('preview-fp-toggle-container');
    const clearButton = document.querySelector('.clear-terminal');
    const terminal = document.querySelector('.output-terminal-content');

    fetchButton.addEventListener('click', runAction);
    previewFpToggle.addEventListener('click', async () => {
        forcePreview = !forcePreview;
        loadPreviewFingerprintConfig();
        appendToOutput(`[+] Switched fingerprint to ${isChecked ? 'beta' : 'preview'}`);
    });

    clearButton.addEventListener('click', () => {
        terminal.innerHTML = '';
        currentFontSize = 14;
        updateFontSize(currentFontSize);
    });
    
    terminal.addEventListener('touchstart', (e) => {
        if (e.touches.length === 2) {
            e.preventDefault();
            initialPinchDistance = getDistance(e.touches[0], e.touches[1]);
        }
    }, { passive: false });
    terminal.addEventListener('touchmove', (e) => {
        if (e.touches.length === 2) {
            e.preventDefault();
            const currentDistance = getDistance(e.touches[0], e.touches[1]);
            
            if (initialPinchDistance === null) {
                initialPinchDistance = currentDistance;
                return;
            }

            const scale = currentDistance / initialPinchDistance;
            const newFontSize = currentFontSize * scale;
            updateFontSize(newFontSize);
            initialPinchDistance = currentDistance;
        }
    }, { passive: false });
    terminal.addEventListener('touchend', () => {
        initialPinchDistance = null;
    });
}

// Function to load the version from module.prop
async function loadVersionFromModuleProp() {
    const versionElement = document.getElementById('version-text');
    try {
        const version = await exec("grep '^version=' /data/adb/modules/playintegrityfix/module.prop | cut -d'=' -f2");
        versionElement.textContent = version.trim();
    } catch (error) {
        appendToOutput("[!] Failed to read version from module.prop");
        console.error("Failed to read version from module.prop:", error);
    }
}

// Function to load spoof config
async function loadSpoofConfig() {
    try {
        const pifJson = await exec(`cat /data/adb/modules/playintegrityfix/pif.json`);
        const config = JSON.parse(pifJson);
        spoofVendingSdkToggle.checked = config.spoofVendingSdk;
    } catch (error) {
        appendToOutput(`[!] Failed to load spoof config`);
        console.error(`Failed to load spoof config:`, error);
    }
}

// Function to setup spoof config button
function setupSpoofConfigButton(container, toggle, type) {
    document.getElementById(container).addEventListener('click', async () => {
        if (shellRunning) return;
        muteToggle();
        try {
            const pifFile = await exec(`
                [ ! -f /data/adb/modules/playintegrityfix/pif.json ] || echo "/data/adb/modules/playintegrityfix/pif.json"
                [ ! -f /data/adb/pif.json ] || echo "/data/adb/pif.json"
            `);
            const files = pifFile.split('\n').filter(line => line.trim() !== '');
            for (const line of files) {
                await updateSpoofConfig(toggle, type, line.trim());
            }
            exec(`
                killall com.google.android.gms.unstable || true
                killall com.android.vending || true
            `);
            loadSpoofConfig();
            appendToOutput(`[+] Changed ${type} config to ${!toggle.checked}`);
        } catch (error) {
            appendToOutput(`[!] Failed to update ${type} config`);
            console.error(`Failed to update ${type} config:`, error);
        }
        unmuteToggle();
    });
}

// Function to update spoof config
async function updateSpoofConfig(toggle, type, pifFile) {
    const isChecked = toggle.checked;
    const pifJson = await exec(`cat ${pifFile}`);
    const config = JSON.parse(pifJson);
    config[type] = !isChecked;
    const newPifJson = JSON.stringify(config, null, 2);
    await exec(`echo '${newPifJson}' > ${pifFile}`);
}

// Function to load preview fingerprint config
function loadPreviewFingerprintConfig() {
    const previewFpToggle = document.getElementById('toggle-preview-fp');
    previewFpToggle.checked = forcePreview;
}

// Function to append element in output terminal
function appendToOutput(content) {
    const output = document.querySelector('.output-terminal-content');
    if (content.trim() === "") {
        const lineBreak = document.createElement('br');
        output.appendChild(lineBreak);
    } else {
        const line = document.createElement('p');
        line.className = 'output-content';
        line.innerHTML = content.replace(/ /g, '&nbsp;');
        output.appendChild(line);
    }
    output.scrollTop = output.scrollHeight;
}

// Function to run the script and display its output
function runAction() {
    if (shellRunning) return;
    muteToggle();
    const args = ["/data/adb/modules/playintegrityfix/autopif.sh"];
    if (forcePreview) args.push('-p');
    const scriptOutput = spawn("sh", args);
    scriptOutput.stdout.on('data', (data) => appendToOutput(data));
    scriptOutput.stderr.on('data', (data) => appendToOutput(data));
    scriptOutput.on('exit', () => {
        appendToOutput("");
        unmuteToggle();
    });
    scriptOutput.on('error', () => {
        appendToOutput("[!] Error: Fail to execute autopif.sh");
        appendToOutput("");
        unmuteToggle();
    });
}

function updateAutopif() {
    muteToggle();
    const scriptOutput = spawn("sh", ["/data/adb/modules/playintegrityfix/autopif_ota.sh"]);
    scriptOutput.stdout.on('data', (data) => appendToOutput(data));
    scriptOutput.stderr.on('data', (data) => appendToOutput(data));
    scriptOutput.on('exit', () => {
        unmuteToggle();
    });
    scriptOutput.on('error', () => {
        appendToOutput("[!] Error: Fail to execute autopif_ota.sh");
        appendToOutput("");
        unmuteToggle();
    });
}

function muteToggle() {
    shellRunning = true;
    document.querySelectorAll('.toggle-list').forEach(toggle => {
        toggle.classList.add('toggle-muted');
    });
}

function unmuteToggle() {
    shellRunning = false;
    document.querySelectorAll('.toggle-list').forEach(toggle => {
        toggle.classList.remove('toggle-muted');
    });
}

/**
 * Simulate MD3 ripple animation
 * Usage: class="ripple-element" style="position: relative; overflow: hidden;"
 * Note: Require background-color to work properly
 * @return {void}
 */
function applyRippleEffect() {
    document.querySelectorAll('.ripple-element').forEach(element => {
        if (element.dataset.rippleListener !== "true") {
            element.addEventListener("pointerdown", async (event) => {
                // Pointer up event
                const handlePointerUp = () => {
                    ripple.classList.add("end");
                    setTimeout(() => {
                        ripple.classList.remove("end");
                        ripple.remove();
                    }, duration * 1000);
                    element.removeEventListener("pointerup", handlePointerUp);
                    element.removeEventListener("pointercancel", handlePointerUp);
                };
                element.addEventListener("pointerup", handlePointerUp);
                element.addEventListener("pointercancel", handlePointerUp);

                const ripple = document.createElement("span");
                ripple.classList.add("ripple");

                // Calculate ripple size and position
                const rect = element.getBoundingClientRect();
                const width = rect.width;
                const size = Math.max(rect.width, rect.height);
                const x = event.clientX - rect.left - size / 2;
                const y = event.clientY - rect.top - size / 2;

                // Determine animation duration
                let duration = 0.2 + (width / 800) * 0.4;
                duration = Math.min(0.8, Math.max(0.2, duration));

                // Set ripple styles
                ripple.style.width = ripple.style.height = `${size}px`;
                ripple.style.left = `${x}px`;
                ripple.style.top = `${y}px`;
                ripple.style.animationDuration = `${duration}s`;
                ripple.style.transition = `opacity ${duration}s ease`;

                // Adaptive color
                const computedStyle = window.getComputedStyle(element);
                const bgColor = computedStyle.backgroundColor || "rgba(0, 0, 0, 0)";
                const isDarkColor = (color) => {
                    const rgb = color.match(/\d+/g);
                    if (!rgb) return false;
                    const [r, g, b] = rgb.map(Number);
                    return (r * 0.299 + g * 0.587 + b * 0.114) < 96; // Luma formula
                };
                ripple.style.backgroundColor = isDarkColor(bgColor) ? "rgba(255, 255, 255, 0.2)" : "";

                // Append ripple
                element.appendChild(ripple);
            });
            element.dataset.rippleListener = "true";
        }
    });
}

// Function to check if running in MMRL
async function checkMMRL() {
    if (typeof ksu !== 'undefined' && ksu.mmrl) {
        // Set status bars theme based on device theme
        try {
            $playintegrityfix.setLightStatusBars(!window.matchMedia('(prefers-color-scheme: dark)').matches)
        } catch (error) {
            console.log("Error setting status bars theme:", error)
        }
    }
}

function getDistance(touch1, touch2) {
    return Math.hypot(
        touch1.clientX - touch2.clientX,
        touch1.clientY - touch2.clientY
    );
}

function updateFontSize(newSize) {
    currentFontSize = Math.min(Math.max(newSize, MIN_FONT_SIZE), MAX_FONT_SIZE);
    const terminal = document.querySelector('.output-terminal-content');
    terminal.style.fontSize = `${currentFontSize}px`;
}

document.addEventListener('DOMContentLoaded', async () => {
    checkMMRL();
    loadVersionFromModuleProp();
    await loadSpoofConfig();
    spoofConfig.forEach(config => {
        setupSpoofConfigButton(config.container, config.toggle, config.type);
    });
    loadPreviewFingerprintConfig();
    applyButtonEventListeners();
    applyRippleEffect();
    updateAutopif();
});
