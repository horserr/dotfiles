# flags

154.0.4258.37

<!-- Warning: Experimental features ahead! By enabling these features, you could lose browser data or compromise your security or privacy. Enabled features apply to all users of this browser. If you are an enterprise admin you should not be using these flags in production. -->

## Anonymize local IPs exposed by WebRTC.

Conceal local IP addresses with mDNS hostnames. – Mac, Windows, Linux

- #enable-webrtc-hide-local-ips-with-mdns

Enabled

## Smooth Scrolling

Animate smoothly when scrolling page content. – Windows, Linux, Android

- #smooth-scrolling

Enabled

## Experimental QUIC protocol

Enable experimental QUIC protocol support. – Mac, Windows, Linux, Android

- #enable-quic

Enabled

## Experimental JavaScript

Enable web pages to use experimental JavaScript features. – Mac, Windows, Linux, Android

- #enable-javascript-harmony

Enabled

## WebAssembly lazy compilation

Enables lazy (JIT on first call) compilation of WebAssembly modules. – Mac, Windows, Linux, Android

- #enable-webassembly-lazy-compilation

Enabled

## Future V8 VM features

This enables upcoming and experimental V8 VM features. This flag does not enable experimental JavaScript features. – Mac, Windows, Linux, Android

- #enable-future-v8-vm-features

Enabled

## GPU rasterization

Use GPU to rasterize web content. – Mac, Windows, Linux, Android

- #enable-gpu-rasterization

Enabled

## Enable Zero-Copy Video Capture

Camera produces a gpu friendly buffer on capture and, if there is, hardware accelerated video encoder consumes the buffer – Windows

- #zero-copy-video-capture

Enabled

## Experimental system keyboard lock

Enables websites to use the keyboard.lock() API to intercept system keyboard shortcuts and have the events routed directly to the website when in fullscreen mode. – Mac, Windows, Linux

- #system-keyboard-lock

Disabled

## Parallel downloading

Enable parallel downloading to accelerate download speed. – Mac, Windows, Linux, Android

- #enable-parallel-downloading

Enabled

## Experimental Tracking Prevention Features

Enables upcoming and experimental improvements to Tracking Prevention. – Mac, Windows, Linux, Android

- #edge-experimental-tracking-prevention-features

Enabled

## Searchbox Autocomplete Favicon Cache

Enables the favicon cache for autocomplete matches in the NTP composer, providing site favicons as icons for URL-type suggestions. – Mac, Windows, Linux

- #edge-omnibox-autocomplete-favicon-cache

Enabled

## Edge Omnibox Mark Near-Duplicates

Mark near-duplicate results for debug visualization instead of delete – Mac, Windows, Linux

- #edge-omnibox-mark-only-deduplication

Enabled

## Enable UndersideV2 Sidepane Component Extension

When enabled, the Copilot sidepane loads copilot.microsoft.com as the top-level document rather than embedding it in an iframe. – Mac, Windows, Linux

- #edge-underside-v2-component-extension

Enabled

## Edge Icon Refresh

When enabled, swaps in the refreshed icon across Edge settings and UI surfaces. Restricted to Microsoft-internal machines/users. – Mac, Windows, Linux

- #edge-copilot-icon-refresh

Enabled

## Edge Copilot Mode

Turn on to make the Copilot mode available to opt-in. In order to experience the copilot mode, please go to Edge settings to opt-in the Copilot mode. – Mac, Windows, Linux

- #edge-copilot-mode

Enabled

## Edge Cowork Bridge

Enables the Copilot Bridge extension to accept tool-action messages from the Cowork surface. – Mac, Windows, Linux

- #edge-copilot-bridge-cowork

Enabled

## Enable Studio NTP Component Extension

When enabled, the Studio NTP loads copilot.microsoft.com as the top-level document rather than embedding it in an iframe. – Mac, Windows, Linux

- #edge-studio-ntp-component-extension

Enabled

## Enable Studio NTP Personalized Cards

When enabled, personalized cards will be shown on Studio NTP. – Mac, Windows, Linux

- #edge-studio-ntp-personalized-cards

Enabled

## Copilot App Configuration

Configures the Composer behavior for Copilot App, including autocomplete settings and suggestion filtering. – Mac, Windows, Linux

- #edge-wchromium-config

Enabled

## Omnibox Work: Enable Copilot Chat

Enables 'Ask Copilot' suggestion to be shown in the omnibox when user is signed in with an AAD account. – Mac, Windows, Linux

- #edge-omnibox-commercial-copilot-chat

Enabled

## Omnibox Consumer: Enable Copilot Chat

Enables 'Ask Copilot' suggestion to be shown in the omnibox when user is not signed in or signed in with an MSA account. – Mac, Windows, Linux

- #edge-omnibox-consumer-copilot-chat

Enabled Chat dynamic

## Open Grouped History in History Hub

When enabled, clicking on Omnibox Grouped History suggestions will redirect users to the History Hub instead of immediately opening a Tab Group – Mac, Windows, Linux

- #edge-omnibox-history-clusters-connection

Enabled

## Edge AI Mode

Enables AI Mode features. – Mac, Windows, Linux

- #edge-ai-search

Enabled

## Omnibox UI Hide Steady-State URL Scheme

In the omnibox, hide the scheme from steady state displayed URLs. It is restored during editing. – Mac, Windows, Linux, Android

- #edge-omnibox-ui-hide-steady-state-url-scheme

Enabled

## Omnibox UI Hide Steady-State URL Trivial Subdomains

In the omnibox, hide trivial subdomains from steady state displayed URLs. Hidden portions are restored during editing. – Mac, Windows, Linux, Android

- #edge-omnibox-ui-hide-steady-state-url-trivial-subdomains

Enabled

