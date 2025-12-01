'use client';

import React from 'react';
import { KingdomShell } from '@/components/layout/KingdomShell';
import { FederationMap } from '@/components/dashboard/FederationMap';
import { StatusBeacon } from '@/components/dashboard/StatusBeacon';
import { TrustCard } from '@/components/ui/TrustCard';
import { ProviderBadge } from '@/components/ui/ProviderBadge';
import { Activity, Shield, Key, Clock, AlertTriangle } from 'lucide-react';

export default function Dashboard() {
    return (
        <KingdomShell>
            <div className="space-y-8">
                {/* Header Section */}
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-cal text-white mb-2">Federation Overview</h1>
                        <p className="text-zinc-400">Real-time OIDC trust visualization and metrics.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <StatusBeacon status="healthy" label="System Operational" className="bg-white/5 px-4 py-2 rounded-full border border-white/10" />
                        <button className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-medium transition-colors shadow-[0_0_20px_rgba(79,70,229,0.4)]">
                            Refresh Data
                        </button>
                    </div>
                </div>

                {/* Main Visualization */}
                <FederationMap />

                {/* Metrics Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <TrustCard
                        title="Active Sessions"
                        icon={Activity}
                        status="active"
                        glowColor="indigo"
                    >
                        <div className="mt-4">
                            <span className="text-4xl font-mono text-white">24</span>
                            <p className="text-sm text-zinc-500 mt-1">Current OIDC exchanges</p>
                        </div>
                    </TrustCard>

                    <TrustCard
                        title="Trust Policies"
                        icon={Shield}
                        status="active"
                        glowColor="purple"
                    >
                        <div className="mt-4">
                            <span className="text-4xl font-mono text-white">12</span>
                            <p className="text-sm text-zinc-500 mt-1">Active federation rules</p>
                        </div>
                    </TrustCard>

                    <TrustCard
                        title="Token Rotations"
                        icon={Key}
                        status="active"
                        glowColor="emerald"
                    >
                        <div className="mt-4">
                            <span className="text-4xl font-mono text-white">1.2k</span>
                            <p className="text-sm text-zinc-500 mt-1">Keys rotated (24h)</p>
                        </div>
                    </TrustCard>

                    <TrustCard
                        title="Security Alerts"
                        icon={AlertTriangle}
                        status="inactive"
                        glowColor="amber"
                    >
                        <div className="mt-4">
                            <span className="text-4xl font-mono text-white">0</span>
                            <p className="text-sm text-zinc-500 mt-1">No active threats detected</p>
                        </div>
                    </TrustCard>
                </div>

                {/* Recent Activity & Providers */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Activity Feed */}
                    <div className="lg:col-span-2 space-y-4">
                        <h2 className="text-xl font-cal text-white">Recent Federation Events</h2>
                        <div className="bg-black/20 border border-white/10 rounded-2xl p-6 backdrop-blur-sm">
                            <div className="space-y-6">
                                {[
                                    { time: '2m ago', event: 'GitHub Action "Deploy-Prod" assumed role "AWS-Deployer"', status: 'success', provider: 'aws' },
                                    { time: '15m ago', event: 'Token exchange validated for Azure Service Principal', status: 'success', provider: 'azure' },
                                    { time: '1h ago', event: 'GCP Workload Identity pool updated', status: 'info', provider: 'gcp' },
                                    { time: '2h ago', event: 'Failed assumption attempt from unknown repo', status: 'error', provider: 'aws' },
                                ].map((item, i) => (
                                    <div key={i} className="flex items-start gap-4 group">
                                        <div className="mt-1">
                                            <div className={`w-2 h-2 rounded-full ${item.status === 'success' ? 'bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.5)]' :
                                                    item.status === 'error' ? 'bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]' :
                                                        'bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,0.5)]'
                                                }`} />
                                        </div>
                                        <div className="flex-1">
                                            <p className="text-sm text-zinc-300 group-hover:text-white transition-colors">{item.event}</p>
                                            <div className="flex items-center gap-2 mt-1">
                                                <Clock className="w-3 h-3 text-zinc-600" />
                                                <span className="text-xs text-zinc-600">{item.time}</span>
                                                <span className="text-xs text-zinc-600">•</span>
                                                <span className="text-xs uppercase tracking-wider text-zinc-500">{item.provider}</span>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>

                    {/* Connected Providers */}
                    <div className="space-y-4">
                        <h2 className="text-xl font-cal text-white">Trust Anchors</h2>
                        <div className="space-y-3">
                            <div className="p-4 rounded-xl bg-gradient-to-r from-[#FF9900]/10 to-transparent border border-[#FF9900]/20 flex items-center justify-between group hover:border-[#FF9900]/40 transition-all">
                                <div className="flex items-center gap-3">
                                    <ProviderBadge provider="aws" />
                                    <div>
                                        <p className="text-sm font-medium text-white">AWS IAM</p>
                                        <p className="text-xs text-zinc-500">Connected</p>
                                    </div>
                                </div>
                                <div className="w-2 h-2 rounded-full bg-[#FF9900] shadow-[0_0_10px_rgba(255,153,0,0.5)]" />
                            </div>

                            <div className="p-4 rounded-xl bg-gradient-to-r from-[#0078D4]/10 to-transparent border border-[#0078D4]/20 flex items-center justify-between group hover:border-[#0078D4]/40 transition-all">
                                <div className="flex items-center gap-3">
                                    <ProviderBadge provider="azure" />
                                    <div>
                                        <p className="text-sm font-medium text-white">Azure AD</p>
                                        <p className="text-xs text-zinc-500">Connected</p>
                                    </div>
                                </div>
                                <div className="w-2 h-2 rounded-full bg-[#0078D4] shadow-[0_0_10px_rgba(0,120,212,0.5)]" />
                            </div>

                            <div className="p-4 rounded-xl bg-gradient-to-r from-[#4285F4]/10 to-transparent border border-[#4285F4]/20 flex items-center justify-between group hover:border-[#4285F4]/40 transition-all">
                                <div className="flex items-center gap-3">
                                    <ProviderBadge provider="gcp" />
                                    <div>
                                        <p className="text-sm font-medium text-white">Google Cloud</p>
                                        <p className="text-xs text-zinc-500">Connected</p>
                                    </div>
                                </div>
                                <div className="w-2 h-2 rounded-full bg-[#4285F4] shadow-[0_0_10px_rgba(66,133,244,0.5)]" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </KingdomShell>
    );
}
