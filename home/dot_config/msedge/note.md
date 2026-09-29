edge policies storage location:

HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate
HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Edge

[msedge policies](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies)

[Configure Microsoft Edge using Initial Preferences settings for the first run](https://learn.microsoft.com/en-us/deployedge/initial-preferences-support-on-microsoft-edge-browser)

[Configurable Microsoft Edge commands](https://go.microsoft.com/fwlink/?linkid=2186950)

folder structure illustration: https://www.cnblogs.com/suv789/p/18042562

```tree
data/
├── Ad Blocking/
│   └── blocklist                              (107893)
├── Autofill/
├── AutoLaunchProtocolsComponent/
├── BrowserMetrics/
│   └── BrowserMetrics-6ABBB7FE-6154.pma       (4194304)
├── CertificateRevocation/
├── component_crx_cache/
├── Crashpad/
│   ├── attachments/
│   ├── reports/
│   ├── metadata                                (0)
│   ├── settings.dat                            (288)
│   └── throttle_store.dat                      (20)
├── Default/
│   ├── AutofillAiModelCache/
│   ├── AutofillStrikeDatabase/
│   ├── blob_storage/
│   ├── Blueprints/
│   ├── BudgetDatabase/
│   ├── Cache/
│   ├── ClientCertificates/
│   ├── Code Cache/
│   ├── Collections/
│   ├── commerce_subscription_db/
│   ├── DawnGraphiteCache/
│   ├── DawnWebGPUCache/
│   ├── discount_infos_db/
│   ├── discounts_db/
│   ├── DualEngine/
│   ├── EdgeCoupons/
│   ├── EdgeHubAppUsage/
│   ├── EdgePushStorageWithConnectTokenAnd Key/
│   ├── EdgeSessions/
│   ├── EdgeWallet/
│   ├── EntityExtraction/
│   ├── Extension Rules/
│   ├── Extension Scripts/
│   ├── Extension State/
│   ├── Extensions/
│   ├── Feature Engagement Tracker/
│   ├── GPUCache/
│   ├── JumpListIconsRecentWorkspacesV2/
│   ├── Local Extension Settings/
│   ├── Local Storage/
│   ├── Network/
│   ├── Nurturing/
│   ├── optimization_guide_hint_cache_store/
│   ├── parcel_tracking_db/
│   ├── PersistentOriginTrials/
│   ├── Segmentation Platform/
│   ├── Service Worker/
│   ├── Session Storage/
│   ├── Sessions/
│   ├── Shared Dictionary/
│   ├── shared_proto_db/
│   ├── Site Characteristics Database/
│   ├── Storage/
│   ├── Sync Data/
│   ├── WebStorage/
│   ├── Workspaces/
│   ├── Affiliation Database                     (53248)
│   ├── Affiliation Database-journal             (0)
│   ├── arbitration_service_config.json          (20347)
│   ├── BookmarkMergedSurfaceOrdering            (6)
│   ├── declarative_performance_observer.db      (32768)
│   ├── declarative_performance_observer.db-journal  (0)
│   ├── DIPS                                     (4096)
│   ├── DIPS-wal                                 (45352)
│   ├── Edge Profile Picture.png                 (91415)
│   ├── ExtensionActivityEdge                    (32768)
│   ├── ExtensionActivityEdge-journal            (0)
│   ├── Favicons                                 (20480)
│   ├── Favicons-journal                         (0)
│   ├── favorites_diagnostic.log                 (2254)
│   ├── heavy_ad_intervention_opt_out.db         (16384)
│   ├── heavy_ad_intervention_opt_out.db-journal (0)
│   ├── History                                  (212992)
│   ├── History-journal                          (41552)
│   ├── HubApps Icons                             (28672)
│   ├── HubApps Icons-journal                     (0)
│   ├── load_statistics.db                        (4096)
│   ├── load_statistics.db-shm                    (32768)
│   ├── load_statistics.db-wal                    (663352)
│   ├── LOCK                                      (0)
│   ├── LOG                                       (0)
│   ├── Login Data                                (51200)
│   ├── Login Data For Account                    (51200)
│   ├── Login Data For Account-journal            (0)
│   ├── Login Data-journal                        (0)
│   ├── Network Action Predictor                  (53248)
│   ├── Network Action Predictor-journal          (0)
│   ├── Preferences                               (13466)
│   ├── PreferredApps                             (33)
│   ├── README                                    (182)
│   ├── Secure Preferences                        (114221)
│   ├── ServerCertificate                         (20480)
│   ├── ServerCertificate-journal                 (0)
│   ├── settings_diagnostic.log                   (60266)
│   ├── Shortcuts                                 (20480)
│   ├── Shortcuts-journal                         (0)
│   ├── Top Sites                                 (20480)
│   ├── Top Sites-journal                         (0)
│   ├── Vpn Tokens                                (28672)
│   ├── Vpn Tokens-journal                        (0)
│   ├── Web Data                                  (227328)
│   └── Web Data-journal                          (0)
├── Domain Actions/
├── EADPData Component/
├── Edge Data Protection Lists/
├── Edge Entity Extraction/
├── Edge Notifications/
├── Edge Shopping/
├── Edge Sidebar/
├── Edge Signal Triggers/
├── Edge Themes Resources/
│   └── themes_suggesations_metadata.json          (3583)
├── Edge Wallet/
├── Edge3pSerp/
├── EdgeArbitration/
├── EdgeLanguageDetectionModel/
├── extensions_crx_cache/
├── FirstPartySetsPreloaded/
├── GPUPersistentCache/
│   └── DawnGraphiteCache/
├── GrShaderCache/
│   ├── data_0                                    (45056)
│   ├── data_1                                    (270336)
│   ├── data_2                                    (8192)
│   ├── data_3                                    (4202496)
│   ├── f_000001                                  (16472)
│   ├── f_000002                                  (20628)
│   ├── f_000003                                  (20956)
│   ├── f_000004                                  (21232)
│   ├── f_000005                                  (19432)
│   ├── f_000006                                  (24684)
│   ├── f_000007                                  (24536)
│   ├── f_000008                                  (25388)
│   ├── f_000009                                  (24464)
│   ├── f_00000a                                  (23744)
│   ├── f_00000b                                  (20340)
│   ├── f_00000c                                  (24624)
│   ├── f_00000d                                  (23836)
│   ├── f_00000e                                  (23272)
│   ├── f_00000f                                  (22448)
│   └── index                                     (262512)
├── hyphen-data/
├── MEIPreload/
├── Nurturing/
│   ├── campaign_history                           (20480)
│   └── campaign_history-journal                   (0)
├── OnDeviceHeadSuggestModel/
├── OriginTrials/
├── PKIMetadata/
├── ProvenanceData/
├── ProvenanceDataAllowList/
├── ProvenanceDataTensors/
├── RecoveryImproved/
├── Safe Browsing/
├── SafetyTips/
├── ShaderCache/
│   ├── data_0                                     (8192)
│   ├── data_1                                     (270336)
│   ├── data_2                                     (8192)
│   ├── data_3                                     (8192)
│   └── index                                      (262512)
├── SmartScreen/
│   └── RemoteData/
├── Speech Recognition/
├── Subresource Filter/
│   └── Unindexed Rules/
├── Trust Protection Lists/
├── TrustTokenKeyCommitments/
├── Typosquatting/
├── Web Notifications Deny List/
├── Well Known Domains/
├── WidevineCdm/
├── WorkspacesNavigationComponent/
├── ZxcvbnData/
├── First Run                                      (0)
├── first_party_sets.db                            (49152)
├── first_party_sets.db-journal                    (0)
├── FirstLaunchAfterInstallation                   (0)
├── Last Browser                                   (120)
├── Last Version                                   (13)
├── Local State                                    (4246)
├── Variations                                     (86)
├── VariationsRuntimeSeedV2                        (19)
├── VariationsSafeSeedV2                           (11)
└── VariationsSeedV2                               (5233)
```