## Sign in with Google

Allows Google sign-in to Edge profile. – Mac, Windows

- #edge-swag-m1-google

Enabled

## Workspaces Emoji

Enables emoji support for workspaces, allowing users to pick an emoji as the workspace icon. – Mac, Windows, Linux

- #edge-workspaces-emoji

Enabled

## Workspaces Inline Window Switching

Enables the ability to switch between workspaces within a single browser window, without needing to open a new window for each workspace. – Mac, Windows, Linux

- #edge-workspaces-inline-window-switching

Enabled

## Workspace Pinning

Enable the ability to pin workspaces for quick access. Pinned workspaces will appear in the browser frame and at the top of the menu. – Mac, Windows, Linux

- #edge-workspaces-pinning

Enabled

## Microsoft 360 Viewer Extension

If enabled, sites can use the Microsoft 360 Viewer Extension to present 360 videos to VR – Windows

- #edge-microsoft-360-viewer

Enabled

## Boost screen refresh rate when scrolling.

Allows Windows to temporarily boost the refresh rate up when scrolling (provided the machine has a VRR panel and a supporting driver). This provides an overall smoother scrolling experience. – Windows

- #edge-refresh-rate-boost-on-scroll

Enabled

## Browser tab experiences in Windows

Allows Windows to show open Microsoft Edge tabs in OS experiences like Alt + Tab, pinned sites, and more. – Windows

- #edge-window-tab-manager

Enabled

## Explain Console errors with Copilot

Enables Copilot explanations for error messages in the DevTools Console. – Mac, Windows, Linux

- #edge-ai-explain-devtools

Enabled

## Enable CSS Copilot

Enables using Copilot in the Microsoft Edge Sidebar to explain HTML elements and CSS styles. – Mac, Windows, Linux

- #edge-devtools-css-copilot

Enabled

## Hardware Media Key Handling

Enables using media keys to control the active media session. This requires MediaSessionService to be enabled too – Mac, Windows, Linux

- #hardware-media-key-handling

Enabled

## Force High Performance GPU

Forces use of high performance GPU if available. Warning: this flag may increase power consumption leading to shorter battery time. – Windows

- #force-high-performance-gpu

Enabled

## Heavy ad privacy mitigations

Enables privacy mitigations for the heavy ad intervention. Disabling this makes the intervention deterministic. Defaults to enabled. – Mac, Windows, Linux, Android

- #heavy-ad-privacy-mitigations

Enabled

## Run video capture service in browser

Run the video capture service in the browser process. – Windows

- #run-video-capture-service-in-browser

Enabled

## Enable experimental cookie features

Enable new features that affect setting, sending, and managing cookies. The enabled features are subject to change at any time. – Mac, Windows, Linux, Android

- #enable-experimental-cookie-features

Enabled

## Desktop PWA Link Capturing

Enables opening links from the browser in an installed PWA. Currently under reimplementation. – Mac, Windows, Linux

- #enable-user-navigation-capturing-pwa

Enabled

## Make scrollbar follow theme

If enabled makes the root scrollbar follow the browser's theme color. – Windows, Linux

- #root-scrollbar-follows-browser-theme

Enabled

## DOM Storage SQLite Backend

Uses a SQLite-powered backing store for local and session storage. No data is migrated from existing backing stores, including LevelDB stores or SQLite stores with older schemas; use at your own peril. – Mac, Windows, Linux, Android

- #dom-storage-sqlite

Enabled
Temporarily unexpire M152 flags.
Temporarily unexpire flags that expired as of M152. These flags will be removed soon. – Mac, Windows, Linux, Android

- #temporary-unexpire-flags-m152

Default
Temporarily unexpire M153 flags.
Temporarily unexpire flags that expired as of M153. These flags will be removed soon. – Mac, Windows, Linux, Android

- #temporary-unexpire-flags-m153

Default
Enable benchmarking
Sets all features to a fixed state; that is, disables randomization for feature states. If '(Default Feature States)' is selected, sets all features to their default state. If '(Match Field Trial Testing Config)' is selected, sets all features to the state configured in the field trial testing config. This is used by developers and testers to diagnose whether an observed problem is caused by a non-default base::Feature configuration. This flag is automatically reset after 3 restarts and will be off from the 4th restart. On the 3rd restart, the flag will appear to be off but the effect is still active. – Mac, Windows, Linux, Android

- #enable-benchmarking

Disabled
Override software rendering list
Overrides the built-in software rendering list and enables GPU-acceleration on unsupported system configurations. – Mac, Windows, Linux, Android

- #ignore-gpu-blocklist

Disabled
Accelerated 2D canvas
Enables the use of the GPU to perform 2d canvas rendering instead of using software rendering. – Mac, Windows, Linux, Android

- #disable-accelerated-2d-canvas

Enabled
Partial swap
Sets partial swap behavior. – Mac, Windows, Linux, Android

- #ui-disable-partial-swap

Enabled
Allow WebRTC to adjust the input volume.
Allow the Audio Processing Module in WebRTC to adjust the input volume during a real-time call. Disable if microphone muting or clipping issues are observed when the browser is running and used for a real-time call. This flag is experimental and may be removed at any time. – Mac, Windows, Linux

- #enable-webrtc-allow-input-volume-adjustment

Default
WebRTC downmix capture audio method.
Override the method that the Audio Processing Module in WebRTC uses to downmix the captured audio to mono (when needed) during a real-time call. This flag is experimental and may be removed at any time. – Mac, Windows, Linux

- #enable-webrtc-apm-downmix-capture-audio-method

Default
Show Autofill predictions
Annotates web forms with Autofill field type predictions as placeholder text. – Mac, Windows, Linux, Android

- #show-autofill-type-predictions

