# edge://version
# edge://gpu

edge='"/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"'

# --window-size=width,height
# --disable-gpu
switches=(
    "--start-maximized"
    "--force-device-scale-factor=2.9"
    "--javascript-harmony"
    "--force-high-performance-gpu"
    "--disable-features=SystemKeyboardLock"
)

enableFeatures=(
    "--enable-experimental-cookie-features"
    "--enable-gpu-rasterization"
    "--enable-quic"
    "--enable-smooth-scrolling"
    "--enable-features=DomStorageSqlite,EdgeSearchboxFaviconCache,HardwareMediaKeyHandling,HeavyAdPrivacyMitigations,IsolatedWebApps,MediaFoundationD3D11VideoCapture,OmniboxUIExperimentHideSteadyStateUrlScheme,OmniboxUIExperimentHideSteadyStateUrlTrivialSubdomains,ParallelDownloading,PwaNavigationCapturing,RootScrollbarFollowsBrowserTheme,RunVideoCaptureServiceInBrowserProcess,V8VmFuture,WebAssemblyLazyCompilation,WebMachineLearningNeuralNetwork,WebRtcHideLocalIpsWithMdns,msAISearchEnabled,msCopilotMode2,msEdgeAIExplainConsoleError,msEdgeCIconRefresh,msEdgeCSSCopilot,msEdgeCopilotBridgeCowork,msEdgeExperimentalTrackingPreventionFeatures,msEdgeOmniboxHistoryClusterConnection,msEdgeSpaceworksEmoji,msEdgeSpaceworksInlineWindowSwitching,msEdgeSpaceworksPinning,msEdgeStudioNTPPersonalizedCards,msEnableWChromiumConfig,msMicrosoft360Viewer,msOmniboxComposerReformulationUx,msOmniboxCopilotChatCommercial,msOmniboxCopilotChatConsumer:CopilotChatConsumerRanking/4/OmniboxEmitConsumerCopilotChatForm/EDGAACT2M,msOmniboxMarkOnlyDedup,msRefreshRateBoostOnScroll,msStudioNtpComponentExtension,msSwagM1Google,msUndersideV2ComponentExtension,msWindowTabManagerPublic"
)

# --flag-switches-begin --flag-switches-end

alias edge="$edge"
alias edgefull="$edge --start-fullscreen"
alias telegram="$edge --app=https://web.telegram.org"
alias edgeguest="$edge --guest"
alias edgeprivate="$edge --inprivate"

# --user-data-dir="" support variable: https://learn.microsoft.com/en-us/deployedge/edge-learnmore-create-user-directory-vars

# edge kiosk mode: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-configure-kiosk-mode
# some commands: https://github.com/cezaraugusto/chromium-edge-launcher/blob/main/docs/edge-flags-for-tools.md
