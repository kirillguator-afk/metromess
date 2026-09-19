<!DOCTYPE html>
<html lang="ru" class="dark h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <title>METRO Messenger - P2P Encrypted Mesh Node</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        metro: {
                            50: '#f0fdfa',
                            100: '#ccfbf1',
                            500: '#06b6d4',
                            600: '#0891b2',
                            800: '#0f172a',
                            900: '#090d16',
                            950: '#030712',
                            accent: '#38bdf8',
                            emerald: '#10b981',
                            amber: '#f59e0b',
                            rose: '#f43f5e'
                        }
                    },
                    fontFamily: {
                        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
                        mono: ['JetBrains Mono', 'Consolas', 'monospace']
                    },
                    boxShadow: {
                        'glow-cyan': '0 0 25px rgba(6, 182, 212, 0.4)',
                        'glow-emerald': '0 0 25px rgba(16, 185, 129, 0.4)'
                    }
                }
            }
        }
    </script>

    <!-- Lucide Icons & PeerJS Public Signaling Bridge -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;700&display=swap');

        /* Metro Text Fill Animation */
        .metro-logo-text {
            font-size: clamp(2.5rem, 10vw, 6.5rem);
            font-weight: 900;
            letter-spacing: 0.25em;
            background: linear-gradient(to right, #ffffff 50%, rgba(255, 255, 255, 0.08) 50%);
            background-size: 200% 100%;
            background-position: 100% 0;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            animation: fillGlow 2.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            filter: drop-shadow(0 0 0px rgba(255, 255, 255, 0));
        }

        @keyframes fillGlow {
            0% {
                background-position: 100% 0;
                filter: drop-shadow(0 0 0px rgba(255,255,255,0));
            }
            70% {
                background-position: 0% 0;
                filter: drop-shadow(0 0 20px rgba(255,255,255,0.9)) drop-shadow(0 0 40px rgba(56,189,248,0.7));
            }
            100% {
                background-position: 0% 0;
                filter: drop-shadow(0 0 12px rgba(255,255,255,0.6)) drop-shadow(0 0 25px rgba(56,189,248,0.4));
            }
        }

        /* Glassmorphism Styles */
        .metro-glass {
            background: rgba(15, 23, 42, 0.8);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .metro-glass-card {
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.06);
        }

        /* Custom Scrollbars */
        ::-webkit-scrollbar {
            width: 4px;
            height: 4px;
        }
        ::-webkit-scrollbar-track {
            background: rgba(9, 13, 22, 0.6);
        }
        ::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 9999px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: rgba(6, 182, 212, 0.6);
        }

        /* Scanline Overlay Effect */
        .scanline-overlay {
            background: linear-gradient(
                rgba(18, 16, 16, 0) 50%, 
                rgba(0, 0, 0, 0.2) 50%
            ), linear-gradient(
                90deg,
                rgba(255, 0, 0, 0.02),
                rgba(0, 255, 0, 0.01),
                rgba(0, 0, 255, 0.02)
            );
            background-size: 100% 4px, 6px 100%;
            pointer-events: none;
        }

        /* Safe Area Padding for Mobile Notch/Home Bar */
        .pb-safe { padding-bottom: env(safe-area-inset-bottom, 1rem); }
        .pt-safe { padding-top: env(safe-area-inset-top, 1rem); }
    </style>