Default
Soft Navigation Heuristics
Enables the soft navigation heuristics, including support for PerformanceObserver. See the documentation at https://permanently-removed.invalid/docs/web-platform/soft-navigations-experiment. – Mac, Windows, Linux, Android

- #soft-navigation-heuristics

Default
Blocking Focus Without User Activation
When enabled, the focus-without-user-activation permissions policy can be used by embedders to block programmatic focus calls (element.focus(), window.focus(), autofocus) from iframes unless triggered by a user gesture. – Mac, Windows, Linux, Android

- #blocking-focus-without-user-activation

Default
WebTransport Developer Mode
When enabled, removes the requirement that all certificates used for WebTransport over HTTP/3 are issued by a known certificate root. – Mac, Windows, Linux, Android

- #webtransport-developer-mode

Disabled
Latest stable JavaScript features
Some web pages use legacy or non-standard JavaScript extensions that may conflict with the latest JavaScript features. This flag allows disabling support of those features for compatibility with such pages. – Mac, Windows, Linux, Android

- #disable-javascript-harmony-shipping

Enabled
Experimental WebAssembly
Enable web pages to use experimental WebAssembly features. – Mac, Windows, Linux, Android

- #enable-experimental-webassembly-features

Disabled
WebAssembly baseline compiler
Enables WebAssembly baseline compilation and tier up. – Mac, Windows, Linux, Android

- #enable-webassembly-baseline

Default
WebAssembly tiering
Enables tiered compilation of WebAssembly (will tier up to TurboFan if #enable-webassembly-baseline is enabled). – Mac, Windows, Linux, Android

- #enable-webassembly-tiering

Default
Experimental Web Platform features
Enables experimental Web Platform features that are in development. – Mac, Windows, Linux, Android

- #enable-experimental-web-platform-features

Disabled
Hardware-accelerated video decode
Hardware-accelerated video decode where available. – Mac, Windows, Linux, Android

- #disable-accelerated-video-decode

Enabled
Hardware-accelerated video encode
Hardware-accelerated video encode where available. – Mac, Windows, Android

- #disable-accelerated-video-encode

Enabled
Hardware Secure Decryption Fallback
Allows automatically disabling hardware secure Content Decryption Module (CDM) after failures or crashes. Subsequent playback may use software secure CDMs. If this feature is disabled, the fallback will never happen and users could be stuck with playback failures. – Windows

- #enable-hardware-secure-decryption-fallback

Default
Show autofill signatures.
Annotates web forms with Autofill signatures as HTML attributes. Also marks password fields suitable for password generation. – Mac, Windows, Linux, Android

- #enable-show-autofill-signatures

Disabled
WebGL Draft Extensions
Enabling this option allows web applications to access the WebGL extensions that are still in draft status. – Mac, Windows, Linux, Android

- #enable-webgl-draft-extensions

Disabled
Zero-copy rasterizer
Raster threads write directly to GPU memory associated with tiles. – Mac, Windows, Linux, Android

- #enable-zero-copy

Default
Enable Isolated Web Apps
Enables experimental support for Isolated Web Apps. See https://github.com/reillyeon/isolated-web-apps for more information. – Mac, Windows, Linux

- #enable-isolated-web-apps

Default
Enable Isolated Web App Developer Mode
Enables the installation of unverified Isolated Web Apps – Mac, Windows, Linux

- #enable-isolated-web-app-dev-mode

Default
Isolate additional origins
Requires dedicated processes for an additional set of origins, specified as a comma-separated list. – Mac, Windows, Linux, Android

- #isolate-origins

Disabled
Disable site isolation
Disables site isolation (SitePerProcess, IsolateOrigins, etc). Intended for diagnosing bugs that may be due to out-of-process iframes. Opt-out has no effect if site isolation is force-enabled using a command line switch or using an enterprise policy. Caution: this disables important mitigations for the Spectre CPU vulnerability affecting most computers. – Mac, Windows, Linux, Android

- #site-isolation-trial-opt-out

Default
Desktop PWA tab strips
Tabbed application mode - enables the `tabbed` display mode which allows web apps to add a tab strip to their app. – Mac, Windows, Linux

- #enable-desktop-pwas-tab-strip

Default
Desktop PWA tab strips settings
Experimental UI for selecting whether a PWA should open in tabbed mode. – Mac, Windows, Linux

- #enable-desktop-pwas-tab-strip-settings

Default
Desktop PWA tab strip customizations
Enable PWAs to customize their tab strip when in tabbed mode by adding the `tab_strip` manifest field. – Mac, Windows, Linux

- #enable-desktop-pwas-tab-strip-customizations

Default
Desktop PWA Additional Windowing Controls
Enable PWAs to: (1) manually recreate the minimize, maximize and restore window functionalities, (2) set windows (non-/)resizable and (3) listen to window's move events with respective APIs. – Mac, Windows, Linux

- #enable-desktop-pwas-additional-windowing-controls

Default
Record web app debug info
Enables recording additional web app related debugging data to be displayed in: chrome://web-app-internals – Mac, Windows, Linux

- #record-web-app-debug-info

Default
Connect to Cast devices on all IP addresses
Have the Media Router connect to Cast devices on all IP addresses, not just RFC1918/RFC4193 private addresses. – Mac, Windows, Linux

- #media-router-cast-allow-all-ips

Default
Allow all sites to initiate mirroring
When enabled, allows all websites to request to initiate tab mirroring via Presentation API. Requires #cast-media-route-provider to also be enabled – Mac, Windows, Linux

- #allow-all-sites-to-initiate-mirroring

Default
Enables logging of all Cast messages.
Enables logging of all messages exchanged between websites, Chrome, and Cast receivers in chrome://media-router-internals. – Mac, Windows, Linux

- #cast-message-logging

Default
Toggle hardware accelerated H.264 video encoding for Cast Streaming
The default is to allow hardware H.264 encoding when recommended for the platform. If enabled, hardware H.264 encoding will always be allowed when supported by the platform. If disabled, hardware H.264 encoding will never be used. – Mac, Windows, Linux

- #cast-streaming-hardware-h264

Default
Toggle hardware accelerated VP8 video encoding for Cast Streaming
The default is to allow hardware VP8 encoding when recommended for the platform. If enabled, hardware VP8 encoding will always be allowed when supported by the platform (regardless of recommendation). If disabled, hardware VP8 encoding will never be used. – Mac, Windows, Linux

- #cast-streaming-hardware-vp8

Default
Toggle hardware accelerated VP9 video encoding for Cast Streaming
The default is to allow hardware VP9 encoding when recommended for the platform. If enabled, hardware VP9 encoding will always be allowed when supported by the platform (regardless of recommendation). If disabled, hardware VP9 encoding will never be used. – Mac, Windows, Linux

- #cast-streaming-hardware-vp9

Default
Enable hardware H264 video encoding on for Cast Streaming on Windows
Offers the H264 video codec when negotiating Cast Streaming, and uses hardware-accelerated H264 encoding if selected for the session – Windows

- #enable-cast-streaming-win-hardware-h264

Default
WebXR/WebGPU Binding
Enables rendering with WebGPU for WebXR sessions. WebXR Projection Layers must be also be enabled to use this feature. – Windows, Android

- #webxr-webgpu-binding

Default
WebXR Incubations
Enables experimental features for WebXR. – Mac, Windows, Linux, Android

- #webxr-incubations

Default
WebXR Internals Debugging Page
Enables the webxr-internals developer page which can be used to help debug issues with the WebXR Device API. – Mac, Windows, Linux, Android

- #webxr-internals

Default
Force WebXr Runtime
Force the browser to use a particular runtime, even if it would not usually be enabled or would otherwise not be selected based on the attached hardware. – Mac, Windows, Linux, Android

- #webxr-runtime

Default
WebXr Hand Anonymization Strategy
Force the browser to use a particular strategy for anonymizing hand data, the default order has a hierarchy of strategies to try and if all of them fail, then no data will be returned, while this choice does allow the (not recommended) alternative of bypassing these algorithms all together. – Mac, Windows, Linux, Android

- #webxr-hand-anonymization

Default
Block scripts loaded via document.write
Disallows fetches for third-party parser-blocking scripts inserted into the main frame via document.write. – Mac, Windows, Linux, Android

- #disallow-doc-written-script-loads

Default
Use Windows Runtime MIDI API
Use Windows Runtime MIDI API for WebMIDI (effective only on Windows 10 or later). – Windows

- #use-winrt-midi-api

Default
Force UI direction
Explicitly force the UI to left-to-right (LTR) or right-to-left (RTL) mode, overriding the default direction of the UI language. – Mac, Windows, Linux, Android

- #force-ui-direction

Default
Force text direction
Explicitly force the per-character directionality of UI text to left-to-right (LTR) or right-to-left (RTL) mode, overriding the default direction of the character language. – Mac, Windows, Linux, Android

- #force-text-direction

Default
TLS 1.3 Early Data
This option enables TLS 1.3 Early Data, allowing GET requests to be sent during the handshake when resuming a connection to a compatible TLS 1.3 server. – Mac, Windows, Linux, Android

- #enable-tls13-early-data

Default
Auto Dark Mode for Web Contents
Automatically render all web contents using a dark theme. – Mac, Windows, Linux

- #enable-force-dark

Default
Experimental Web Payments API features
Enable experimental Web Payments API features – Mac, Windows, Linux, Android

- #enable-web-payments-experimental-features

Default
Fill passwords on account selection
Filling of passwords when an account is explicitly selected by the user rather than autofilling credentials on page load. – Mac, Windows, Linux, Android

- #fill-on-account-select

Default
Force color profile
Forces the browser to use a specific color profile instead of the color of the window's current monitor, as specified by the operating system. – Mac, Windows, Linux, Android

- #force-color-profile

Default
Forced Colors
Enables forced colors mode for web content. – Mac, Windows, Linux, Android

- #forced-colors

Default
Adaptive global tone mapping
Enables parsing and rendering of adaptive global tone mapping (AGTM) aka SMTPE ST 2094-50 HDR metadata – Mac, Windows, Linux, Android

- #hdr-agtm

Default
Enable network logging to file
Enables network logging to a file named netlog.json in the user data directory. The file can be imported into chrome://net-internals. – Mac, Windows, Linux, Android

- #enable-network-logging-to-file

Disabled
Insecure origins treated as secure
Treat given (insecure) origins as secure origins. Multiple origins can be supplied as a comma-separated list. Origins must have their protocol specified e.g. "http://example.com". For the definition of secure contexts, see https://w3c.github.io/webappsec-secure-contexts/ – Mac, Windows, Linux, Android

- #unsafely-treat-insecure-origin-as-secure

Disabled
Choose ANGLE graphics backend
Choose the graphics backend for ANGLE. D3D11 is used on most Windows computers by default. – Windows

- #use-angle

Default
Ad Selection API
Enables the Ad Selection API and associated features such as Attribution Reporting, Fenced Frames, Shared Storage, Private Aggregation. – Mac, Windows, Linux, Android

- #edge-ad-selection-api

Disabled
Ad Selection API - Consented Debug Token
Enables Ad Selection API debugging with the provided token. Privacy-preserving auctions running on an Ad Selection API trusted server with a matching token will be able to log information about the auction to enable debugging. Note that this logging may include information about the user's browsing history normally kept private. – Mac, Windows, Linux, Android

- #edge-ad-selection-debug-token

Disabled
Automated password change
If enabled, Edge can change a saved password on the site on the user's behalf instead of requiring the user to update it manually. – Mac, Windows, Linux

- #edge-automated-password-change

Default
Enable Cloud Policy V2
Enables the use of a new Cloud Policy backend. – Mac, Windows, Linux, Android

- #edge-cloud-policy-v2

Default
Enable Cloud Policy V2 Tasks
Enables the use of tasks on the new Cloud Policy backend. – Mac, Windows, Linux, Android

- #edge-cloud-policy-v2-tasks

Default
Apple Sign-In Button on Profile Menu
Shows an Apple sign-in button on the profile menu. Sign in with Apple(#edge-swag-m1-apple) must be enabled for sign-in to work. – Mac, Windows

- #edge-enable-apple-sign-in-button-on-flyout

Default
Google Sign-In Button on Profile Menu
Shows a Google sign-in button on the profile menu. Sign in with Google(#edge-swag-m1-google) must be enabled for sign-in to work. – Mac, Windows

- #edge-enable-google-sign-in-button-on-flyout

Default
Edge SDCH (ZSDCH Content-Encoding)
Enables Edge Sdch (ZSDCH Content-Encoding) support. – Mac, Windows, Linux, Android

- #edge-enable-zsdch-content-encoding

Default
Favorites configuration export for administrators
Enables a feature in the favorites management experience (edge://favorites) for administrators to export favorites configuration state for use in the Configure Favorites enterprise policy. – Mac, Windows, Linux

- #edge-favorites-admin-export

Default
Enable experimentation 'full' mode
If enabled and 'ExperimentationAndConfigurationServiceControl' group policy was not set, Edge client will behave as if the group policy was set to 'full mode', which will enable experimentation on the client. – Mac, Windows, Linux, Android

- #edge-optin-experimentation

Default
Use Aura for Find on page
Compose Find on page UI using Aura instead of using a popup window – Windows

- #edge-find-aura

Default
Use Aura for Omnibox
Compose Omnibox using Aura instead of using a popup window – Windows

- #edge-omnibox-aura

Default
CMFeature: Composer Search Chat Turnaround UX
Shows a button in the address bar to reformulate query in Bing search or Copilot chat after qualifying composer navigations. – Mac, Windows, Linux

- #edge-omnibox-composer-search-chat-turnaround-ux

Default
CMFeature: Composer Outerframe Text Buffer
Enhance composer responsiveness while page is loading – Mac, Windows, Linux

- #edge-omnibox-composer-outerframe-text-buffer

Default
CMFeature: Composer Outerframe Text Buffer Visibility
Enhance composer responsiveness while page is loading with debug UI – Mac, Windows, Linux

- #edge-omnibox-composer-outerframe-text-buffer-visibility

Default
Edge Omnibox Remove Near-Duplicate Direct Navigations
Remove near-duplicate direct navigation results in Omnibox using new heuristics – Mac, Windows, Linux

- #edge-omnibox-direct-nav-eager-deduplication

Default
Edge Omnibox Remove Near-Duplicate Documents
Remove near-duplicate document results in Omnibox using new heuristics – Mac, Windows, Linux

- #edge-omnibox-document-eager-deduplication

Default
Edge Omnibox Remove Near-Duplicates
Remove near-duplicate results in Omnibox using new heuristics – Mac, Windows, Linux

- #edge-omnibox-eager-deduplication

Default
Edge Omnibox Focus Ring MAI Colors and Sizes
Enables different Omnibox focus ring color and size combinations for light and dark mode. – Mac, Windows, Linux

- #edge-omnibox-focus-ring-mai-colors-and-size

Default
Commercial Copilot: Route MSA accounts through BizChat
When enabled, MSA primary accounts are routed through BizChat WebUI. – Mac, Windows, Linux

- #edge-commercial-copilot-msa-in-bizchat

Default
Direct Navigation Suggestion Ranking
Enables the Direct Navigation provider on Unified Composer NTP and specifies how to rank its suggestions. – Mac, Windows, Linux

- #edge-direct-navigation-ranking

Default
CMFeature: Unified Composer NTP
Turn on Unified Composer on New Tab Page. – Mac, Windows, Linux

- #edge-ntp-composer

Default
CMFeature: Consumer Chat Ranking
Ranking of chat suggestion in the search box on the experimental New TabPage in an unsigned in or MSA profile. – Mac, Windows, Linux

- #edge-ntp-composer-chat-ranking

Default
CMFeature: Enable Studio-Based Edge NTP
When enabled, the Edge NTP architecture switches to using the Studio-based NTP service on Linux, Windows, and macOS systems. – Mac, Windows, Linux

- #edge-studio-ntp

Default
Cowork review banner
When enabled, a Cowork agent can show a tab for review with an "I'm done" banner. Required by the Cowork review side panel. – Mac, Windows, Linux

- #edge-tools-cowork-show-tab-banner

Default
Cowork review side panel
When enabled, a Cowork review shows the reviewed tab and the agent host side by side by parking the agent host in a dedicated panel associated with the reviewed tab. The variation parks the reviewed tab instead. Has no effect without the Cowork review banner. – Mac, Windows, Linux

- #edge-tools-cowork-review-host-side-panel

Default
Cowork agent tab close confirmation
When enabled, closing a tab an agent is operating on asks for confirmation first. Enabled is the widest behaviour: a tab in review and the agent host holding a parked reviewed tab prompt as well, which is the same as the third variation. The other two variations narrow it to locked tabs only, or to locked tabs and tabs in review. – Mac, Windows, Linux

- #edge-tools-cowork-agent-tab-close-confirmation

Default
Enable OneJS-Based Edge NTP
When enabled, the Edge NTP architecture switches to using the OneJS-based NTP service on Linux, Windows, and macOS systems. – Mac, Windows, Linux

- #edge-onejs-ntp

Disabled
CMFeature: Studio Feed Content Market Override
Controls the content market of the feed in the Studio NTP Feature – Mac, Windows, Linux

- #edge-studio-ntp-feed-content-market-override

Default
Enable Studio NTP Tips Suggestions
When enabled, tips suggestions will be shown on Studio NTP. – Mac, Windows, Linux

- #edge-studio-ntp-tips-suggestions

Default
Enable History Cluster Provider
Shows History Clusters as a separate suggestion row – Mac, Windows, Linux

- #edge-omnibox-history-clusters-provider

Default
Edge History Clusters Internal Page
Enables History Clusters log messages to be shown – Mac, Windows, Linux

- #edge-omnibox-history-clusters-internals-page

Default
NewTabPagePrerender
If enabled, NewTabPage can trigger prerender – Mac, Windows, Linux

- #edge-prerender-new-tab-page-trigger

Default
Sign in with Apple
Allows Apple sign-in to Edge profile. – Mac, Windows

- #edge-swag-m1-apple

Default
Show Windows 11 visual effects in browser
Enables an appearance setting to use same visual effects as Windows 11 on your browser. This option can then be turned on/off at edge://settings/appearance. – Mac, Windows, Linux

- #edge-visual-rejuv-mica

Default
Web Remix
Enables the Web Remix surface, including the edge://blueprint WebUI page. – Mac, Windows, Linux

- #edge-remix

Default
Web UI Web Vitals Performance Measurement Tool
Enables the Web Vitals Performance measurement tool for WebUI 2 apps. – Mac, Windows, Linux, Android

- #edge-webui-webvitals

Default
PlayReady DRM for Windows
Enables the PlayReady content decryption module in Microsoft Edge. This feature requires Windows 10+. – Windows

- #edge-playready-drm-win10

Default
Widevine DRM
Enables the Widevine content decryption module in Microsoft Edge. – Mac, Windows

- #edge-widevine-drm

Default
Enable Experimentation Payload Fetch on startup
Enables experimentation payload fetch on startup and every time the app enters foreground, regardless of the time passed in between the fetches. – Mac, Windows, Linux, Android

- #edge-disable-variations-seed-fetch-throttling

Disabled
ClickOnce Support
When enabled, file downloads that request ClickOnce handling will invoke the ClickOnce application with the server-provided URL. This feature flag will be overridden if your organization configures the "Allow users to open files using the ClickOnce protocol" policy. – Windows

- #edge-click-once

Default
Enable remote debugging through Windows Device Portal
Enables remote debugging of browser tabs over the local network through Windows Device Portal. – Windows

- #edge-devtools-wdp-remote-debugging

Default
Edge Extended ETW Events Logging
Enables the Extended Edge ETW Events for logging – Windows

- #edge-extended-etw-events

Default
Emulate Windows SKU
Enables emulation of different Windows device families and editions for testing purposes. – Windows

- #edge-emulate-windows-sku

Default
Force Synchronous SmartScreen Reputation checks when WCF is Enabled
If Microsoft Defender Web Content Filtering is enabled, SmartScreen reputation checks will occur synchronously, delaying navigation until the web service call returns. Synchronous behavior can prevent momentary display of content from blocked website categories – Windows

- #edge-smartscreen-wcf-sync

Default
Prompt API for on-device language model
Enables the exploratory Prompt API, allowing you to run natural language processing tasks by prompting the on-device small language model in Microsoft Edge. Uses the Phi-mini model by default, unless overridden through other flags. Exploratory APIs are designed for local prototyping only, to help discover potential use cases, and may never launch. The Prompt API is intended for natural language processing tasks such as summarizing, classifying, or rephrasing text. It is NOT suitable for use cases that require factual accuracy. Please read the Phi-mini model card [1] for more information and comply with the Intended use and Responsible AI considerations. – Mac, Windows, Linux

https://go.microsoft.com/fwlink/?linkid=2285563

- #edge-llm-prompt-api-for-phi-mini

Default
Language detection web platform API
When enabled, JS can use the web platform's language detection API – Mac, Windows, Linux, Android

- #edge-language-detection-api

Default
Summarizer API for on-device language model
Enables the Summarizer API, allowing you to summarize text with the on-device small language model in Microsoft Edge. Uses the Phi-mini model by default, unless overridden through other flags. The API may be subject to changes including the supported options. Exploratory APIs are designed for local prototyping only, to help discover potential use cases, and may never launch. This API is NOT suitable for use cases that require factual accuracy (e.g. answering knowledge questions). Please read the Phi-mini model card [1] for more information and comply with the Intended use and Responsible AI considerations. – Mac, Windows, Linux

https://go.microsoft.com/fwlink/?linkid=2285563

- #edge-llm-summarization-api-for-phi-mini

Default
Writer API for on-device language model
Enables the Writer API, allowing you to write a piece of text with the on-device small language model in Microsoft Edge. Uses the Phi-mini model by default, unless overridden through other flags. The API may be subject to changes including the supported options. Exploratory APIs are designed for local prototyping only, to help discover potential use cases, and may never launch. This API is NOT suitable for use cases that require factual accuracy (e.g. answering knowledge questions). Please read the Phi-mini model card [1] for more information and comply with the Intended use and Responsible AI considerations. – Mac, Windows, Linux

https://go.microsoft.com/fwlink/?linkid=2285563

- #edge-llm-writer-api-for-phi-mini

Default
Rewriter API for on-device language model
Enables the Rewriter API, allowing you to rewrite a piece of text with the on-device small language model in Microsoft Edge. Uses the Phi-mini model by default, unless overridden through other flags. The API may be subject to changes including the supported options. Exploratory APIs are designed for local prototyping only, to help discover potential use cases, and may never launch. This API is NOT suitable for use cases that require factual accuracy (e.g. answering knowledge questions). Please read the Phi-mini model card [1] for more information and comply with the Intended use and Responsible AI considerations. – Mac, Windows, Linux

https://go.microsoft.com/fwlink/?linkid=2285563

- #edge-llm-rewriter-api-for-phi-mini

Default
Enable on device AI model debug logs
Enables on device AI model to log and save debug messages that can be shown in the internals page. – Mac, Windows, Linux, Android

- #edge-llm-on-device-model-debug-logs

Disabled
Enable on device AI model performance parameters override
Enables overriding of the on device AI model performance parameters. – Mac, Windows, Linux

- #edge-llm-on-device-model-performance-param

Default
Enable Digital Signature for PDF on Legacy (PDFium based) PDF Viewer
This feature flag takes effect only in case of legacy (PDFium based) PDF viewer where it enables the verification of digital signature in PDF files in the browser. This feature can be managed via the "Enable Secure Environment for Digitally Signed PDF" policy. Note: If the Policy is enabled, it will take precedence over the feature flag. The New PDF Viewer has Digital Signature enabled by default. – Mac, Windows

- #edge-digsig-enabled-pdf

Default
Open DevTools source files in Visual Studio Code
Enables opening source files shown in DevTools in Visual Studio Code. – Mac, Windows, Linux

- #edge-devtools-open-vscode

Default
Enable DevTools symbol server extension support
Enables source map resolution through the DevTools symbol server extension. – Mac, Windows, Linux

- #edge-devtools-symbol-server-extension

Default
Log DevTools uncaught exceptions to the Console
Logs uncaught exceptions from DevTools to the DevTools Console. – Mac, Windows, Linux

- #edge-devtools-uncaught-exception

Default
Enable support for XFA in PDF
Enables loading XFA based forms in PDF. – Mac, Windows, Linux

- #edge-pdf-viewer-xfa

Default
Use Updated UI for Global Media Controls
When enabled, Global Media Controls will use the new updated UI including icons, layout, media slider and toggle button styling instead of current Global Media Controls UI. – Mac, Windows, Linux

- #edge-global-media-controls-updated-ui

Default
Fluent overlay scrollbars.
To experiment with Fluent overlay scrollbars, enable this feature and turn the 'Always Show Scrollbars' setting off in edge://settings/?search=Always+show+scrollbars. – Windows, Linux

- #edge-overlay-scrollbars-win-style

Default
OOPIF for PDF Viewer Extension
Use an OOPIF for the PDF Viewer Extension, instead of a GuestView. – Mac, Windows, Linux

- #edge-pdf-extension-oopif

Default
PDF WebUI Visual Update
Enables the updated WebUI2 based rendering for Microsoft Edge's PDF viewer UI. – Mac, Windows, Linux

- #edge-pdf-webui-update

Default
PDF MIP view label
Show policy label details for MIP protected PDFs – Mac, Windows

- #edge-pdf-mip-view-label

Default
Enable GameInput data fetcher
Enables Gamepad API to use GameInput for gamepad access. – Windows

- #enable-windows-gameinput-data-fetcher

Default
Enable gpu service logging
Enable printing the actual GL driver calls. – Mac, Windows, Linux, Android

- #enable-gpu-service-logging

Disabled
Strict-Origin-Isolation
Experimental security mode that strengthens the site isolation policy. Controls whether site isolation should use origins instead of scheme and eTLD+1. – Mac, Windows, Linux, Android

- #strict-origin-isolation

Default
Unsafe WebGPU Support
Convenience flag for WebGPU development. Enables best-effort WebGPU support on unsupported configurations and more! Note that this flag could expose security issues to websites so only use it for your own development. – Mac, Windows, Linux, Android

- #enable-unsafe-webgpu

Disabled
Elastic Overscroll
Enables Elastic Overscrolling on touchscreens and precision touchpads. – Windows, Android

- #elastic-overscroll

Default
MediaFoundation Video Capture
Enable/Disable the usage of MediaFoundation for video capture. Fall back to DirectShow if disabled. – Windows

- #enable-media-foundation-video-capture

Default
Enables WebNN API
Enables the Web Machine Learning Neural Network (WebNN) API. Spec at https://www.w3.org/TR/webnn/ – Mac, Windows, Linux, Android

- #web-machine-learning-neural-network

Default
Enables experimental WebNN API features
Enables additional, experimental features in Web Machine Learning Neural Network (WebNN) API. Requires the "WebNN API" flag to be enabled. – Mac, Windows, Linux, Android

- #experimental-web-machine-learning-neural-network

Default
ONNX Runtime backend for WebNN
Enables using ONNX Runtime for CPU, GPU and NPU inference with the WebNN API. Disabling this flag enables a fallback to TFLite. – Windows

- #webnn-onnxruntime

Default
Trees in viz
Enables the renderer to send a CC LayerTree to the viz/gpu process instead of a CompositorFrame. This allows viz to generate and submit the CompositorFrame directly. – Mac, Windows, Linux, Android

- #trees-in-viz

Default
FedCmAutofill
Allows RPs to enhance autofill with FedCM. – Mac, Windows, Linux, Android

- #fedcm-autofill

Default
FedCM with delegation support
Enables IdPs to delegate presentation to the browser. – Mac, Windows, Linux, Android

- #fedcm-delegation

Default
FedCM with IdP Registration support
Enables RPs to get identity credentials from registered IdPs. – Mac, Windows, Linux

- #fedcm-idp-registration

Default
FedCmLightweightMode
Enables IdPs to store user profile information using the login status API. – Mac, Windows, Linux

- #fedcm-lightweight-mode

Default
FedCmMetricsEndpoint
Allows the FedCM API to send performance measurement to the metrics endpoint on the identity provider side. Requires FedCM to be enabled. – Mac, Windows, Linux, Android

- #fedcm-metrics-endpoint

Default
FedCmWithoutWellKnownEnforcement
Supports configURL that's not in the IdP's .well-known file. – Mac, Windows, Linux, Android

- #fedcm-without-well-known-enforcement

Default
FedCmSegmentationPlatform
Enables the segmentation platform service to provide UI volume recommendations to FedCM. – Mac, Windows, Linux, Android

- #fedcm-segmentation-platform

Default
DigitalCredentials
Enables the three-party verifier/holder/issuer identity model. – Mac, Windows, Linux, Android

- #web-identity-digital-credentials

Default
DigitalCredentialsCreation
Enables the Digital Credentials Creation API. – Mac, Windows, Linux, Android

- #web-identity-digital-credentials-creation

Default
Test Third Party Cookie Phaseout
Enable to test third-party cookie phaseout. Learn more: https://permanently-removed.invalid/3pcd-flags – Mac, Windows, Linux, Android

- #test-third-party-cookie-phaseout

Disabled
Skia Graphite
Enable Skia Graphite. This will use the Dawn backend by default, but can be overridden with command line flags for testing on non-official developer builds. See --skia-graphite-dawn-backend flag in gpu_switches.h. – Mac, Windows, Linux, Android

- #skia-graphite

Default
Origin-keyed Processes by default
Enables origin-keyed process isolation for most pages (i.e., those assigned to an origin-keyed agent cluster by default). This improves security but also increases the number of processes created. Note: enabling this feature also enables 'Origin-keyed Agent Clusters by default'. – Mac, Windows, Linux, Android

- #origin-keyed-processes-by-default

Default
Compression dictionary transport
Enables compression dictionary transport. – Mac, Windows, Linux, Android

- #enable-compression-dictionary-transport

Default
Deprecate the unload event
Controls the default for Permissions-Policy unload. If enabled, unload handlers are deprecated and will not receive the unload event unless a Permissions-Policy to enable them has been explicitly set. If disabled, unload handlers will continue to receive the unload event unless explicitly disabled by Permissions-Policy, even during the gradual rollout of their deprecation. – Mac, Windows, Linux, Android

- #deprecate-unload

Default
Device Bound Session Credentials (Standard)
Enables the official version of Device Bound Session Credentials. For more information see https://github.com/WICG/dbsc. – Mac, Windows, Linux

- #enable-standard-device-bound-session-credentials

Default
throttle-main-thread-to-60hz
Throttle main thread updates to 60fps, even when VSync rate is higher. – Mac, Windows, Linux, Android

- #throttle-main-thread-to-60hz

Default
Local Network Access Checks
Enables Local Network Access checks. See: https://chromestatus.com/feature/5152728072060928 – Mac, Windows, Linux, Android

- #local-network-access-check

Default
Web App Install Element
Enables the <install> HTML element which allows web apps to be installed declaratively. – Mac, Windows, Linux

- #web-app-install-element

Default
Web App Installation API
Enables the Web App Installation API which allows web apps to be installed programmatically using navigator.install(). – Mac, Windows, Linux

- #web-app-installation-api

Default
Web App Migration API
Enables the API for same-site web app migrations. – Mac, Windows, Linux

- #web-app-migration-api

Default
Extensibility API support for deep-links within DevTools
Extends console.timestamp to support adding deep-links into the DevTools Performance Panel, which (when clicked) call into a DevTools extension – Mac, Windows, Linux

- #enable-devtools-deep-link-via-extensibility-api

Default
Contextual Tasks
Enable the contextual tasks feature. – Mac, Windows, Linux, Android

- #contextual-tasks

Default
Connection Allowlists
Enables a prototype implementation of `Connection-Allowlist` header parsing and enforcement. See https://github.com/mikewest/anti-exfil/ – Mac, Windows, Linux, Android

- #connection-allowlists

Default
IDB SQLite Backing Store
Uses a SQLite-powered backing store for IndexedDB. No data is migrated from existing backing stores, including LevelDB stores or SQLite stores with older schemas; use at your own peril. – Mac, Windows, Linux, Android

- #idb-sqlite-backing-store

Default
Arabic-Indic Digit Input
Enable/Disable Arabic-Indic digit input while holding right alt or ctrl+alt on Arabic 101 keyboard layout. – Windows

- #enable-arabic-indic-digit-input

Default
Enable protocol monitor in DevTools
Enables the protocol monitor panel, which displays the DevTools Protocol (CDP) traffic between DevTools and the browser. – Mac, Windows, Linux, Android

- #devtools-protocol-monitor

Default
WebMCP support in DevTools
Enables WebMCP support in DevTools. – Mac, Windows, Linux, Android

- #devtools-webmcp-support

Default
WebMCP for testing
Enables the WebMCP API. – Mac, Windows, Linux, Android

- #enable-webmcp-testing

Default
Preserve HTTP message bodies across navigations for DevTools
Enables a durable message storing mechanism, which allows preserving HTTP message bodies for debugging. – Mac, Windows, Linux, Android

- #devtools-enable-durable-messages

Default
Instrumentation breakpoints
Enables instrumentation breakpoints in DevTools. – Mac, Windows, Linux, Android

- #devtools-instrumentation-breakpoints

Default
Source map scopes in the Sources panel
Enables source map scopes in the DevTools Sources panel. – Mac, Windows, Linux, Android

- #devtools-source-map-scopes-in-sources-panel

Default
Your changes will take effect after you restart Microsoft Edge.