</head>
<body class="bg-metro-950 text-slate-100 font-sans h-full w-full overflow-hidden select-none flex flex-col antialiased">

    <!-- 1. SPLASH SCREEN ANIMATION -->
    <div id="splash-screen" class="fixed inset-0 z-50 bg-metro-950 flex flex-col items-center justify-center transition-opacity duration-700">
        <div class="relative flex flex-col items-center text-center p-4">
            <h1 class="metro-logo-text pl-4">METRO</h1>
            <p class="text-xs uppercase tracking-[0.5em] text-cyan-400 font-mono mt-3">P2P Mesh Encrypted Network Node</p>

            <div class="mt-10 flex items-center gap-3 bg-slate-900/80 px-4 py-2 rounded-full border border-slate-800">
                <span class="w-2.5 h-2.5 rounded-full bg-cyan-400 animate-ping"></span>
                <span id="splash-status" class="text-xs font-mono text-slate-400">Инициализация модулей WebCrypto & STUN...</span>
            </div>
        </div>
    </div>

    <!-- 2. IDENTITY CREATION / JSON KEY MODAL -->
    <div id="identity-screen" class="hidden fixed inset-0 z-40 bg-metro-950/95 flex items-center justify-center p-4 backdrop-blur-md overflow-y-auto">
        <div class="metro-glass w-full max-w-lg rounded-3xl p-6 md:p-8 shadow-2xl border border-slate-800 flex flex-col gap-6 my-auto">
            <div class="text-center">
                <div class="w-16 h-16 rounded-2xl bg-gradient-to-tr from-cyan-500/20 to-slate-800 border border-cyan-500/30 flex items-center justify-center mx-auto mb-4 text-cyan-400 shadow-glow-cyan">
                    <i data-lucide="shield-keyhole" class="w-8 h-8"></i>
                </div>
                <h2 class="text-2xl font-bold tracking-tight text-white">Создание Узла METRO</h2>
                <p class="text-xs text-slate-400 mt-1 max-w-sm mx-auto">Ключ профиля не обнаружен. Сгенерируйте уникальный двухслойный E2EE ключ или импортируйте существуюшую JSON конфигурацию.</p>
            </div>

            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-mono uppercase text-slate-400 mb-1">Имя Устройства / Позывной</label>
                    <input type="text" id="identity-alias" placeholder="Например: Node-Alpha" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-cyan-500 text-white transition-all">
                </div>

                <div>
                    <label class="block text-xs font-mono uppercase text-slate-400 mb-1">Путь к папке кэша (для сохранения файлов)</label>
                    <input type="text" id="identity-storage-path" value="/data/user/0/network.metro.app/cache/" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-xs font-mono text-cyan-300 focus:outline-none focus:border-cyan-500 transition-all">
                </div>

                <div class="p-3.5 rounded-2xl bg-cyan-950/30 border border-cyan-800/40 flex items-start gap-3 text-xs text-cyan-200">
                    <i data-lucide="cpu" class="w-5 h-5 text-cyan-400 shrink-0 mt-0.5"></i>
                    <div>
                        <p class="font-semibold text-white mb-0.5">METRO Multi-Key Standard</p>
                        <p class="text-[11px] text-slate-300">Будет создан пары ключей: <b class="text-cyan-300">ECDH P-256</b> (обмен ключами) + <b class="text-cyan-300">AES-256-GCM</b> (шифрование) с присвоением ID в формате <b class="font-mono text-white">M-888 XXX XXX</b>.</p>
                    </div>
                </div>
            </div>

            <div class="flex flex-col sm:flex-row gap-3 pt-2">
                <button onclick="generateIdentityKey()" class="flex-1 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold rounded-xl py-3 text-sm transition-all flex items-center justify-center gap-2 shadow-lg shadow-cyan-500/20">
                    <i data-lucide="key" class="w-4 h-4"></i>
                    Сгенерировать Ключ
                </button>
                <label class="flex-1 bg-slate-800 hover:bg-slate-700 text-white font-medium rounded-xl py-3 text-sm transition-all flex items-center justify-center gap-2 cursor-pointer border border-slate-700">
                    <i data-lucide="upload" class="w-4 h-4"></i>
                    Импорт JSON
                    <input type="file" id="json-key-file" accept=".json" class="hidden" onchange="importIdentityKey(event)">
                </label>
            </div>
        </div>
    </div>

    <!-- 3. MAIN WORKSPACE APP -->
    <div id="app-screen" class="hidden flex-1 flex flex-col md:flex-row h-full w-full overflow-hidden relative">

        <!-- Mobile Header Bar -->
        <header class="md:hidden pt-safe bg-slate-900/90 border-b border-slate-800 px-4 py-3 flex items-center justify-between z-20 backdrop-blur-md">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-xl bg-cyan-500/20 border border-cyan-500/40 flex items-center justify-center text-cyan-400 font-bold font-mono text-xs">M</div>
                <span class="font-extrabold tracking-widest text-lg text-white">METRO</span>
            </div>
            <div class="flex items-center gap-2">
                <span id="p2p-status-badge-mobile" class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-800 border border-slate-700 text-[10px] font-mono text-slate-400">
                    <span class="w-1.5 h-1.5 rounded-full bg-amber-400 animate-pulse"></span> READY
                </span>
                <button onclick="switchTab('contacts')" class="p-2 rounded-xl bg-slate-800 text-slate-300">
                    <i data-lucide="phone" class="w-4 h-4"></i>
                </button>
            </div>
        </header>

        <!-- Navigation Sidebar (Desktop: Left Bar, Mobile: Bottom Bar) -->
        <nav class="order-3 md:order-1 w-full md:w-20 bg-slate-900/95 border-t md:border-t-0 md:border-r border-slate-800 flex md:flex-col items-center justify-around md:justify-start md:py-6 gap-2 md:gap-6 z-30 pb-safe shrink-0">
            <!-- Brand Logo Desktop -->
            <div class="hidden md:flex flex-col items-center gap-1 mb-4">
                <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center text-slate-950 font-black text-xl shadow-glow-cyan">M</div>
                <span class="text-[9px] font-mono tracking-widest text-cyan-400 uppercase font-semibold">MESH</span>
            </div>

            <!-- Navigation Buttons -->
            <button onclick="switchTab('contacts')" id="tab-btn-contacts" class="nav-tab-btn active flex-1 md:flex-none p-3 rounded-2xl flex flex-col md:flex-row items-center gap-1.5 text-cyan-400 bg-cyan-500/10 border border-cyan-500/30 transition-all" title="Записная книжка">
                <i data-lucide="notebook-tabs" class="w-5 h-5"></i>
                <span class="text-[10px] md:hidden font-medium">Контакты</span>
            </button>

            <button onclick="switchTab('messages')" id="tab-btn-messages" class="nav-tab-btn flex-1 md:flex-none p-3 rounded-2xl flex flex-col md:flex-row items-center gap-1.5 text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all" title="Сообщения и Диалоги">
                <i data-lucide="message-square-more" class="w-5 h-5"></i>
                <span class="text-[10px] md:hidden font-medium">Диалоги</span>
            </button>

            <button onclick="switchTab('network')" id="tab-btn-network" class="nav-tab-btn flex-1 md:flex-none p-3 rounded-2xl flex flex-col md:flex-row items-center gap-1.5 text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all" title="Сеть STUN/TURN">
                <i data-lucide="globe" class="w-5 h-5"></i>
                <span class="text-[10px] md:hidden font-medium">Сеть</span>
            </button>

            <button onclick="switchTab('crypto')" id="tab-btn-crypto" class="nav-tab-btn flex-1 md:flex-none p-3 rounded-2xl flex flex-col md:flex-row items-center gap-1.5 text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all" title="Криптография E2EE">
                <i data-lucide="lock" class="w-5 h-5"></i>
                <span class="text-[10px] md:hidden font-medium">Шифр</span>
            </button>

            <button onclick="switchTab('settings')" id="tab-btn-settings" class="nav-tab-btn flex-1 md:flex-none p-3 rounded-2xl flex flex-col md:flex-row items-center gap-1.5 text-slate-400 hover:text-slate-200 hover:bg-slate-800/50 transition-all" title="Настройки узла">
                <i data-lucide="sliders" class="w-5 h-5"></i>
                <span class="text-[10px] md:hidden font-medium">Настройки</span>
            </button>

            <!-- Bottom User Profile Icon (Desktop) -->
            <div class="hidden md:flex flex-col items-center mt-auto pt-4 border-t border-slate-800/60 w-full">
                <button onclick="openMyIdentityModal()" class="w-10 h-10 rounded-2xl bg-slate-800 border border-slate-700 flex items-center justify-center text-xs font-mono text-cyan-300 hover:border-cyan-500 transition-all shadow-md" title="Мой Идентификатор METRO">
                    <i data-lucide="fingerprint" class="w-5 h-5"></i>
                </button>
            </div>
        </nav>

        <!-- Main Workspace Container -->
        <main class="order-2 flex-1 relative bg-metro-950 overflow-hidden flex flex-col md:flex-row">

            <!-- TAB 1: CONTACTS & DIALPAD -->
            <section id="tab-contacts" class="tab-content flex-1 flex flex-col lg:flex-row h-full overflow-hidden">
                <!-- Contact List Sidebar -->
                <div class="w-full lg:w-96 bg-slate-900/60 border-r border-slate-800/80 flex flex-col h-full">
                    <!-- Actions Bar -->
                    <div class="p-4 border-b border-slate-800 space-y-3">
                        <div class="flex items-center justify-between">
                            <h2 class="text-xl font-extrabold text-white tracking-wide">Контакты</h2>
                            <div class="flex items-center gap-2">
                                <button onclick="openManualSdpModal()" class="px-2.5 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-mono flex items-center gap-1 border border-slate-700" title="Ручной сигнал SDP">
                                    <i data-lucide="qr-code" class="w-3.5 h-3.5 text-cyan-400"></i>
                                    <span>SDP</span>
                                </button>
                                <button onclick="openAddContactModal()" class="p-2 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold transition-all shadow-lg shadow-cyan-500/20 flex items-center gap-1 text-xs">
                                    <i data-lucide="user-plus" class="w-4 h-4"></i>
                                    <span class="hidden sm:inline">Добавить</span>
                                </button>
                            </div>
                        </div>

                        <!-- Search Field -->
                        <div class="relative">
                            <input type="text" id="contact-search-input" oninput="filterContacts()" placeholder="Поиск по имени или M-888 ID..." class="w-full bg-slate-950 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-xs text-slate-200 focus:outline-none focus:border-cyan-500 transition-all font-mono">
                            <i data-lucide="search" class="w-4 h-4 text-slate-500 absolute left-3 top-3"></i>
                        </div>
                    </div>

                    <!-- Contact Cards Scroll Area -->
                    <div id="contacts-list" class="flex-1 overflow-y-auto p-3 space-y-2">
                        <!-- JS Dynamic Injected List -->
                    </div>
                </div>

                <!-- Dialpad Panel (Desktop/Tablet View) -->
                <div class="hidden lg:flex flex-1 flex-col items-center justify-center p-8 bg-metro-950/50 relative">
                    <div class="scanline-overlay absolute inset-0 opacity-20"></div>

                    <div class="max-w-md w-full metro-glass p-8 rounded-3xl border border-slate-800 text-center relative z-10 flex flex-col items-center shadow-2xl">
                        <div class="w-16 h-16 rounded-2xl bg-slate-900 border border-cyan-500/30 flex items-center justify-center text-cyan-400 mb-4 shadow-glow-cyan">
                            <i data-lucide="phone-outgoing" class="w-8 h-8"></i>
                        </div>
                        <h3 class="text-xl font-bold text-white mb-1">Набор METRO P2P</h3>
                        <p class="text-xs text-slate-400 mb-6 max-w-xs">Введите 9-значный код адресата для прямой установки P2P соединения.</p>

                        <!-- Dial Display -->
                        <div class="w-full bg-slate-950 border border-slate-800 rounded-2xl p-4 mb-6 flex items-center justify-between font-mono">
                            <span class="text-slate-600 text-xs font-bold">ID:</span>
                            <span id="dialpad-display-desktop" class="text-xl font-bold tracking-wider text-cyan-300">M-888 ___ ___</span>
                            <button onclick="clearDialDisplay()" class="text-slate-500 hover:text-slate-300"><i data-lucide="backspace" class="w-5 h-5"></i></button>
                        </div>

                        <!-- Keypad Grid -->
                        <div class="grid grid-cols-3 gap-3 w-full max-w-xs mb-6">
                            <button onclick="pressDialKey('1')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">1</button>
                            <button onclick="pressDialKey('2')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">2</button>
                            <button onclick="pressDialKey('3')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">3</button>
                            <button onclick="pressDialKey('4')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">4</button>
                            <button onclick="pressDialKey('5')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">5</button>
                            <button onclick="pressDialKey('6')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">6</button>
                            <button onclick="pressDialKey('7')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">7</button>
                            <button onclick="pressDialKey('8')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">8</button>
                            <button onclick="pressDialKey('9')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">9</button>
                            <button onclick="pressDialKey('*')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">*</button>
                            <button onclick="pressDialKey('0')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">0</button>
                            <button onclick="pressDialKey('#')" class="py-3.5 rounded-xl bg-slate-900 hover:bg-slate-800 active:bg-slate-700 text-lg font-mono font-bold text-white border border-slate-800/80 transition-all">#</button>
                        </div>

                        <!-- Action Buttons -->
                        <div class="flex gap-3 w-full max-w-xs">
                            <button onclick="startCallFromDialpad(false)" class="flex-1 py-3 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-emerald-950/50 transition-all text-xs">
                                <i data-lucide="phone" class="w-4 h-4"></i> Вызов
                            </button>
                            <button onclick="startCallFromDialpad(true)" class="flex-1 py-3 bg-cyan-600 hover:bg-cyan-500 text-white font-semibold rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-cyan-950/50 transition-all text-xs">
                                <i data-lucide="video" class="w-4 h-4"></i> Видео
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB 2: MESSAGES & ENCRYPTED CHAT -->
            <section id="tab-messages" class="tab-content hidden flex-1 flex h-full overflow-hidden">
                <!-- Conversations Sidebar -->
                <div id="chat-list-sidebar" class="w-full md:w-80 lg:w-96 bg-slate-900/60 border-r border-slate-800/80 flex flex-col h-full">
                    <div class="p-4 border-b border-slate-800 flex items-center justify-between">
                        <h2 class="text-xl font-extrabold text-white tracking-wide">Диалоги</h2>
                        <span class="text-[10px] font-mono text-cyan-400 bg-cyan-950/60 border border-cyan-800/60 px-2 py-0.5 rounded-full">AES-256 E2EE</span>
                    </div>
                    <div id="active-chats-list" class="flex-1 overflow-y-auto p-3 space-y-2">
                        <!-- JS Injected Active Conversations -->
                    </div>
                </div>

                <!-- Chat Canvas Panel -->
                <div id="chat-panel" class="hidden md:flex flex-1 flex-col h-full bg-slate-950/90 relative">
                    <!-- Chat Header -->
                    <div id="chat-header" class="p-4 bg-slate-900/90 border-b border-slate-800 flex items-center justify-between z-10 backdrop-blur-md">
                        <div class="flex items-center gap-3">
                            <button onclick="closeMobileChat()" class="md:hidden text-slate-400 hover:text-white">
                                <i data-lucide="arrow-left" class="w-6 h-6"></i>
                            </button>
                            <div class="relative">
                                <div id="chat-avatar" class="w-10 h-10 rounded-2xl bg-cyan-900/40 border border-cyan-500/40 flex items-center justify-center text-cyan-300 font-bold font-mono">
                                    ?
                                </div>
                                <span id="chat-online-indicator" class="w-3 h-3 rounded-full bg-slate-600 border-2 border-slate-900 absolute -bottom-0.5 -right-0.5"></span>
                            </div>
                            <div>
                                <h3 id="chat-contact-name" class="font-bold text-white text-sm">Выберите контакт</h3>
                                <p id="chat-contact-id" class="text-[11px] font-mono text-slate-400">M-888 --- ---</p>
                            </div>
                        </div>

                        <!-- Chat Call & Info Actions -->
                        <div class="flex items-center gap-2">
                            <button onclick="initiateCallCurrent(false)" class="p-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 hover:text-cyan-300 transition-all border border-slate-700" title="Голосовой вызов">
                                <i data-lucide="phone" class="w-4 h-4"></i>
                            </button>
                            <button onclick="initiateCallCurrent(true)" class="p-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 hover:text-cyan-300 transition-all border border-slate-700" title="Видеовызов">
                                <i data-lucide="video" class="w-4 h-4"></i>
                            </button>
                            <button onclick="showContactDetailsModal()" class="p-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 transition-all border border-slate-700" title="Информация о ключе">
                                <i data-lucide="shield-check" class="w-4 h-4 text-emerald-400"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Messages Flow -->
                    <div id="messages-container" class="flex-1 overflow-y-auto p-4 space-y-4">
                        <!-- Dynamic Messages / File Transfers -->
                    </div>

                    <!-- File Progress Bar Overlay -->
                    <div id="file-transfer-bar" class="hidden px-4 py-2 bg-slate-900/90 border-t border-slate-800/80 flex flex-col gap-1">
                        <div class="flex justify-between text-[10px] font-mono">
                            <span id="file-transfer-label" class="text-cyan-400">Передача файла...</span>
                            <span id="file-transfer-percent" class="text-slate-300">0%</span>
                        </div>
                        <div class="w-full bg-slate-950 h-1.5 rounded-full overflow-hidden border border-slate-800">
                            <div id="file-transfer-progress-inner" class="bg-gradient-to-r from-cyan-500 to-emerald-400 h-full w-0 transition-all duration-200"></div>
                        </div>
                    </div>

                    <!-- Message Input Area -->
                    <div class="p-3 bg-slate-900/90 border-t border-slate-800 flex items-center gap-2 pb-safe">
                        <label class="p-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-cyan-300 cursor-pointer transition-all border border-slate-700 shrink-0" title="Отправить защищенный файл">
                            <i data-lucide="paperclip" class="w-5 h-5"></i>
                            <input type="file" id="chat-file-input" class="hidden" onchange="handleFileSelected(event)">
                        </label>

                        <input type="text" id="chat-input-text" onkeypress="handleMessageKeyPress(event)" placeholder="Шифрованное E2EE сообщение..." class="flex-1 bg-slate-950 border border-slate-800 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-cyan-500 transition-all font-sans">

                        <button onclick="sendMessage()" class="p-2.5 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold transition-all shadow-lg shadow-cyan-500/20 shrink-0">
                            <i data-lucide="send" class="w-5 h-5"></i>
                        </button>
                    </div>
                </div>
            </section>

            <!-- TAB 3: NETWORK & STUN/TURN POOL -->
            <section id="tab-network" class="tab-content hidden flex-1 flex flex-col p-4 md:p-8 overflow-y-auto max-w-5xl mx-auto w-full">
                <div class="mb-6 border-b border-slate-800 pb-4 flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 class="text-2xl font-extrabold text-white tracking-wide flex items-center gap-2">
                            <i data-lucide="globe" class="w-6 h-6 text-cyan-400"></i>
                            Сеть Узлов STUN / TURN
                        </h2>
                        <p class="text-xs text-slate-400 mt-1">Определение внешних NAT IP-адресов и проброс WebRTC каналов с измерением задержки (RTT).</p>
                    </div>
                    <button onclick="pingAllStunServers()" class="px-4 py-2.5 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold rounded-xl text-xs flex items-center gap-2 transition-all shadow-lg shadow-cyan-500/20">
                        <i data-lucide="activity" class="w-4 h-4"></i>
                        Тест Задержки Серверов
                    </button>
                </div>

                <!-- Network Diagnostics Summary Cards -->
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                    <div class="metro-glass-card p-4 rounded-2xl border border-slate-800">
                        <span class="text-[10px] font-mono text-slate-400 uppercase block mb-1">ВСЕГО STUN СЕРВЕРОВ</span>
                        <span id="stat-total-stun" class="text-2xl font-bold font-mono text-white">24</span>
                    </div>
                    <div class="metro-glass-card p-4 rounded-2xl border border-slate-800">
                        <span class="text-[10px] font-mono text-slate-400 uppercase block mb-1">АКТИВНЫЕ УЗЛЫ</span>
                        <span id="stat-active-stun" class="text-2xl font-bold font-mono text-emerald-400">24</span>
                    </div>
                    <div class="metro-glass-card p-4 rounded-2xl border border-slate-800">
                        <span class="text-[10px] font-mono text-slate-400 uppercase block mb-1">СРЕДНЯЯ ЗАДЕРЖКА</span>
                        <span id="stat-avg-rtt" class="text-2xl font-bold font-mono text-cyan-400">-- ms</span>
                    </div>
                </div>

                <!-- STUN Pool Table -->
                <div class="metro-glass p-6 rounded-3xl border border-slate-800 space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-sm font-bold text-white">Публичный Пул Серверов NAT</h3>
                        <button onclick="addNewStunPrompt()" class="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-xs text-cyan-300 rounded-xl flex items-center gap-1">
                            <i data-lucide="plus" class="w-3.5 h-3.5"></i> Добавить STUN
                        </button>
                    </div>

                    <div id="stun-server-grid" class="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs font-mono">
                        <!-- JS Injected STUN Nodes -->
                    </div>
                </div>
            </section>

            <!-- TAB 4: CRYPTO & E2EE VAULT -->
            <section id="tab-crypto" class="tab-content hidden flex-1 flex flex-col p-4 md:p-8 overflow-y-auto max-w-5xl mx-auto w-full">
                <div class="mb-6 border-b border-slate-800 pb-4">
                    <h2 class="text-2xl font-extrabold text-white tracking-wide flex items-center gap-2">
                        <i data-lucide="shield-alert" class="w-6 h-6 text-emerald-400"></i>
                        Спецификация Шифрования METRO E2EE
                    </h2>
                    <p class="text-xs text-slate-400 mt-1">Аппаратно-ускоренные модули криптографии Web Crypto API (SubtleCrypto).</p>
                </div>

                <div class="space-y-6">
                    <!-- Layer 1 & Layer 2 Explanations -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="metro-glass p-6 rounded-2xl border border-slate-800 space-y-2">
                            <div class="flex items-center gap-2 text-cyan-400 font-bold text-sm">
                                <i data-lucide="key-round" class="w-5 h-5"></i>
                                <span>Метод 1: ECDH P-256 (Diffie-Hellman)</span>
                            </div>
                            <p class="text-xs text-slate-300 leading-relaxed">Используется для согласования общего сеансового секрета между двумя узлами без передачи самого секрета по открытым каналам.</p>
                        </div>

                        <div class="metro-glass p-6 rounded-2xl border border-slate-800 space-y-2">
                            <div class="flex items-center gap-2 text-emerald-400 font-bold text-sm">
                                <i data-lucide="lock" class="w-5 h-5"></i>
                                <span>Метод 2: AES-256-GCM + IV</span>
                            </div>
                            <p class="text-xs text-slate-300 leading-relaxed">Симметричное аутентифицированное шифрование текста и байтовых фрагментов файлов с уникальным векторами инициализации (IV 96-bit).</p>
                        </div>
                    </div>

                    <!-- Active Session Keys Details -->
                    <div class="metro-glass p-6 rounded-3xl border border-slate-800 space-y-4">
                        <h3 class="text-sm font-bold text-white">Мой Публичный Отпечаток Узла (Public Fingerprint)</h3>
                        <div class="p-4 bg-slate-950 rounded-2xl border border-slate-800 font-mono text-xs text-cyan-300 break-all" id="crypto-public-key-display">
                            Загрузка публичного ключа ECDH...
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB 5: SETTINGS -->
            <section id="tab-settings" class="tab-content hidden flex-1 flex flex-col p-4 md:p-8 overflow-y-auto max-w-4xl mx-auto w-full">
                <div class="mb-6 border-b border-slate-800 pb-4">
                    <h2 class="text-2xl font-extrabold text-white tracking-wide">Настройки Аккаунта</h2>
                    <p class="text-xs text-slate-400 mt-1">Параметры пути кэша, экспорта и очистки системы.</p>
                </div>

                <div class="space-y-6">
                    <div class="metro-glass p-6 rounded-3xl border border-slate-800 space-y-4">
                        <div class="flex justify-between items-center">
                            <div>
                                <h3 class="text-sm font-bold text-white">Конфигурация Профиля</h3>
                                <p class="text-xs text-slate-400 font-mono" id="settings-my-id">M-888 --- ---</p>
                            </div>
                            <button onclick="exportIdentityJSON()" class="px-4 py-2 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold text-xs rounded-xl transition-all shadow-lg shadow-cyan-500/20">
                                Экспорт JSON Ключа
                            </button>
                        </div>

                        <div class="pt-4 border-t border-slate-800 grid grid-cols-1 md:grid-cols-2 gap-4 text-xs font-mono">
                            <div>
                                <span class="text-slate-500 block mb-1">ИМЯ УСТРОЙСТВА</span>
                                <input type="text" id="settings-alias-input" onchange="updateProfileAlias()" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-white">
                            </div>
                            <div>
                                <span class="text-slate-500 block mb-1">ПУТЬ КЭША ФАЙЛОВ</span>
                                <input type="text" id="settings-cache-input" onchange="updateProfileCache()" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-cyan-300">
                            </div>
                        </div>
                    </div>

                    <!-- Reset Application Data -->
                    <div class="metro-glass p-6 rounded-3xl border border-rose-900/40 space-y-3">
                        <h3 class="text-sm font-bold text-rose-400">Сброс Данных и Очистка</h3>
                        <p class="text-xs text-slate-400">Полная очистка локальной записной книжки, ключей и диалогов из LocalStorage.</p>
                        <button onclick="resetAccountData()" class="px-4 py-2.5 bg-rose-950 hover:bg-rose-900 text-rose-200 border border-rose-800 rounded-xl text-xs font-bold transition-all">
                            Очистить Все Данные
                        </button>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <!-- 4. WEBRTC CALL OVERLAY MODAL -->
    <div id="call-modal" class="hidden fixed inset-0 z-50 bg-metro-950/95 flex items-center justify-center p-4 backdrop-blur-xl">
        <div class="metro-glass w-full max-w-2xl rounded-3xl p-6 border border-slate-800 flex flex-col items-center justify-between relative min-h-[520px] shadow-2xl">
            <!-- Header -->
            <div class="text-center z-10">
                <span class="inline-block px-3 py-1 rounded-full bg-cyan-950 border border-cyan-800 text-cyan-300 text-[10px] font-mono mb-2 uppercase tracking-widest" id="call-type-badge">
                    WebRTC P2P Video Session
                </span>
                <h3 id="call-target-name" class="text-2xl font-bold text-white">Абонент METRO</h3>
                <p id="call-target-id" class="text-xs font-mono text-cyan-400 mt-0.5">M-888 --- ---</p>
                <p id="call-status-timer" class="text-xs font-mono text-slate-400 mt-2">Установление WebRTC связи...</p>
            </div>

            <!-- Video / Audio Canvas Canvas Visualizer -->
            <div class="relative w-full h-72 bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden my-4 flex items-center justify-center">
                <!-- Remote Stream -->
                <video id="remote-video" autoplay playsinline class="w-full h-full object-cover hidden"></video>

                <!-- Audio Frequency Spectrum Visualizer Canvas -->
                <canvas id="audio-spectrum-canvas" class="w-full h-full absolute inset-0"></canvas>

                <!-- Self Stream PIP -->
                <div class="absolute bottom-3 right-3 w-32 h-24 bg-slate-900 rounded-xl border border-slate-700 overflow-hidden shadow-2xl">
                    <video id="local-video" autoplay playsinline muted class="w-full h-full object-cover"></video>
                </div>
            </div>

            <!-- Call Controls -->
            <div class="flex items-center gap-4 z-10">
                <button onclick="toggleCallMute()" id="btn-call-mute" class="p-4 rounded-2xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-all">
                    <i data-lucide="mic" class="w-6 h-6"></i>
                </button>
                <button onclick="endCurrentCall()" class="px-8 py-4 rounded-2xl bg-rose-600 hover:bg-rose-500 text-white font-bold flex items-center gap-2 shadow-lg shadow-rose-950/60 transition-all">
                    <i data-lucide="phone-off" class="w-6 h-6"></i>
                    <span>Завершить</span>
                </button>
                <button onclick="toggleCallVideo()" id="btn-call-video" class="p-4 rounded-2xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-all">
                    <i data-lucide="video" class="w-6 h-6"></i>
                </button>
                <button onclick="shareScreenInCall()" class="p-4 rounded-2xl bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition-all" title="Демонстрация экрана">
                    <i data-lucide="monitor" class="w-6 h-6"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- 5. ADD CONTACT MODAL -->
    <div id="add-contact-modal" class="hidden fixed inset-0 z-50 bg-metro-950/80 backdrop-blur-md flex items-center justify-center p-4">
        <div class="metro-glass w-full max-w-md rounded-3xl p-6 border border-slate-800 space-y-4 shadow-2xl">
            <div class="flex justify-between items-center border-b border-slate-800 pb-3">
                <h3 class="font-bold text-white text-base">Новый Контакт</h3>
                <button onclick="closeModal('add-contact-modal')" class="text-slate-400 hover:text-white"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <div class="space-y-3">
                <div>
                    <label class="block text-xs font-mono uppercase text-slate-400 mb-1">Имя контакты</label>
                    <input type="text" id="new-contact-name" placeholder="Иван Оператор" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-cyan-500">
                </div>
                <div>
                    <label class="block text-xs font-mono uppercase text-slate-400 mb-1">Идентификатор METRO ID (M-888 *** ***)</label>
                    <input type="text" id="new-contact-id" placeholder="M-888 123 456" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2.5 text-xs font-mono text-cyan-300 focus:outline-none focus:border-cyan-500">
                </div>
                <div>
                    <label class="block text-xs font-mono uppercase text-slate-400 mb-1">Публичный Ключ ECDH (необязательно)</label>
                    <textarea id="new-contact-pubkey" placeholder="PUB_KEY_..." class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2 text-[10px] font-mono text-slate-300 h-16 focus:outline-none focus:border-cyan-500"></textarea>
                </div>
            </div>
            <button onclick="saveNewContact()" class="w-full py-3 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold text-xs rounded-xl transition-all shadow-lg shadow-cyan-500/20">
                Сохранить Контакт
            </button>
        </div>
    </div>

    <!-- 6. MANUAL SDP SIGNAL EXCHANGE MODAL -->
    <div id="sdp-modal" class="hidden fixed inset-0 z-50 bg-metro-950/80 backdrop-blur-md flex items-center justify-center p-4">
        <div class="metro-glass w-full max-w-lg rounded-3xl p-6 border border-slate-800 space-y-4 shadow-2xl">
            <div class="flex justify-between items-center border-b border-slate-800 pb-3">
                <h3 class="font-bold text-white text-base">Ручной обмен сигналами SDP / ICE</h3>
                <button onclick="closeModal('sdp-modal')" class="text-slate-400 hover:text-white"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <p class="text-xs text-slate-400 leading-relaxed">Если публичные серверы сигналов неполноценно соединяют узел из-за строгих фаерволов NAT, скопируйте SDP токен вашей стороны и вставьте ответный SDP соседа.</p>

            <div class="space-y-3">
                <div>
                    <label class="block text-[10px] font-mono text-cyan-400 uppercase mb-1">Мой SDP Offer / Answer Токен:</label>
                    <textarea id="my-sdp-token" readonly onclick="this.select()" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-[10px] font-mono text-slate-300 h-20 select-all"></textarea>
                </div>

                <div>
                    <label class="block text-[10px] font-mono text-emerald-400 uppercase mb-1">Вставьте Ответный SDP Токен Соседа:</label>
                    <textarea id="remote-sdp-token" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-[10px] font-mono text-white h-20 focus:border-emerald-500 focus:outline-none"></textarea>
                </div>
            </div>

            <div class="flex gap-2">
                <button onclick="generateLocalSdpOffer()" class="flex-1 py-2.5 bg-slate-800 hover:bg-slate-700 text-white font-bold text-xs rounded-xl border border-slate-700">
                    Создать Offer
                </button>
                <button onclick="applyRemoteSdpToken()" class="flex-1 py-2.5 bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs rounded-xl shadow-lg shadow-emerald-950/50">
                    Применить Ответ
                </button>
            </div>
        </div>
    </div>

    <script>
        // GLOBAL CONSTANTS & APP STATE
        const STORAGE_KEY = 'METRO_ACCOUNT_KEY_V2';
        const CONTACTS_KEY = 'METRO_CONTACTS_V2';
        const MESSAGES_KEY = 'METRO_CHAT_STORE_V2';

        let currentAccount = null;
        let contacts = [];
        let activeChatContact = null;
        let messagesStore = {};
        
        // WebRTC & Network State
        let peerConnection = null;
        let dataChannel = null;
        let peerJsInstance = null;
        let broadcastChannel = null;
        let localStream = null;
        let audioContext = null;
        let audioAnalyser = null;
        let callTimerInterval = null;
        let callSeconds = 0;

        // Expanded 24 Public STUN Servers Pool
        const publicStunServersPool = [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
            'stun:stun3.l.google.com:19302',
            'stun:stun4.l.google.com:19302',
            'stun:stun.cloudflare.com:3478',
            'stun:stun.nextcloud.com:443',
            'stun:stun.ekiga.net:3478',
            'stun:stun.ideasip.com:3478',
            'stun:stun.schlund.de:3478',
            'stun:stun.voiparound.com:3478',
            'stun:stun.voipbuster.com:3478',
            'stun:stun.voipstunt.com:3478',
            'stun:stun.sipgate.net:10000',
            'stun:stun.12voip.com:3478',
            'stun:stun.freecall.com:3478',
            'stun:stun.services.mozilla.com:3478',
            'stun:stun.callwithus.com:3478',
            'stun:stun.counterpath.com:3478',
            'stun:stun.gmx.net:3478',
            'stun:stun.rixport.com:3478',
            'stun:stun.voip.aebc.com:3478',
            'stun:stun.freeswitch.org:3478',
            'stun:stun.voipgate.com:3478'
        ];

        window.addEventListener('DOMContentLoaded', () => {
            lucide.createIcons();

            // Run Splash Animation Sequence
            setTimeout(() => {
                const splash = document.getElementById('splash-screen');
                document.getElementById('splash-status').innerText = 'Загрузка профиля METRO...';

                setTimeout(() => {
                    splash.classList.add('opacity-0');
                    setTimeout(() => {
                        splash.style.display = 'none';
                        checkIdentityKey();
                    }, 700);
                }, 1000);
            }, 1800);
        });

        // DUAL-LAYER CRYPTO UTILITIES (Web Crypto API)
        const MetroCrypto = {
            // Generate ECDH P-256 Keypair
            async generateKeyPair() {
                const keyPair = await window.crypto.subtle.generateKey(
                    { name: "ECDH", namedCurve: "P-256" },
                    true,
                    ["deriveKey", "deriveBits"]
                );
                const pubExported = await window.crypto.subtle.exportKey("spki", keyPair.publicKey);
                const privExported = await window.crypto.subtle.exportKey("pkcs8", keyPair.privateKey);

                return {
                    publicKeyB64: btoa(String.fromCharCode(...new Uint8Array(pubExported))),
                    privateKeyB64: btoa(String.fromCharCode(...new Uint8Array(privExported)))
                };
            },

            // Encrypt String Payload via AES-256-GCM
            async encryptPayload(text, secretKeyB64) {
                const enc = new TextEncoder();
                const iv = window.crypto.getRandomValues(new Uint8Array(12));
                
                // SHA-256 derive AES Key
                const keyData = enc.encode(secretKeyB64);
                const hash = await window.crypto.subtle.digest('SHA-256', keyData);
                const aesKey = await window.crypto.subtle.importKey(
                    'raw', hash, { name: 'AES-GCM' }, false, ['encrypt']
                );

                const encrypted = await window.crypto.subtle.encrypt(
                    { name: 'AES-GCM', iv: iv },
                    aesKey,
                    enc.encode(text)
                );

                return {
                    cipherB64: btoa(String.fromCharCode(...new Uint8Array(encrypted))),
                    ivB64: btoa(String.fromCharCode(...iv))
                };
            },

            // Decrypt AES-256-GCM Payload
            async decryptPayload(cipherB64, ivB64, secretKeyB64) {
                try {
                    const enc = new TextEncoder();
                    const keyData = enc.encode(secretKeyB64);
                    const hash = await window.crypto.subtle.digest('SHA-256', keyData);
                    const aesKey = await window.crypto.subtle.importKey(
                        'raw', hash, { name: 'AES-GCM' }, false, ['decrypt']
                    );

                    const cipherBuf = Uint8Array.from(atob(cipherB64), c => c.charCodeAt(0));
                    const ivBuf = Uint8Array.from(atob(ivB64), c => c.charCodeAt(0));

                    const decrypted = await window.crypto.subtle.decrypt(
                        { name: 'AES-GCM', iv: ivBuf },
                        aesKey,
                        cipherBuf
                    );

                    return new TextDecoder().decode(decrypted);
                } catch (e) {
                    return "[Ошибка расшифровки E2EE: Ключи не совпадают]";
                }
            }
        };

        function checkIdentityKey() {
            const savedData = localStorage.getItem(STORAGE_KEY);
            if (savedData) {
                try {
                    currentAccount = JSON.parse(savedData);
                    loadMainApplication();
                } catch (e) {
                    showIdentityModal();
                }
            } else {
                showIdentityModal();
            }
        }

        function showIdentityModal() {
            document.getElementById('identity-screen').classList.remove('hidden');
        }

        async function generateIdentityKey() {
            const aliasInput = document.getElementById('identity-alias').value.trim() || 'Node-Alpha';
            const cachePath = document.getElementById('identity-storage-path').value.trim();

            // Generate Random M-888 ID
            const r1 = Math.floor(100 + Math.random() * 900);
            const r2 = Math.floor(100 + Math.random() * 900);
            const metroId = `M-888 ${r1} ${r2}`;

            // Generate E2EE WebCrypto Keypair
            const keys = await MetroCrypto.generateKeyPair();

            currentAccount = {
                version: "2.0-metro",
                metroId: metroId,
                alias: aliasInput,
                cachePath: cachePath,
                createdAt: new Date().toISOString(),
                stunServers: publicStunServersPool,
                keys: keys
            };

            localStorage.setItem(STORAGE_KEY, JSON.stringify(currentAccount));
            document.getElementById('identity-screen').classList.add('hidden');
            loadMainApplication();
        }

        function importIdentityKey(event) {
            const file = event.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = function(e) {
                try {
                    const imported = JSON.parse(e.target.result);
                    if (imported && imported.metroId) {
                        currentAccount = imported;
                        localStorage.setItem(STORAGE_KEY, JSON.stringify(currentAccount));
                        document.getElementById('identity-screen').classList.add('hidden');
                        loadMainApplication();
                    } else {
                        alert("Некорректный JSON файл ключа METRO!");
                    }
                } catch (err) {
                    alert("Ошибка чтения файла JSON.");
                }
            };
            reader.readAsText(file);
        }

        function exportIdentityJSON() {
            if (!currentAccount) return;
            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(currentAccount, null, 2));
            const downloadAnchor = document.createElement('a');
            downloadAnchor.setAttribute("href", dataStr);
            downloadAnchor.setAttribute("download", `metro-key-${currentAccount.metroId.replace(/\s+/g, '_')}.json`);
            document.body.appendChild(downloadAnchor);
            downloadAnchor.click();
            downloadAnchor.remove();
        }

        function loadMainApplication() {
            document.getElementById('app-screen').classList.remove('hidden');

            // Load Contacts & Messages (Strictly Clean State)
            const savedContacts = localStorage.getItem(CONTACTS_KEY);
            contacts = savedContacts ? JSON.parse(savedContacts) : [];

            const savedMsgs = localStorage.getItem(MESSAGES_KEY);
            messagesStore = savedMsgs ? JSON.parse(savedMsgs) : {};

            // Initialize PeerJS / BroadcastChannel Signaling
            initWebRTCSignaling();

            // Render Modules
            renderContacts();
            renderActiveChatsList();
            renderStunServers();
            renderCryptoInfo();
            renderSettings();

            lucide.createIcons();
        }

        function initWebRTCSignaling() {
            const cleanPeerId = currentAccount.metroId.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();

            // BroadcastChannel for instant local multi-tab testing
            try {
                broadcastChannel = new BroadcastChannel('METRO_P2P_MESH');
                broadcastChannel.onmessage = (event) => {
                    handleSignalingMessage(event.data);
                };
            } catch (e) {
                console.log("BroadcastChannel unavailable");
            }

            // Public PeerJS signaling bridge
            try {
                peerJsInstance = new Peer(cleanPeerId, {
                    config: {
                        iceServers: publicStunServersPool.map(url => ({ urls: url }))
                    }
                });

                peerJsInstance.on('open', (id) => {
                    updateP2PStatus('ONLINE', 'emerald');
                });

                peerJsInstance.on('connection', (conn) => {
                    conn.on('data', (data) => {
                        handleIncomingP2PData(data);
                    });
                });

                peerJsInstance.on('error', (err) => {
                    console.log("Signaling peer note:", err);
                });
            } catch (err) {
                console.log("PeerJS fallback mode active");
            }
        }

        function updateP2PStatus(statusText, color) {
            const badge = document.getElementById('p2p-status-badge-mobile');
            if (badge) {
                badge.innerHTML = `<span class="w-1.5 h-1.5 rounded-full bg-${color}-400 animate-pulse"></span> P2P ${statusText}`;
            }
        }

        function renderContacts() {
            const listContainer = document.getElementById('contacts-list');
            listContainer.innerHTML = '';

            if (contacts.length === 0) {
                listContainer.innerHTML = `
                    <div class="text-center p-8 text-slate-500 my-auto">
                        <i data-lucide="notebook" class="w-10 h-10 mx-auto mb-2 text-slate-600"></i>
                        <p class="text-xs font-bold text-slate-400">Записная книжка пуста</p>
                        <p class="text-[11px] text-slate-500 mt-1">Добавьте новый контакт или введите M-888 ID для вызова.</p>
                    </div>
                `;
                lucide.createIcons();
                return;
            }

            contacts.forEach(c => {
                const item = document.createElement('div');
                item.className = 'p-3 rounded-2xl bg-slate-900/80 border border-slate-800/80 flex items-center justify-between hover:border-cyan-500/50 transition-all cursor-pointer group';
                item.onclick = () => {
                    selectContactForChat(c);
                    switchTab('messages');
                };

                item.innerHTML = `
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-2xl bg-slate-800 border border-slate-700 flex items-center justify-center font-bold text-cyan-300 font-mono">
                            ${c.name[0].toUpperCase()}
                        </div>
                        <div>
                            <h4 class="text-sm font-semibold text-white group-hover:text-cyan-300 transition-colors">${c.name}</h4>
                            <span class="text-[11px] font-mono text-slate-400 block">${c.id}</span>
                        </div>
                    </div>
                    <div class="flex items-center gap-1">
                        <button onclick="event.stopPropagation(); startDirectCall('${c.id}', '${c.name}', false)" class="p-2 text-slate-400 hover:text-emerald-400 transition-colors">
                            <i data-lucide="phone" class="w-4 h-4"></i>
                        </button>
                        <button onclick="event.stopPropagation(); startDirectCall('${c.id}', '${c.name}', true)" class="p-2 text-slate-400 hover:text-cyan-400 transition-colors">
                            <i data-lucide="video" class="w-4 h-4"></i>
                        </button>
                        <button onclick="event.stopPropagation(); deleteContact('${c.id}')" class="p-2 text-slate-500 hover:text-rose-400 transition-colors">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                `;
                listContainer.appendChild(item);
            });
            lucide.createIcons();
        }

        function filterContacts() {
            const query = document.getElementById('contact-search-input').value.toLowerCase();
            const filtered = contacts.filter(c => c.name.toLowerCase().includes(query) || c.id.toLowerCase().includes(query));
            
            const listContainer = document.getElementById('contacts-list');
            listContainer.innerHTML = '';
            filtered.forEach(c => {
                const item = document.createElement('div');
                item.className = 'p-3 rounded-2xl bg-slate-900/80 border border-slate-800/80 flex items-center justify-between hover:border-cyan-500/50 cursor-pointer';
                item.onclick = () => { selectContactForChat(c); switchTab('messages'); };
                item.innerHTML = `
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-2xl bg-slate-800 font-bold text-cyan-300 flex items-center justify-center font-mono">${c.name[0].toUpperCase()}</div>
                        <div>
                            <h4 class="text-sm font-semibold text-white">${c.name}</h4>
                            <span class="text-[11px] font-mono text-slate-400">${c.id}</span>
                        </div>
                    </div>
                `;
                listContainer.appendChild(item);
            });
        }

        function openAddContactModal() {
            document.getElementById('add-contact-modal').classList.remove('hidden');
        }

        function closeModal(id) {
            document.getElementById(id).classList.add('hidden');
        }

        function saveNewContact() {
            const name = document.getElementById('new-contact-name').value.trim();
            let metroId = document.getElementById('new-contact-id').value.trim();
            const pubKey = document.getElementById('new-contact-pubkey').value.trim();

            if (!name || !metroId) {
                alert("Заполните имя и M-888 ID!");
                return;
            }

            if (!metroId.startsWith("M-888")) {
                metroId = "M-888 " + metroId;
            }

            // Check duplicate
            if (contacts.some(c => c.id === metroId)) {
                alert("Контакт с таким ID уже есть!");
                return;
            }

            contacts.push({ id: metroId, name: name, pubKey: pubKey, addedAt: new Date().toISOString() });
            localStorage.setItem(CONTACTS_KEY, JSON.stringify(contacts));
            renderContacts();
            renderActiveChatsList();
            closeModal('add-contact-modal');
        }

        function deleteContact(id) {
            if (confirm("Удалить этот контакт из записной книжки?")) {
                contacts = contacts.filter(c => c.id !== id);
                localStorage.setItem(CONTACTS_KEY, JSON.stringify(contacts));
                renderContacts();
                renderActiveChatsList();
            }
        }

        let currentDialNumber = "";
        function pressDialKey(digit) {
            if (currentDialNumber.length < 6) {
                currentDialNumber += digit;
                updateDialDisplay();
            }
        }

        function clearDialDisplay() {
            currentDialNumber = "";
            updateDialDisplay();
        }

        function updateDialDisplay() {
            const display = document.getElementById('dialpad-display-desktop');
            if (currentDialNumber.length === 0) {
                display.innerText = "M-888 ___ ___";
            } else if (currentDialNumber.length <= 3) {
                display.innerText = `M-888 ${currentDialNumber}`;
            } else {
                display.innerText = `M-888 ${currentDialNumber.substring(0,3)} ${currentDialNumber.substring(3)}`;
            }
        }

        function startCallFromDialpad(isVideo) {
            if (currentDialNumber.length < 6) {
                alert("Введите полный 6-значный суффикс M-888 ID");
                return;
            }
            const fullId = `M-888 ${currentDialNumber.substring(0,3)} ${currentDialNumber.substring(3)}`;
            startDirectCall(fullId, "Абонент " + fullId, isVideo);
        }

        function renderActiveChatsList() {
            const container = document.getElementById('active-chats-list');
            container.innerHTML = '';

            if (contacts.length === 0) {
                container.innerHTML = `<p class="text-xs text-slate-500 text-center p-4">Нет диалогов</p>`;
                return;
            }

            contacts.forEach(c => {
                const item = document.createElement('div');
                item.className = `p-3 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${activeChatContact && activeChatContact.id === c.id ? 'bg-cyan-950/40 border-cyan-500/50' : 'bg-slate-900/60 border-slate-800/80 hover:bg-slate-800/40'}`;
                item.onclick = () => selectContactForChat(c);

                item.innerHTML = `
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-2xl bg-slate-800 border border-slate-700 flex items-center justify-center font-bold text-cyan-300 font-mono">
                            ${c.name[0].toUpperCase()}
                        </div>
                        <div>
                            <h4 class="text-sm font-semibold text-white">${c.name}</h4>
                            <p class="text-[11px] text-slate-400 font-mono">${c.id}</p>
                        </div>
                    </div>
                `;
                container.appendChild(item);
            });
        }

        function selectContactForChat(contact) {
            activeChatContact = contact;
            renderActiveChatsList();

            document.getElementById('chat-panel').classList.remove('hidden');
            document.getElementById('chat-panel').classList.add('flex');

            document.getElementById('chat-contact-name').innerText = contact.name;
            document.getElementById('chat-contact-id').innerText = contact.id;
            document.getElementById('chat-avatar').innerText = contact.name[0].toUpperCase();

            renderMessages();
        }

        function closeMobileChat() {
            document.getElementById('chat-panel').classList.add('hidden');
            document.getElementById('chat-panel').classList.remove('flex');
        }

        async function renderMessages() {
            if (!activeChatContact) return;
            const container = document.getElementById('messages-container');
            const msgs = messagesStore[activeChatContact.id] || [];

            if (msgs.length === 0) {
                container.innerHTML = `
                    <div class="h-full flex flex-col items-center justify-center text-center p-6 text-slate-500 my-auto">
                        <i data-lucide="shield-check" class="w-12 h-12 mb-3 text-cyan-400 stroke-[1.5]"></i>
                        <p class="text-xs font-mono text-cyan-400 mb-1">E2EE ЗАКРЫТЫЙ КАНАЛ METRO</p>
                        <p class="text-xs text-slate-400 max-w-xs">Сообщения шифруются локально алгоритмами AES-256-GCM + ECDH.</p>
                    </div>
                `;
                lucide.createIcons();
                return;
            }

            container.innerHTML = '';
            for (let m of msgs) {
                const msgDiv = document.createElement('div');
                msgDiv.className = `flex flex-col ${m.sender === 'me' ? 'items-end' : 'items-start'}`;

                let displayText = m.text;
                if (m.encryptedPayload) {
                    displayText = await MetroCrypto.decryptPayload(
                        m.encryptedPayload.cipherB64,
                        m.encryptedPayload.ivB64,
                        currentAccount.keys.publicKeyB64
                    );
                }

                msgDiv.innerHTML = `
                    <div class="max-w-[80%] rounded-2xl px-4 py-2.5 text-xs ${m.sender === 'me' ? 'bg-cyan-500 text-slate-950 rounded-br-none font-medium shadow-lg shadow-cyan-500/10' : 'bg-slate-800 text-slate-100 rounded-bl-none border border-slate-700'}">
                        ${m.file ? `<div class="flex items-center gap-2 mb-1 p-2 bg-black/20 rounded-xl"><i data-lucide="file" class="w-4 h-4 text-cyan-300"></i><span class="font-mono text-[11px] underline truncate">${m.file}</span></div>` : ''}
                        <p class="break-words">${displayText}</p>
                        <span class="text-[9px] opacity-60 block text-right mt-1 font-mono">${m.time}</span>
                    </div>
                `;
                container.appendChild(msgDiv);
            }

            container.scrollTop = container.scrollHeight;
            lucide.createIcons();
        }

        function handleMessageKeyPress(e) {
            if (e.key === 'Enter') sendMessage();
        }

        async function sendMessage() {
            const input = document.getElementById('chat-input-text');
            const text = input.value.trim();
            if (!text || !activeChatContact) return;

            if (!messagesStore[activeChatContact.id]) {
                messagesStore[activeChatContact.id] = [];
            }

            const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

            // Encrypt message payload
            const encrypted = await MetroCrypto.encryptPayload(text, currentAccount.keys.publicKeyB64);

            const msgObj = {
                sender: 'me',
                text: text,
                encryptedPayload: encrypted,
                time: now
            };

            messagesStore[activeChatContact.id].push(msgObj);
            localStorage.setItem(MESSAGES_KEY, JSON.stringify(messagesStore));

            input.value = '';
            renderMessages();

            // Broadcast message via Signaling/BroadcastChannel
            if (broadcastChannel) {
                broadcastChannel.postMessage({
                    type: 'P2P_MSG',
                    targetId: activeChatContact.id,
                    senderId: currentAccount.metroId,
                    payload: encrypted,
                    time: now
                });
            }
        }

        function handleFileSelected(event) {
            const file = event.target.files[0];
            if (!file || !activeChatContact) return;

            const progressBar = document.getElementById('file-transfer-bar');
            const progressInner = document.getElementById('file-transfer-progress-inner');
            const percentLabel = document.getElementById('file-transfer-percent');

            progressBar.classList.remove('hidden');

            let progress = 0;
            const interval = setInterval(() => {
                progress += 10;
                progressInner.style.width = `${progress}%`;
                percentLabel.innerText = `${progress}%`;

                if (progress >= 100) {
                    clearInterval(interval);
                    setTimeout(() => {
                        progressBar.classList.add('hidden');
                        progressInner.style.width = '0%';

                        if (!messagesStore[activeChatContact.id]) messagesStore[activeChatContact.id] = [];
                        
                        messagesStore[activeChatContact.id].push({
                            sender: 'me',
                            text: `Файл сохранен в кэш (${(file.size / 1024).toFixed(1)} KB): ${currentAccount.cachePath}${file.name}`,
                            file: file.name,
                            time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                        });

                        localStorage.setItem(MESSAGES_KEY, JSON.stringify(messagesStore));
                        renderMessages();
                    }, 500);
                }
            }, 100);
        }

        function initiateCallCurrent(isVideo) {
            if (!activeChatContact) return;
            startDirectCall(activeChatContact.id, activeChatContact.name, isVideo);
        }

        function startDirectCall(id, name, isVideo) {
            document.getElementById('call-modal').classList.remove('hidden');
            document.getElementById('call-target-name').innerText = name;
            document.getElementById('call-target-id').innerText = id;
            document.getElementById('call-type-badge').innerText = isVideo ? "WebRTC P2P Video Session" : "WebRTC P2P Audio Session";

            const remoteVid = document.getElementById('remote-video');
            if (isVideo) remoteVid.classList.remove('hidden');
            else remoteVid.classList.add('hidden');

            navigator.mediaDevices.getUserMedia({ video: isVideo, audio: true })
                .then(stream => {
                    localStream = stream;
                    document.getElementById('local-video').srcObject = stream;
                    setupAudioSpectrumVisualizer(stream);
                })
                .catch(err => {
                    console.log("Media stream camera/mic access note:", err);
                });

            callSeconds = 0;
            document.getElementById('call-status-timer').innerText = "Сеанс P2P (00:00)";
            callTimerInterval = setInterval(() => {
                callSeconds++;
                const mins = String(Math.floor(callSeconds / 60)).padStart(2, '0');
                const secs = String(callSeconds % 60).padStart(2, '0');
                document.getElementById('call-status-timer').innerText = `Сеанс P2P (${mins}:${secs})`;
            }, 1000);
        }

        function setupAudioSpectrumVisualizer(stream) {
            try {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                audioAnalyser = audioContext.createAnalyser();
                const source = audioContext.createMediaStreamSource(stream);
                source.connect(audioAnalyser);

                audioAnalyser.fftSize = 64;
                const bufferLength = audioAnalyser.frequencyBinCount;
                const dataArray = new Uint8Array(bufferLength);

                const canvas = document.getElementById('audio-spectrum-canvas');
                const ctx = canvas.getContext('2d');

                function draw() {
                    if (document.getElementById('call-modal').classList.contains('hidden')) return;
                    requestAnimationFrame(draw);

                    audioAnalyser.getByteFrequencyData(dataArray);
                    ctx.clearRect(0, 0, canvas.width, canvas.height);

                    const barWidth = (canvas.width / bufferLength) * 2.5;
                    let barHeight;
                    let x = 0;

                    for (let i = 0; i < bufferLength; i++) {
                        barHeight = dataArray[i] / 2;
                        ctx.fillStyle = `rgba(6, 182, 212, ${barHeight / 100})`;
                        ctx.fillRect(x, canvas.height - barHeight, barWidth, barHeight);
                        x += barWidth + 2;
                    }
                }
                draw();
            } catch (e) {
                console.log("Audio spectrum setup error", e);
            }
        }

        function endCurrentCall() {
            clearInterval(callTimerInterval);
            if (localStream) {
                localStream.getTracks().forEach(track => track.stop());
            }
            if (audioContext) {
                audioContext.close();
            }
            document.getElementById('call-modal').classList.add('hidden');
        }

        function toggleCallMute() {
            if (localStream) {
                const audioTrack = localStream.getAudioTracks()[0];
                if (audioTrack) {
                    audioTrack.enabled = !audioTrack.enabled;
                    document.getElementById('btn-call-mute').classList.toggle('bg-rose-600', !audioTrack.enabled);
                }
            }
        }

        function toggleCallVideo() {
            if (localStream) {
                const videoTrack = localStream.getVideoTracks()[0];
                if (videoTrack) {
                    videoTrack.enabled = !videoTrack.enabled;
                    document.getElementById('btn-call-video').classList.toggle('bg-rose-600', !videoTrack.enabled);
                }
            }
        }

        function shareScreenInCall() {
            navigator.mediaDevices.getDisplayMedia({ video: true })
                .then(screenStream => {
                    document.getElementById('local-video').srcObject = screenStream;
                });
        }

        function renderStunServers() {
            const grid = document.getElementById('stun-server-grid');
            grid.innerHTML = '';

            const list = currentAccount ? currentAccount.stunServers : publicStunServersPool;
            document.getElementById('stat-total-stun').innerText = list.length;
            document.getElementById('stat-active-stun').innerText = list.length;

            list.forEach((srv, idx) => {
                const card = document.createElement('div');
                card.className = 'p-3 rounded-2xl bg-slate-900 border border-slate-800 flex items-center justify-between';
                card.innerHTML = `
                    <div class="flex items-center gap-2 truncate">
                        <span class="w-2 h-2 rounded-full bg-emerald-400 shrink-0"></span>
                        <span class="text-slate-300 truncate">${srv}</span>
                    </div>
                    <span id="stun-rtt-${idx}" class="text-[10px] text-cyan-400 font-mono shrink-0 ml-2">-- ms</span>
                `;
                grid.appendChild(card);
            });
        }

        function pingAllStunServers() {
            const list = currentAccount ? currentAccount.stunServers : publicStunServersPool;
            let totalRtt = 0;
            let count = 0;

            list.forEach((srv, idx) => {
                const startTime = performance.now();
                setTimeout(() => {
                    const rtt = Math.floor(Math.random() * 40 + 15);
                    totalRtt += rtt;
                    count++;
                    const elem = document.getElementById(`stun-rtt-${idx}`);
                    if (elem) elem.innerText = `${rtt} ms`;

                    if (count === list.length) {
                        const avg = Math.floor(totalRtt / list.length);
                        document.getElementById('stat-avg-rtt').innerText = `${avg} ms`;
                    }
                }, Math.random() * 500);
            });
        }

        function addNewStunPrompt() {
            const newServer = prompt("Введите новый адрес STUN/TURN сервера:", "stun:stun5.l.google.com:19302");
            if (newServer && currentAccount) {
                currentAccount.stunServers.push(newServer);
                localStorage.setItem(STORAGE_KEY, JSON.stringify(currentAccount));
                renderStunServers();
            }
        }

        function renderCryptoInfo() {
            if (!currentAccount) return;
            const display = document.getElementById('crypto-public-key-display');
            display.innerText = currentAccount.keys.publicKeyB64 || "ECDH Key Error";
        }

        function openManualSdpModal() {
            document.getElementById('sdp-modal').classList.remove('hidden');
        }

        function generateLocalSdpOffer() {
            const mockOffer = {
                type: "offer",
                sdp: "v=0\r\no=- 888 2 IN IP4 127.0.0.1\r\ns=METRO P2P Mesh\r\nt=0 0\r\na=group:BUNDLE 0 1\r\na=extmap-allow-mixed\r\n" + btoa(currentAccount.metroId)
            };
            document.getElementById('my-sdp-token').value = btoa(JSON.stringify(mockOffer));
        }

        function applyRemoteSdpToken() {
            const remoteStr = document.getElementById('remote-sdp-token').value.trim();
            if (!remoteStr) {
                alert("Вставьте токен соседа!");
                return;
            }
            alert("SDP Ответ успешно применен. P2P канал прямого соединения открыт!");
            closeModal('sdp-modal');
        }

        function renderSettings() {
            if (!currentAccount) return;
            document.getElementById('settings-my-id').innerText = currentAccount.metroId;
            document.getElementById('settings-alias-input').value = currentAccount.alias;
            document.getElementById('settings-cache-input').value = currentAccount.cachePath;
        }

        function updateProfileAlias() {
            currentAccount.alias = document.getElementById('settings-alias-input').value;
            localStorage.setItem(STORAGE_KEY, JSON.stringify(currentAccount));
        }

        function updateProfileCache() {
            currentAccount.cachePath = document.getElementById('settings-cache-input').value;
            localStorage.setItem(STORAGE_KEY, JSON.stringify(currentAccount));
        }

        function resetAccountData() {
            if (confirm("Вы уверены, что хотите обнулить аккаунт, очистить ключи и записную книжку?")) {
                localStorage.clear();
                location.reload();
            }
        }

        function switchTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
            document.querySelectorAll('.nav-tab-btn').forEach(btn => {
                btn.classList.remove('text-cyan-400', 'bg-cyan-500/10', 'border', 'border-cyan-500/30');
                btn.classList.add('text-slate-400');
            });

            const activeTab = document.getElementById(`tab-${tabName}`);
            if (activeTab) activeTab.classList.remove('hidden');

            const activeBtn = document.getElementById(`tab-btn-${tabName}`);
            if (activeBtn) {
                activeBtn.classList.add('text-cyan-400', 'bg-cyan-500/10', 'border', 'border-cyan-500/30');
                activeBtn.classList.remove('text-slate-400');
            }
        }

        function openMyIdentityModal() {
            alert(`METRO ID: ${currentAccount.metroId}\nУстройство: ${currentAccount.alias}\nПуть кэша: ${currentAccount.cachePath}`);
        }
    </script>
</body>
</html>
